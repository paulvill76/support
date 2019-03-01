Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Type,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, ParameterSetName = 'ByValue')][ValidateNotNullOrEmpty()][ValidateSet('ById', 'ByName')][string]$SearchBy,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'ByValue', HelpMessage = 'Specify the item which you want to search for. Supports wildcard searches using: *')][ValidateNotNullOrEmpty()][string]$SearchByValue,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3, HelpMessage = 'An array of the fields/properties/columns you want to return from the search.')][ValidateNotNullOrEmpty()][array]$Fields = @(),
        [Parameter(Mandatory = $false, Position = 4)][ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int]$Limit = 100,
        [Parameter(Mandatory = $false, Position = 5)][ValidateNotNullOrEmpty()][ValidateRange(0, [int]::MaxValue)][int]$Skip = 0
    )
    Begin
    {
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $TypeCommand = @()
        $TypeCommand += [PSCustomObject]@{'Type' = @('user', 'users'); 'Url' = '/api/search/systemusers'; 'Method' = 'POST'; 'ById' = '_id'; 'ByName' = 'username'; 'Paginate' = $true; 'SupportRegexFilter' = $true; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('system', 'systems'); 'Url' = '/api/search/systems'; 'Method' = 'POST'; 'ById' = '_id'; 'ByName' = 'displayName'; 'Paginate' = $true; 'SupportRegexFilter' = $true; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('policy', 'policies'); 'Url' = '/api/v2/policies'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('group', 'system_group', 'user_group'); 'Url' = '/api/v2/groups'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('application', 'applications'); 'Url' = '/api/applications'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('directory', 'directories'); 'Url' = '/api/v2/directories'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('command', 'commands'); 'Url' = '/api/commands'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('radiusservers'); 'Url' = '/api/radiusservers'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; }

        $TypeCommand += [PSCustomObject]@{'Type' = @('policyresults'); 'Url' = '/api/v2/policies/{Policy_Id}/policyresults'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = $false; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
        $TypeCommand += [PSCustomObject]@{'Type' = @('applicationUsers'); 'Url' = '/api/v2/applications/{Application_Id}/users'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = $false; 'Paginate' = $true; 'SupportRegexFilter' = $false; }
    }
    Process
    {
        Try
        {
            # Identify the command type to run to get the object for the specified item
            $TypeCommandItem = $TypeCommand | Where-Object {$Type -in $_.Type}
            If ($TypeCommandItem)
            {
                $TypeCommandItem.Type = $Type
                $ById = $TypeCommandItem.ById
                $ByName = $TypeCommandItem.ByName
                $SupportRegexFilter = $TypeCommandItem.SupportRegexFilter
                # Create $FunctionParameters hashtable for splatting
                $FunctionParameters = [ordered]@{}
                # Get function parameters and filter out unnecessary parameters
                $PSBoundParameters.GetEnumerator() | ForEach-Object {
                    If ($_.Key -notin ('SearchBy', 'SearchByValue', 'Type'))
                    {
                        $FunctionParameters.Add($_.Key, $_.Value) | Out-Null
                    }
                }
                # Get custom object parameters and filter out unnecessary parameters
                $TypeCommandItem.PSObject.Properties | Where-Object {$_.Name -notin ('ById', 'ByName', 'SupportRegexFilter', 'Type')} | ForEach-Object {
                    # Add parameters from the custom object to the FunctionParameters hashtable
                    $FunctionParameters.Add($_.Name, $_.Value) | Out-Null
                }
                # If searching ByValue add filters to query string and body.
                If ($PSCmdlet.ParameterSetName -eq 'ByValue')
                {
                    $QueryStrings = @()
                    $BodyParts = @()
                    # Determine search method
                    $PropertyIdentifier = Switch ($SearchBy)
                    {
                        'ById' {$TypeCommandItem.ById};
                        'ByName' {$TypeCommandItem.ByName};
                    }
                    # Populate Url placeholders. Assumption is that if an endpoint requires an Id to be passed in the Url that it does not require a filter because its looking for an exact match already.
                    If ($FunctionParameters['Url'] -match '({)(.*?)(})')
                    {
                        Write-Verbose ('Populating ' + $Matches[0] + ' with ' + $SearchByValue)
                        $FunctionParameters['Url'] = $FunctionParameters['Url'].Replace($Matches[0], $SearchByValue)
                    }
                    Else
                    {
                        # Add filters for exact match and wildcards
                        If ($SearchByValue -match '\*')
                        {
                            If ($SupportRegexFilter)
                            {
                                $BodyParts += ('"filter":[{"' + $PropertyIdentifier + '":{"$regex": "(?i)(' + $SearchByValue.Replace('*', ')(.*?)(') + ')"}}]').Replace('()', '')
                            }
                            Else
                            {
                                Write-Error ('The endpoint ' + $FunctionParameters['Url'] + ' does not support wildcards in the $SearchByValue. Please remove "*" from "' + $SearchByValue + '".')
                            }
                        }
                        Else
                        {
                            $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValue
                            $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValue + '"}]'
                        }
                    }
                    # Build query string and body
                    $JoinedQueryStrings = $QueryStrings -join '&'
                    $JoinedBodyParts = $BodyParts -join ','
                    # Build final body and url
                    If ($JoinedBodyParts)
                    {
                        $Body = '{' + $JoinedBodyParts + '}'
                    }
                    If ($JoinedQueryStrings)
                    {
                        $FunctionParameters['Url'] = $FunctionParameters['Url'] + '?' + $JoinedQueryStrings
                    }
                    # Add parameters from the script to the FunctionParameters hashtable
                    $FunctionParameters.Add('Body', $Body) | Out-Null
                }
                ## Escape Url????
                # $FunctionParameters['Url'] = ([uri]::EscapeDataString($FunctionParameters['Url'])
                # Run command
                Write-Verbose ('Invoke-JCApi ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
                $Results = Invoke-JCApi @FunctionParameters
                If ($Results)
                {
                    # Update results
                    $Results | ForEach-Object {
                        # Create the default property display set
                        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$_.PSObject.Properties.Name)
                        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                        # Add the list of standard members
                        Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers)
                        # Add ById and ByName as hidden properties to results
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('ById') -Value:($ById)
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('ByName') -Value:($ByName)
                    }
                }
                Else
                {
                    Write-Verbose ('No results found.')
                }
            }
            Else
            {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + $TypeCommand.Type -join ',')
            }
        }
        Catch
        {
            $Exception = $_.Exception
            $Message = $Exception.Message
            While ($Exception.InnerException)
            {
                $Exception = $Exception.InnerException
                $Message += "`n" + $Exception.Message
            }
            Write-Error ($_.FullyQualifiedErrorId.ToString() + "`n" + $_.InvocationInfo.PositionMessage + "`n" + $Message)
        }
    }
    End
    {
        $ErrorActionPreference = $CurrentErrorActionPreference
        Return $Results
    }
}
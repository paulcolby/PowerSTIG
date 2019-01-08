<#
    This file is dot sourced into every composite. It consolidates testing of exceptions,
    skipped rules, and organizational objects that were provided to the composite
#>
Describe "$($stig.TechnologyRole) $($stig.StigVersion) mof output" {

    It 'Should compile the MOF without throwing' {
        {
            & $technologyConfig `
                -BrowserVersion $stig.TechnologyRole `
                -StigVersion $stig.StigVersion `
                -OutputPath $TestDrive `
                -OfficeApp $stig.TechnologyRole `
                -ConfigPath $configPath `
                -PropertiesPath $propertiesPath `
                -OsVersion $stig.TechnologyVersion `
                -ForestName 'integration.test' `
                -DomainName 'integration.test' `
                -OsRole $stig.TechnologyRole `
                -SqlVersion $stig.TechnologyVersion `
                -SqlRole $stig.TechnologyRole`
                -WebAppPool $WebAppPool `
                -WebsiteName $WebsiteName `
                -LogPath $TestDrive
        } | Should -Not -Throw
    }

    $configurationDocumentPath = "$TestDrive\localhost.mof"
    $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

    $ruleNames = (Get-Member -InputObject $DscXml.DISASTIG | 
        Where-Object -FilterScript {$_.Name -match '.*Rule' -and $_.Name -ne "DocumentRule" -and $_.Name -ne "ManualRule"}).Name

    foreach ($ruleName in $ruleNames)
    {
        Context $ruleName {
            $hasAllSettings = $true
            $dscXml = @($dscXml.DISASTIG.$ruleName.Rule) | 
                Where-Object {$PSItem.conversionstatus -eq 'pass' -and $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"}
            $dscMof = $instances |
                Where-Object {Get-ResourceMatchStatement -ruleName $ruleName}

            foreach ( $setting in $dscXml )
            {
                If (-not ($dscMof.ResourceID -match $setting.id) )
                {
                    Write-Warning -Message "Missing $ruleName Setting $($setting.id)"
                    $hasAllSettings = $false
                }
            }

            It "Should have $($dscXml.count) $ruleName settings" {
                $hasAllSettings | Should -Be $true
            }
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) Exception" {

    Context 'Single Exception' {

        It "Should compile the MOF with STIG exception $exception without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole`
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -Exception $exception
            } | Should -Not -Throw
        }
    }
    Context 'Multiple Exceptions' {

        It "Should compile the MOF with STIG exceptions $exceptionMultiple without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole`
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -Exception $exceptionMultiple
            } | Should -Not -Throw
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRule" {

    Context 'Single Rule' {

        It 'Should compile the MOF without throwing' {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRule `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscXml = $skipRule.count
        $dscMof = @($instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"})
        #endregion

        It "Should have $dscXml Skipped settings" {
            $dscMof.count | Should -Be $dscXml
        }
    }

    Context 'Multiple Rules' {

        It 'Should compile the MOF without throwing' {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -SkipRule $skipRuleMultiple `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -OutputPath $TestDrive
            } | Should -Not -Throw
        }

        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $expectedSkipRuleCount = $skipRuleMultiple.count
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleCount
        }

    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) SkipRuleType" {
    Context 'Single Type' {
        It "Should compile the MOF without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -SkipruleType $skipRuleType 
            } | Should -Not -Throw
        }
        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleTypeCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleTypeCount
        }
    }
    Context 'Multiple Types' {
        It "Should compile the MOF without throwing" {
            {
                & $technologyConfig `
                    -BrowserVersion $stig.TechnologyRole `
                    -StigVersion $stig.StigVersion `
                    -OutputPath $TestDrive `
                    -OfficeApp $stig.TechnologyRole `
                    -ConfigPath $configPath `
                    -PropertiesPath $propertiesPath `
                    -OsVersion $stig.TechnologyVersion `
                    -ForestName 'integration.test' `
                    -DomainName 'integration.test' `
                    -OsRole $stig.TechnologyRole `
                    -SqlVersion $stig.TechnologyVersion `
                    -SqlRole $stig.TechnologyRole `
                    -WebAppPool $WebAppPool `
                    -WebsiteName $WebsiteName `
                    -LogPath $TestDrive `
                    -SkipruleType $skipRuleTypeMultiple 
            } | Should -Not -Throw
        }
        #region Gets the mof content
        $configurationDocumentPath = "$TestDrive\localhost.mof"
        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
        #endregion

        #region counts how many Skips there are and how many there should be.
        $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
        #endregion

        It "Should have $expectedSkipRuleTypeMultipleCount Skipped settings" {
            $dscMof.count | Should -Be $expectedSkipRuleTypeMultipleCount
        }
    }
}

Describe "$($stig.TechnologyRole) $($stig.StigVersion) OrgSettings" {

    $stigPath = $stig.path.TrimEnd(".xml")
    $orgSettings = $stigPath + ".org.default.xml"

    It "Should compile the MOF with OrgSettings without throwing" {
        {
            & $technologyConfig `
                -BrowserVersion $stig.TechnologyRole `
                -StigVersion $stig.StigVersion `
                -OutputPath $TestDrive `
                -OfficeApp $stig.TechnologyRole `
                -ConfigPath $configPath `
                -PropertiesPath $propertiesPath `
                -OsVersion $stig.TechnologyVersion `
                -ForestName 'integration.test' `
                -DomainName 'integration.test' `
                -OsRole $stig.TechnologyRole `
                -SqlVersion $stig.TechnologyVersion `
                -SqlRole $stig.TechnologyRole`
                -WebAppPool $WebAppPool `
                -WebsiteName $WebsiteName `
                -LogPath $TestDrive `
                -Orgsettings $orgSettings
        } | Should -Not -Throw
    }
}

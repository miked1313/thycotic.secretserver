﻿function Initialize-SdkClient {
    [cmdletbinding()]
    param(
        # Secret Server
        [Parameter(Mandatory, ParameterSetName = 'init')]
        [string]
        $SecretServer,

        # SDK Client Management rule name
        [Parameter(Mandatory, ParameterSetName = 'init')]
        [string]
        $RuleName,

        # SDK Client Management rule onboarding key
        [Parameter(ParameterSetName = 'init')]
        [string]
        $OnboardingKey,

        # Config path for the key/config files
        [Parameter(Mandatory, ParameterSetName = 'init')]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [string]
        $ConfigPath,

        # Overwrite configuration (drop and create a new)
        [switch]
        $Force
    )
    begin {
        $tssParams = $PSBoundParameters
        $tssExe = [IO.Path]::Combine([string]$PSModuleRoot, 'bin', 'tss.exe')

        if ($IsLinux) {
            Write-Verbose "SDK Client, tss utility, has some dependencies required on certain Linux distributions, more details: https://docs.thycotic.com/ss/10.9.0/api-scripting/sdk-cli#task_2__installing_the_sdk_client"
        }
    }
    process {
        Write-Verbose "Provided command parameters: $(. $GetInvocation $PSCmdlet.MyInvocation)"

        if ($tssParams.ContainsKey('Force')) {
            $tssRemoveArgs = "remove --confirm --key-directory '$ConfigPath' --config-directory '$ConfigPath'"
            try {
                $remove = Invoke-Expression -Command "$tssExe $tssRemoveArgs"
                Write-Verbose "SDK Client raw output: $remove"
                if ($remove -eq 'Your configuration settings have been removed.') {
                } else {
                    Write-Waring "Issue removing configuration files for [$SecretServer]: $remove"
                    return
                }
            } catch {
                Write-Warning "Issue removing SDK Client (tss) config files for [$SecretServer]"
                $err = $_
                . $ErrorHandling $err
            }
        }

        $tssArgs = [ordered]@{}
        switch ($tssParams.Keys) {
            'SecretServer' { $tssArgs.SecretServer = "--url $SecretServer" }
            'RuleName' { $tssArgs.RuleName = "--rule-name $RuleName" }
            'OnboardingKey' { $tssArgs.OnboardingKey = "--onboarding-key '$OnboardingKey'" }
            'ConfigPath' { $tssArgs.ConfigDirectory = "--key-directory '$ConfigPath' --config-directory '$ConfigPath'" }
        }

        $tssInitArgs = "init $($tssArgs['SecretServer']) $($tssArgs['RuleName']) $($tssArgs['OnboardingKey']) $($tssArgs['ConfigDirectory'])"
        try {
            $response = Invoke-Expression -Command "$tssExe $tssInitArgs"
            Write-Verbose "SDK Client raw output: $response"

            if ($response -eq 'Your SDK client account registration is complete.') {
                Write-Host 'SDK Client initialization completed successfully'
            }
            if ($response -eq 'This machine is already initialized. Remove the configuration settings.') {
                Write-Warning "Initialization has already been run for this host, include -Force parameter if you want to drop and reinitialize"
            }
        } catch {
            Write-Warning "Issue initializing SDK Client (tss) for [$SecretServer]"
            $err = $_
            . $ErrorHandling $err
        }
    }
}
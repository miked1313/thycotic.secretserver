function Test-FolderAction {
    <#
    .SYNOPSIS
    Test for an allowed action on a Folder

    .DESCRIPTION
    Test for an allowed action on a Folder

    .EXAMPLE
    session = New-TssSession -SecretServer https://alpha -Credential ssCred
    Test-TssFolderAction -TssSession $session -FolderId 75 -Action AddSecret

    Test for action AddSecret on Folder ID 75, returning true if exists and false if not

    .LINK
    https://thycotic-ps.github.io/thycotic.secretserver/commands/Test-TssFolderAction

    .LINK
    https://github.com/thycotic-ps/thycotic.secretserver/blob/main/src/functions/folders/Test-FolderAction.ps1

    .NOTES
    Requires TssSession object returned by New-TssSession
    #>
    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param (
        # TssSession object created by New-TssSession for auth
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [TssSession]
        $TssSession,

        # Folder ID
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int]
        $FolderId,

        # Action to test for
        [Parameter(Mandatory)]
        [ValidateSet('CreateSubfolder','EditFolder','AddSecret','DeleteFolder','MoveFolder')]
        [string]
        $Action
    )
    begin {
        $tssParams = $PSBoundParameters
    }
    process {
        if ($tssParams.ContainsKey('TssSession') -and $TssSession.IsValidSession()) {
            Write-Verbose "Provided command parameters: $(. $GetInvocation $PSCmdlet.MyInvocation)"
            $folderResult = . $GetFolderState $TssSession $FolderId

            if (-not $folderResult) {
                Write-Warning "No result returned for folder [$FolderId]"
            } else {
                $folderResult.TestAction($Action)
            }
        } else {
            Write-Warning "No valid session found"
        }
    }
}
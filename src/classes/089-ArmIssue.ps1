# Based on code from the ARM VS Code Extension
# https://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/src/Language.ts

# An issue that was detected while parsing a deployment template.
class ArmIssue {

    [ArmSpan]$span
    [String]$Message

    ArmIssue ([ArmSpan]$span, [string]$message) {
        if ($span -eq $null -or $span.length -lt 1) {
            Write-Error -Message "span must not be null or less than 2 characters." -ErrorAction Stop
        }
        if ([String]::IsNullOrWhiteSpace($message)) {
            Write-Error -Message "message must not be null or empty." -ErrorAction Stop
        }

        $this.Span = $span
        $this.Message = $message
    }

    [ArmIssue] translate([int]$movement) {
        return [ArmIssue]::New($this.span.translate($movement), $this.message)
    }
}

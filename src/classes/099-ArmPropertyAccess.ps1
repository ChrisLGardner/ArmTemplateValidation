# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE value representing a property access (source.property).
class ArmPropertyAccess : ArmValue {

    [ArmValue]$Source
    [ArmToken]$PeriodToken
    [ArmToken]$NameToken

    ArmPropertyAccess ([ArmValue]$source, [ArmToken]$periodToken, [ArmToken]$nameToken) {

        if ($null -eq $Source -or $null -eq $PeriodToken) {
            Write-Error -Message "Source and PeriodToken cannot be null" -ErrorAction Stop
        }

        $this.Source = $Source
        $this.PeriodToken = $PeriodToken
        $this.NameToken = $NameToken
        $this.source.parent = $this
    }

    # Get an array of the names of the property access source values that lead to $this property
    # access. The top of the stack is the name of the root-most property access. The bottom of the
    # stack is the name of $this PropertyAccess's source.
    [String[]] sourcesNameStack() {
        [string[]]$result = $null

        $propertyAccessSource = $this.source
        while ($propertyAccessSource) {
            $result += $propertyAccessSource.nameToken.stringValue
            $propertyAccessSource = $propertyAccessSource.source
        }

        return $result
    }

    # Get the root source value of $this PropertyAccess as a FunctionValue.
    [ArmFunctionValue] functionSource() {
        $currentSource = $this.source
        while ($currentSource -and $currentSource -is [ArmPropertyAccess]) {
            $currentSource = $currentSource.source
        }
        return $currentSource
    }

    [ArmSpan] GetSpan() {
        $result = $this.source.getSpan()

        if ($this.nameToken -ne $null) {
            $result = $result.union($this.nameToken.span)
        }
        else {
            $result = $result.union($this.periodToken.span)
        }

        return $result
    }

    [bool] contains([int]$characterIndex) {
        return $this.getSpan().contains($characterIndex, $true)
    }

    [void] accept([ArmVisitor]$Visitor) {
        $visitor.visitPropertyAccess($this)
    }

    [string] toString() {
        $result = "$($this.source.toString())."
        if ($this.nameToken -ne $null) {
            $result += $this.nameToken.stringValue
        }
        return $result
    }
}

# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

class ArmSpan {
    [int]$StartIndex

    [int]$Length

    ArmSpan([int]$startIndex, [int]$length) {
        $this.StartIndex = $startIndex
        $this.Length = $length
    }

    # Get the start index of this span.
    [int] startIndex(){
        return $this.startIndex
    }

    # Get the length of this span.
    [int] length() {
        return $this.Length
    }

    # Get the last index of this span.
    [int] endIndex() {
        if ($this.length -gt 0) {
            $EndIndex = $this.length - 1
        }
        else {
            $EndIndex = 0
        }

        return $this.startIndex + $EndIndex
    }

    # Get the index directly after this span.
    # If this span started at 3 and had a length of 4 ([3,7)), then the after
    # end index would be 7.
    [int] afterEndIndex() {
        return $this.startIndex + $this.length
    }

    # Determine if the provided index is contained by this span.
    # If this span started at 3 and had a length of 4 ([3, 7)), then all
    # indexes between 3 and 6 (inclusive) would be contained. 2 and 7 would
    # not be contained.
    [bool] contains([int]$index, [bool]$includeAfterEndIndex) {
        $result = $this.startIndex -le $index
        if ($result) {
            if ($includeAfterEndIndex) {
                $result = $index -le $this.afterEndIndex()
            }
            else {
                $result = $index -le $this.endIndex()
            }
        }
        return $result
    }

    # Create a new span that is a union of this Span and the provided Span.
    # If the provided Span is null, then this Span will be returned.
    [ArmSpan] union([ArmSpan]$rhs) {
        [ArmSpan]$result = $null
        if ($null -ne $rhs) {
            $minStart = [Math]::min($this.startIndex, $rhs.startIndex)
            $maxAfterEndIndex = [Math]::max($this.afterEndIndex(), $rhs.afterEndIndex())
            $result = [ArmSpan]::New($minStart, ($maxAfterEndIndex - $minStart))
        }
        else {
            $result = $this
        }
        return $result
    }

    [ArmSpan] translate([int]$movement) {
        if ($movement -eq 0) {
            $result = $this
        }
        else {
            $result = [ArmSpan]::New(($this.startIndex + $movement), $this.length)
        }

        return $result
    }

    [string] toString() {
        return "[$($this.startIndex), $($this.afterEndIndex())]"
    }
}

# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# The ArmValue class is the generic base class that all other values inherit from.
class ArmValue {
    [ArmValue]$parent
    [ArmSpan]$Span

    [void]SetParent([ArmValue]$parent) {
        $this.parent = $parent
    }

    [bool]contains([int]$characterIndex) {
        return $this.span.contains($CharacterIndex)
    }

    [string]toString() {
        return $this.Span.toString()
    }

    [void]accept([ArmVisitor]$visitor) {}
}

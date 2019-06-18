class ArmBasicToken {

    [string]$Text

    [ArmBasicTokenType]$Type

    ArmBasicToken ([String]$Text, [ArmBasicTokenType]$Type) {

        $this.Text = $Text
        $this.Type = $Type
    }

    [string] toString() {
        return $this.text
    }

    [int] length() {
        return $this.text.length
    }

    [ArmBasicTokenType] GetTokenType() {
        return $this.type
    }
}

$Script:LeftCurlyBracket = [ArmBasicToken]::New("{", [ArmBasicTokenType]::LeftCurlyBracket)
$Script:RightCurlyBracket = [ArmBasicToken]::New("}", [ArmBasicTokenType]::RightCurlyBracket)
$Script:LeftSquareBracket = [ArmBasicToken]::New("[", [ArmBasicTokenType]::LeftSquareBracket)
$Script:RightSquareBracket = [ArmBasicToken]::New("]", [ArmBasicTokenType]::RightSquareBracket)
$Script:LeftParenthesis = [ArmBasicToken]::New("(", [ArmBasicTokenType]::LeftParenthesis)
$Script:RightParenthesis = [ArmBasicToken]::New(")", [ArmBasicTokenType]::RightParenthesis)
$Script:Underscore = [ArmBasicToken]::New("_", [ArmBasicTokenType]::Underscore)
$Script:Period = [ArmBasicToken]::New(".", [ArmBasicTokenType]::Period)
$Script:Dash = [ArmBasicToken]::New("-", [ArmBasicTokenType]::Dash)
$Script:Plus = [ArmBasicToken]::New("+", [ArmBasicTokenType]::Plus)
$Script:Comma = [ArmBasicToken]::New(",", [ArmBasicTokenType]::Comma)
$Script:Colon = [ArmBasicToken]::New(":", [ArmBasicTokenType]::Colon)
$Script:SingleQuote = [ArmBasicToken]::New("'", [ArmBasicTokenType]::SingleQuote)
$Script:DoubleQuote = [ArmBasicToken]::New('"', [ArmBasicTokenType]::DoubleQuote)
$Script:Backslash = [ArmBasicToken]::New("\", [ArmBasicTokenType]::Backslash)
$Script:ForwardSlash = [ArmBasicToken]::New("/", [ArmBasicTokenType]::ForwardSlash)
$Script:Asterisk = [ArmBasicToken]::New("*", [ArmBasicTokenType]::Asterisk)
$Script:Space = [ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space)

<#
    .SYNOPSIS
    Outputs to a UTF-8-encoded file *without a BOM* (byte-order mark).

    .DESCRIPTION
    Mimics the most important aspects of Out-File:
    * Input objects are sent to Out-String first.
    * - Append allows you to append to an existing file, -NoClobber prevents
        overwriting of an existing file.
    * - Width allows you to specify the line width for the text representations
        of input objects that aren't strings.
    However, it is not a complete implementation of all Out-String parameters:
    * Only a literal output path is supported, and only as a parameter.
    * -Force is not supported.

    Caveat: *All* pipeline input is buffered before writing output starts,
            but the string representations are generated and written to the target
            file one by one.

    .NOTES
    The raison d'être for this advanced function is that, as of PowerShell v5,
    Out-File still lacks the ability to write UTF-8 files without a BOM:
    using -Encoding UTF8 invariably prepends a BOM.
#>
Function Out-FileUtf8NoBom {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)] [String] $LiteralPath,
        [Switch] $Append,
        [Switch] $NoClobber,
        [AllowNull()] [Int] $Width,
        [Parameter(ValueFromPipeline)] $InputObject
    )

    #Requires -Version 3

    # Make sure that the .NET framework sees the same working dir. as PS
    # and resolve the input path to a full path.
    [System.IO.Directory]::SetCurrentDirectory($PWD) # Caveat: .NET Core doesn't support [Environment]::CurrentDirectory
    $LiteralPath = [IO.Path]::GetFullPath($LiteralPath)

    # If -NoClobber was specified, throw an exception if the target file already
    # exists.
    If ($NoClobber -And (Test-Path $LiteralPath)) {
        Throw [IO.IOException] "The file '$LiteralPath' already exists."
    }

    # Create a StreamWriter object.
    # Note that we take advantage of the fact that the StreamWriter class by default:
    # - uses UTF-8 encoding
    # - without a BOM.
    $Sw = New-Object IO.StreamWriter $LiteralPath, $Append

    $HtOutStringArgs = @{}

    If ($Width) {
        $HtOutStringArgs += @{
            Width = $Width
        }
    }

    # Note: By not using begin / process / end blocks, we're effectively running
    #       in the end block, which means that all pipeline input has already
    #       been collected in automatic variable $Input.
    #       We must use this approach, because using | Out-String individually
    #       in each iteration of a process block would format each input object
    #       with an indvidual header.
    Try {
        $Input | Out-String -Stream @htOutStringArgs | ForEach-Object {
            $Sw.WriteLine($PSItem)
        }
    } Finally {
        $Sw.Dispose()
    }
}

Foreach ($I In Get-ChildItem -Recurse) {
    If ($I.PSIsContainer) {
        Continue
    }

    $Dest = $I.Fullname.Replace($PWD, "utf8")

    If (!(Test-Path $(Split-Path $Dest -Parent))) {
        New-Item $(Split-Path $Dest -Parent) -Type Directory
    }

    Get-Content $I | Out-FileUtf8NoBom $Dest
}

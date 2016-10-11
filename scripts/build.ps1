$ErrorActionPreference = 'Stop'

$scriptPath = $MyInvocation.MyCommand.Path
$rootFolder = Split-Path $scriptPath | Split-Path

Push-Location $rootFolder

function ProcessLastExitCode {
    param($exitCode, $msg)
    if ($exitCode.Equals(0))
    {
        Write-Error "$msg, exit code: $exitCode"
        Pop-Location
        Exit 1
    }
}

# install latest docfx
& cinst docfx
ProcessLastExitCode($lastexitcode, "failed to install latest docfx")

# clean api_ref
Remove-Item "api-ref\*" -Force -recurse

# run docfx metadata to generate YAML metadata
& docfx metadata
ProcessLastExitCode($lastexitcode, "failed to run docfx metadata")

# merge toc.yml if needed
if(Test-Path scripts/mergeToc.js)
{
    & node scripts/mergeToc.js
    ProcessLastExitCode($lastexitcode, "failed to merge toc.yml")
}

Pop-Location
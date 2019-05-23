& Bcdedit.exe -set TESTSIGNING ON
if ($LASTEXITCODE -eq 0) {
    Add-content -Path C:\ProgramData\test-signing-is-enabled -Value ""
}

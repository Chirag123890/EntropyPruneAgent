function Validate-ControlPlane {
    $manifestPath = "/root/EntropyPruneAgent/manifest.json"

    if (-Not (Test-Path $manifestPath)) {
        Write-Host "❌ Manifest not found at $manifestPath"
        return
    }

    $manifest = Get-Content $manifestPath | ConvertFrom-Json

    Write-Host "`n🔍 Validating Control-Plane Manifest:`n"

    # Validate scripts
    foreach ($scriptName in $manifest.scripts.PSObject.Properties.Name) {
        $scriptPath = $manifest.scripts.$scriptName
        if (Test-Path $scriptPath) {
            Write-Host "✅ Script exists: $scriptName → $scriptPath"
        } else {
            Write-Host "❌ Missing script: $scriptName → $scriptPath"
            if ($scriptName -eq "run_weekly_audit") {
                $content = @'
#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M")
logfile="/root/audit-logs/audit_$timestamp.txt"
pwsh -File /root/EntropyPruneAgent/audit-prune.ps1 > "$logfile"

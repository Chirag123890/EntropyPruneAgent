function Repair-ControlPlane {
    $manifestPath = "/root/EntropyPruneAgent/manifest.json"
    if (-Not (Test-Path $manifestPath)) {
        Write-Host "❌ Manifest not found."
        return
    }

    $manifest = Get-Content $manifestPath | ConvertFrom-Json

    Write-Host "`n🔧 Running Self-Repair Engine:`n"

    # Repair scripts
    foreach ($scriptName in $manifest.scripts.PSObject.Properties.Name) {
        $scriptPath = $manifest.scripts.$scriptName
        if (-Not (Test-Path $scriptPath)) {
            Write-Host "⚠️ Missing script: $scriptName → $scriptPath"
            if ($scriptName -eq "run_weekly_audit") {
                $content = @'
#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M")
logfile="/root/audit-logs/audit_$timestamp.txt"
pwsh -File /root/EntropyPruneAgent/audit-prune.ps1 > "$logfile"

function Summarize-AuditLogs {
    $logDir = "/root/audit-logs"
    if (-Not (Test-Path $logDir)) {
        Write-Host "📁 Log directory not found: $logDir"
        return
    }

    $logFiles = Get-ChildItem -Path $logDir -Filter "audit_*.txt" | Sort-Object Name
    $summary = @{}

    foreach ($file in $logFiles) {
        $content = Get-Content $file.FullName
        $timestamp = ($file.Name -replace "audit_|\.txt", "")
        $violations = ($content | Select-String -Pattern "→").Count
        $summary[$timestamp] = $violations
    }

    Write-Host "`n📊 Entropy Trend Summary:`n"
    foreach ($entry in $summary.GetEnumerator()) {
        $status = if ($entry.Value -eq 0) { "✅ Stable" } else { "⚠️ $($entry.Value) violations" }
        Write-Host "$($entry.Key): $status"
    }
}

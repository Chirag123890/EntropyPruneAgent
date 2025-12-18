function Inject-SliceAudit {
    param (
        [string]$slice
    )

    $manifestPath = "/root/EntropyPruneAgent/manifest.json"
    if (-Not (Test-Path $manifestPath)) {
        Write-Host "❌ Manifest not found."
        return
    }

    $manifest = Get-Content $manifestPath | ConvertFrom-Json
    $entropyMap = $manifest.entropy_categories

    if (-Not ($entropyMap.PSObject.Properties.Name -contains $slice)) {
        Write-Host "⚠️ Slice '$slice' not found in manifest."
        Write-Host "Available slices:"
        $entropyMap.PSObject.Properties.Name | ForEach-Object { Write-Host "  - $_" }
        return
    }

    $installed = @()
    $dpkgOutput = bash -c "dpkg -l"
    foreach ($line in $dpkgOutput) {
        if ($line.StartsWith("ii")) {
            $parts = $line -split '\s+'
            if ($parts.Length -ge 2) {
                $installed += $parts[1]
            }
        }
    }

    $violations = @()
    foreach ($pkg in $entropyMap.$slice) {
        if ($installed -contains $pkg) {
            $violations += "$slice ��� $pkg"
        }
    }

    if ($violations.Count -eq 0) {
        Write-Host "��� No violations found in slice '$slice'."
        return
    }

    Write-Host "`n���� Violations in slice '$slice':`n"
    foreach ($v in $violations) {
        Write-Host "������ $v"
    }

    Write-Host "`n���� Prune slice '$slice'? (y/n)"
    $confirm = Read-Host
    if ($confirm -eq "y") {
        foreach ($v in $violations) {
            $pkg = $v.Split("���")[1].Trim()
            Write-Host "Removing $pkg..."
            bash -c "apt remove -y $pkg"
        }
        Write-Host "`n��� Slice '$slice' pruned."
    } else {
        Write-Host "���� Pruning aborted."
    }
}

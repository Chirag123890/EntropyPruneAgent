function Audit-And-Prune {
    # Pre-audit self-repair
    $repairScript = "/root/EntropyPruneAgent/self-repair.ps1"
    if (Test-Path $repairScript) {
        . $repairScript
        Repair-ControlPlane
    } else {
        Write-Host "⚠️ Self-repair script not found. Skipping validation."
    }

    # Begin audit
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

    $entropyMap = @{
        "Redundant" = @("coreutils-from-gnu", "bsdutils")
        "Optional_GUI" = @("gir1.2-packagekitglib-1.0", "x11-common", "xauth", "xclip")
        "Optional_Encoding" = @("libcbor0.10", "xml-core", "sgml-base")
        "Optional_Python" = @("python3-wadllib")
        "Optional_Security" = @("libaudit1", "libaudit-common", "libapparmor1")
        "Optional_Build_Helper" = @("make", "rpcsvc-proto")
    }

    $violations = @()

    foreach ($category in $entropyMap.Keys) {
        foreach ($pkg in $entropyMap[$category]) {
            if ($installed -contains $pkg) {
                $violations += "$category ��� $pkg"
            }
        }
    }

    if ($violations.Count -eq 0) {
        Write-Host "��� No entropy detected. System is atomically stable."
        return
    }

    Write-Host "`n���� Entropy Detected:`n"
    foreach ($v in $violations) {
        Write-Host "������ $v"
    }

    Write-Host "`n���� Begin pruning? (y/n)"
    $confirm = Read-Host
    if ($confirm -eq "y") {
        foreach ($v in $violations) {
            $pkg = $v.Split("���")[1].Trim()
            Write-Host "Removing $pkg..."
            bash -c "apt remove -y $pkg"
        }
        Write-Host "`n��� Pruning complete. Run Audit-And-Prune again to verify."
    } else {
        Write-Host "���� Pruning aborted. No changes made."
    }
}

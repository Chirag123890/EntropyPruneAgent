# 🧩 EntropyPruneAgent v1.0

A lightweight, self-healing audit tool for Termux + PowerShell Ubuntu environments.  
It detects entropy (unnecessary packages), prunes them, validates scripts, and repairs itself.

---

## 🚀 Features
- 🔍 Audit installed packages
- 🧹 Prune entropy slices (GUI, Python, Security, etc.)
- 📊 Weekly scheduled audits with logs
- 🔧 Self-repair engine for scripts and aliases
- ✅ Control-plane validation

---

## 📦 Quick Start

```bash
git clone https://github.com/chirag/EntropyPruneAgent.git
cd EntropyPruneAgent
pwsh -File audit-prune.ps1

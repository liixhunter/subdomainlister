# 🔎 Subdomain Scanner Tool

A unified script for subdomain enumeration that combines multiple tools:
- **Assetfinder**
- **Subfinder**
- **Sublist3r**
- **AS3NT (Another Subdomain ENumeration Tool)**

It supports:
- Verbose mode with execution times and loading bars
- Error handling
- Saving results in either a single merged file or separate files per tool
- Deduplication of results
- Automatic extraction of subdomains from AS3NT CSV output

---

## 📦 Requirements

### 1. System Packages
Make sure your system has the following installed:

- `git`
- `golang`
- `python3` (tested with Python 3.10+; Python 3.13 also works)
- `python3-pip`
- `build-essential`
- `automake`
- `autoconf`
- `libtool`
- `pkg-config`
- `curl`
- `wget`
- `unzip`

Install on Debian/Ubuntu:
```bash
sudo apt update && sudo apt install -y git golang python3 python3-pip build-essential automake autoconf libtool pkg-config curl wget unzip
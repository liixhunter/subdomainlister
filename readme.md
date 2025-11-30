
```markdown
# 🌌 NebulaRecon — Subdomain Discovery Toolkit

```
╔════════════════════════════════════════════════════════╗
║            🔎 NebulaRecon — Subdomain Scanner          ║
║        Asset discovery across the cosmic web 🌌        ║
║  Tools: assetfinder • subfinder • sublist3r 🚀         ║
╚════════════════════════════════════════════════════════╝
```

NebulaRecon is a **Bash-powered toolkit** for subdomain discovery.  
It orchestrates multiple tools in parallel, normalizes results, and provides a colorful, emoji-rich user experience.

---

## ✨ Features
- ⚡ Parallel scanning across:
  - [assetfinder](https://github.com/tomnomnom/assetfinder)
  - [subfinder](https://github.com/projectdiscovery/subfinder)
  - [Sublist3r](https://github.com/aboul3la/Sublist3r)
- 🎛 Output modes:
  - **single** → merged results in one file
  - **separate** → individual files per tool
- 🧹 Normalization: lowercase, trim, deduplication, valid FQDN filtering
- 🧭 Verbose timings with spinner + per-tool status
- 💾 Output directory handling and log files
- ⏱ Timeout + retries per tool
- 🌈 Colorful banner and emoji-rich UX

---

## 📦 Dependencies & Installation

NebulaRecon requires three tools. Install them before running:

  ```

### 1. Assetfinder
- GitHub: [tomnomnom/assetfinder](https://github.com/tomnomnom/assetfinder)
- Install via Go:
  ```bash
    go install github.com/tomnomnom/assetfinder@latest
  ```

### 2. Subfinder
- GitHub: [projectdiscovery/subfinder](https://github.com/projectdiscovery/subfinder)
- Install via Go:
   ```bash
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
  ```
- Or download binaries from [Releases](https://github.com/projectdiscovery/subfinder/releases).

### 3. Sublist3r
- GitHub: [aboul3la/Sublist3r](https://github.com/aboul3la/Sublist3r)
- Install via Python:
  ```bash
  git clone https://github.com/aboul3la/Sublist3r.git
  cd Sublist3r
  pip install -r requirements.txt
  python sublist3r.py -h
  ```

---

## 🚀 Setup

Clone the repository and make the script executable:

```bash
git clone https://github.com/liixhunter/NebulaRecon.git
cd NebulaRecon
chmod +x nebula_recon.sh
```

---

## 🔎 Usage

```bash
./nebula_recon.sh --url <domain> | --file <domains.txt> [options]
```

### Options
- `--mode <single|separate>` → Output mode (default: `single`)
- `--out <path>` → Output file (single mode) or directory (separate mode)
- `--verbose` → Enable verbose logs and timings
- `--help` → Show help message

---

## 📂 Examples

Single domain, merged output:
```bash
./nebula_recon.sh --url example.com --mode single --out results.txt --verbose
```

Multiple domains, separate outputs:
```bash
./nebula_recon.sh --file domains.txt --mode separate --out ./out
```

---

## 📜 Output

- **Single mode** → All results merged into one file (deduplicated).
- **Separate mode** → Individual files per tool stored in the specified directory.

---

## ✅ Dependency Check

The script automatically verifies that `assetfinder`, `subfinder`, and `sublist3r` are installed.  
If any are missing, it will stop and prompt you to install them.

---

## 🛠 Development Notes

- Written in **Bash** with strict error handling (`set -euo pipefail`).
- Uses **ANSI colors** and emojis for better UX.
- Normalizes domains (lowercase, trims, removes protocol and trailing slash).
- Cleans results with deduplication and sorting.

---

## 📜 License

MIT License © 2025 — Your Name  
Feel free to use, modify, and share.
```

---






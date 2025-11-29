#!/bin/bash

# 🎯 Subdomain Scanner Tool
# Features:
# - Banner with colors
# - Verbose mode with execution times and loading bar
# - Error handling
# - Save mode: single merged file or separate files per tool
# - AS3NT integration with automatic subdomain extraction from CSV
# - Dependency check for AS3NT Python modules (e.g., shodan)

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"

VERBOSE=false
SAVE_MODE=""
OUTPUT_FILE=""

banner() {
    echo -e "${CYAN}"
    echo "====================================================="
    echo -e "   🔎 ${GREEN}Subdomain Scanner${RESET} 🚀"
    echo -e "   Powered by ${YELLOW}assetfinder${RESET}, ${MAGENTA}subfinder${RESET}, ${CYAN}sublist3r${RESET}, and ${BLUE}AS3NT${RESET}"
    echo "====================================================="
    echo -e "${RESET}"
}

usage() {
    echo "Usage: $0 --url <domain> | --file <file> [--verbose]"
    exit 1
}

check_dependencies() {
    echo -e "${CYAN}[INFO] Checking dependencies...${RESET}"
    for dep in assetfinder subfinder sublist3r as3nt; do
        if ! command -v $dep &>/dev/null; then
            echo -e "${RED}[ERROR] Missing dependency:${RESET} $dep"
        else
            echo -e "${GREEN}[OK]${RESET} Found $dep"
        fi
    done

    # Check Python modules for AS3NT
    python3 - <<EOF
try:
    import shodan
    print("[OK] Python module 'shodan' is installed")
except ImportError:
    print("[ERROR] Missing Python module 'shodan'. Install with: pip3 install shodan")
EOF
}

banner
check_dependencies

# Parse arguments
if [[ $# -lt 2 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            DOMAIN=$2
            shift 2
            ;;
        --file)
            FILE=$2
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            usage
            ;;
    esac
done

# Ask user how to save results
echo -e "${YELLOW}💾 Do you want results in a single merged file or separate files per tool?${RESET}"
echo -e "Type '${GREEN}single${RESET}' or '${MAGENTA}separate${RESET}': "
read SAVE_MODE

if [[ "$SAVE_MODE" == "single" ]]; then
    echo -e "${CYAN}📂 Enter the desired output filename (e.g., results.txt):${RESET}"
    read OUTPUT_FILE
    > "$OUTPUT_FILE"   # clear file once
fi

# Error handler + verbose + loading bar
run_command() {
    local cmd="$1"
    local outfile="$2"

    echo -e "${YELLOW}[INFO] Starting:${RESET} $cmd"
    local start_time=$(date +%s)

    if [[ -n "$outfile" ]]; then
        eval "$cmd" >> "$outfile" 2>>"${outfile}.err" &
    else
        eval "$cmd" &
    fi
    local pid=$!

    # Loading bar animation
    local bar=""
    while kill -0 $pid 2>/dev/null; do
        bar="$bar▏"
        printf "\r${CYAN}[LOADING]${RESET} %s" "$bar"
        sleep 1
    done
    printf "\r${GREEN}[DONE]${RESET} %-60s\n" "$cmd"

    wait $pid
    local status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $status -ne 0 ]]; then
        echo -e "${RED}[ERROR] Command failed with status $status:${RESET} $cmd"
    else
        echo -e "${GREEN}[SUCCESS]${RESET} Finished in ${duration}s"
    fi
}

extract_subdomains() {
    local csv_file=$1
    local output_file=$2
    if [[ -f "$csv_file" ]]; then
        cut -d',' -f2 "$csv_file" | sort -u > "$output_file"
        echo -e "${GREEN}[✔] Extracted subdomains saved to:${RESET} $output_file"
    else
        echo -e "${RED}[ERROR] CSV file not found, skipping extraction:${RESET} $csv_file"
    fi
}

scan_domain() {
    local domain=$1
    echo -e "${BLUE}[*] Scanning domain:${RESET} $domain"

    if [[ "$SAVE_MODE" == "single" ]]; then
        run_command "assetfinder --subs-only $domain" "$OUTPUT_FILE"
        run_command "subfinder -d $domain -silent -recursive -all" "$OUTPUT_FILE"
        run_command "sublist3r -d $domain -o /dev/stdout" "$OUTPUT_FILE"

        local tmp_csv="${domain}_as3nt.csv"
        run_command "as3nt -t $domain -11 -o $tmp_csv" ""
        extract_subdomains "$tmp_csv" "$OUTPUT_FILE"
        rm -f "$tmp_csv"

    else
        run_command "assetfinder --subs-only $domain > ${domain}_assetfinder.txt"
        run_command "subfinder -d $domain -silent -recursive -all > ${domain}_subfinder.txt"
        run_command "sublist3r -d $domain -o ${domain}_sublist3r.txt"

        local csv_file="${domain}_as3nt.csv"
        run_command "as3nt -t $domain -11 -o $csv_file" ""
        extract_subdomains "$csv_file" "${domain}_as3nt_subdomains.txt"

        echo -e "${GREEN}[✔] Results saved separately:${RESET}"
        echo "   - ${domain}_assetfinder.txt"
        echo "   - ${domain}_subfinder.txt"
        echo "   - ${domain}_sublist3r.txt"
        echo "   - ${domain}_as3nt.csv"
        echo "   - ${domain}_as3nt_subdomains.txt"

        local total=$(cat "${domain}_assetfinder.txt" "${domain}_subfinder.txt" "${domain}_sublist3r.txt" "${domain}_as3nt_subdomains.txt" 2>/dev/null | sort -u | wc -l)
        echo -e "${MAGENTA}[Summary] Found $total unique subdomains across all tools for $domain${RESET}"
    fi
}

# Run for single domain or file
GLOBAL_START=$(date +%s)

if [[ -n "$DOMAIN" ]]; then
    scan_domain "$DOMAIN"
elif [[ -n "$FILE" ]]; then
    while read -r domain; do
        scan_domain "$domain"
    done < "$FILE"
    if [[ "$SAVE_MODE" == "single" ]]; then
        sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
        local count=$(wc -l < "$OUTPUT_FILE" 2>/dev/null || echo 0)
        echo -e "${MAGENTA}[Summary] $count unique subdomains saved in $OUTPUT_FILE${RESET}"
    fi
else
    usage
fi

GLOBAL_END=$(date +%s)
GLOBAL_DURATION=$((GLOBAL_END - GLOBAL_START))
echo -e "${CYAN}[INFO] Total scan completed in ${GLOBAL_DURATION}s${RESET}"

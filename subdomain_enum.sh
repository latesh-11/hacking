#!/bin/bash

# Check if the domain is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

DOMAIN=$1
OUTPUT_DIR="$DOMAIN-results"
COMBINED_SUBDOMAINS="$OUTPUT_DIR/all_subdomains.txt"
LIVE_SUBDOMAINS="$OUTPUT_DIR/live_subdomains.txt"

# Create output directory
mkdir -p $OUTPUT_DIR

# Step 1: Subdomain Enumeration with Subfinder
echo "[*] Running Subfinder..."
subfinder -d $DOMAIN -silent > "$OUTPUT_DIR/subfinder.txt"

# Step 2: Subdomain Enumeration with Assetfinder
echo "[*] Running Assetfinder..."
assetfinder --subs-only $DOMAIN > "$OUTPUT_DIR/assetfinder.txt"

# Step 3: Subdomain Enumeration with Amass
echo "[*] Running Amass..."
amass enum -d $DOMAIN -o "$OUTPUT_DIR/amass.txt"

# Step 4: Combine the results from all three tools into one file
echo "[*] Combining results..."
cat "$OUTPUT_DIR/subfinder.txt" "$OUTPUT_DIR/assetfinder.txt" "$OUTPUT_DIR/amass.txt" | sort -u > $COMBINED_SUBDOMAINS

# Step 5: Probe for live domains using httprobe
echo "[*] Probing for live domains..."
cat $COMBINED_SUBDOMAINS | httprobe > $LIVE_SUBDOMAINS

# Step 6: Capture screenshots of live domains using Gowitness
echo "[*] Capturing screenshots with Gowitness..."
gowitness file -f $LIVE_SUBDOMAINS --destination "$OUTPUT_DIR/screenshots"

echo "[*] Subdomain enumeration and screenshot capture completed. Results stored in $OUTPUT_DIR"

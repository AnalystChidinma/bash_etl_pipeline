#!/bin/bash
set -e  # Stop the script if any command fails

# CONFIGURATION

# Source_DIR is the path where your file is stored

SOURCE_DIR="./data/transformed"
DEST_BASE="./json_and_CSV"

# Create a timestamp, e.g., 20251106_223045
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEST_DIR="$DEST_BASE/$TIMESTAMP"

# Create the destination folder
mkdir -p "$DEST_DIR"

echo "Starting File Management Process..."
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"

# Find CSV and JSON files (only in the current level, not subfolders)
FILES=$(find "$SOURCE_DIR" -maxdepth 1 -type f \( -iname "*.csv" -o -iname "*.json" \))

# If no files found, stop
if [ -z "$FILES" ]; then
  echo "  No CSV or JSON files found in $SOURCE_DIR"
  exit 0
fi

# Move each file found
for file in $FILES; do
  mv "$file" "$DEST_DIR/"
done

# -------- CREATE MANIFEST --------
MANIFEST_FILE="$DEST_DIR/manifest.txt"

echo "Archive timestamp: $TIMESTAMP" > "$MANIFEST_FILE"
echo "Source directory: $SOURCE_DIR" >> "$MANIFEST_FILE"
echo "Destination directory: $DEST_DIR" >> "$MANIFEST_FILE"
echo "Moved files:" >> "$MANIFEST_FILE"

ls "$DEST_DIR" | grep -E "\.csv$|\.json$" >> "$MANIFEST_FILE"

# -------- SUMMARY --------
COUNT=$(ls "$DEST_DIR" | grep -E "\.csv$|\.json$" | wc -l)
echo " $COUNT files moved successfully."
echo " Manifest created at: $MANIFEST_FILE"
echo " File Management Process Complete!"

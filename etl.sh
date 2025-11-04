#!/bin/bash
set -e  # stop script if any command fails

source .env

mkdir -p $RAW_DIR $TRANSFORMED_DIR $GOLD_DIR $LOG_DIR

echo "----- Starting ETL Pipeline -----" | tee -a $LOG_DIR/pipeline.log

# Extract Stage
echo "Extracting data from source..."
RAW_FILE="$RAW_DIR/data.csv"

curl -s -o $RAW_FILE "$DEC_SOURCE_URL"

# Validate download
if [[ -f "$RAW_FILE" ]]; then
    FILE_SIZE=$(stat -c%s "$RAW_FILE")
    CHECKSUM=$(md5sum "$RAW_FILE" | awk '{print $1}')
    echo "✅ Download successful. File size: ${FILE_SIZE} bytes, MD5: ${CHECKSUM}" | tee -a $LOG_DIR/pipeline.log
else
    echo "❌ Download failed" | tee -a $LOG_DIR/pipeline.log
    exit 1
fi
# Transform Stage


echo "Transforming data..." | tee -a $LOG_DIR/pipeline.log

TRANSFORMED_FILE="$TRANSFORMED_DIR/cleaned_data.csv"

# Example transformation using awk:
# - Skip empty lines
# - Remove duplicate header rows
# - Rename columns (if necessary)
# - Filter out rows where any key column is empty

awk -F',' 'BEGIN {OFS=","}
NR==1 {
    # Capture header and rename columns if needed
    for (i=1; i<=NF; i++) {
        gsub(/ /, "_", $i);      # Replace spaces with underscores
        gsub(/"/, "", $i);       # Remove quotes
    }
    print $0;                    # Print header
    next
}
NF > 0 { print $0 }              # Skip completely empty lines
' "$RAW_FILE" > "$TRANSFORMED_FILE"

# Validate transformation
if [[ -s "$TRANSFORMED_FILE" ]]; then
    ROW_COUNT=$(wc -l < "$TRANSFORMED_FILE")
    echo "✅ Transformation complete. Rows processed: $ROW_COUNT" | tee -a $LOG_DIR/pipeline.log
else
    echo "❌ Transformation failed or produced empty file." | tee -a $LOG_DIR/pipeline.log
    exit 1
fi

#!/bin/bash
set -e

# Load environment variables
source .env

# Generate timestamp for unique log file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/etl_${TIMESTAMP}.log"

# Create all needed directories if not present
mkdir -p "$RAW_DIR" "$TRANSFORMED_DIR" "$GOLD_DIR" "$LOG_DIR"

# Force flag setup
FORCE=false
if [[ "$1" == "--force" ]]; then
  FORCE=true
fi

# Redirect all output (stdout + stderr) to both terminal and log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting ETL Pipeline Run at $(date)"
echo "Log file: $LOG_FILE"
echo "----- Starting ETL Pipeline -----" | tee -a $LOG_DIR/pipeline.log

# Extract Stage
echo "Extracting data from source..."
RAW_FILE="$RAW_DIR/data.csv"

curl -s -o $RAW_FILE "$DEC_SOURCE_URL"

# Validate download
if [[ -f "$RAW_FILE" ]]; then
    FILE_SIZE=$(stat -c%s "$RAW_FILE")    CHECKSUM=$(md5sum "$RAW_FILE" | awk '{print $1}')
    echo "Download successful. File size: ${FILE_SIZE} bytes, MD5: ${CHECKSUM}" | tee -a $LOG_DIR/pipeline.log
else
    echo "Download failed" | tee -a $LOG_DIR/pipeline.log
    exit 1
fi

# Transform Stage

echo "----- Starting Transformation Stage -----" | tee -a $LOG_DIR/pipeline.log
echo "Transforming data..." | tee -a $LOG_DIR/pipeline.log

TRANSFORMED_FILE="$TRANSFORMED_DIR/finance_2023.csv"

# Using AWK to:
# - Rename columns
# - Select specific columns
# - Filter rows where year = 2023

awk -F',' 'BEGIN {OFS=","}
NR==1 {
    # Rename specific headers
    for (i=1; i<=NF; i++) {
        if ($i == "VariableCode") $i="variable_code";
        if ($i == "Value") $i="value";
        if ($i == "Units") $i="units";
        if ($i == "Year") $i="year";
    }
    print "year","value","units","variable_code";  # Select only these 4 columns
}
NR>1 && $1 == 2023 {
    print $1,$2,$3,$4;
}' "$RAW_FILE" > "$TRANSFORMED_FILE"

# Validate transformation
if [[ -s "$TRANSFORMED_FILE" ]]; then
    ROW_COUNT=$(wc -l < "$TRANSFORMED_FILE")
    echo "Transformation complete. Rows processed: $ROW_COUNT" | tee -a $LOG_DIR/pipeline.log
else
    echo "Transformation failed or no rows found for 2023" | tee -a $LOG_DIR/pipeline.log
    exit 1
fi


# Load Stage

echo "----- Starting Load Stage -----" | tee -a $LOG_DIR/pipeline.log
echo "Loading data into Gold layer..." | tee -a $LOG_DIR/pipeline.log

# Define variables
DATE=$(date +%Y-%m-%d)
GOLD_FILE="$GOLD_DIR/finance_2023.csv.gz"
PARTITION_DIR="$GOLD_DIR/ingestion_date=$DATE"

# Create partitioned folder
mkdir -p "$PARTITION_DIR"

# Compress the transformed file into Gold directory
gzip -c "$TRANSFORMED_FILE" > "$GOLD_FILE"

# Copy compressed file into partitioned directory
cp "$GOLD_FILE" "$PARTITION_DIR/"

# Generate MD5 checksum for verification
CHECKSUM_FILE="$PARTITION_DIR/finance_2023.csv.md5"
md5sum "$TRANSFORMED_FILE" | awk '{print $1}' > "$CHECKSUM_FILE"

# Confirmation messages for all steps
echo "Gold layer file created: $GOLD_FILE" | tee -a $LOG_DIR/pipeline.log
echo "Partition folder created: $PARTITION_DIR" | tee -a $LOG_DIR/pipeline.log
echo "MD5 checksum generated at: $CHECKSUM_FILE" | tee -a $LOG_DIR/pipeline.log

# Final confirmation
echo "ETL pipeline completed successfully at $(date)!" | tee -a $LOG_DIR/pipeline.log
echo "log file: $LOG_FILE"

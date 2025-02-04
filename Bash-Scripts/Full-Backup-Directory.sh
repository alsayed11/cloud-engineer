#!/bin/bash

# Configuration
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="backup_$TIMESTAMP.tar.gz"
LOG_FILE="/var/log/backup_script.log"
RETENTION_DAYS=7  # Delete backups older than 7 days

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Log start time
START_TIME=$(date +%s)  # Capture start time in seconds
echo "[$(date)] Starting backup of $SOURCE_DIR..." | tee -a "$LOG_FILE"

# First command: Create a compressed backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"

# Check if the first command succeeded
if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)  # Capture end time in seconds
    BACKUP_DURATION=$((END_TIME - START_TIME))  # Calculate time taken

    echo "[$(date)] Backup completed successfully: $BACKUP_DIR/$BACKUP_FILE" | tee -a "$LOG_FILE"
    echo "[$(date)] Backup took $BACKUP_DURATION seconds." | tee -a "$LOG_FILE"

    # Second command: Remove old backups (older than RETENTION_DAYS)
    find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

    # Check if cleanup succeeded
    if [ $? -eq 0 ]; then
        echo "[$(date)] Old backups cleaned up (retaining last $RETENTION_DAYS days)" | tee -a "$LOG_FILE"
    else
        echo "[$(date)] WARNING: Failed to clean up old backups." | tee -a "$LOG_FILE"
    fi

else
    echo "[$(date)] ERROR: Backup failed!" | tee -a "$LOG_FILE"
    exit 1
fi

echo "[$(date)] Backup process completed successfully." | tee -a "$LOG_FILE"


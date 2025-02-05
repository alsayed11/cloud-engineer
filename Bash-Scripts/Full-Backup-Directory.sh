#!/bin/bash

# ===========================================
# Backup Script for /var/www/html
# ===========================================
# Author: Sayed Husain
# Date: Feb 04, 2025
# Description:
#   - This script backs up the /var/www/html directory.
#   - It logs execution time and errors.
#   - It retains backups for 7 days and deletes older ones.
#   - It considers the backup successful even if cleanup fails.
#   - It sends an email notification whether the backup succeeds or fails.
# ===========================================

# Configuration Variables
SOURCE_DIR="/var/www/html"      # Directory to back up
BACKUP_DIR="/backups"           # Where to store backups
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")  # Timestamp for backup file name
BACKUP_FILE="backup_$TIMESTAMP.tar.gz"  # Backup file name
LOG_FILE="/var/log/backup_script.log"  # Log file path
RETENTION_DAYS=7              # Number of days to retain backups

# Email Configuration
EMAIL_TO="your-email@example.com"  # Replace with your email
EMAIL_SUBJECT_SUCCESS="Backup Successful: $TIMESTAMP"
EMAIL_SUBJECT_FAILURE="Backup Failed: $TIMESTAMP"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Start logging and capture start time
START_TIME=$(date +%s)  # Capture script start time
echo "[$(date)] Starting backup of $SOURCE_DIR..." | tee -a "$LOG_FILE"

# Create the backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)  # Capture end time after backup completion
    BACKUP_DURATION=$((END_TIME - START_TIME))  # Calculate time taken

    echo "[$(date)] Backup completed successfully: $BACKUP_DIR/$BACKUP_FILE" | tee -a "$LOG_FILE"
    echo "[$(date)] Backup took $BACKUP_DURATION seconds." | tee -a "$LOG_FILE"

    # Cleanup old backups (retain last $RETENTION_DAYS days)
    find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

    # Check if cleanup was successful
    if [ $? -eq 0 ]; then
        echo "[$(date)] Old backups cleaned up (retaining last $RETENTION_DAYS days)" | tee -a "$LOG_FILE"
    else
        # Important Note:
        # The script considers the backup operation successful even if the cleanup fails.
        # This is intentional, as a failed cleanup does not affect the integrity of the backup itself.
        echo "[$(date)] WARNING: Failed to clean up old backups." | tee -a "$LOG_FILE"
    fi

    # Send success email notification
    echo -e "Backup was successful.\n\nBackup File: $BACKUP_DIR/$BACKUP_FILE\nDuration: $BACKUP_DURATION seconds." | mail -s "$EMAIL_SUBJECT_SUCCESS" "$EMAIL_TO"

else
    echo "[$(date)] ERROR: Backup failed!" | tee -a "$LOG_FILE"

    # Send failure email notification
    echo -e "Backup failed for $SOURCE_DIR.\nPlease check the logs at $LOG_FILE for more details." | mail -s "$EMAIL_SUBJECT_FAILURE" "$EMAIL_TO"

    exit 1  # Exit with error code 1 if backup fails
fi

# Log final success message
echo "[$(date)] Backup process completed successfully." | tee -a "$LOG_FILE"


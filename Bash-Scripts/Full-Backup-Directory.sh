#!/bin/bash
# ===========================================
# Backup Script for /var/www/html
# ===========================================
# Author: Sayed Husain
# Date: Feb 04, 2025
# Description:
#   - This script backs up the /var/www/html directory.
#   - It logs execution time, errors, and reasons for failure.
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
LOCK_FILE="/var/run/backup_script.lock"  # Lock file to prevent concurrent runs

# Email Configuration
EMAIL_TO="alsayed10@hotmail.com"  # Replace with your email
EMAIL_SUBJECT_SUCCESS="Backup Successful: $TIMESTAMP"
EMAIL_SUBJECT_FAILURE="Backup Failed: $TIMESTAMP"

# Function to send emails
send_email() {
    local subject="$1"
    local body="$2"
    echo -e "$body" | mail -s "$subject" "$EMAIL_TO"
}

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Start logging and capture start time
START_TIME=$(date +%s)  # Capture script start time
echo "[$(date)] Starting backup of $SOURCE_DIR..." | tee -a "$LOG_FILE"

# Prevent concurrent runs using a lock file
if [ -e "$LOCK_FILE" ]; then
    echo "[$(date)] ERROR: Another instance of the script is already running." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Another instance of the backup script is already running."
    exit 1
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

# Validate required tools
command -v tar >/dev/null || { echo "[$(date)] ERROR: 'tar' is not installed." | tee -a "$LOG_FILE"; exit 1; }
command -v mail >/dev/null || { echo "[$(date)] ERROR: 'mail' is not installed." | tee -a "$LOG_FILE"; exit 1; }

# Check if source directory exists and is not empty
if [ ! -d "$SOURCE_DIR" ]; then
    echo "[$(date)] ERROR: Source directory '$SOURCE_DIR' does not exist." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Source directory '$SOURCE_DIR' does not exist. Backup aborted."
    exit 1
elif [ -z "$(ls -A "$SOURCE_DIR")" ]; then
    echo "[$(date)] ERROR: Source directory '$SOURCE_DIR' is empty." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Source directory '$SOURCE_DIR' is empty. Backup aborted."
    exit 1
fi

# Check available disk space
FREE_SPACE=$(df --output=avail "$BACKUP_DIR" | tail -n1)
REQUIRED_SPACE=$(du -sb "$SOURCE_DIR" | awk '{print $1}')
if [ "$FREE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo "[$(date)] ERROR: Insufficient disk space in '$BACKUP_DIR'. Required: $REQUIRED_SPACE bytes, Available: $FREE_SPACE bytes." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Insufficient disk space in '$BACKUP_DIR'. Backup aborted."
    exit 1
fi

# Create the backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Backup creation failed. Reason: Tar command failed." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Backup creation failed. Reason: Tar command failed."
    exit 1
fi

# Verify the integrity of the backup
tar -tzf "$BACKUP_DIR/$BACKUP_FILE" >/dev/null
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Backup file '$BACKUP_FILE' is corrupted." | tee -a "$LOG_FILE"
    send_email "$EMAIL_SUBJECT_FAILURE" "Backup file '$BACKUP_FILE' is corrupted. Backup failed."
    exit 1
fi

# Log success and calculate duration
END_TIME=$(date +%s)  # Capture end time after backup completion
BACKUP_DURATION=$((END_TIME - START_TIME))  # Calculate time taken
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | awk '{print $1}')
echo "[$(date)] Backup completed successfully: $BACKUP_DIR/$BACKUP_FILE" | tee -a "$LOG_FILE"
echo "[$(date)] Backup took $BACKUP_DURATION seconds. Backup size: $BACKUP_SIZE" | tee -a "$LOG_FILE"

# Cleanup old backups (retain last $RETENTION_DAYS days)
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;
if [ $? -eq 0 ]; then
    echo "[$(date)] Old backups cleaned up (retaining last $RETENTION_DAYS days)" | tee -a "$LOG_FILE"
else
    echo "[$(date)] WARNING: Failed to clean up old backups." | tee -a "$LOG_FILE"
fi

# Send success email notification
send_email "$EMAIL_SUBJECT_SUCCESS" "Backup was successful.\n\nBackup File: $BACKUP_DIR/$BACKUP_FILE\nDuration: $BACKUP_DURATION seconds\nSize: $BACKUP_SIZE"

# Log final success message
echo "[$(date)] Backup process completed successfully." | tee -a "$LOG_FILE"

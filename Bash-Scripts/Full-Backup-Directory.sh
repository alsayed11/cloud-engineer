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

# Create backup and log output
echo "[$(date)] Starting backup of $SOURCE_DIR..." | tee -a "$LOG_FILE"

if tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"; then
    echo "[$(date)] Backup completed: $BACKUP_DIR/$BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ERROR: Backup failed!" | tee -a "$LOG_FILE"
    exit 1
fi

# Remove old backups
find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;
echo "[$(date)] Old backups cleaned up (retaining last $RETENTION_DAYS days)" | tee -a "$LOG_FILE"

echo "[$(date)] Backup process completed successfully." | tee -a "$LOG_FILE"


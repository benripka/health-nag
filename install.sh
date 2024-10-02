#!/bin/bash

# Define constants
INSTALL_DIR="/usr/share/health-nag"
SCRIPT_NAME="screen_overlay.py"
REMINDERS_FILE="/etc/health-nag/reminders.json"
CRON_MARKER="# SCREEN_OVERLAY_REMINDER"
LOG_FILE="/var/log/health-nag.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Function to remove existing crontab entries
remove_existing_crontab() {
    current_crontab=$(crontab -l)
    if echo "$current_crontab" | grep -q "$CRON_MARKER"; then
        log_message "Removing existing crontab entries with marker: $CRON_MARKER"
        echo "$current_crontab" | grep -v "$CRON_MARKER" | crontab -
    else
        log_message "No existing crontab entries to remove."
    fi
}

clear_log_file() {
    echo "" > "$LOG_FILE"
    log_message "Log file cleared"
}

# Function to add new crontab entry
add_crontab_entry() {
    (crontab -l 2>/dev/null; echo "$1 >> $LOG_FILE 2>&1 $CRON_MARKER") | crontab -
}

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"
log_message "Created installation directory $INSTALL_DIR"

# Make art directory
mkdir -p "$INSTALL_DIR/art"
log_message "Created art directory $INSTALL_DIR/art"

# Remove file copying operations

# Modify crontab entries to use the new paths
add_crontab_entry "$cron /usr/bin/$SCRIPT_NAME --name \"$name\""

# Read reminders.json and create cron jobs
if [ -f "$INSTALL_DIR/$REMINDERS_FILE" ]; then
    log_message "$REMINDERS_FILE found. Setting up cron jobs."
    jq -c '.[]' "$INSTALL_DIR/$REMINDERS_FILE" | while read -r reminder; do
        if [ $? -ne 0 ]; then
            log_message "Error reading $REMINDERS_FILE."
            exit 1
        fi
        name=$(echo "$reminder" | jq -r '.name')
        cron=$(echo "$reminder" | jq -r '.cron')
        # Ex. * * * * * export DISPLAY=:1 && export XAUTHORITY=/run/user/1001/gdm/Xauthority && /home/ben/.local/share/health-nag/screen_overlay.py --name 'eyes'  >> /home/ben/health-nag.log 2>&1
        add_crontab_entry "$cron /usr/bin/$SCRIPT_NAME --name \"$name\""
        log_message "Added cron job for reminder '$name': $cron"
    done
else
    log_message "Error: $REMINDERS_FILE not found."
    exit 1
fi

log_message "Installation complete. Cron jobs have been set up for the current user."

# Get the last reminder from reminders.json and run it as a test
if [ -f "$INSTALL_DIR/$REMINDERS_FILE" ]; then
    last_reminder=$(jq -c '.[-1]' "$INSTALL_DIR/$REMINDERS_FILE")
    if [ $? -eq 0 ] && [ ! -z "$last_reminder" ]; then
        last_reminder_name=$(echo "$last_reminder" | jq -r '.name')
        log_message "Running last reminder '$last_reminder_name' as a test..."
        export DISPLAY=$DISPLAY && export XAUTHORITY=$XAUTHORITY && "$INSTALL_DIR/$SCRIPT_NAME" --name "$last_reminder_name"
    else
        log_message "Error: Unable to get last reminder from $REMINDERS_FILE"
    fi
else
    log_message "Error: $REMINDERS_FILE not found."
fi

log_message "Running first reminder as a test..."

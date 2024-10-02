#!/bin/bash

# Define constants
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALL_DIR="$HOME/.local/share/health-nag"
SCRIPT_NAME="screen_overlay.py"
REMINDERS_FILE="reminders.json"
CRON_MARKER="# SCREEN_OVERLAY_REMINDER"
LOG_FILE="$HOME/health-nag.log"

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

# Copy entire health-nag directory to installation directory
cp -R "$SCRIPT_DIR"/* "$INSTALL_DIR"
log_message "Copied health-nag to $INSTALL_DIR"

# Make screen_overlay.py executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
log_message "Made $SCRIPT_NAME executable"

# Copy art assets to installation directory
cp "$SCRIPT_DIR"/art/* "$INSTALL_DIR/art"
log_message "Copied art assets to $INSTALL_DIR/art"

# Copy reminders.json to installation directory
cp "$SCRIPT_DIR/$REMINDERS_FILE" "$INSTALL_DIR"
log_message "Copied $REMINDERS_FILE to $INSTALL_DIR"

# Remove existing crontab entries
remove_existing_crontab

# Clear log file
clear_log_file

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
        add_crontab_entry "$cron export DISPLAY=$DISPLAY && export XAUTHORITY=$XAUTHORITY && $INSTALL_DIR/$SCRIPT_NAME --name \"$name\""
        log_message "Added cron job for reminder '$name': $cron"
    done
else
    log_message "Error: $REMINDERS_FILE not found."
    exit 1
fi

log_message "Installation complete. Cron jobs have been set up for the current user."

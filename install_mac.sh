#!/bin/bash

# Define constants
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALL_DIR="$HOME/Library/Application Support/health-nag"
SCRIPT_NAME="screen_overlay.py"
REMINDERS_FILE="reminders.json"
LOG_FILE="$HOME/Library/Logs/health-nag.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

clear_log_file() {
    echo "" > "$LOG_FILE"
    log_message "Log file cleared"
}

# Function to create launchd plist
create_launchd_plist() {
    local name="$1"
    local schedule="$2"
    local plist_path="$HOME/Library/LaunchAgents/com.health-nag.$name.plist"
    
    # Create plist file
    cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.health-nag.$name</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>$INSTALL_DIR/$SCRIPT_NAME</string>
        <string>--name</string>
        <string>$name</string>
    </array>
    <key>StartCalendarInterval</key>
    $schedule
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
    <key>StandardErrorPath</key>
    <string>$LOG_FILE</string>
</dict>
</plist>
EOF

    # Load the plist
    launchctl load "$plist_path"
    log_message "Created and loaded launchd plist for $name"
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

# Clear log file
clear_log_file

# Read reminders.json and create launchd jobs
if [ -f "$INSTALL_DIR/$REMINDERS_FILE" ]; then
    log_message "$REMINDERS_FILE found. Setting up launchd jobs."
    /usr/local/bin/jq -c '.[]' "$INSTALL_DIR/$REMINDERS_FILE" | while read -r reminder; do
        if [ $? -ne 0 ]; then
            log_message "Error reading $REMINDERS_FILE."
            exit 1
        fi
        name=$(echo "$reminder" | /usr/local/bin/jq -r '.name')
        cron=$(echo "$reminder" | /usr/local/bin/jq -r '.cron')
        
        # Convert cron to launchd schedule
        minute=$(echo "$cron" | awk '{print $1}')
        hour=$(echo "$cron" | awk '{print $2}')
        day=$(echo "$cron" | awk '{print $3}')
        month=$(echo "$cron" | awk '{print $4}')
        weekday=$(echo "$cron" | awk '{print $5}')
        
        schedule="<dict>"
        [ "$minute" != "*" ] && schedule+="<key>Minute</key><integer>$minute</integer>"
        [ "$hour" != "*" ] && schedule+="<key>Hour</key><integer>$hour</integer>"
        [ "$day" != "*" ] && schedule+="<key>Day</key><integer>$day</integer>"
        [ "$month" != "*" ] && schedule+="<key>Month</key><integer>$month</integer>"
        [ "$weekday" != "*" ] && schedule+="<key>Weekday</key><integer>$weekday</integer>"
        schedule+="</dict>"
        
        create_launchd_plist "$name" "$schedule"
    done
else
    log_message "Error: $REMINDERS_FILE not found."
    exit 1
fi

log_message "Installation complete. Launchd jobs have been set up for the current user."

# Get the last reminder from reminders.json and run it as a test
if [ -f "$INSTALL_DIR/$REMINDERS_FILE" ]; then
    last_reminder=$(/usr/local/bin/jq -c '.[-1]' "$INSTALL_DIR/$REMINDERS_FILE")
    if [ $? -eq 0 ] && [ ! -z "$last_reminder" ]; then
        last_reminder_name=$(echo "$last_reminder" | /usr/local/bin/jq -r '.name')
        log_message "Running last reminder '$last_reminder_name' as a test..."
        "$INSTALL_DIR/$SCRIPT_NAME" --name "$last_reminder_name"
    else
        log_message "Error: Unable to get last reminder from $REMINDERS_FILE"
    fi
else
    log_message "Error: $REMINDERS_FILE not found."
fi

log_message "Installation complete. Test run finished."
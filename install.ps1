# Define constants
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$INSTALL_DIR = "$env:LOCALAPPDATA\health-nag"
$SCRIPT_NAME = "screen_overlay.py"
$REMINDERS_FILE = "reminders.json"
$LOG_FILE = "$env:USERPROFILE\health-nag.log"

# Function to log messages
function Log-Message {
    param([string]$message)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message" | Out-File -Append -FilePath $LOG_FILE
}

# Function to remove existing scheduled tasks
function Remove-ExistingTasks {
    Get-ScheduledTask | Where-Object {$_.TaskName -like "HealthNag*"} | Unregister-ScheduledTask -Confirm:$false
    Log-Message "Removed existing HealthNag tasks"
}

# Create installation directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
Log-Message "Created installation directory $INSTALL_DIR"

# Copy entire health-nag directory to installation directory
Copy-Item -Path "$SCRIPT_DIR\*" -Destination $INSTALL_DIR -Recurse -Force
Log-Message "Copied health-nag to $INSTALL_DIR"

# Remove existing scheduled tasks
Remove-ExistingTasks

# Clear log file
Clear-Content -Path $LOG_FILE
Log-Message "Log file cleared"

# Read reminders.json and create scheduled tasks
if (Test-Path "$INSTALL_DIR\$REMINDERS_FILE") {
    Log-Message "$REMINDERS_FILE found. Setting up scheduled tasks."
    $reminders = Get-Content "$INSTALL_DIR\$REMINDERS_FILE" | ConvertFrom-Json
    foreach ($reminder in $reminders) {
        $taskName = "HealthNag_$($reminder.name)"
        $action = New-ScheduledTaskAction -Execute "pythonw" -Argument "$INSTALL_DIR\$SCRIPT_NAME --name `"$($reminder.name)`""
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest -Force
        Log-Message "Added scheduled task for reminder '$($reminder.name)'"
    }
} else {
    Log-Message "Error: $REMINDERS_FILE not found."
    exit 1
}

Log-Message "Installation complete. Scheduled tasks have been set up for the current user."

# Run the last reminder as a test
if (Test-Path "$INSTALL_DIR\$REMINDERS_FILE") {
    $lastReminder = ($reminders | Select-Object -Last 1).name
    Log-Message "Running last reminder '$lastReminder' as a test..."
    Start-Process pythonw -ArgumentList "$INSTALL_DIR\$SCRIPT_NAME --name `"$lastReminder`""
} else {
    Log-Message "Error: $REMINDERS_FILE not found."
}

Log-Message "Running first reminder as a test..."
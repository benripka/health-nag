<div>
<h1 style="border-bottom: none; margin-bottom: 0;">Health-Nag</h1>
<h3 style="border-bottom: none; margin-top: 0;">A stricter enforcer of healthy habits</h3>
</div>
Health-Nag is a desktop utility designed to provide forceful health-related reminders for those who are prone to hyperfixation. This tool aims to interrupt intense focus periods with important reminders to maintain physical and mental well-being such as resting your eyes, eating, hydrating, and taking breaks. Health-Nag ensures that critical health reminders are not easily ignored.

## How it works
Periodically your screen is taken over by an overlay like this:
![When a reminder is triggered](<docs/Screenshot from 2024-10-02 10-42-53.png>)
The overlay cannot be exited until either the reminder is complete, or you agree to the consequences of exiting
![When you try to exit the overlay](<docs/Screenshot from 2024-10-02 10-42-58.png>)
## Features
- 3 reminder presets for:
   - Eyes: Reminds you to look away from your screen every 1 hr. Blocks screen for 30 seconds.
   - Food: Reminds you to eat at 9am, 12pm, and 6pm. Blocks screen for 5 minutes.
   - Drink: Reminds you to drink every 2 hours. Blocks screen for 10 seconds.
- Customizable reminder messages and intervals

## Installation 

### Debian/Ubuntu Linux


1. Download the .deb file from the latest release (https://github.com/benripka/health-nag/releases/tag/v1.0.0)

2. Install the .deb file:
```
sudo dpkg -i health-nag.deb
```

## Add new reminders to nag yourself about
To add custom reminders, rn you have to install it manually.

1.  Clone the repo
```
git clone https://github.com/benripka/health-nag.git
```

2.  Add an entry to the `reminders.json` file, for example:

```
{
  "reminders": [
    {
      "name": "mind",
      "command": "Have you meditated today?",
      "overrideReason": "Not now... My mind shall remain cluttered and my soul untamed.",
      "overrideKey": "clutter my mind",
      "duration": 60,
      "asciiArtPath": "./art/food.txt",
      "description": "The 20-20-20 rule:
       Every 20 minutes, look up from your screen and focus on an item approximately 20 feet away for at least 20 seconds. 
       This allows your eye muscles to relax after prolonged screen time and helps prevent digital eye strain."
    }
  ]
}
```
3. Run the reinstall script to install with your custom reminders setup script:
```
chmod +x reinstall.sh
./reinstall.sh
```

### Installation on macOS !!!!WARNING: This is untested, probably won't work. If you fix it please create a PR.

For macOS users, we provide a separate installation script that uses launchd instead of cron for scheduling reminders. Follow these steps to install Health Nag on your Mac:

1. Ensure you have Python 3 installed on your system. You can download it from [python.org](https://www.python.org/downloads/mac-osx/) if needed.

2. Install the `jq` command-line JSON processor if you haven't already. The easiest way is to use Homebrew:
   ```
   brew install jq
   ```
   If you don't have Homebrew, you can install it from [brew.sh](https://brew.sh/).

3. Clone this repository or download it as a ZIP file and extract it.

4. Open Terminal and navigate to the directory containing the Health Nag files.

5. Make the macOS install script executable:
   ```
   chmod +x install_mac.sh
   ```

6. Run the installation script:
   ```
   ./install_mac.sh
   ```

7. The script will create the necessary directories, copy files, and set up launchd jobs for each reminder defined in `reminders.json`.

8. After installation, the script will run a test to ensure everything is working correctly.

9. You can check the log file at `~/Library/Logs/health-nag.log` for any issues or to confirm successful installation.

Note: The macOS version uses launchd plists located in `~/Library/LaunchAgents/` to schedule reminders. If you need to modify or remove reminders later, you can edit the `reminders.json` file and re-run the installation script, or manually edit the plist files.

If you encounter any issues or need to uninstall, you can remove the launchd jobs by running:
```
launchctl unload ~/Library/LaunchAgents/com.health-nag.eyes.plist
```

### Installation on Windows - !!!WARNING: This is untested, probably won't work. If you fix it please create a PR.

1. Ensure you have Python installed on your system. You can download it from [python.org](https://www.python.org/downloads/).

2. Install required Python packages:
   ```
   pip install tkinter
   ```

3. Clone this repository or download it as a ZIP file and extract it:
   ```
   git clone https://github.com/benripka/health-nag.git
   cd health-nag
   ```

4. Run the PowerShell install script to set up the reminders. This will also run the last reminder in the list (for testing purposes). Rerunning the install script will reset the reminders to those set in reminders.json:
   ```powershell
   # Open PowerShell as Administrator
   Set-ExecutionPolicy RemoteSigned -Scope Process
   .\install.ps1
   ```

   Note: The `Set-ExecutionPolicy` command allows the script to run. You may need to adjust your execution policy if you encounter issues.

5. The script will:
   - Create an installation directory at `%LOCALAPPDATA%\health-nag`
   - Copy all necessary files to the installation directory
   - Set up scheduled tasks for each reminder in `reminders.json`
   - Run the last reminder as a test

6. You can view the installation log at `%USERPROFILE%\health-nag.log`

After installation, the reminders will run according to their scheduled times. You can manage these tasks using the Windows Task Scheduler.

## Contributing

Contributions are welcome! If you have ideas for improving Health-Nag or adding features beneficial for ADHD management, please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- PyQt5 for providing the GUI framework
- The `keyboard` library for hotkey functionality

## Support

If you encounter any problems, have suggestions, or need assistance adapting Health-Nag to your specific ADHD management needs, please open an issue on the GitHub repository.

---

Stay healthy, stay focused!
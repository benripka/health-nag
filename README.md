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

## Installation (Debian/Ubuntu Linux)

1. Update your package list:
   ```
   sudo apt update
   ```

2. Install the required system packages:
   ```
   sudo apt install python3-pyqt5 python3-pip x11-utils
   ```

3. Clone this repository:
   ```
   git clone https://github.com/benripka/health-nag.git
   cd health-nag
   ```

4. Run the install script to install the presets. This will also run the last reminder in the list (for testing purposes) Rerunning the install script will reset the reminders to those set in reminders.json:
   ```
   cd health-nag
   cat install.sh # Inspect the script first to make sure you trust it
   sudo chmod +x install.sh
   ./install.sh
   ```

## Test your installation

1. Run the script from install location (~/.local/bin/health-nag):

   ```
   ~/.local/bin/health-nag/screen_overlay.py --name "eyes"
   ```
   ```
   ~/.local/bin/health-nag/screen_overlay.py \
     --cron "* 9,12,18 * * *" # Run at 9am, 12pm, and 6pm \
     --command "Have you eaten?" \
     --overrideReason "What I'm doing right now is so important I would rather wither away than stop." \
     --overrideKey "wither me away" \
     --duration 4 \
     --asciiArtPath ./art/food.txt \
     --description "The 20-20-20 rule:
       Every 20 minutes, look up from your screen and focus on an item approximately 20 feet away for at least 20 seconds. 
       This allows your eye muscles to relax after prolonged screen time and helps prevent digital eye strain."
   ```

## Add new reminders to nag yourself about

1. Add an entry to the `reminders.json` file, for example:

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
Where
```
* * * * * command_to_run
- - - - -
| | | | |
| | | | +----- Day of the week (0 - 7) (Sunday = 0 or 7)
| | | +------- Month (1 - 12)
| | +--------- Day of the month (1 - 31)
| +----------- Hour (0 - 23)
+------------- Minute (0 - 59)
```

2. Rerun the install script:
```
./install.sh
```

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
#!/usr/bin/env python3
import logging
import tkinter as tk
import argparse
import json
import os

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

logger.info("Starting health-nag-script")

def load_reminder(name):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    reminders_file = os.path.join(script_dir, 'reminders.json')
    with open(reminders_file, 'r') as f:
        reminders = json.load(f)
    
    for reminder in reminders:
        if reminder['name'] == name:
            return reminder
    
    raise ValueError(f"No reminder found with name '{name}'")

def overlay(reminder):
    def enable_override():
        if override_var.get():
            input_label.pack(pady=20)
            input_field.pack(pady=20)
            submit_button.pack(pady=20)
        else:
            input_label.pack_forget()
            input_field.pack_forget()
            submit_button.pack_forget()

    def submit_override():
        if input_field.get() == reminder['overrideKey']:
            root.destroy()  # Allow the user to dismiss the overlay early
        else:
            error_label.pack(pady=10)

    root = tk.Tk()
    root.title("Reminder")

    # Make the window fullscreen
    root.attributes("-fullscreen", True)
    root.attributes("-topmost", True)  # Ensure it stays on top
    root.configure(bg='#282c34')

    # Main content frame to center the content
    content_frame = tk.Frame(root, bg='#282c34')
    content_frame.place(relx=0.5, rely=0.5, anchor="center")

    # Display ASCII art
    full_art_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), reminder['asciiArtPath'])
    with open(full_art_path, 'r') as f:
        ascii_art_content = f.read()
    
    art_label = tk.Label(content_frame, text=ascii_art_content, fg="#61dafb", bg='#282c34', font=("Courier", 12))
    art_label.pack(pady=40)

    # Main command label
    label = tk.Label(content_frame, text=reminder['command'], fg="#61dafb", bg='#282c34', font=("Helvetica", 46, "bold"))
    label.pack(pady=40)

        # Explanation label for the 20-20-20 rule (optional, this can be removed if not needed)
    explanation_label = tk.Label(content_frame, text=f"""{reminder['description']}""",
                                 fg="white", bg='#282c34', font=("Helvetica", 21), wraplength=1200, justify="center")
    explanation_label.pack(pady=40)

    # Checkbox for override
    override_var = tk.BooleanVar()

    override_checkbox = tk.Checkbutton(content_frame, text=reminder['overrideReason'],
                                       variable=override_var, command=enable_override, bg='#282c34', fg="orange", selectcolor="#282c34", font=("Helvetica", 16), wraplength=1200, justify="center")
    override_checkbox.pack(pady=40)

    input_label = tk.Label(content_frame, text=f"Fine... type: '{reminder['overrideKey']}'", fg="red", bg='#282c34', font=("Helvetica", 12))
    input_label.pack_forget()

    # Input field for the override code (hidden by default)
    input_field = tk.Entry(content_frame, font=("Helvetica", 28))
    input_field.pack_forget()

    # Submit button (hidden by default)
    submit_button = tk.Button(content_frame, text="Submit", command=submit_override, font=("Helvetica", 21), bg="#61dafb", fg="black")
    submit_button.pack_forget()

    # Error label (hidden by default)
    error_label = tk.Label(content_frame, text=f"Incorrect value! Please type: '{reminder['overrideKey']}'")
    error_label.pack_forget()

    # Block all input
    root.bind("<Escape>", lambda e: None)  # Ignore escape
    root.update()

    # Display the overlay for the specified duration unless dismissed by the user
    root.after(reminder['duration'] * 1000, root.destroy)  # Auto-destroy after the specified time
    root.mainloop()


if __name__ == "__main__":
    logger.info(f"Running reminder")
    parser = argparse.ArgumentParser(description='Display a screen overlay with custom messages and override options.')
    
    parser.add_argument('--name', help='The name of the reminder to display (must be defined in reminders.json)')
    parser.add_argument('--command', help='The main command/message to display')
    parser.add_argument('--overrideReason', help='The reason for overriding the overlay')
    parser.add_argument('--overrideKey', help='The key word/phrase to type to override the overlay')
    parser.add_argument('--description', help='An optional description/explanation to display below the main command')
    parser.add_argument('--duration', type=int, help='The duration for the overlay in seconds')
    parser.add_argument('--asciiArtPath', help='Path to the ASCII art file to display at the top of the overlay')

    args = parser.parse_args()

    if args.name:
        reminder = load_reminder(args.name)
    else:
        reminder = {
            'command': args.command,
            'overrideReason': args.overrideReason,
            'overrideKey': args.overrideKey,
            'description': args.description,
            'duration': args.duration,
            'asciiArtPath': args.asciiArtPath
        }
    logger.info(f"Running reminder: {reminder['name']}")
    logger.info(f"$DISPLAY = {os.environ.get('DISPLAY')}")
    logger.info(f"XAUTHORITY = {os.environ.get('XAUTHORITY')}")
    
    overlay(reminder)


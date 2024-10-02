#!/usr/bin/env python3
import logging
import tkinter as tk
import argparse
import json
import os

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

logger.info("Starting health-nag-script")

reminders_file = '/etc/health-nag/reminders.json'
art_dir = '/usr/share/health-nag/'

if not os.path.exists(reminders_file):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    reminders_file = os.path.join(script_dir, 'reminders.json')

if not os.path.exists(art_dir):
    art_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'ascii-art')

def load_reminder(name):
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
    full_art_path = os.path.join(art_dir, reminder['asciiArtPath'])   
    with open(full_art_path, 'r') as f:
        ascii_art_content = f.read()
    
    art_label = tk.Label(content_frame, text=ascii_art_content, fg="#61dafb", bg='#282c34', font=("Courier", 12))
    art_label.pack(pady=40)

    # Main command label
    label = tk.Label(content_frame, text=reminder['command'], fg="#61dafb", bg='#282c34', font=("Courier", 36))
    label.pack(pady=(40, 20))

    # Timer label
    remaining_time = reminder['duration']
    timer_label = tk.Label(content_frame, text="", fg="#61dafb", bg='#282c34', font=("Courier", 36))
    timer_label.pack(pady=(0, 20))

    def update_timer():
        nonlocal remaining_time
        if remaining_time > 0:
            minutes, seconds = divmod(remaining_time, 60)
            timer_label.config(text=f"{minutes:02d}:{seconds:02d}")
            remaining_time -= 1
            root.after(1000, update_timer)
        else:
            root.destroy()

    # Start the timer
    update_timer()

    # Explanation label for the 20-20-20 rule (optional, this can be removed if not needed)
    explanation_label = tk.Label(content_frame, text=f"""{reminder['description']}""",
                                 fg="white", bg='#282c34', font=("Courier", 18), wraplength=1200, justify="center")
    explanation_label.pack(pady=40)

    # Override reason label
    override_reason_label = tk.Label(content_frame, text=reminder['overrideReason'],
                                 fg="orange", bg='#282c34', font=("Courier", 16), wraplength=2000, justify="center")
    override_reason_label.pack(pady=(40, 20))  # Increased bottom padding

    # Override checkbox
    override_frame = tk.Frame(content_frame, bg='#282c34')
    override_frame.pack(pady=(0, 20))  # Added padding below the frame

    override_var = tk.BooleanVar()
    override_checkbox = tk.Checkbutton(override_frame, text="Override",
                                       variable=override_var, command=enable_override, 
                                       bg='black', fg="orange", selectcolor="#282c34", 
                                       activebackground='black', activeforeground="orange",
                                       font=("Courier", 16), bd=0, highlightthickness=0)
    
    override_checkbox.pack(side=tk.RIGHT)

    input_label = tk.Label(content_frame, text=f"Fine... type: '{reminder['overrideKey']}'", fg="red", bg='#282c34', font=("Courier", 12))
    input_label.pack_forget()

    # Input field for the override code (hidden by default)
    input_field = tk.Entry(content_frame, font=("Courier", 28))
    input_field.pack_forget()

    # Submit button (hidden by default)
    submit_button = tk.Button(content_frame, text="Submit", command=submit_override, font=("Courier", 21), bg="#61dafb", fg="black")
    submit_button.pack_forget()

    # Error label (hidden by default)
    error_label = tk.Label(content_frame, text=f"Incorrect value! Please type: '{reminder['overrideKey']}'")
    error_label.pack_forget()

    # Block all input
    root.bind("<Escape>", lambda e: None)  # Ignore escape
    root.update()

    # Remove the auto-destroy after line
    # root.after(reminder['duration'] * 1000, root.destroy)

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
    overlay(reminder)


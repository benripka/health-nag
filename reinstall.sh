#!/bin/bash

# Check if health-nag directory exists before removing
if [ -d "health-nag" ]; then
    echo "Removing existing health-nag directory..."
    rm -rf health-nag
else
    echo "health-nag directory does not exist. Skipping removal."
fi

# Check if health-nag.deb file exists before removing
if [ -f "health-nag.deb" ]; then
    echo "Uninstalling health-nag"
    sudo dpkg -r health-nag
    echo "Removing existing health-nag.deb file..."
    rm health-nag.deb
else
    echo "health-nag.deb file does not exist. Skipping removal."
fi

# Create necessary directories
mkdir -p health-nag/DEBIAN
mkdir -p health-nag/usr/local/bin
mkdir -p health-nag/etc/health-nag
mkdir -p health-nag/usr/share/health-nag
mkdir -p health-nag/var/log

# Copy Python script and assets
cp screen_overlay.py health-nag/usr/local/bin/screen_overlay.py
cp reminders.json health-nag/etc/health-nag/reminders.json
cp -r art/*.txt health-nag/usr/share/health-nag/

# Copy control and postinst from the packaging directory
cp packaging/control health-nag/DEBIAN/control
cp packaging/postinst health-nag/DEBIAN/postinst
chmod +x health-nag/DEBIAN/postinst
dpkg-deb --build health-nag
sudo dpkg -i health-nag.deb
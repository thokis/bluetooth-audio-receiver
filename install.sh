#!/bin/bash

# Set bluetooth name
cp {audio.conf,main.conf} /tmp/
echo "Name=$HOSTNAME" >> /tmp/audio.conf

# Check for required packages and install them if needed
sudo sh dependencies.sh

# Check if pulseaudio is enabled and restart it if needed
if [ ! -e "$HOME/.config/systemd/user/default.target.wants/pulseaudio.service" ]; then
  systemctl --user enable --now pulseaudio; else
  systemctl --user restart pulseaudio
fi

# Replacing modified bluetooth.service, installing modified simple-agent and bluez configs
# root privileges and sudo are required
sudo cp bluetooth.service /etc/systemd/system/
sudo cp bluez-lib /usr/local/sbin/bluetooth-audio-receiver
sudo cp /tmp/{audio.conf,main.conf} /etc/bluetooth/

# Check if bluetooth is enabled and restart it if needed
sudo systemctl daemon-reload
if [ ! -e "/etc/systemd/system/bluetooth.target.wants/bluetooth.service" ]; then
  sudo systemctl enable --now bluetooth; else
  sudo systemctl restart bluetooth
fi

# Check for systemd user directory and create it if not present
if [ ! -d "$HOME/.config/systemd/user" ]; then
  mkdir -p "$HOME/.config/systemd/user"
fi

# Installing simple-agent.service and enable it
cp simple-agent.service ~/.config/systemd/user/
systemctl --user enable --now simple-agent

echo "bluetooth-audio-receiver was installed"
exit 0

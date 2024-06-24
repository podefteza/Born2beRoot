#!/bin/bash

# Calculate minutes since boot
calculate_minutes_since_boot() {
    boot_time=$(who -b | awk '$1 == "system" {print $4 " " $5}')
    boot_epoch=$(date -d "$boot_time" +%s)
    current_epoch=$(date +%s)
    minutes_since_boot=$(( (current_epoch - boot_epoch) / 60 ))
    echo "$minutes_since_boot"
}

# Interval in minutes
interval_minutes=10

# Calculate minutes since boot
minutes_since_boot=$(calculate_minutes_since_boot)

# Check if the current time is a multiple of the interval since boot
if [ $(( minutes_since_boot % interval_minutes )) -eq 0 ]; then
    /usr/local/bin/monitoring.sh
fi

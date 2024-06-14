#!/bin/bash

# Function to calculate minutes since boot
calculate_minutes_since_boot() {
    boot_time=$(who -b | awk '$1 == "system" {print $4 " " $5}')
    boot_epoch=$(date -d "$boot_time" +%s)
    current_epoch=$(date +%s)
    minutes_since_boot=$(( (current_epoch - boot_epoch) / 60 ))
    echo "$minutes_since_boot"
}

# Check if the current time is a multiple of the interval since boot
interval_minutes=10
minutes_since_boot=$(calculate_minutes_since_boot)

if [ $(( minutes_since_boot % interval_minutes )) -eq 0 ]; then
    # Get system information
    arc=$(uname -a)
    pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
    vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
    fram=$(free -m | awk '$1 == "Mem:" {print $2}')
    uram=$(free -m | awk '$1 == "Mem:" {print $3}')
    aram=$(free -m | awk '$1 == "Mem:" {print $7}')
    pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
    fdisk=$(df -BM --total | grep '^total' | awk '{print $2}' | sed 's/M//')
    udisk=$(df -BM --total | grep '^total' | awk '{print $3}' | sed 's/M//')
    adisk=$(df -BM --total | grep '^total' | awk '{print $4}' | sed 's/M//')
    pdisk=$(df -BM --total | grep '^total' | awk '{printf("%.2f"), $3/$2*100}')
    fdisk_gb=$(awk "BEGIN {printf \"%.2f\", $fdisk/1024}")
    udisk_gb=$(awk "BEGIN {printf \"%.2f\", $udisk/1024}")
    adisk_gb=$(awk "BEGIN {printf \"%.2f\", $adisk/1024}")
    cpul=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
    lb=$(who -b | awk '$1 == "system" {print $3 " " $4 " " $5}')
    lb_formatted=$(date -d "$lb" '+%Y-%m-%d %H:%M')
    lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
    ctcp=$(ss -neopt state established | wc -l)
    ulog=$(users | wc -w)
    ip=$(hostname -I | awk '{print $1}')
    mac=$(ip link show | grep "ether" | awk '{print $2}')
    cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

    # Output results using wall
    wall "	#Architecture: $arc
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: $uram/${fram}MB ($pram%) - Available: ${aram}MB
	#Disk Usage: ${udisk_gb}GB/${fdisk_gb}GB ($pdisk%) - Available: ${adisk_gb}GB
	#CPU load: $cpul
	#Last boot: $lb_formatted
	#LVM use: $lvmu
	#Connections TCP: $ctcp ESTABLISHED
	#User log: $ulog
	#Network: IP $ip MAC ($mac)
	#Sudo: $cmds cmd"
else
    echo "Not running monitoring script at $(date)"
fi

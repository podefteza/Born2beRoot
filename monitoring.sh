#!/bin/bash

# Architecture and Kernel version
arc=$(uname -a)

# Number of physical processors
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)

# Number of virtual processors
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)

# Available and used RAM
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
aram=$(free -m | awk '$1 == "Mem:" {print $7}')
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk space calculations in MB
fdisk=$(df -BM --total | grep '^total' | awk '{print $2}' | sed 's/M//')
udisk=$(df -BM --total | grep '^total' | awk '{print $3}' | sed 's/M//')
adisk=$(df -BM --total | grep '^total' | awk '{print $4}' | sed 's/M//')
pdisk=$(df -BM --total | grep '^total' | awk '{printf("%.2f"), $3/$2*100}')

# Convert MB to GB for display with two decimal places using awk
fdisk_gb=$(awk "BEGIN {printf \"%.2f\", $fdisk/1024}")
udisk_gb=$(awk "BEGIN {printf \"%.2f\", $udisk/1024}")
adisk_gb=$(awk "BEGIN {printf \"%.2f\", $adisk/1024}")

# CPU load
cpul=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

# Last reboot
lb=$(who -b | awk '$1 == "system" {print $3 " " $4 " " $5}')
lb_formatted=$(date -d "$lb" '+%Y-%m-%d %H:%M')

# LVM usage
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)

# Active TCP connections
ctcp=$(ss -neopt state established | wc -l)

# Number of users
ulog=$(users | wc -w)

# IPv4 and MAC address
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | grep "ether" | awk '{print $2}')

# Number of sudo commands executed
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Output results
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

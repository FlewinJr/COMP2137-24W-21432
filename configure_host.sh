#!/bin/bash

# Function to handle signals
trap '' TERM HUP INT

# Function to display usage
usage() {
    echo "Usage: $0 [-v] [-name desiredName] [-ip desiredIPAddress] [-hostentry desiredName desiredIPAddress]"
    echo "Options:"
    echo "  -v                   Enable verbose mode"
    echo "  -name desiredName    Set the desired host name"
    echo "  -ip desiredIPAddress Set the desired IP address"
    echo "  -hostentry desiredName desiredIPAddress Set the desired host entry"
    exit 1
}

# Function to log changes
log_changes() {
    local message="$1"
    logger -t configure-host.sh "$message"
}

# Function to configure host name
configure_name() {
    local desired_name="$1"
    local current_name=$(hostname)
    local verbose=false

    # Parse options
    while getopts ":v" opt; do
        case $opt in
            v)
                verbose=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
        esac
    done

    # Set desired name
    if [ "$desired_name" != "$current_name" ]; then
        sudo hostnamectl set-hostname "$desired_name"
        if [ $? -eq 0 ]; then
            if [ "$verbose" = true ]; then
                echo "Host name changed to: $desired_name"
                log_changes "Host name changed to: $desired_name"
            fi
        else
            echo "Error: Failed to set host name" >&2
        fi
    elif [ "$verbose" = true ]; then
        echo "Host name is already set to: $desired_name"
    fi
}

# Function to configure IP address
configure_ip() {
    local desired_ip="$1"
    local current_ip=$(hostname -I | cut -d ' ' -f 1)
    local verbose=false

    # Parse options
    while getopts ":v" opt; do
        case $opt in
            v)
                verbose=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
        esac
    done

    # Set desired IP address
    if [ "$desired_ip" != "$current_ip" ]; then
        sudo sed -i "/^$current_ip/c\address: $desired_ip" /etc/netplan/00-installer-config.yaml
        sudo netplan apply
        if [ $? -eq 0 ]; then
            if [ "$verbose" = true ]; then
                echo "IP address changed to: $desired_ip"
                log_changes "IP address changed to: $desired_ip"
            fi
        else
            echo "Error: Failed to set IP address" >&2
        fi
    elif [ "$verbose" = true ]; then
        echo "IP address is already set to: $desired_ip"
    fi
}

# Function to configure host entry
configure_host_entry() {
    local desired_name="$1"
    local desired_ip="$2"
    local verbose=false

    # Parse options
    while getopts ":v" opt; do
        case $opt in
            v)
                verbose=true
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
        esac
    done

    # Set desired host entry
    if ! grep -q "$desired_name" /etc/hosts; then
        echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts >/dev/null
        if [ $? -eq 0 ]; then
            if [ "$verbose" = true ]; then
                echo "Host entry added: $desired_name $desired_ip"
                log_changes "Host entry added: $desired_name $desired_ip"
            fi
        else
            echo "Error: Failed to add host entry" >&2
        fi
    elif [ "$verbose" = true ]; then
        echo "Host entry already exists: $desired_name $desired_ip"
    fi
}

# Main script
if [ $# -eq 0 ]; then
    usage
fi

# Parse options
while getopts ":v:name:ip:hostentry:" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        name)
            configure_name "$OPTARG" "$@"
            ;;
        ip)
            configure_ip "$OPTARG" "$@"
            ;;
        hostentry)
            configure_host_entry "$OPTARG" "$2"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

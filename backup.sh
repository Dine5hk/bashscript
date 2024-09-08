#!/bin/bash

read -s -p "Enter password for Servers: " server_password
echo  # Move to a new line after password input

# Define common variables
server_user="ubuntu"
server_ips=("10.10.10.10" )

# Log file name based on current date and time
path="/home/ubuntu/backup_$(date +'%Y%m%d_%H%M%S').log"


# Function to execute commands on each server
execute_commands() {
    local server_ip="$1"

    echo "Connecting to $server_ip..." >> "$path"

    # Use a heredoc for readability and proper handling of commands
    sshpass -p "$server_password" ssh -T "$server_user"@"$server_ip" 2>/dev/null << EOF >> "$path"
        sudo -i
        cd /opt
        sh codebkp.sh
        if [ \$? -eq 0 ]; then
            echo 'codebkp.sh ran successfully'
        else
            echo 'codebkp.sh encountered an error'
        fi
        echo "Operations on $server_ip logged in $path" >> "$path"
EOF


    echo  # Add a newline for better readability
}

# Execute commands for each server sequentially
for server_ip in "${server_ips[@]}"; do
    execute_commands "$server_ip"
done

echo "All operations completed. Log file: $path" >> "$path"

# Exit the script with success
exit 0

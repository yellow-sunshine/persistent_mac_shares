# Checks if your dns server is set to an expected IP address and if the IP address of the network interface is in the expected range
# This ensures that the script only runs when the computer is on the correct network and not at another location where it would fail
# To run make sure this file has execute permissions and type: ./persistent_shares.sh on the command line
# Set to a cron job to run every 3 min or 10 min to your liking. 

#Set the DNS Server you expect on the network you want this script to run
DNS1="10.20.0.30"

# Only run if the IP address of the network interface is in the expected range (first 3 octets only)
threeOctets="10.20.0"

# Add your shares you want to be persistent
declare shares=(
        "smb://<user>:<password>@<ip or domain>/<share directory>" 
        "smb://exampleuser:passwordexample@example.com/folder/to/my/share" 
        "smb://yellowsunshine:password123@192.168.0.20/pictures" 
        "smb://jimbob:123password@mywork.com/important work files" 
)

# Don't change anything below this line
# = = = = = = = = = = = = = = = = = = =






# Run ifconfig -l and store the output in an array
ethernets=($(ifconfig -l))
# Check if the IP address of the network interface is in the expected range and DNS is correct
correctNetwork=0
currentDNS1=$(/usr/sbin/scutil --dns | /usr/bin/grep 'nameserver\[[0-9]*\]' | /usr/bin/head -n 1 | /usr/bin/awk '{print $3}')
for n in ${!ethernets[@]}; do
    # echo "checking ${ethernets[$n]}"
    currentIP=$(ifconfig ${ethernets[$n]} | grep "inet " | awk '{print $2}')
    currentThreeOctets=$(echo $currentIP | cut -d "." -f 1-3)
    if [ "$currentDNS1" == "$DNS1" ] && [ "$currentThreeOctets" == "$threeOctets" ]; then
        correctNetwork=1
        # echo "Correct network: ${ethernets[$n]}"
        break
    fi
done

if [ correctNetwork=1 ]; then
    # Get the output of the mount command which will be used later to check if the share is already mounted
    mount_output=$(mount)
    for i in ${!shares[@]}; do
        smb_url=${shares[$i]}
        # Extract the string after the "@" symbol using a regular expression to find the share name
        # Also replace spaces with %20 to make it a valid URL
        extracted_share=$(echo "$smb_url" | sed -E 's/.*@//; s/ /%20/g')
        # Check if the share is already mounted
        if ! echo "$mount_output" | grep -q "$extracted_share"; then
            # Extract the domain name
            domain=$(echo "$smb_url" | sed -E 's/^[^@]+@([^/]+).*$/\1/')
            # Check if the server is online, with a timeout of 1 second
            if /sbin/ping -q -c 1 -W 1 $domain >/dev/null; then
                smb_mount_point="/Volumes/$(basename "$smb_url")"
                window="$(basename "$smb_url")"
                if [ ! -d "$smb_mount_point" ]; then
                    echo "Mounting $window on $smb_mount_point"
                    open -g "$smb_url"
                    sleep 0.3
                    osascript -e 'tell application "Finder" to close window "'"$window"'"' 2>/dev/null
                fi
            fi
        fi
    done
fi

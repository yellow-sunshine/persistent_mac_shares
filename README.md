# persistent_mac_shares
Ensures network drives are mounted when on a given network. First, this script will check if the current DNS server is an expected DNS server. Second, it will check the first three octets of the local IP address. This is an attempt to ensure we are on the corect network and not trying to mount shares that are not accessible because the user is not at home/work. Once the script has determined it is on the correct network it will check if the share is already mounted. If it is not, then it will check if the server holding the share is pingable. If it is, it will attempt to mount each share. 

To use follow these instructions:

1. Open a command prompt and change directories to the location of persistent_shares.sh
    cd /location/of/file
2. Change file permissions to give execute permissions
    sudo chmod +x persistent_shares.sh
3. Edit the text file persistent_shares.sh adding in your DNS server, expected IP range, and your smb url shares
4. Open crontab
    crontab -e
5. Add the following line with your location to the persistent_shares.sh file:
    */3 * * * * /bin/bash /Users/UNSERNAME/location/of/file/persistent_netdrive.sh
    
This will run the every 3 min attempting to mount your shared drive

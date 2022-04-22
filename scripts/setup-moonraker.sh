#!/bin/bash
set -e
COL='\033[1;32m'
NC='\033[0m' # No Color
echo -e "${COL}Setting up Moonraker"

read -p "Do you have \"Klipper\" installed? (y/n): " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${COL}\nPlease go to extensions and install Klipper${NC}"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo -e "${COL}Downloading Moonraker\n${NC}"
curl -o moonraker.zip -L https://github.com/Arksine/moonraker/archive/refs/heads/master.zip

echo -e "${COL}Extracting Moonraker\n${NC}"
unzip moonraker.zip
rm -rf moonraker.zip
mv moonraker-master /moonraker

echo -e "${COL}Installing dependencies...\n${NC}"
# install required dependencies
apk add --no-cache libcurl jpeg-dev libjpeg zlib-dev
apk update
pip3 install -r /moonraker/scripts/moonraker-requirements.txt

mkdir -p /root/extensions/moonraker
cat << EOF > /root/extensions/klipper/manifest.json
{
        "title": "Moonraker plugin",
        "description": "Requires OctoKlipper plugin"
}
EOF

cat << EOF > /root/extensions/moonraker/start.sh
#!/bin/sh
python3 /moonraker/moonraker/moonraker.py /moonraker/docs/moonraker.conf -n
EOF

cat << EOF > /root/extensions/klipper/kill.sh
#!/bin/sh
pkill -f 'moonraker\.py'
EOF
chmod +x /root/extensions/moonraker/start.sh
chmod +x /root/extensions/moonraker/kill.sh
chmod 777 /root/extensions/moonraker/start.sh
chmod 777 /root/extensions/moonraker/kill.sh

echo -e "${COL}\nMoonraker installed! Please kill the app and restart it again to see it in extension settings${NC}"

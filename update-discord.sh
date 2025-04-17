#!/bin/bash
set -e -o pipefail

# $home_directory  - will be supplied by install.sh
search_directory="$home_directory/.config/discord"
# Regular expression for version number (e.g., 1.2.3)
version_regex='[0-9]+\.[0-9]+\.[0-9]+'

# Find the current installed version directory
local_version=$(basename $(find "$search_directory" -type d -regextype posix-extended -regex ".*/$version_regex" | sort -Vr | head -n 1))
echo "Current installed version: $local_version"

# URL for the GET request
url="https://discord.com/api/download?platform=linux&format=deb"
# Perform the GET request and capture headers without following redirect
headers=$(curl -s -D - -o /dev/null "$url")
# Extract the Location header, trimming newlines or whitespace
location=$(echo "$headers" | grep -i "Location:" | cut -d " " -f 2 | tr -d '\r\n')
latest_version=$(echo "$location" | xargs basename)
latest_version=${latest_version%.deb}
latest_version=${latest_version//discord-}
echo "Latest version: $latest_version"

if [[ "$latest_version" == "$local_version" ]]; then
    echo "Discord already at latest version."
else
    echo "New Discord version available: $latest_version, downloading from: $location..."
    download_path="/tmp/$(basename $location)"
    curl -o "$download_path" "$location"
    sudo dpkg -i $download_path
    rm $download_path
fi

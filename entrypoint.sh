#!/bin/bash

gamefolder="/usr/lib/games/reactivedrop"
steamcmd="nice -n 19 ionice -c3 steamcmd"

function title() {
  echo ""
  echo $* | boxes -d stone
}


title "updating steamcmd.."
$steamcmd +quit

title "updating game, this might take a while.."
$steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir reactivedrop +login anonymous +app_update 563560 +app_update 1007 +quit
mkdir -p /root/.steamcmd


# .ain and .bsp files need to be in sync, someone decided to use timestamps for that, instead of hashes..
# reset dates on all files to the same as srcds.exe
title "fixing timestamps.."
touch -r "${gamefolder}/srcds.exe" -c \
    $(find "${gamefolder}/reactivedrop/maps" -type f -name '*.bsp' -or -name '*.ain')

cd $gamefolder || exit 1

title "creating links.."

# steam proton is searching for ~/.steam/sdk32 for some steam libs
# these libs are installed in /usr/lib/games by the steamcmd debian package
ln -sf /usr/lib/games/linux32 /root/.steam/sdk32

# the game is somehow searching for steam_appid.txt outside its folder
# /opt is a folder is searches, so we just put it there to fix the workshop
# and steam connectivity
ln -sf "${gamefolder}/steam_appid.txt" /opt/steam_appid.txt

title "writing settings.."

# copy defaults settings to the game folder
cp /usr/local/settings.cfg "${gamefolder}/reactivedrop/cfg/autoexec.cfg"

# and store user setting too
set | grep '^rd_' | cut -d '_' -f 2- | tr '=' ' ' | tr -d "'" > "${gamefolder}/reactivedrop/cfg/user.cfg"

title "starting game.."
screen -S game -dm wine srcds_console.exe -console -game reactivedrop \
  -port "${port:-27005}" \
  -maxplayers "${maxplayers}" \
  +rcon_password swarmtest \
  +map lobby

sleep 5
echo "server started at port ${port:-27005}"

while true; do
  sleep 5
  pid=$(pgrep -f srcds_console)
  if [[ "$pid" == "" ]]; then
    echo "game exited."
    exit 10
  fi
done
#!/bin/bash

function title() {
  echo ""
  echo $* | boxes -d stone
}

title "updating steamcmd.."
steamcmd +quit

title "updating game, this might take a while.."
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir reactivedrop +login anonymous +app_update 563560 +app_update 1007 +quit
mkdir -p /root/.steamcmd

title "creating links.."

# steam proton is searching for ~/.steam/sdk32 for some steam libs
# these libs are installed in /usr/lib/games by the steamcmd debian package
ln -sf /usr/lib/games/linux32 /root/.steam/sdk32

# the game is somehow searching for steam_appid.txt outside its folder
# /opt is a folder is searches, so we just put it there to fix the workshop
# and steam connectivity
ln -sf /usr/lib/games/reactivedrop/steam_appid.txt /opt/steam_appid.txt

title "writing settings.."

# copy defaults settings to the game folder
cp /usr/local/settings.cfg /usr/lib/games/reactivedrop/reactivedrop/cfg/autoexec.cfg

# and store user setting too
set | grep '^rd_' | cut -d '_' -f 2- | tr '=' ' ' | tr -d "'" > /usr/lib/games/reactivedrop/reactivedrop/cfg/user.cfg

title "starting game.."
cd /usr/lib/games/reactivedrop || exit 1
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
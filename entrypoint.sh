#!/bin/bash

gamefolder="/usr/lib/games/reactivedrop"
steamcmd="nice -n 19 ionice -c3 steamcmd"

function title() {
  echo ""
  echo $* | boxes -d stone
}

title "checking for steamcmd updates.."
$steamcmd +quit

title "checking for game updates, this might take a while.."
$steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir reactivedrop +login anonymous +app_update 563560 +app_update 1007 +quit
mkdir -p /root/.steamcmd

# .ain and .bsp files need to be in sync, someone decided to use timestamps for that, instead of hashes..
# reset dates on all files to the same as srcds.exe
title "fixing timestamps.."
touch -r "${gamefolder}/srcds.exe" -c \
  $(find "${gamefolder}/reactivedrop/maps" -type f -name '*.bsp' -or -name '*.ain')

cd $gamefolder || exit 1

title "setting up game.."
echo "creating links.."

# steam proton is searching for ~/.steam/sdk32 for some steam libs
# these libs are installed in /usr/lib/games by the steamcmd debian package
mkdir -p /root/.steam
ln -sf /usr/lib/games/linux32 /root/.steam/sdk32

# symlink steam.dll as well, the game requires (but not ships it)
ln -sf /usr/lib/games/steam.dll "${gamefolder}/steam.dll"
ln -sf /usr/lib/games/steam.dll "${gamefolder}/reactivedrop/steam.dll"

# the game is somehow searching for steam_appid.txt outside its folder
# /opt is a folder is searches, so we just put it there to fix the workshop
# and steam connectivity
ln -sf "${gamefolder}/steam_appid.txt" /opt/steam_appid.txt

echo "writing settings.."

# copy defaults settings to the game folder
cp /usr/local/settings.cfg "${gamefolder}/reactivedrop/cfg/autoexec.cfg"

# touch an empty workshop.cfg, since some users misinterprete the missing file message
touch "${gamefolder}/reactivedrop/cfg/workshop.cfg"

# and store user setting too
set | grep '^rd_' | cut -d '_' -f 2- | tr '=' ' ' | tr -d "'" >"${gamefolder}/reactivedrop/cfg/user.cfg"

echo "starting game.."
truncate -s0 reactivedrop/console.log
screen -L -S game -dm wine srcds_console.exe -console -condebug -conclearlog -game reactivedrop \
  -port "${port:-27005}" \
  -maxplayers "${maxplayers}" \
  -noassert -nomessagebox \
  +map lobby

title "server started at port ${port:-27005}"
tail -n 100 -F reactivedrop/console.log &

while true; do
  sleep 5
  pid=$(pgrep -f srcds_console)
  if [[ "$pid" == "" ]]; then
    echo "game exited."
    exit 10
  fi
done

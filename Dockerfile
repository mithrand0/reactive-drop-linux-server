FROM ghcr.io/mithrand0/linux-proton-steam:latest

# folders
ENV STEAMFOLDER="/opt/steamcmd"
ENV ADDONSFOLDER="/opt/template"

# copy init script
COPY entrypoint.sh /
COPY settings.cfg /usr/local/

# target
ENV WINEARCH=win64
ENV WINEDEBUG=-all

# workdir
VOLUME /usr/lib/games/reactivedrop

# working directory
WORKDIR /usr/lib/games/reactivedrop

# entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
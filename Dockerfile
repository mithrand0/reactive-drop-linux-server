FROM debian:bookworm-slim

# ============================[ SETUP ] =======================
ENV DEBIAN_FRONTEND="noninteractive"

# working directory
WORKDIR /opt

# ============================[ SYSTEM ] ===========================
RUN --mount=type=cache,target=/var/lib/apt apt -qq update \
  && apt -y install --no-install-recommends wget ca-certificates

RUN wget -qO- https://reactivedrop.com/dist/proton_dist.tar.gz | tar xvz -C /opt

# i386
RUN dpkg --add-architecture i386

# steam
RUN sed -i'' 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections
RUN apt update && apt -y install steamcmd

# wine packages
RUN --mount=type=cache,target=/var/lib/apt apt -qq update \
  && apt -y install --no-install-recommends \
   libc6-i386 lib32gcc-s1 libnss-resolve:i386 \
   libfreetype6:i386 libfontconfig1:i386 libnss-resolve:i386 \
   libfreetype6 libxft2

# other packages
RUN --mount=type=cache,target=/var/lib/apt apt -qq update \
  && apt -y install --no-install-recommends \
    locales less procps vim-tiny boxes screen

# expand paths to what proton is using
ENV LD_LIBRARY_PATH="/usr/lib/games/steam:/usr/lib/games/linux32"
ENV PATH="/usr/lib/games/steam:/usr/lib/games/linux32:/opt/bin:$PATH"

# update once
RUN steamcmd || true

# locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# ============================[ SETUP ] =======================
ENV DEBIAN_FRONTEND="noninteractive"
ENV STEAMFOLDER="/opt/steamcmd"
ENV ADDONSFOLDER="/opt/template"

# copy init script
COPY entrypoint.sh /
COPY settings.cfg /usr/local/

# target
ENV WINEARCH=win64
ENV WINEDEBUG=-all

# enable winesync
ENV WINEESYNC=1
ENV WINEFSYNC=1

# workdir
VOLUME /usr/lib/games/reactivedrop

# working directory
WORKDIR /usr/lib/games/reactivedrop

# entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
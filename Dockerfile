FROM debian:bookworm-slim AS proton

# ============================[ SETUP ] =======================
ENV DEBIAN_FRONTEND="noninteractive"
ENV PROTON="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-22/GE-Proton9-22.tar.gz"

# working directory
WORKDIR /opt

# ============================[ SYSTEM ] ===========================
RUN --mount=type=cache,target=/var/lib/apt apt -qq update \
  && apt -y install --no-install-recommends wget ca-certificates

RUN wget -qO- "${PROTON}" | tar xvz -C /opt

# i386
RUN dpkg --add-architecture i386

# steam
RUN sed -i'' 's/main/main contrib non-free/g' /etc/apt/sources.list.d/debian.sources
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

# link proton
RUN mkdir -p /opt/bin && find /opt -type f -name 'wine' -exec ln -sf {} /opt/bin/ \;

# locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen




# FROM mithrand0/linux-proton-steam:latest
FROM proton

RUN apt update; apt -y install psmisc strace htop

# folders
ENV STEAMFOLDER="/opt/steamcmd"
ENV ADDONSFOLDER="/opt/template"

# copy init script
COPY entrypoint.sh /
COPY settings.cfg /usr/local/
COPY steam.dll /usr/lib/games

# target
ENV WINEARCH=win64
ENV WINEDEBUG=-all

# workdir
VOLUME /usr/lib/games/reactivedrop

# working directory
WORKDIR /usr/lib/games/reactivedrop

# entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

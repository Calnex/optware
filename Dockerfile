FROM alpine:3 AS filemaker
## required as debain image does not allow echoing directly to files
WORKDIR /app

RUN echo "deb http://archive.debian.org/debian/ stretch main" > /app/sources.list
RUN echo "deb-src http://archive.debian.org/debian/ stretch main" >> /app/sources.list
RUN echo "deb http://archive.debian.org/debian-security/ stretch/updates main" >> /app/sources.list
RUN echo "deb-src http://archive.debian.org/debian-security/ stretch/updates main" >> /app/sources.list

FROM debian:stretch-20220622

# use archive mirrors
COPY --from=filemaker /app/sources.list /etc/apt/sources.list

RUN apt-get update && \
	apt-get install -y wget build-essential libtool live-build libtool-bin gettext squashfs-tools \
	linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison flex gnupg \
	libncurses-dev

RUN apt-get install -y git gpg  libffi-dev automake  nunit
# openjdk-11-jre libffi7

RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install -y fuseiso genisoimage xorriso

## postgres -todo-

RUN apt-get install -y python2.7

RUN curl -sL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 5.0.4xx --install-dir /usr/share/dotnet --skip-non-versioned-files

RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet


RUN apt-get install -y sudo procps

## dev tools
RUN apt-get install -y vim

# downgrade user and allow sudo
ARG USER=calnex-user
RUN useradd -M -s /bin/bash $USER
RUN usermod -aG sudo $USER
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

USER $USER



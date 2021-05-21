FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install --fix-missing \
  build-essential \
  bzip2 \
  ccache \
  clang-format \
  cmake \
  curl \
  gdb \
  gdbserver \
  git \
  locales \
  python \
  python3-pip \
  shellcheck \
  ssh \
  sudo \
  tar \
  valgrind \
  vim \
  && apt-get autoremove -y && apt-get clean

# fix "Missing privilege separation directory":
# https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
RUN mkdir /run/sshd

RUN locale-gen en_US.utf8 en_GB.utf8 de_DE.utf8 && update-locale

RUN groupadd -g 1000 dev && \
  useradd -m -u 1000 -g 1000 -d /home/dev -s /bin/bash dev && \
  usermod -a -G adm,cdrom,sudo,dip,plugdev dev && \
  echo 'dev:dev' | chpasswd && \
  echo "dev   ALL=(ALL:ALL) ALL" >> /etc/sudoers

COPY ccache.conf /etc/.

USER dev
WORKDIR /home/dev

RUN sed -i 's/\\h/docker/;s/01;32m/01;33m/' /home/dev/.bashrc

RUN mkdir /home/dev/git

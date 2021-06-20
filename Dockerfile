FROM ubuntu:20.04 as cpp_ci_image

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
  python-is-python3 \
  python3 \
  python3-pip \
  shellcheck \
  ssh \
  sudo \
  tar \
  valgrind \
  vim \
  && apt-get autoremove -y && apt-get clean \
  && pip install conan

# fix "Missing privilege separation directory":
# https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
RUN mkdir /run/sshd


FROM cpp_ci_image as cpp_dev_image

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

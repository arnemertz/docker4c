FROM ubuntu:20.04 as cpp_ci_image

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install --fix-missing \
  build-essential \
  bzip2 \
  ccache \
  clang-format \
  cmake \
  cppcheck \
  curl \
  doxygen \
  git \
  graphviz \
  lsb-release \
  python3 \
  python3-pip \
  shellcheck \
  software-properties-common \
  ssh \
  sudo \
  tar \
  wget \
  && apt-get autoremove -y && apt-get clean \
  && pip install conan \
  && bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"


# fix "Missing privilege separation directory":
# https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
RUN mkdir /run/sshd


FROM cpp_ci_image as cpp_dev_image

RUN apt-get -y install --fix-missing \
  cmake-curses-gui \
  gdb \
  gdbserver \
  python-is-python3 \
  valgrind \
  vim \
  && apt-get autoremove -y && apt-get clean

RUN groupadd -g 1000 dev && \
  useradd -m -u 1000 -g 1000 -d /home/dev -s /bin/bash dev && \
  usermod -a -G adm,cdrom,sudo,dip,plugdev dev && \
  echo 'dev:dev' | chpasswd && \
  echo "dev   ALL=(ALL:ALL) ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev

RUN sed -i 's/\\h/docker/;s/01;32m/01;33m/' /home/dev/.bashrc \
  && mkdir -p /home/dev/git

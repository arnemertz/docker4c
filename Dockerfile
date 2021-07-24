#######################################
# CI image:
#   the one used by your CI server
#######################################
FROM ubuntu:20.04 as cpp_ci_image

ARG DEBIAN_FRONTEND=noninteractive
ARG CLANG_VERSION=12

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --fix-missing \
  build-essential \
  bzip2 \
  ccache \
  cmake \
  cppcheck \
  curl \
  doxygen \
  gcovr \
  git \
  graphviz \
  linux-tools-generic \
  lsb-release \
  ninja-build \
  python3 \
  python3-pip \
  shellcheck \
  software-properties-common \
  ssh \
  sudo \
  tar \
  unzip \
  valgrind \
  wget
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh ${CLANG_VERSION}
RUN apt-get -y install clang-format-${CLANG_VERSION} clang-tidy-${CLANG_VERSION} libclang-${CLANG_VERSION}-dev
RUN pip install conan
RUN apt-get autoremove -y && apt-get clean
RUN for c in $(ls /usr/bin/clang*-${CLANG_VERSION}); do link=$(echo $c | sed "s/-${CLANG_VERSION}//"); ln -sf $c $link; done
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 1000
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 1000
RUN pip install behave

# fix "Missing privilege separation directory":
# https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
RUN mkdir /run/sshd

# build include-what-you-use in the version that matches CLANG_VERSION (iwyu branch name)
WORKDIR /var/tmp/build_iwyu
RUN curl -sSL https://github.com/include-what-you-use/include-what-you-use/archive/refs/heads/clang_${CLANG_VERSION}.zip -o temp.zip
RUN unzip temp.zip && rm temp.zip && mv include-what-you-use-clang_${CLANG_VERSION}/* . && rm -r include-what-you-use-clang_${CLANG_VERSION}
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -Bcmake-build
RUN cmake --build cmake-build --target install -- -j ${NCPU}
RUN ldconfig

WORKDIR /
RUN rm -rf /var/tmp/build_iwyu


#######################################
# DEV image:
#   the one you run locally
#######################################
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

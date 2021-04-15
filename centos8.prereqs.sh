#!/bin/bash

function pkgs_install() {
    declare -a PKGS
    PKGS=( annobin-annocheck
    bash-completion
    binutils
    ctags
    dnf-plugins-core
    elfutils
    gcc
    gcc-c++
    gcc-toolset-10-{build,binutils,strace,elfutils-libs,gcc}
    glibc-common.x86_64
    libstdc++-devel.x86_64
    make
    man-pages
    mlocate
    pcre2-tools
    readline-devel
    sudo
    tcl-devel
    valgrind
    vim
    wget
    yum-utils
    )

    dnf install -y "${PKGS[@]}"
}

dnf install -y dnf-plugins-core
dnf config-manager --set-enabled powertools

pkgs_install


#scl enable gcc-toolset-10  bash


#!/bin/sh

set -euo pipefail

function runCmake() {
  cmake ..
}

function main() {
  if [[ ! -d build ]]; then
    mkdir build
  fi

  echo $a

  cd build
  cmake ../
  make
}

main


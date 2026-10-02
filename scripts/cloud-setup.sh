#!/bin/bash
# Setup script for Claude Code cloud environments (Ubuntu 24.04, x86_64).
# Paste into: cloud environment menu -> Edit -> Setup script.
#
# Installs the system packages MOOSE needs and unpacks the prebuilt MOOSE
# toolchain (PETSc, libMesh, WASP, framework + modules) from the
# `moose-prebuilt` branch into /home/user/moose. Runs in a few minutes, so
# the environment cache keeps the result for later sessions.
#
# Afterwards: cd /home/user/Babbler && make -j4 && python3.12 ./run_tests -j4
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
# Some preconfigured PPAs are not reachable; ignore their index errors.
apt-get update -qq || true
apt-get install -y -qq \
  gfortran mpich libmpich-dev libhdf5-mpich-dev libtirpc-dev \
  libblas-dev liblapack-dev zlib1g-dev flex libtool zstd

MOOSE_DIR=/home/user/moose
if [ ! -f "$MOOSE_DIR/framework/libmoose-opt.la" ]; then
  base=https://raw.githubusercontent.com/ayush4424/Babbler/moose-prebuilt
  parts="00 01 02 03"
  tmp=$(mktemp -d)
  pids=()
  for p in $parts; do
    curl -fsSL --retry 3 -o "$tmp/part$p" "$base/moose-prebuilt.tar.zst.part$p" &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid"; done
  curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"
  cat "$tmp"/part* > "$tmp/moose-prebuilt.tar.zst"
  (cd "$tmp" && sha256sum -c SHA256SUMS)
  mkdir -p "$(dirname "$MOOSE_DIR")"
  tar -I zstd -xf "$tmp/moose-prebuilt.tar.zst" -C "$(dirname "$MOOSE_DIR")"
  rm -rf "$tmp"
fi

echo "MOOSE toolchain ready at $MOOSE_DIR"

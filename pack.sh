#!/bin/sh
# Pack a flashable zip: ./pack.sh <path/to/Image or Image.gz> [output.zip]
# The kernel is shipped as Image.gz (the stock boot format) and the zip is built
# fresh from an explicit file list, so old zips or stray files never end up inside.
set -eu

[ $# -ge 1 ] || { echo "usage: $0 <Image|Image.gz> [output.zip]" >&2; exit 1; }
ak3=$(cd "$(dirname "$0")" && pwd)
kernel=$1
out=${2:-A137F-ReSukiSU-$(date +%Y%m%d-%H%M).zip}
case $out in /*) ;; *) out=$PWD/$out;; esac

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

if [ "$(od -An -tx1 -N2 "$kernel" | tr -d ' \n')" = 1f8b ]; then
  cp "$kernel" "$stage/Image.gz"
else
  gzip -9 -n -c "$kernel" > "$stage/Image.gz"
fi
# arm64 Image header carries the magic "ARMd" at offset 0x38
if [ "$(gzip -dc "$stage/Image.gz" 2>/dev/null | head -c 64 | tail -c 8 | head -c 4 | tr -d '\000')" != ARMd ]; then
  echo "$kernel is not an arm64 kernel Image" >&2
  exit 1
fi

cd "$ak3"
cp -R anykernel.sh version LICENSE META-INF tools "$stage/"
rm -f "$out"
(cd "$stage" && zip -qr9 "$out" .)
echo "$out"

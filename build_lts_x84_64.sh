#!/bin/sh

set -e

INDEX=$(curl -s https://nodejs.org/dist/index.json)

LTS=$(echo $INDEX | jq -r 'map(select(.lts))[0].version')

NODE_VERSION="${LTS/v/}"

echo Current LTS: $NODE_VERSION

mkdir -p out

QEMU_ARCH="x86_64"
if [ -f "out/node-v$NODE_VERSION-linux-$QEMU_ARCH-alpine.tar.gz" ]; then
    echo "node-v$NODE_VERSION-linux-$QEMU_ARCH-alpine already compiled"
else
    BASE_IMAGE='library/alpine'
    echo "Building node $NODE_VERSION for $QEMU_ARCH using $BASE_IMAGE" \
    && docker build --build-arg BASE_IMAGE=$BASE_IMAGE --build-arg QEMU_ARCH=$QEMU_ARCH -t node-$QEMU_ARCH . \
    && docker run --rm -e NODE_VERSION=$NODE_VERSION -v $(pwd)/out:/out node-$QEMU_ARCH
fi

./release.sh "$LTS" "$LTS - LTS"

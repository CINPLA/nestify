cd /app/ || exit 1
echo "$SNAP_TOKEN" | snapcraft login --with - || exit 1
snapcraft || exit 1
snapcraft push *.snap --release edge || exit 1


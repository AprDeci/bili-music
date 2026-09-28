#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-local}"
APP_NAME="bili-music"
BINARY_NAME="bilimusic"
ARCH="x86_64"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPDIR="${ROOT_DIR}/build/appimage/AppDir"
TOOLS_DIR="${ROOT_DIR}/build/appimage/tools"
ARTIFACTS_DIR="${ROOT_DIR}/build/artifacts"
OUTPUT_NAME="${APP_NAME}-${VERSION}-linux-${ARCH}.AppImage"
LINUXDEPLOY="${TOOLS_DIR}/linuxdeploy-${ARCH}.AppImage"

cd "${ROOT_DIR}"

flutter build linux --release

rm -rf "${APPDIR}"
mkdir -p "${APPDIR}/usr/bin"
mkdir -p "${APPDIR}/usr/share/icons/hicolor/256x256/apps"
mkdir -p "${TOOLS_DIR}"
mkdir -p "${ARTIFACTS_DIR}"

cp -R build/linux/x64/release/bundle/. "${APPDIR}/usr/bin/"
if command -v magick >/dev/null 2>&1; then
  magick assets/icons/icon2.png -resize 512x512 "${APPDIR}/bilimusic.png"
  magick assets/icons/icon2.png -resize 256x256 "${APPDIR}/usr/share/icons/hicolor/256x256/apps/bilimusic.png"
else
  convert assets/icons/icon2.png -resize 512x512 "${APPDIR}/bilimusic.png"
  convert assets/icons/icon2.png -resize 256x256 "${APPDIR}/usr/share/icons/hicolor/256x256/apps/bilimusic.png"
fi
cp scripts/linux/bilimusic.desktop "${APPDIR}/bilimusic.desktop"

cat > "${APPDIR}/AppRun" <<'EOF'
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/bilimusic" "$@"
EOF
chmod +x "${APPDIR}/AppRun"

if [ ! -f "${LINUXDEPLOY}" ]; then
  curl -L \
    "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${ARCH}.AppImage" \
    -o "${LINUXDEPLOY}"
  chmod +x "${LINUXDEPLOY}"
fi

# 排除宿主机的 GTK/GLib 栈
EXCLUDE_LIBRARIES=(
  'libgtk-3.so*'
  'libgdk-3.so*'
  'libgdk_pixbuf-2.0.so*'
  'libglib-2.0.so*'
  'libgio-2.0.so*'
  'libgobject-2.0.so*'
  'libgmodule-2.0.so*'
  'libgthread-2.0.so*'
  'libpango-1.0.so*'
  'libpangocairo-1.0.so*'
  'libpangoft2-1.0.so*'
  'libatk-1.0.so*'
  'libatk-bridge-2.0.so*'
  'libatspi.so*'
  'libcairo.so*'
  'libcairo-gobject.so*'
  'libepoxy.so*'
)
EXCLUDE_ARGS=()
for library in "${EXCLUDE_LIBRARIES[@]}"; do
  EXCLUDE_ARGS+=(--exclude-library "${library}")
done

export OUTPUT="${ARTIFACTS_DIR}/${OUTPUT_NAME}"

"${LINUXDEPLOY}" \
  --appdir "${APPDIR}" \
  --desktop-file "${APPDIR}/bilimusic.desktop" \
  --icon-file "${APPDIR}/bilimusic.png" \
  "${EXCLUDE_ARGS[@]}" \
  --output appimage

# 确保被排除的库没有被打进包
echo "Checking excluded libraries..."
for library in "${EXCLUDE_LIBRARIES[@]}"; do
  pattern="${library%\*}"
  if find "${APPDIR}/usr/lib" -name "${pattern}*" 2>/dev/null | grep -q .; then
    echo "ERROR: excluded library still present in AppDir: ${library}" >&2
    find "${APPDIR}/usr/lib" -name "${pattern}*" >&2
    exit 1
  fi
done
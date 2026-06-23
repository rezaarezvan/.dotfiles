#!/usr/bin/env bash
set -euo pipefail

SIOYEK_REPOSITORY="${SIOYEK_REPOSITORY:-https://github.com/ahrm/sioyek.git}"
SIOYEK_REF="${SIOYEK_REF:-development}"
QT_VERSION="${QT_VERSION:-6.8.2}"
STATE_DIR="${SIOYEK_STATE_DIR:-$HOME/.local/share/sioyek-build}"
SOURCE_DIR="${SIOYEK_SOURCE_DIR:-$HOME/.cache/sioyek-src}"
QT_DIR="$STATE_DIR/qt"
VENV_DIR="$STATE_DIR/venv"
APP_DIR="${SIOYEK_APP_DIR:-/Applications}"
APP_PATH="$APP_DIR/sioyek.app"
CLI_DIR="${SIOYEK_CLI_DIR:-$HOME/bin}"
CLI_PATH="$CLI_DIR/sioyek"

log() {
    printf '\n==> %s\n' "$*"
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

backup_databases() {
    local timestamp backup_dir database_dir database label found
    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup_dir="$STATE_DIR/backups/$timestamp"
    found=0

    for database_dir in "$HOME/Library/Application Support/sioyek" "$HOME/.local/share/sioyek"; do
        if [[ "$database_dir" == "$HOME/Library/Application Support/sioyek" ]]; then
            label="macos"
        else
            label="xdg"
        fi
        for database in local.db shared.db; do
            if [[ -f "$database_dir/$database" ]]; then
                mkdir -p "$backup_dir"
                cp -p "$database_dir/$database" \
                    "$backup_dir/$label-$database"
                found=1
            fi
        done
    done

    if [[ "$found" -eq 1 ]]; then
        log "Backed up Sioyek databases to $backup_dir"
    else
        log "No existing Sioyek databases found"
    fi
}

install_app() {
    local built_app="$SOURCE_DIR/build/sioyek.app"
    [[ -d "$built_app" ]] || die "build completed without producing $built_app"

    mkdir -p "$CLI_DIR"

    if [[ -w "$APP_DIR" ]]; then
        rm -rf "$APP_PATH"
        ditto "$built_app" "$APP_PATH"
    else
        sudo rm -rf "$APP_PATH"
        sudo ditto "$built_app" "$APP_PATH"
    fi

    xattr -cr "$APP_PATH"
    codesign --force --deep --sign - "$APP_PATH"
    ln -sfn "$APP_PATH/Contents/MacOS/sioyek" "$CLI_PATH"
}

[[ "$(uname -s)" == "Darwin" ]] || die "this installer only supports macOS"
[[ "$(uname -m)" == "arm64" ]] || die "this installer is intended for Apple Silicon"

require_command brew
require_command git
require_command python3
require_command xcode-select
require_command codesign
require_command ditto
require_command xattr

if ! xcode-select -p >/dev/null 2>&1; then
    die "Xcode Command Line Tools are missing; run: xcode-select --install"
fi

log "Installing build prerequisites"
if ! brew list --versions pkgconf >/dev/null 2>&1; then
    brew install pkg-config
fi

mkdir -p "$STATE_DIR"
if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    python3 -m venv "$VENV_DIR"
fi
if [[ ! -x "$VENV_DIR/bin/aqt" ]]; then
    "$VENV_DIR/bin/python" -m pip install --upgrade pip aqtinstall
fi

if [[ ! -x "$QT_DIR/$QT_VERSION/macos/bin/qmake" ]]; then
    log "Installing Qt $QT_VERSION for macOS"
    mkdir -p "$QT_DIR"
    (
        cd "$STATE_DIR"
        "$VENV_DIR/bin/aqt" install-qt mac desktop "$QT_VERSION" clang_64 \
            --outputdir "$QT_DIR" -m all
    )
fi

qt_yield_header="$QT_DIR/$QT_VERSION/macos/lib/QtCore.framework/Headers/qyieldcpu.h"
if [[ -f "$qt_yield_header" ]] && ! grep -q 'include <arm_acle.h>' "$qt_yield_header"; then
    log "Applying Qt ARM compatibility fix for the current macOS SDK"
    sed -i '' '/#include <QtCore\/qtconfigmacros.h>/a\
#if defined(__arm64__)\
#  include <arm_acle.h>\
#endif' "$qt_yield_header"
fi

removed_agl=0
while IFS= read -r -d '' qt_metadata; do
    if grep -q -- '-framework AGL' "$qt_metadata"; then
        sed -i '' \
            -e 's/-framework AGL //g' \
            -e 's/ -framework AGL//g' \
            -e 's/;-framework AGL//g' \
            "$qt_metadata"
        removed_agl=1
    fi
done < <(
    find "$QT_DIR/$QT_VERSION/macos" -type f \
        \( -name '*.conf' -o -name '*.pri' -o -name '*.prl' \) -print0
)
if [[ "$removed_agl" -eq 1 ]]; then
    log "Removed obsolete AGL linkage from Qt metadata"
fi

log "Refreshing Sioyek source"
if [[ -d "$SOURCE_DIR/.git" ]]; then
    git -C "$SOURCE_DIR" restore pdf_viewer_build_config.pro
    if [[ -n "$(git -C "$SOURCE_DIR" status --porcelain --untracked-files=no)" ]]; then
        die "refusing to overwrite local changes in $SOURCE_DIR"
    fi
    git -C "$SOURCE_DIR" fetch --prune origin
else
    rm -rf "$SOURCE_DIR"
    git clone --recursive "$SIOYEK_REPOSITORY" "$SOURCE_DIR"
fi
git -C "$SOURCE_DIR" checkout "$SIOYEK_REF"
git -C "$SOURCE_DIR" pull --ff-only origin "$SIOYEK_REF"
git -C "$SOURCE_DIR" submodule sync --recursive
git -C "$SOURCE_DIR" submodule update --init --recursive

backup_databases

log "Building native Sioyek from $(git -C "$SOURCE_DIR" rev-parse --short HEAD)"
export Qt6_DIR="$QT_DIR/$QT_VERSION/macos"
export QT_PLUGIN_PATH="$Qt6_DIR/plugins"
export PKG_CONFIG_PATH="$Qt6_DIR/lib/pkgconfig"
export QML2_IMPORT_PATH="$Qt6_DIR/qml"
export PATH="$Qt6_DIR/bin:$PATH"

jobs="$(sysctl -n hw.logicalcpu)"

# An interrupted or incompatible Make invocation can leave valid-looking but
# empty archives behind. MuPDF then skips archiving and fails much later while
# linking. Remove only those known-empty outputs before resuming the build.
for archive in \
    "$SOURCE_DIR/mupdf/build/release/libmupdf.a" \
    "$SOURCE_DIR/mupdf/build/release/libmupdf-third.a" \
    "$SOURCE_DIR/mupdf/build/release/libmupdf-pkcs7.a" \
    "$SOURCE_DIR/mupdf/build/release/libmupdf-threads.a"; do
    if [[ -f "$archive" ]] && [[ "$(stat -f %z "$archive")" -lt 1024 ]]; then
        rm "$archive"
    fi
done

(
    cd "$SOURCE_DIR"
    MAKE_PARALLEL="$jobs" ./build_mac.sh
)

log "Installing $APP_PATH"
install_app

log "Verifying native installation"
binary_arch="$(file "$APP_PATH/Contents/MacOS/sioyek")"
printf '%s\n' "$binary_arch"
[[ "$binary_arch" == *"arm64"* ]] || die "installed executable is not arm64"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

printf '\nInstalled Sioyek successfully.\n'
printf 'App: %s\n' "$APP_PATH"
printf 'CLI: %s\n' "$CLI_PATH"
printf 'Source commit: %s\n' "$(git -C "$SOURCE_DIR" rev-parse HEAD)"

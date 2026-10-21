#!/bin/sh
# Build LiteRT (TensorFlow Lite) in place for native development builds of C++ applications.
# The Makefile links against the resulting build tree; nothing is installed.
# LITERT_BUILD must match the Makefile's LITERT_BUILD (default $HOME/LiteRT/cmake_build).
set -eu

LITERT_URL=https://github.com/ShotSpotter/LiteRT.git
LITERT_BRANCH=v2.3.1-sst
LITERT_COMMIT=1881386c68afd3060330c684925345cb079e7c84

LITERT_BUILD="${LITERT_BUILD:-$HOME/LiteRT/cmake_build}"
case "$LITERT_BUILD" in
    /*) ;;
    *) LITERT_BUILD="$PWD/$LITERT_BUILD" ;;
esac
LITERT_SRC="$(dirname "$LITERT_BUILD")"
LITERT_LIB="$LITERT_BUILD/tflite_build/libtensorflow-lite.so"

START_TIME="$(date +%s)"
# Summarize at the end, since the build log is long and easy to scroll past.
report() {
    status=$?
    elapsed=$(( $(date +%s) - START_TIME ))
    elapsed_text="$((elapsed / 60))m $((elapsed % 60))s"
    echo
    if [ "$status" -eq 0 ] && [ -f "$LITERT_LIB" ]; then
        echo "=============================================="
        echo " LiteRT build SUCCEEDED ($elapsed_text)"
        echo " $LITERT_LIB"
        echo "=============================================="
    else
        echo "=============================================="
        echo " LiteRT build FAILED (exit status $status, $elapsed_text)"
        [ "$status" -eq 0 ] && echo " Build finished but $LITERT_LIB was not produced."
        echo " Scroll up for the first error."
        echo "=============================================="
        [ "$status" -ne 0 ] || status=1
    fi
    exit "$status"
}
trap report EXIT

if [ -d "$LITERT_SRC/.git" ]; then
    git -C "$LITERT_SRC" fetch origin "$LITERT_BRANCH"
else
    git clone --branch "$LITERT_BRANCH" "$LITERT_URL" "$LITERT_SRC"
fi
git -C "$LITERT_SRC" checkout "$LITERT_COMMIT"

mkdir -p "$LITERT_BUILD"
cd "$LITERT_BUILD"
cmake "$LITERT_SRC/litert" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DLITERT_ENABLE_SAMSUNG=OFF \
    -DLITERT_BUILD_TESTS=OFF
cmake --build . -j"$(nproc)"

#!/bin/sh
# Build LiteRT (TensorFlow Lite) in place for native development builds of C++ applications.
# The Makefile links against the resulting build tree; nothing is installed.
# LITERT_BUILD must match the Makefile's LITERT_BUILD (default $HOME/LiteRT/cmake_build).
set -eu

LITERT_BUILD="${LITERT_BUILD:-$HOME/LiteRT/cmake_build}"
case "$LITERT_BUILD" in
    /*) ;;
    *) LITERT_BUILD="$PWD/$LITERT_BUILD" ;;
esac
LITERT_SRC="$(cd "$(dirname "$0")/.." && pwd)"
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

mkdir -p "$LITERT_BUILD"
cd "$LITERT_BUILD"
cmake "$LITERT_SRC/litert" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DLITERT_ENABLE_SAMSUNG=OFF \
    -DLITERT_BUILD_TESTS=OFF
cmake --build . -j"$(nproc)"

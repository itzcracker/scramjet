#!/usr/bin/env bash
# Netlify build: compile the Rust rewriter to wasm (packages/core/dist/scramjet.wasm
# and rewriter/wasm/out/wasm.js are gitignored), then build the demo and its deps.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

WASM_BINDGEN_VERSION="0.2.105"
BINARYEN_VERSION="version_133"

TOOLS_DIR="$HOME/.scramjet-tools"
mkdir -p "$TOOLS_DIR/bin"
export PATH="$TOOLS_DIR/bin:$HOME/.cargo/bin:$PATH"

# rust nightly (toolchain pinned by packages/core/rewriter/rust-toolchain.toml)
if ! command -v rustup &> /dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain none
fi
rustup toolchain install nightly --profile minimal --target wasm32-unknown-unknown --component rust-src

if ! [[ "$(wasm-bindgen -V 2> /dev/null)" =~ ^"wasm-bindgen $WASM_BINDGEN_VERSION" ]]; then
	WBG="wasm-bindgen-${WASM_BINDGEN_VERSION}-x86_64-unknown-linux-musl"
	curl -sSfL "https://github.com/wasm-bindgen/wasm-bindgen/releases/download/${WASM_BINDGEN_VERSION}/${WBG}.tar.gz" | tar xz -C "$TOOLS_DIR"
	cp "$TOOLS_DIR/$WBG/wasm-bindgen" "$TOOLS_DIR/bin/"
fi

if ! command -v wasm-opt &> /dev/null; then
	curl -sSfL "https://github.com/WebAssembly/binaryen/releases/download/${BINARYEN_VERSION}/binaryen-${BINARYEN_VERSION}-x86_64-linux.tar.gz" | tar xz -C "$TOOLS_DIR"
	ln -sf "$TOOLS_DIR/binaryen-${BINARYEN_VERSION}/bin/"* "$TOOLS_DIR/bin/"
fi

if ! command -v wasm-snip &> /dev/null; then
	cargo +nightly install --git https://github.com/r58playz/wasm-snip --root "$TOOLS_DIR"
fi

cd "$ROOT/packages/core"
RELEASE=1 pnpm run rewriter:build

cd "$ROOT"
pnpm --filter "@mercuryworkshop/scramjet-demo..." run build

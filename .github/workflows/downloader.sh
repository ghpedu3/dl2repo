# direct link base
#   https://raw.githubusercontent.com/ghpedu3/test/refs/heads/main/artifacts/
__ENABLE_DOWNLOAD_NODE="false"
__ENABLE_DOWNLOAD_DENO="false"

__ENABLE_DOWNLOAD_BUN="false"
__ENABLE_DOWNLOAD_BUN_CANARY="false"

__ENABLE_DOWNLOAD_W64DEVKIT="false"

_ARTIFACTS="$GITHUB_WORKSPACE/artifacts"
mkdir "${_ARTIFACTS}"
cd "${_ARTIFACTS}" || exit $?
_NODE_DIST_BASE_URL="https://nodejs.org/dist"
_NODE_VERSION="24.15.0"
_NODE_BASE_URL="${_NODE_DIST_BASE_URL}/v${_NODE_VERSION}"
_NODE_BASE_NAME="node-v${_NODE_VERSION}"
_NODE_BASE_NAME_URL="${_NODE_BASE_URL}/${_NODE_BASE_NAME}"

{
    pwd
    wget -O - "${_NODE_DIST_BASE_URL}/"
    wget -O - "${_NODE_BASE_URL}/"
    wget -O - "${_NODE_BASE_URL}/win-x64/"
} >"${_ARTIFACTS}/stdout.txt"

true >"${_ARTIFACTS}/stderr.txt"

[ "${__ENABLE_DOWNLOAD_NODE}" = "true" ] && {
    mkdir -p "nodejs/${_NODE_BASE_NAME}"
    cd "nodejs/${_NODE_BASE_NAME}" || exit $?
    # linux
    wget --continue "${_NODE_BASE_NAME_URL}-linux-arm64.tar.xz"
    wget --continue "${_NODE_BASE_NAME_URL}-linux-x64.tar.xz"
    # win-x64
    wget --continue "${_NODE_BASE_NAME_URL}-win-x64.7z"
    wget --continue "${_NODE_BASE_NAME_URL}-x64.msi"
    # win-arm64
    wget --continue "${_NODE_BASE_NAME_URL}-win-arm64.7z"
    wget --continue "${_NODE_BASE_NAME_URL}-arm64.msi"
    # src
    wget --continue "${_NODE_BASE_NAME_URL}.tar.xz"
    # sdk headers
    wget --continue "${_NODE_BASE_NAME_URL}-headers.tar.xz"
    # sdk win-x64
    mkdir win-x64
    cd win-x64 || exit $?
    wget --continue "${_NODE_BASE_URL}/win-x64/node.lib"
    wget --continue "${_NODE_BASE_URL}/win-x64/node_pdb.7z"
    cd ..
    # sdk win-arm64
    mkdir win-arm64
    cd win-arm64 || exit $?
    wget --continue "${_NODE_BASE_URL}/win-arm64/node.lib"
    wget --continue "${_NODE_BASE_URL}/win-arm64/node_pdb.7z"
    cd ..
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'NODE download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_DENO_DIST_BASE_URL="https://github.com/denoland/deno/releases/download"
_DENO_VERSION="2.7.14"
_DENO_BASE_URL="${_DENO_DIST_BASE_URL}/v${_DENO_VERSION}"
_DENO_BASE_NAME="deno-${_DENO_VERSION}"

[ "${__ENABLE_DOWNLOAD_DENO}" = "true" ] && {
    mkdir -p "deno/${_DENO_BASE_NAME}"
    cd "deno/${_DENO_BASE_NAME}" || exit $?
    # linux-x64
    wget --continue "${_DENO_BASE_URL}/deno-x86_64-unknown-linux-gnu.zip"
    wget --continue "${_DENO_BASE_URL}/denort-x86_64-unknown-linux-gnu.zip"
    # linux-arm64
    wget --continue "${_DENO_BASE_URL}/deno-aarch64-unknown-linux-gnu.zip"
    wget --continue "${_DENO_BASE_URL}/denort-aarch64-unknown-linux-gnu.zip"
    # win-x64
    wget --continue "${_DENO_BASE_URL}/deno-x86_64-pc-windows-msvc.zip"
    wget --continue "${_DENO_BASE_URL}/denort-x86_64-pc-windows-msvc.zip"
    # win-arm64
    wget --continue "${_DENO_BASE_URL}/deno-aarch64-pc-windows-msvc.zip"
    wget --continue "${_DENO_BASE_URL}/denort-aarch64-pc-windows-msvc.zip"
    # src
    wget --continue "${_DENO_BASE_URL}/deno_src.tar.gz"
    # d.ts
    wget --continue "${_DENO_BASE_URL}/lib.deno.d.ts"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'DENO download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_BUN_CANARY_COMMIT="c5a2f8ffce1c9cc117887203004ea1f305b44c6a"
_BUN_CANARY_BASE_URL="https://github.com/oven-sh/bun/releases/download/canary"
_BUN_CANARY_BASE_NAME="bun-canary-${_BUN_CANARY_COMMIT}"
[ "${__ENABLE_DOWNLOAD_BUN_CANARY}" = "true" ] && {
    mkdir -p "bun/canary/${_BUN_CANARY_BASE_NAME}"
    cd "bun/canary/${_BUN_CANARY_BASE_NAME}" || exit $?
    # linux-x64
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-x64.zip"
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-x64-baseline.zip"
    # linux-x64-musl
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-x64-musl.zip"
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-x64-musl-baseline.zip"
    # linux-arm64
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-aarch64.zip"
    # linux-arm64-musl
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-linux-aarch64-musl.zip"
    # win-x64
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-windows-x64.zip"
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-windows-x64-baseline.zip"
    # win-arm64
    wget --continue "${_BUN_CANARY_BASE_URL}/bun-windows-aarch64.zip"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BUN_CANARY download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_W64DEVKIT_DIST_BASE_URL="https://github.com/skeeto/w64devkit/releases/download"
_W64DEVKIT_VERSION="2.7.0"
_W64DEVKIT_BASE_URL="${_W64DEVKIT_DIST_BASE_URL}/v${_W64DEVKIT_VERSION}"
_W64DEVKIT_BASE_NAME="w64devkit-${_W64DEVKIT_VERSION}"
[ "${__ENABLE_DOWNLOAD_W64DEVKIT}" = "true" ] && {
    mkdir -p "w64devkit/${_W64DEVKIT_BASE_NAME}"
    cd "w64devkit/${_W64DEVKIT_BASE_NAME}" || exit $?
    
    wget --continue "${_W64DEVKIT_BASE_URL}/w64devkit-x64-${_W64DEVKIT_VERSION}.7z.exe"
    wget --continue "${_W64DEVKIT_BASE_URL}/w64devkit-x86-${_W64DEVKIT_VERSION}.7z.exe"
    # large file
    wget --continue "${_W64DEVKIT_BASE_URL}/source.tar" && {
        split --bytes=100MiB --numeric-suffixes=1 source.tar source.tar.part
        rm source.tar
    }
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'W64DEVKIT download was disabled' >>"${_ARTIFACTS}/stderr.txt"

# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-linux-arm64.tar.xz
# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-win-x64.7z


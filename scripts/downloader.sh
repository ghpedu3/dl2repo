# direct link base
#   https://raw.githubusercontent.com/ghpedu3/test/refs/heads/main/artifacts/
__ENABLE_DOWNLOAD_NODE="false"
__ENABLE_DOWNLOAD_DENO="false"

__ENABLE_DOWNLOAD_QJSNG="false"

__ENABLE_DOWNLOAD_BUN="false"
__ENABLE_DOWNLOAD_BUN_CANARY="false"

__ENABLE_DOWNLOAD_BBW32="false"
__ENABLE_DOWNLOAD_W64DEVKIT="false"

__ENABLE_DOWNLOAD_TCMD="false"

__ENABLE_DOWNLOAD_TMP="true"

_ARTIFACTS="$GITHUB_WORKSPACE/artifacts"
mkdir "${_ARTIFACTS}"
cd "${_ARTIFACTS}" || exit $?
_NODE_DIST_BASE_URL="https://nodejs.org/dist"
_NODE_VERSION="22.22.2"
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
    wget --continue "${_NODE_BASE_NAME_URL}-linux-armv7l.tar.xz"
    wget --continue "${_NODE_BASE_NAME_URL}-linux-arm64.tar.xz"
    wget --continue "${_NODE_BASE_NAME_URL}-linux-x64.tar.xz"
    # win-x64
    wget --continue "${_NODE_BASE_NAME_URL}-win-x64.7z"
    wget --continue "${_NODE_BASE_NAME_URL}-x64.msi"
    # win-arm64
    wget --continue "${_NODE_BASE_NAME_URL}-win-arm64.7z"
    wget --continue "${_NODE_BASE_NAME_URL}-arm64.msi"
    # win-x86
    wget --continue "${_NODE_BASE_NAME_URL}-win-x86.7z"
    wget --continue "${_NODE_BASE_NAME_URL}-x86.msi"
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
    # sdk win-x86
    mkdir win-x86
    cd win-x86 || exit $?
    wget --continue "${_NODE_BASE_URL}/win-x86/node.lib"
    wget --continue "${_NODE_BASE_URL}/win-x86/node_pdb.7z"
    cd ..
    
    cd "${_ARTIFACTS}"
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

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'DENO download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_QJSNG_DIST_BASE_URL="https://github.com/quickjs-ng/quickjs/releases/download"
_QJSNG_VERSION="0.13.0"
_QJSNG_BASE_URL="${_QJSNG_DIST_BASE_URL}/v${_QJSNG_VERSION}"
_QJSNG_BASE_NAME="quickjs-ng-${_QJSNG_VERSION}"

[ "${__ENABLE_DOWNLOAD_QJSNG}" = "true" ] && {
    mkdir -p "quickjs-ng/${_QJSNG_BASE_NAME}"
    cd "quickjs-ng/${_QJSNG_BASE_NAME}" || exit $?
    
    wget --continue "${_QJSNG_BASE_URL}/qjs-darwin"
    wget --continue "${_QJSNG_BASE_URL}/qjs-linux-aarch64"
    wget --continue "${_QJSNG_BASE_URL}/qjs-linux-armv7"
    wget --continue "${_QJSNG_BASE_URL}/qjs-linux-riscv64"
    wget --continue "${_QJSNG_BASE_URL}/qjs-linux-x86"
    wget --continue "${_QJSNG_BASE_URL}/qjs-linux-x86_64"
    wget --continue "${_QJSNG_BASE_URL}/qjs-wasi-reactor.wasm"
    wget --continue "${_QJSNG_BASE_URL}/qjs-wasi.wasm"
    wget --continue "${_QJSNG_BASE_URL}/qjs-windows-x86.exe"
    wget --continue "${_QJSNG_BASE_URL}/qjs-windows-x86_64.exe"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-darwin"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-linux-aarch64"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-linux-armv7"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-linux-riscv64"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-linux-x86"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-linux-x86_64"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-windows-x86.exe"
    wget --continue "${_QJSNG_BASE_URL}/qjsc-windows-x86_64.exe"
    wget --continue "${_QJSNG_BASE_URL}/quickjs-amalgam.zip"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'QJSNG download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_BUN_DIST_BASE_URL="https://github.com/oven-sh/bun/releases/download"
_BUN_VERSION="1.3.13"
_BUN_BASE_URL="${_BUN_DIST_BASE_URL}/bun-v${_BUN_VERSION}"
_BUN_BASE_NAME="bun-v${_BUN_VERSION}"

[ "${__ENABLE_DOWNLOAD_BUN}" = "true" ] && {
    mkdir -p "bun/${_BUN_BASE_NAME}"
    cd "bun/${_BUN_BASE_NAME}" || exit $?
    # linux-x64
    wget --continue "${_BUN_BASE_URL}/bun-linux-x64.zip"
    wget --continue "${_BUN_BASE_URL}/bun-linux-x64-baseline.zip"
    # linux-x64-musl
    wget --continue "${_BUN_BASE_URL}/bun-linux-x64-musl.zip"
    wget --continue "${_BUN_BASE_URL}/bun-linux-x64-musl-baseline.zip"
    # linux-arm64
    wget --continue "${_BUN_BASE_URL}/bun-linux-aarch64.zip"
    # linux-arm64-musl
    wget --continue "${_BUN_BASE_URL}/bun-linux-aarch64-musl.zip"
    # win-x64
    wget --continue "${_BUN_BASE_URL}/bun-windows-x64.zip"
    wget --continue "${_BUN_BASE_URL}/bun-windows-x64-baseline.zip"
    # win-arm64
    wget --continue "${_BUN_BASE_URL}/bun-windows-aarch64.zip"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BUN download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_BUN_CANARY_COMMIT="d5945cffad9037d064001c3dcde6aceb06362deb"
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

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BUN_CANARY download was disabled' >>"${_ARTIFACTS}/stderr.txt"



_BBW32_BASE_VERSION="FRP-6075"
_BBW32_VERSION_COMMIT_TAG="g169694ebd"
_BBW32_VERSION="${_BBW32_BASE_VERSION}-${_BBW32_VERSION_COMMIT_TAG}"
_BBW32_BASE_URL="https://frippery.org/files/busybox"
_BBW32_PRE_RELEASE_BASE_URL="${_BBW32_BASE_URL}/prerelease"
_BBW32_REL_NOTES_BASE_URL="https://frippery.org/busybox/release-notes"
_BBW32_BASE_NAME="busybox-w32-${_BBW32_BASE_VERSION}"
[ "${__ENABLE_DOWNLOAD_BBW32}" = "true" ] && {
    mkdir -p "busybox-w32/${_BBW32_BASE_NAME}"
    cd "busybox-w32/${_BBW32_BASE_NAME}" || exit $?

    wget --continue "${_BBW32_BASE_URL}/busybox-${_BBW32_VERSION}.1.gz"
    wget --continue "${_BBW32_BASE_URL}/busybox-w32-${_BBW32_VERSION}.tgz"
    wget --continue "${_BBW32_BASE_URL}/busybox-w32-${_BBW32_VERSION}.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox-w64-${_BBW32_VERSION}.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox-w64u-${_BBW32_VERSION}.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox-w64a-${_BBW32_VERSION}.exe"

    cd ..
    mkdir current
    cd current
    
    wget --continue "${_BBW32_BASE_URL}/busybox.1.gz"
    wget --continue "${_BBW32_BASE_URL}/busybox.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox64.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox64u.exe"
    wget --continue "${_BBW32_BASE_URL}/busybox64a.exe"

    cd ..
    mkdir pre-release
    cd pre-release

    wget --continue "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre.exe"
    wget --continue "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre32w.exe"
    wget --continue "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64.exe"
    wget --continue "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64u.exe"
    wget --continue "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64a.exe"

    cd ..
    mkdir release-notes
    cd release-notes
    
    wget --continue "${_BBW32_REL_NOTES_BASE_URL}/${_BBW32_BASE_VERSION}.html"
    wget --continue "${_BBW32_REL_NOTES_BASE_URL}/current.html"
    wget --continue "${_BBW32_REL_NOTES_BASE_URL}/index.html"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BBW32 download was disabled' >>"${_ARTIFACTS}/stderr.txt"


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

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'W64DEVKIT download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_TCMD_DIST_BASE_URL="https://jpsoft.com/downloads"
_TCMD_VERSION="36"
_TCMD_BASE_URL="${_TCMD_DIST_BASE_URL}/v${_TCMD_VERSION}"
_TCMD_BASE_NAME="tcmd-${_TCMD_VERSION}"

[ "${__ENABLE_DOWNLOAD_TCMD}" = "true" ] && {
    mkdir -p "tcmd/${_TCMD_BASE_NAME}"
    cd "tcmd/${_TCMD_BASE_NAME}" || exit $?

    wget --continue "${_TCMD_BASE_URL}/tcmd.exe"
    wget --continue "${_TCMD_BASE_URL}/tcc.exe"
    wget --continue "${_TCMD_BASE_URL}/cmdebug.exe"
    wget --continue "${_TCMD_BASE_URL}/tcc-rt.exe"
    wget --continue "${_TCMD_BASE_URL}/TakeCommand.pdf"
    wget --continue "${_TCMD_BASE_URL}/TakeCommand.ewriter"
    wget --continue "${_TCMD_BASE_URL}/CMDebug.pdf"
    wget --continue "${_TCMD_BASE_URL}/CMDebug.ewriter"

    wget --continue "https://jpsoft.com/all-downloads/all-downloads.html"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TCMD download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_TMP}" = "true" ] && {
    mkdir "tmp"
    cd "tmp" || exit $?

    # wget --continue "https://jpsoft.com/all-downloads/all-downloads.html"
    # wget --user-agent="Mozilla/5.0" --continue --content-disposition "https://en.wikipedia.org/api/rest_v1/page/pdf/TCP_hole_punching"
    wget "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TMP download was disabled' >>"${_ARTIFACTS}/stderr.txt"

# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-linux-arm64.tar.xz
# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-win-x64.7z


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
__ENABLE_DOWNLOAD_CHROME="false"
__ENABLE_DOWNLOAD_MSEDIT="false"
__ENABLE_DOWNLOAD_MSDEF="false"
__ENABLE_DOWNLOAD_GITHUB_CLI="false"
__ENABLE_DOWNLOAD_7ZIP="false"
__ENABLE_DOWNLOAD_RUBY_INSTALLER_WIN="false"
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
    true && {
        wget --continue "${_W64DEVKIT_BASE_URL}/source.tar" && {
            split --bytes=49MiB --numeric-suffixes=1 source.tar source.tar.part
            rm source.tar
        }
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

_MSEDIT_DIST_BASE_URL="https://github.com/microsoft/edit/releases/download"
_MSEDIT_VERSION="2.0.0"
_MSEDIT_BASE_URL="${_MSEDIT_DIST_BASE_URL}/v${_MSEDIT_VERSION}"
_MSEDIT_BASE_NAME="edit-${_MSEDIT_VERSION}"

[ "${__ENABLE_DOWNLOAD_MSEDIT}" = "true" ] && {
    mkdir -p "microsoft-edit/${_MSEDIT_BASE_NAME}"
    cd "microsoft-edit/${_MSEDIT_BASE_NAME}" || exit $?
    # linux-x64
    wget --continue "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-x86_64-linux-gnu.tar.gz"
    # linux-arm64
    wget --continue "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-aarch64-linux-gnu.tar.gz"
    # win-x64
    wget --continue "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-x86_64-windows.zip"
    # win-arm64
    wget --continue "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-aarch64-windows.zip"
    # src
    wget --content-disposition "https://github.com/microsoft/edit/archive/refs/tags/v${_MSEDIT_VERSION}.tar.gz"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'MSEDIT download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_MSDEF}" = "true" ] && {
    _MSDEF_BASE_NAME="mpam-fe"
    mkdir -p "${_MSDEF_BASE_NAME}"
    cd "${_MSDEF_BASE_NAME}" || exit $?

    # x64
    true && {
        _MSDEF_NAME_X64="${_MSDEF_BASE_NAME}_x64.exe"
        wget --no-verbose -O "${_MSDEF_NAME_X64}" "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=x64" && {
                split --bytes=49MiB --numeric-suffixes=1 "${_MSDEF_NAME_X64}" "${_MSDEF_NAME_X64}.part"
                rm "${_MSDEF_NAME_X64}"
        }
    }
    # x86
    false && {
        _MSDEF_NAME_X86="${_MSDEF_BASE_NAME}_x86.exe"
        wget --no-verbose -O "${_MSDEF_NAME_X86}" "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=x86" && {
                split --bytes=49MiB --numeric-suffixes=1 "${_MSDEF_NAME_X86}" "${_MSDEF_NAME_X86}.part"
                rm "${_MSDEF_NAME_X86}"
        }
    }
    # arm64
    false && {
        _MSDEF_NAME_ARM64="${_MSDEF_BASE_NAME}_arm64.exe"
        wget --no-verbose -O "${_MSDEF_NAME_ARM64}" "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=arm64" && {
                split --bytes=49MiB --numeric-suffixes=1 "${_MSDEF_NAME_ARM64}" "${_MSDEF_NAME_ARM64}.part"
                rm "${_MSDEF_NAME_ARM64}"
        }
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'MSDEF download was disabled' >>"${_ARTIFACTS}/stderr.txt"

_GITHUB_CLI_DIST_BASE_URL="https://github.com/cli/cli/releases/download"
_GITHUB_CLI_VERSION="2.92.0"
_GITHUB_CLI_BASE_URL="${_GITHUB_CLI_DIST_BASE_URL}/v${_GITHUB_CLI_VERSION}"
_GITHUB_CLI_BASE_NAME="gh_${_GITHUB_CLI_VERSION}"

[ "${__ENABLE_DOWNLOAD_GITHUB_CLI}" = "true" ] && {
    mkdir -p "gh/${_GITHUB_CLI_BASE_NAME}"
    cd "gh/${_GITHUB_CLI_BASE_NAME}" || exit $?
    # linux
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_386.tar.gz"
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_amd64.tar.gz"
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_arm64.tar.gz"
    # win-x86
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_386.msi"
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_386.zip"
    # win-x64
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_amd64.msi"
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_amd64.zip"
    # win-arm64
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_arm64.msi"
    wget --no-verbose "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_arm64.zip"
    # src
    wget --no-verbose --content-disposition "https://github.com/cli/cli/archive/refs/tags/v${_GITHUB_CLI_VERSION}.tar.gz"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'GITHUB_CLI download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_7ZIP_DIST_BASE_URL="https://github.com/ip7z/7zip/releases/download"
_7ZIP_VERSION="26.01"
_7ZIP_BASE_URL="${_7ZIP_DIST_BASE_URL}/${_7ZIP_VERSION}"
_7ZIP_BASE_NAME="7zip-${_7ZIP_VERSION}"

[ "${__ENABLE_DOWNLOAD_7ZIP}" = "true" ] && {
    mkdir -p "7zip/${_7ZIP_BASE_NAME}"
    cd "7zip/${_7ZIP_BASE_NAME}" || exit $?

    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-arm.exe"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-arm64.exe"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-extra.7z"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-arm.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-arm64.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-x64.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-x86.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-mac.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-src.7z"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-src.tar.xz"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-x64.exe"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-x64.msi"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}.exe"
    wget --no-verbose "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}.msi"
    wget --no-verbose "${_7ZIP_BASE_URL}/lzma${_7ZIP_VERSION/./}.7z"
    wget --no-verbose "${_7ZIP_BASE_URL}/7zr.exe"

    wget --no-verbose --content-disposition "https://github.com/ip7z/7zip/archive/refs/tags/${_7ZIP_VERSION}.tar.gz"
    wget --no-verbose --content-disposition "https://github.com/ip7z/7zip/archive/refs/tags/${_7ZIP_VERSION}.zip"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo '7ZIP download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_RUBY_INSTALLER_WIN}" = "true" ] && {
    mkdir -p "rubyinstaller"
    cd "rubyinstaller" || exit $?

    # ruby-4.0
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-4.0.3-1-x64.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-4.0.3-1-x64.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-devkit-4.0.3-1-x64.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-4.0.3-1-x64.exe" "rubyinstaller-devkit-4.0.3-1-x64.exe.part"
        rm "rubyinstaller-devkit-4.0.3-1-x64.exe"
    }
    # ruby-3.4    
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x64.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x64.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x86.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x86.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-devkit-3.4.9-1-x64.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.4.9-1-x64.exe" "rubyinstaller-devkit-3.4.9-1-x64.exe.part"
        rm "rubyinstaller-devkit-3.4.9-1-x64.exe"
    }
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-devkit-3.4.9-1-x86.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.4.9-1-x86.exe" "rubyinstaller-devkit-3.4.9-1-x86.exe.part"
        rm "rubyinstaller-devkit-3.4.9-1-x86.exe"
    }
    # ruby-3.3
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x64.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x64.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x86.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x86.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-devkit-3.3.11-1-x64.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.3.11-1-x64.exe" "rubyinstaller-devkit-3.3.11-1-x64.exe.part"
        rm "rubyinstaller-devkit-3.3.11-1-x64.exe"
    }
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-devkit-3.3.11-1-x86.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.3.11-1-x86.exe" "rubyinstaller-devkit-3.3.11-1-x86.exe.part"
        rm "rubyinstaller-devkit-3.3.11-1-x86.exe"
    }
    # ruby-3.2
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x64.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x64.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x86.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x86.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-devkit-3.2.11-1-x64.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.2.11-1-x64.exe" "rubyinstaller-devkit-3.2.11-1-x64.exe.part"
        rm "rubyinstaller-devkit-3.2.11-1-x64.exe"
    }
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-devkit-3.2.11-1-x86.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-3.2.11-1-x86.exe" "rubyinstaller-devkit-3.2.11-1-x86.exe.part"
        rm "rubyinstaller-devkit-3.2.11-1-x86.exe"
    }
    # ruby-2.7
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x64.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x64.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x86.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x86.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-devkit-2.7.8-1-x64.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-2.7.8-1-x64.exe" "rubyinstaller-devkit-2.7.8-1-x64.exe.part"
        rm "rubyinstaller-devkit-2.7.8-1-x64.exe"
    }
    wget --no-verbose "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-devkit-2.7.8-1-x86.exe" && {
        split --bytes=49MiB --numeric-suffixes=1 "rubyinstaller-devkit-2.7.8-1-x86.exe" "rubyinstaller-devkit-2.7.8-1-x86.exe.part"
        rm "rubyinstaller-devkit-2.7.8-1-x86.exe"
    }
    # ruby-2.3
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-doc-chm.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-i386-mingw32.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-x64-mingw32.7z"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/rubyinstaller-2.3.3.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/rubyinstaller-2.3.3-x64.exe"
    # DevKit 4.7.2 (20130224, Ruby 2.0 Edition)
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/devkit-4.7.2/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
    wget --no-verbose "https://github.com/oneclick/rubyinstaller/releases/download/devkit-4.7.2/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'RUBY_INSTALLER_WIN download was disabled' >>"${_ARTIFACTS}/stderr.txt"

[ "${__ENABLE_DOWNLOAD_CHROME}" = "true" ] && {
    mkdir -p "google-chrome"
    cd "google-chrome" || exit $?
    GoogleChromeStandaloneEnterprise64="https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
    GoogleChromeStandaloneEnterprise="https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"
    ChromeStandaloneSetup64="https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BFDC21362-D83A-7CF4-7354-10A215B91416%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3D-arch_x64-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup64.exe"
    ChromeStandaloneSetup="https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BFDC21362-D83A-7CF4-7354-10A215B91416%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3D-arch_x86-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup.exe"

    true && {
        wget "${GoogleChromeStandaloneEnterprise64}" && {
                split --bytes=49MiB --numeric-suffixes=1 GoogleChromeStandaloneEnterprise64.msi GoogleChromeStandaloneEnterprise64.msi.part
                rm GoogleChromeStandaloneEnterprise64.msi
        }
    }
    false && {
        wget "${GoogleChromeStandaloneEnterprise}" && {
                split --bytes=49MiB --numeric-suffixes=1 GoogleChromeStandaloneEnterprise.msi GoogleChromeStandaloneEnterprise.msi.part
                rm GoogleChromeStandaloneEnterprise.msi
        }
    }
    false && {
        wget "${ChromeStandaloneSetup64}" && {
                split --bytes=49MiB --numeric-suffixes=1 ChromeStandaloneSetup64.exe ChromeStandaloneSetup64.exe.part
                rm ChromeStandaloneSetup64.exe
        }
    }
    false && {
        wget "${ChromeStandaloneSetup}"&& {
                split --bytes=49MiB --numeric-suffixes=1 ChromeStandaloneSetup.exe ChromeStandaloneSetup.exe.part
                rm ChromeStandaloneSetup.exe
        }
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'CHROME download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_TMP}" = "true" ] && {
    mkdir "tmp"
    cd "tmp" || exit $?

    # wget --continue "https://jpsoft.com/all-downloads/all-downloads.html"
    # wget --user-agent="Mozilla/5.0" --continue --content-disposition "https://en.wikipedia.org/api/rest_v1/page/pdf/TCP_hole_punching"
    wget --user-agent="Mozilla/5.0" --continue --content-disposition "https://en.wikipedia.org/api/rest_v1/page/pdf/Cranelift"
    false && {
        wget "https://download.sysinternals.com/files/SysinternalsSuite.zip" && {
            split --bytes=49MiB --numeric-suffixes=1 SysinternalsSuite.zip SysinternalsSuite.zip.part
            rm SysinternalsSuite.zip
        }
    }
    # wget "https://download.sysinternals.com/files/PSTools.zip"

    # wget "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe"
    # wget -O "git-windows-minimal.2.54.0.nupkg" "https://www.nuget.org/api/v2/package/Git-Windows-Minimal/2.54.0"
    false && {
        wget -O "gitforwindows.2.54.0.nupkg" "https://www.nuget.org/api/v2/package/GitForWindows/2.54.0" && {
            split --bytes=49MiB --numeric-suffixes=1 gitforwindows.2.54.0.nupkg gitforwindows.2.54.0.nupkg.part
            rm gitforwindows.2.54.0.nupkg
        }
    }

    # wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-amd64.xz"
    # wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-arm64.xz"
    # wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-windows-4.0-amd64.exe.xz"
    # wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-gogit-windows-4.0-amd64.exe.xz"
    # wget --no-verbose "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-386.xz"
    # wget --no-verbose "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-gogit-windows-4.0-386.exe.xz"
    # wget --no-verbose "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-windows-4.0-386.exe.xz"
    # wget --no-verbose "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-freebsd14-amd64.xz"
    # wget --no-verbose "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-src-1.26.1.tar.gz"

    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/dokan.zip"
    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/DokanSetup.exe"
    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/DokanSetupDbg.exe"
    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_ARM64.msi"
    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_x64.msi"
    # wget --no-verbose "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_x86.msi"
    # wget --no-verbose "https://github.com/dokan-dev/dokan-dotnet/releases/download/v2.3.0.3/DokanNet.2.3.0.3.nupkg"

    # wget --no-verbose "https://github.com/jrsoftware/issrc/releases/download/is-6_7_1/innosetup-6.7.1.exe"
    # wget --no-verbose "https://github.com/jrsoftware/issrc/releases/download/is-7_0_0_2/innosetup-7.0.0-preview-3-x64.exe"
    # wget --no-verbose "https://github.com/jrsoftware/issrc/releases/download/is-7_0_0_2/innosetup-7.0.0-preview-3-x86.exe"


    
    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TMP download was disabled' >>"${_ARTIFACTS}/stderr.txt"

# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-linux-arm64.tar.xz
# wget https://nodejs.org/dist/v26.0.0/node-v26.0.0-win-x64.7z


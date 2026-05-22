#!/bin/bash

# direct link base
#   https://raw.githubusercontent.com/ghpedu3/test/refs/heads/main/artifacts/
__ENABLE_DOWNLOAD_NODE="false"
__ENABLE_DOWNLOAD_DENO="false"
__ENABLE_DOWNLOAD_ELECTRON="false"
__ENABLE_DOWNLOAD_QJSNG="false"
__ENABLE_DOWNLOAD_BUN="false"
__ENABLE_DOWNLOAD_BUN_CANARY="false"
__ENABLE_DOWNLOAD_BBW32="false"
__ENABLE_DOWNLOAD_W64DEVKIT="false"
__ENABLE_DOWNLOAD_GOLANG="false"
__ENABLE_DOWNLOAD_MSGO="false"
__ENABLE_DOWNLOAD_PWSH="false"
__ENABLE_DOWNLOAD_TCMD="false"
__ENABLE_DOWNLOAD_CHROME="false"
__ENABLE_DOWNLOAD_MSEDIT="false"
__ENABLE_DOWNLOAD_VSCODE="false"
__ENABLE_DOWNLOAD_MSDEF="false"
__ENABLE_DOWNLOAD_GITHUB_CLI="false"
__ENABLE_DOWNLOAD_7ZIP="false"
__ENABLE_DOWNLOAD_RUBY_INSTALLER_WIN="false"
__ENABLE_DOWNLOAD_TMP="true"


my_wget() {

	local URL=''
	local PARAMS=()
	
	[ "${1:+#}#" = "#" ] && {
		echo URL not specified
		return 1;
	}
	URL="${1}"
	shift

	[ "${1:+#}#" = "##" ] && {
		PARAMS[0]="-O"
		PARAMS[1]="${1##*/}"
	}
	[ "${1+#}#" = "##" ] && shift

	[ "${@:+#}#" = "##" ] && {
		PARAMS+=("$@")
	} || {
		PARAMS=('--no-verbose' "${PARAMS[@]}")
	}

	local TMP_DIR="$(date --utc +%Y%m%d-%H%M%S-%N)-$RANDOM"
	mkdir "$TMP_DIR" || return 1
	cd "$TMP_DIR" || return 1
	echo wget "${PARAMS[@]}" "'$URL'"
	wget "${PARAMS[@]}" "$URL" && {
		local OUT=''
		for OUT in *; do
		    local SIZE=0
		    SIZE=$(stat -c%s "$OUT")

	        [ $SIZE -gt $((49 * 1024 * 1024)) ] && {
	    	    echo "split --bytes=49MiB --numeric-suffixes=1 '$OUT' '$OUT.part'"
		        split --bytes=49MiB --numeric-suffixes=1 "$OUT" "$OUT.part"
		        rm "$OUT"
	        }
	    done
	    mv * ../
	}
	cd ..
	rm -rf "$TMP_DIR"
}

# mirror_site_wget <url> <mirror_name>
mirror_site_wget() {
    local CONST_USER_AGENT="Mozilla/5.0"
    local URL=''
	local MNANE=''

	[ "${1:+#}#" = "#" ] && {
		echo URL not specified
		return 1;
	}
	URL="${1}"
	shift

	[ "${1:+#}#" = "#" ] && {
		echo Mirror name not specified
		return 1;
	}
	MNAME="${1##*/}"
	[ "${MNAME:+#}#" = "#" ] && {
		echo Mirror name not specified
		return 1;
	}

	mkdir -p "wget-mirror/${MNAME}" || return 1
	cd "wget-mirror/${MNAME}" || return 1
	
	echo "wget --execute='robots=off' --mirror --convert-links --adjust-extension --page-requisites --no-parent --no-verbose --user-agent='${CONST_USER_AGENT}' '${URL}'"
	wget --execute='robots=off' --mirror --execute='robots=off' --convert-links --adjust-extension --page-requisites --no-parent --no-verbose --user-agent="${CONST_USER_AGENT}" "${URL}"
	local url_component="${URL##*/}"
	local url_path="${URL%/$url_component}"
	local _url_path="${url_path/https:\/\//}"
	[ "${url_path}" = "${_url_path}" ] && {
	    _url_path="${url_path/http:\/\//}"
	    [ "${url_path}" = "${_url_path}" ] && {
	        url_path="${url_path/ftp:\/\//}"
	    } || {
	        url_path="${_url_path}"
	    }
	} || {
	    url_path="${_url_path}"
	}
	{
	    echo "<html>"
        echo "<head>"
	    echo "    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" >"
	    echo "    <meta HTTP-EQUIV=\"Refresh\" CONTENT=\"0; URL=./${url_path}/index.html\" >"
	    echo "    <title>${MNAME}</title>"
        echo "</head>"
        echo "<!--"
        echo "    wget --execute='robots=off' --mirror --convert-links --adjust-extension --page-requisites --no-parent --user-agent='${CONST_USER_AGENT}' '${URL}'"
        echo "-->"
        echo "</html>"
	} > "index.html"

	cd ..
	local TAR_NAME="${MNAME}.tar.gz"
	echo "tar -czf '${TAR_NAME}' '${MNAME}'"
	tar -czf "${TAR_NAME}" "${MNAME}" && {
	    rm -rf "${MNAME}"
	    local SIZE=0
	    SIZE=$(stat -c%s "${TAR_NAME}")
	    [ ${SIZE} -gt $((49 * 1024 * 1024)) ] && {
	        echo "split --bytes=49MiB --numeric-suffixes=1 '${TAR_NAME}' '${TAR_NAME}.part'"
	        split --bytes=49MiB --numeric-suffixes=1 "${TAR_NAME}" "${TAR_NAME}.part"
	        rm "${TAR_NAME}"
	    }
	    true
	} || rm -rf "${MNAME}"
	cd ..
}

get_node_api_docs() {
    local NODE_VERSION=''
    LOCAL URL=''

    [ "${1:+#}#" = "#" ] && {
		echo node version not specified
		return 1;
	}
	NODE_VERSION="${1}"
	URL="https://nodejs.org/dist/v${NODE_VERSION}/docs/"
	wget --no-verbose --spider "${URL}" && mirror_site_wget "${URL}" "node_api_${NODE_VERSION}"
}

_ARTIFACTS="$GITHUB_WORKSPACE/artifacts"
mkdir "${_ARTIFACTS}"
cd "${_ARTIFACTS}" || exit $?
_NODE_DIST_BASE_URL="https://nodejs.org/dist"
_NODE_VERSION="24.16.0"
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
    my_wget "${_NODE_BASE_NAME_URL}-linux-armv7l.tar.xz"
    my_wget "${_NODE_BASE_NAME_URL}-linux-arm64.tar.xz"
    my_wget "${_NODE_BASE_NAME_URL}-linux-x64.tar.xz"
    # win-x64
    my_wget "${_NODE_BASE_NAME_URL}-win-x64.7z"
    my_wget "${_NODE_BASE_NAME_URL}-x64.msi"
    # win-arm64
    my_wget "${_NODE_BASE_NAME_URL}-win-arm64.7z"
    my_wget "${_NODE_BASE_NAME_URL}-arm64.msi"
    # win-x86
    my_wget "${_NODE_BASE_NAME_URL}-win-x86.7z"
    my_wget "${_NODE_BASE_NAME_URL}-x86.msi"
    # src
    my_wget "${_NODE_BASE_NAME_URL}.tar.xz"
    # sdk headers
    my_wget "${_NODE_BASE_NAME_URL}-headers.tar.xz"
    # sdk win-x64
    mkdir win-x64
    cd win-x64 || exit $?
    my_wget "${_NODE_BASE_URL}/win-x64/node.lib"
    my_wget "${_NODE_BASE_URL}/win-x64/node_pdb.7z"
    cd ..
    # sdk win-arm64
    mkdir win-arm64
    cd win-arm64 || exit $?
    my_wget "${_NODE_BASE_URL}/win-arm64/node.lib"
    my_wget "${_NODE_BASE_URL}/win-arm64/node_pdb.7z"
    cd ..
    # sdk win-x86
    mkdir win-x86
    cd win-x86 || exit $?
    my_wget "${_NODE_BASE_URL}/win-x86/node.lib"
    my_wget "${_NODE_BASE_URL}/win-x86/node_pdb.7z"
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
    my_wget "${_DENO_BASE_URL}/deno-x86_64-unknown-linux-gnu.zip"
    my_wget "${_DENO_BASE_URL}/denort-x86_64-unknown-linux-gnu.zip"
    # linux-arm64
    my_wget "${_DENO_BASE_URL}/deno-aarch64-unknown-linux-gnu.zip"
    my_wget "${_DENO_BASE_URL}/denort-aarch64-unknown-linux-gnu.zip"
    # win-x64
    my_wget "${_DENO_BASE_URL}/deno-x86_64-pc-windows-msvc.zip"
    my_wget "${_DENO_BASE_URL}/denort-x86_64-pc-windows-msvc.zip"
    # win-arm64
    my_wget "${_DENO_BASE_URL}/deno-aarch64-pc-windows-msvc.zip"
    my_wget "${_DENO_BASE_URL}/denort-aarch64-pc-windows-msvc.zip"
    # src
    my_wget "${_DENO_BASE_URL}/deno_src.tar.gz"
    # d.ts
    my_wget "${_DENO_BASE_URL}/lib.deno.d.ts"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'DENO download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_GOLANG_BASE_URL="https://dl.google.com/go"
_GOLANG_VERSION="1.26.3"
_GOLANG_BASE_NAME="go-${_GOLANG_VERSION}"

[ "${__ENABLE_DOWNLOAD_GOLANG}" = "true" ] && {
    mkdir -p "golang/${_GOLANG_BASE_NAME}"
    cd "golang/${_GOLANG_BASE_NAME}" || exit $?
    
	for n in \
        "src.tar.gz" \
        "linux-386.tar.gz" \
        "linux-amd64.tar.gz" \
        "linux-arm64.tar.gz" \
        "linux-armv6l.tar.gz" \
        "windows-386.zip" \
        "windows-386.msi" \
        "windows-amd64.zip" \
        "windows-amd64.msi" \
        "freebsd-386.tar.gz" \
        "freebsd-amd64.tar.gz" \
        "freebsd-arm64.tar.gz" \
        "netbsd-386.tar.gz" \
        "netbsd-amd64.tar.gz" \
        "netbsd-arm64.tar.gz" \
        "openbsd-386.tar.gz" \
        "openbsd-amd64.tar.gz" \
        "openbsd-arm64.tar.gz" \
        "windows-arm64.zip" \
        "windows-arm64.msi"
    do    
        my_wget "${_GOLANG_BASE_URL}/go${_GOLANG_VERSION}.$n"
    done

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'GOLANG download was disabled' >>"${_ARTIFACTS}/stderr.txt"

_MSGO_BASE_URL="https://aka.ms/golang/release/latest"
_MSGO_VERSION="1.26.3"
_MSGO_BASE_NAME="go-${_MSGO_VERSION}"
[ "${__ENABLE_DOWNLOAD_MSGO}" = "true" ] && {
    mkdir -p "msgo/${_MSGO_BASE_NAME}"
    cd "msgo/${_MSGO_BASE_NAME}" || exit $?
    
	for n in \
        "assets.json" \
        "src.tar.gz" \
        "linux-armv6l.tar.gz" \
        "linux-arm64.tar.gz" \
        "linux-amd64.tar.gz" \
        "windows-amd64.zip"
    do    
        my_wget "${_MSGO_BASE_URL}/go${_MSGO_VERSION}.$n" "" --no-verbose --content-disposition
    done

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'MSGO download was disabled' >>"${_ARTIFACTS}/stderr.txt"

_ELECTRON_DIST_BASE_URL="https://github.com/electron/electron/releases/download"
_ELECTRON_VERSION="42.0.1"
_ELECTRON_BASE_URL="${_ELECTRON_DIST_BASE_URL}/v${_ELECTRON_VERSION}"
_ELECTRON_BASE_NAME="electron-${_ELECTRON_VERSION}"

[ "${__ENABLE_DOWNLOAD_ELECTRON}" = "true" ] && {
    mkdir -p "electron/${_ELECTRON_BASE_NAME}"
    cd "electron/${_ELECTRON_BASE_NAME}" || exit $?

    # electron
    true && {
        for i in \
            "electron-v${_ELECTRON_VERSION}-linux-arm64.zip" \
            "electron-v${_ELECTRON_VERSION}-linux-armv7l.zip" \
            "electron-v${_ELECTRON_VERSION}-linux-x64.zip" \
            "electron-v${_ELECTRON_VERSION}-win32-arm64.zip" \
            "electron-v${_ELECTRON_VERSION}-win32-ia32.zip" \
            "electron-v${_ELECTRON_VERSION}-win32-x64.zip" \
            "electron-api.json" \
            "electron.d.ts"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    # ffmpeg
    true && {
        for i in \
            "ffmpeg-v${_ELECTRON_VERSION}-linux-arm64.zip" \
            "ffmpeg-v${_ELECTRON_VERSION}-linux-armv7l.zip" \
            "ffmpeg-v${_ELECTRON_VERSION}-linux-x64.zip" \
            "ffmpeg-v${_ELECTRON_VERSION}-win32-arm64.zip" \
            "ffmpeg-v${_ELECTRON_VERSION}-win32-ia32.zip" \
            "ffmpeg-v${_ELECTRON_VERSION}-win32-x64.zip"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    # chromedriver
    true && {
        for i in \
            "chromedriver-v${_ELECTRON_VERSION}-linux-arm64.zip" \
            "chromedriver-v${_ELECTRON_VERSION}-linux-armv7l.zip" \
            "chromedriver-v${_ELECTRON_VERSION}-linux-x64.zip" \
            "chromedriver-v${_ELECTRON_VERSION}-win32-arm64.zip" \
            "chromedriver-v${_ELECTRON_VERSION}-win32-ia32.zip" \
            "chromedriver-v${_ELECTRON_VERSION}-win32-x64.zip"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    # mksnapshot
    true && {
        for i in \
            "mksnapshot-v${_ELECTRON_VERSION}-linux-arm64-x64.zip" \
            "mksnapshot-v${_ELECTRON_VERSION}-linux-armv7l-x64.zip" \
            "mksnapshot-v${_ELECTRON_VERSION}-linux-x64.zip" \
            "mksnapshot-v${_ELECTRON_VERSION}-win32-arm64-x64.zip" \
            "mksnapshot-v${_ELECTRON_VERSION}-win32-ia32.zip" \
            "mksnapshot-v${_ELECTRON_VERSION}-win32-x64.zip"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    # libcxx
    true && {
        for i in \
            "libcxx-objects-v${_ELECTRON_VERSION}-linux-arm64.zip" \
            "libcxx-objects-v${_ELECTRON_VERSION}-linux-armv7l.zip" \
            "libcxx-objects-v${_ELECTRON_VERSION}-linux-x64.zip" \
            "libcxxabi_headers.zip" \
            "libcxx_headers.zip"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    # hunspell_dictionaries
    true && {
        for i in \
            "hunspell_dictionaries.zip"
        do
            my_wget "${_ELECTRON_BASE_URL}/$i"
        done
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'ELECTRON download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_QJSNG_DIST_BASE_URL="https://github.com/quickjs-ng/quickjs/releases/download"
_QJSNG_VERSION="0.13.0"
_QJSNG_BASE_URL="${_QJSNG_DIST_BASE_URL}/v${_QJSNG_VERSION}"
_QJSNG_BASE_NAME="quickjs-ng-${_QJSNG_VERSION}"

[ "${__ENABLE_DOWNLOAD_QJSNG}" = "true" ] && {
    mkdir -p "quickjs-ng/${_QJSNG_BASE_NAME}"
    cd "quickjs-ng/${_QJSNG_BASE_NAME}" || exit $?
    
    my_wget "${_QJSNG_BASE_URL}/qjs-darwin"
    my_wget "${_QJSNG_BASE_URL}/qjs-linux-aarch64"
    my_wget "${_QJSNG_BASE_URL}/qjs-linux-armv7"
    my_wget "${_QJSNG_BASE_URL}/qjs-linux-riscv64"
    my_wget "${_QJSNG_BASE_URL}/qjs-linux-x86"
    my_wget "${_QJSNG_BASE_URL}/qjs-linux-x86_64"
    my_wget "${_QJSNG_BASE_URL}/qjs-wasi-reactor.wasm"
    my_wget "${_QJSNG_BASE_URL}/qjs-wasi.wasm"
    my_wget "${_QJSNG_BASE_URL}/qjs-windows-x86.exe"
    my_wget "${_QJSNG_BASE_URL}/qjs-windows-x86_64.exe"
    my_wget "${_QJSNG_BASE_URL}/qjsc-darwin"
    my_wget "${_QJSNG_BASE_URL}/qjsc-linux-aarch64"
    my_wget "${_QJSNG_BASE_URL}/qjsc-linux-armv7"
    my_wget "${_QJSNG_BASE_URL}/qjsc-linux-riscv64"
    my_wget "${_QJSNG_BASE_URL}/qjsc-linux-x86"
    my_wget "${_QJSNG_BASE_URL}/qjsc-linux-x86_64"
    my_wget "${_QJSNG_BASE_URL}/qjsc-windows-x86.exe"
    my_wget "${_QJSNG_BASE_URL}/qjsc-windows-x86_64.exe"
    my_wget "${_QJSNG_BASE_URL}/quickjs-amalgam.zip"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'QJSNG download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_BUN_DIST_BASE_URL="https://github.com/oven-sh/bun/releases/download"
_BUN_VERSION="1.3.14"
_BUN_BASE_URL="${_BUN_DIST_BASE_URL}/bun-v${_BUN_VERSION}"
_BUN_BASE_NAME="bun-v${_BUN_VERSION}"

[ "${__ENABLE_DOWNLOAD_BUN}" = "true" ] && {
    mkdir -p "bun/${_BUN_BASE_NAME}"
    cd "bun/${_BUN_BASE_NAME}" || exit $?
    # linux-x64
    my_wget "${_BUN_BASE_URL}/bun-linux-x64.zip"
    my_wget "${_BUN_BASE_URL}/bun-linux-x64-baseline.zip"
    # linux-x64-musl
    my_wget "${_BUN_BASE_URL}/bun-linux-x64-musl.zip"
    my_wget "${_BUN_BASE_URL}/bun-linux-x64-musl-baseline.zip"
    # linux-arm64
    my_wget "${_BUN_BASE_URL}/bun-linux-aarch64.zip"
    # linux-arm64-musl
    my_wget "${_BUN_BASE_URL}/bun-linux-aarch64-musl.zip"
    # win-x64
    my_wget "${_BUN_BASE_URL}/bun-windows-x64.zip"
    my_wget "${_BUN_BASE_URL}/bun-windows-x64-baseline.zip"
    # win-arm64
    my_wget "${_BUN_BASE_URL}/bun-windows-aarch64.zip"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BUN download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_BUN_CANARY_COMMIT="19d8ade2c6c1f0eeae50bd9d7f2a4bf4a2551557"
_BUN_CANARY_BASE_URL="https://github.com/oven-sh/bun/releases/download/canary"
_BUN_CANARY_BASE_NAME="bun-canary-${_BUN_CANARY_COMMIT}"
[ "${__ENABLE_DOWNLOAD_BUN_CANARY}" = "true" ] && {
    mkdir -p "bun/canary/${_BUN_CANARY_BASE_NAME}"
    cd "bun/canary/${_BUN_CANARY_BASE_NAME}" || exit $?
    # linux-x64
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-x64.zip"
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-x64-baseline.zip"
    # linux-x64-musl
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-x64-musl.zip"
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-x64-musl-baseline.zip"
    # linux-arm64
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-aarch64.zip"
    # linux-arm64-musl
    my_wget "${_BUN_CANARY_BASE_URL}/bun-linux-aarch64-musl.zip"
    # win-x64
    my_wget "${_BUN_CANARY_BASE_URL}/bun-windows-x64.zip"
    my_wget "${_BUN_CANARY_BASE_URL}/bun-windows-x64-baseline.zip"
    # win-arm64
    my_wget "${_BUN_CANARY_BASE_URL}/bun-windows-aarch64.zip"

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

    my_wget "${_BBW32_BASE_URL}/busybox-${_BBW32_VERSION}.1.gz"
    my_wget "${_BBW32_BASE_URL}/busybox-w32-${_BBW32_VERSION}.tgz"
    my_wget "${_BBW32_BASE_URL}/busybox-w32-${_BBW32_VERSION}.exe"
    my_wget "${_BBW32_BASE_URL}/busybox-w64-${_BBW32_VERSION}.exe"
    my_wget "${_BBW32_BASE_URL}/busybox-w64u-${_BBW32_VERSION}.exe"
    my_wget "${_BBW32_BASE_URL}/busybox-w64a-${_BBW32_VERSION}.exe"

    cd ..
    mkdir current
    cd current
    
    my_wget "${_BBW32_BASE_URL}/busybox.1.gz"
    my_wget "${_BBW32_BASE_URL}/busybox.exe"
    my_wget "${_BBW32_BASE_URL}/busybox64.exe"
    my_wget "${_BBW32_BASE_URL}/busybox64u.exe"
    my_wget "${_BBW32_BASE_URL}/busybox64a.exe"

    cd ..
    mkdir pre-release
    cd pre-release

    my_wget "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre.exe"
    my_wget "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre32w.exe"
    my_wget "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64.exe"
    my_wget "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64u.exe"
    my_wget "${_BBW32_PRE_RELEASE_BASE_URL}/busybox_pre64a.exe"

    cd ..
    mkdir release-notes
    cd release-notes
    
    my_wget "${_BBW32_REL_NOTES_BASE_URL}/${_BBW32_BASE_VERSION}.html"
    my_wget "${_BBW32_REL_NOTES_BASE_URL}/current.html"
    my_wget "${_BBW32_REL_NOTES_BASE_URL}/index.html"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'BBW32 download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_W64DEVKIT_DIST_BASE_URL="https://github.com/skeeto/w64devkit/releases/download"
_W64DEVKIT_VERSION="2.7.0"
_W64DEVKIT_BASE_URL="${_W64DEVKIT_DIST_BASE_URL}/v${_W64DEVKIT_VERSION}"
_W64DEVKIT_BASE_NAME="w64devkit-${_W64DEVKIT_VERSION}"
[ "${__ENABLE_DOWNLOAD_W64DEVKIT}" = "true" ] && {
    mkdir -p "w64devkit/${_W64DEVKIT_BASE_NAME}"
    cd "w64devkit/${_W64DEVKIT_BASE_NAME}" || exit $?
    
    my_wget "${_W64DEVKIT_BASE_URL}/w64devkit-x64-${_W64DEVKIT_VERSION}.7z.exe"
    my_wget "${_W64DEVKIT_BASE_URL}/w64devkit-x86-${_W64DEVKIT_VERSION}.7z.exe"
    my_wget "${_W64DEVKIT_BASE_URL}/source.tar"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'W64DEVKIT download was disabled' >>"${_ARTIFACTS}/stderr.txt"

_PWSH_DIST_BASE_URL="https://github.com/PowerShell/PowerShell/releases/download"
_PWSH_VERSION="7.6.1"
_PWSH_BASE_URL="${_PWSH_DIST_BASE_URL}/v${_PWSH_VERSION}"
_PWSH_BASE_NAME="pwsh-${_PWSH_VERSION}"
[ "${__ENABLE_DOWNLOAD_PWSH}" = "true" ] && {
    mkdir -p "pwsh/${_PWSH_BASE_NAME}"
    cd "pwsh/${_PWSH_BASE_NAME}" || exit $?
    
    my_wget "${_PWSH_BASE_URL}/hashes.sha256"
    # linux-package
    false && {
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-1.cm.aarch64.rpm"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-1.cm.x86_64.rpm"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-1.rh.x86_64.rpm"
        my_wget "${_PWSH_BASE_URL}/powershell_${_PWSH_VERSION}-1.deb_amd64.deb"
    }
    # linux-archive
    true && {
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-arm32.tar.gz"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-arm64.tar.gz"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-musl-x64.tar.gz"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-x64-fxdependent.tar.gz"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-x64-musl-noopt-fxdependent.tar.gz"
        my_wget "${_PWSH_BASE_URL}/powershell-${_PWSH_VERSION}-linux-x64.tar.gz"
    }
    # win-x64
    true && {
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-x64.msi"
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-x64.zip"
    }
    # win-x86
    true && {
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-x86.msi"
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-x86.zip"
    }
    # win-arm64
    false && {
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-arm64.msi"
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-arm64.zip"
    }
    # win-fxdependent
    true && {
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-fxdependent.zip"
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}-win-fxdependentWinDesktop.zip"
    }
    # win-msixbundle
    false && {
        my_wget "${_PWSH_BASE_URL}/PowerShell-${_PWSH_VERSION}.msixbundle"
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'PWSH download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_TCMD_DIST_BASE_URL="https://jpsoft.com/downloads"
_TCMD_VERSION="36"
_TCMD_BASE_URL="${_TCMD_DIST_BASE_URL}/v${_TCMD_VERSION}"
_TCMD_BASE_NAME="tcmd-${_TCMD_VERSION}"

[ "${__ENABLE_DOWNLOAD_TCMD}" = "true" ] && {
    mkdir -p "tcmd/${_TCMD_BASE_NAME}"
    cd "tcmd/${_TCMD_BASE_NAME}" || exit $?

    my_wget "${_TCMD_BASE_URL}/tcmd.exe"
    my_wget "${_TCMD_BASE_URL}/tcc.exe"
    my_wget "${_TCMD_BASE_URL}/cmdebug.exe"
    my_wget "${_TCMD_BASE_URL}/tcc-rt.exe"
    my_wget "${_TCMD_BASE_URL}/TakeCommand.pdf"
    my_wget "${_TCMD_BASE_URL}/TakeCommand.ewriter"
    my_wget "${_TCMD_BASE_URL}/CMDebug.pdf"
    my_wget "${_TCMD_BASE_URL}/CMDebug.ewriter"

    my_wget "https://jpsoft.com/all-downloads/all-downloads.html"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TCMD download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_VSCODE_DIST_BASE_URL="https://update.code.visualstudio.com"
_VSCODE_VERSION="1.120.0"
_VSCODE_BASE_URL="${_VSCODE_DIST_BASE_URL}/${_VSCODE_VERSION}"
_VSCODE_BASE_NAME="vscode-${_VSCODE_VERSION}"

[ "${__ENABLE_DOWNLOAD_VSCODE}" = "true" ] && {
    mkdir -p "vscode/${_VSCODE_BASE_NAME}"
    cd "vscode/${_VSCODE_BASE_NAME}" || exit $?
    
	# win-x64
    true && {
        # Windows x64 System installer
        my_wget "${_VSCODE_BASE_URL}/win32-x64/stable" "" --no-verbose --content-disposition

        # Windows x64 User installer
        my_wget "${_VSCODE_BASE_URL}/win32-x64-user/stable" "" --no-verbose --content-disposition

        # Windows x64 zip
        my_wget "${_VSCODE_BASE_URL}/win32-x64-archive/stable" "" --no-verbose --content-disposition

        # Windows x64 CLI
        my_wget "${_VSCODE_BASE_URL}/cli-win32-x64/stable" "" --no-verbose --content-disposition
    }

    # win-arm64
    false && {
        # Windows Arm64 System installer
        my_wget "${_VSCODE_BASE_URL}/win32-arm64/stable" "" --no-verbose --content-disposition

        # Windows Arm64 User installer
        my_wget "${_VSCODE_BASE_URL}/win32-arm64-user/stable" "" --no-verbose --content-disposition

        # Windows Arm64 zip
        my_wget "${_VSCODE_BASE_URL}/win32-arm64-archive/stable" "" --no-verbose --content-disposition

        # Windows Arm64 CLI
        my_wget "${_VSCODE_BASE_URL}/cli-win32-arm64/stable" "" --no-verbose --content-disposition
    }

    # linux-x64
    false && {
        # Linux x64
        my_wget "${_VSCODE_BASE_URL}/linux-x64/stable" "" --no-verbose --content-disposition

        # Linux x64 debian
        my_wget "${_VSCODE_BASE_URL}/linux-deb-x64/stable" "" --no-verbose --content-disposition

        # Linux x64 rpm
        my_wget "${_VSCODE_BASE_URL}/linux-rpm-x64/stable" "" --no-verbose --content-disposition

        # Linux x64 snap
        my_wget "${_VSCODE_BASE_URL}/linux-snap-x64/stable" "" --no-verbose --content-disposition

        # Linux x64 CLI
        my_wget "${_VSCODE_BASE_URL}/cli-linux-x64/stable" "" --no-verbose --content-disposition
    }

    # linux-arm32
    false && {
        # Linux Arm32
        my_wget "${_VSCODE_BASE_URL}/linux-armhf/stable" "" --no-verbose --content-disposition

        # Linux Arm32 debian
        my_wget "${_VSCODE_BASE_URL}/linux-deb-armhf/stable" "" --no-verbose --content-disposition

        # Linux Arm32 rpm
        my_wget "${_VSCODE_BASE_URL}/linux-rpm-armhf/stable" "" --no-verbose --content-disposition

        # Linux Arm32 CLI
        my_wget "${_VSCODE_BASE_URL}/cli-linux-armhf/stable" "" --no-verbose --content-disposition
    }

    # linux-arm64
    false && {
        # Linux Arm64
        my_wget "${_VSCODE_BASE_URL}/linux-arm64/stable" "" --no-verbose --content-disposition

        # Linux Arm64 debian
        my_wget "${_VSCODE_BASE_URL}/linux-deb-arm64/stable" "" --no-verbose --content-disposition

        # Linux Arm64 rpm
        my_wget "${_VSCODE_BASE_URL}/linux-rpm-arm64/stable" "" --no-verbose --content-disposition

        # Linux Arm64 CLI
        my_wget "${_VSCODE_BASE_URL}/cli-linux-arm64/stable" "" --no-verbose --content-disposition
    }

    # macOS
    false && {
        # macOS Universal
        my_wget "${_VSCODE_BASE_URL}/darwin-universal/stable" "" --no-verbose --content-disposition

        # macOS Intel chip
        my_wget "${_VSCODE_BASE_URL}/darwin/stable" "" --no-verbose --content-disposition

        # macOS Intel chip CLI
        my_wget "${_VSCODE_BASE_URL}/cli-darwin-x64/stable" "" --no-verbose --content-disposition

        # macOS Apple silicon
        my_wget "${_VSCODE_BASE_URL}/darwin-arm64/stable" "" --no-verbose --content-disposition

        # macOS Apple silicon CLI
        my_wget "${_VSCODE_BASE_URL}/cli-darwin-arm64/stable" "" --no-verbose --content-disposition
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'VSCODE download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_MSEDIT_DIST_BASE_URL="https://github.com/microsoft/edit/releases/download"
_MSEDIT_VERSION="2.0.0"
_MSEDIT_BASE_URL="${_MSEDIT_DIST_BASE_URL}/v${_MSEDIT_VERSION}"
_MSEDIT_BASE_NAME="edit-${_MSEDIT_VERSION}"

[ "${__ENABLE_DOWNLOAD_MSEDIT}" = "true" ] && {
    mkdir -p "microsoft-edit/${_MSEDIT_BASE_NAME}"
    cd "microsoft-edit/${_MSEDIT_BASE_NAME}" || exit $?
    # linux-x64
    my_wget "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-x86_64-linux-gnu.tar.gz"
    # linux-arm64
    my_wget "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-aarch64-linux-gnu.tar.gz"
    # win-x64
    my_wget "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-x86_64-windows.zip"
    # win-arm64
    my_wget "${_MSEDIT_BASE_URL}/${_MSEDIT_BASE_NAME}-aarch64-windows.zip"
    # src
    my_wget "https://github.com/microsoft/edit/archive/refs/tags/v${_MSEDIT_VERSION}.tar.gz" "" --no-verbose --content-disposition

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'MSEDIT download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_MSDEF}" = "true" ] && {
    _MSDEF_BASE_NAME="mpam-fe"
    mkdir -p "${_MSDEF_BASE_NAME}"
    cd "${_MSDEF_BASE_NAME}" || exit $?

    # x64
    my_wget "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=x64" "${_MSDEF_BASE_NAME}_x64.exe"

    # x86
    # my_wget "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=x86" "${_MSDEF_BASE_NAME}_x86.exe"

    # arm64
    # my_wget "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=arm64" "${_MSDEF_BASE_NAME}_arm64.exe"

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
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_386.tar.gz"
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_amd64.tar.gz"
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_linux_arm64.tar.gz"
    # win-x86
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_386.msi"
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_386.zip"
    # win-x64
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_amd64.msi"
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_amd64.zip"
    # win-arm64
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_arm64.msi"
    my_wget "${_GITHUB_CLI_BASE_URL}/${_GITHUB_CLI_BASE_NAME}_windows_arm64.zip"
    # src
    my_wget "https://github.com/cli/cli/archive/refs/tags/v${_GITHUB_CLI_VERSION}.tar.gz" "" --no-verbose --content-disposition

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'GITHUB_CLI download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_7ZIP_DIST_BASE_URL="https://github.com/ip7z/7zip/releases/download"
_7ZIP_VERSION="26.01"
_7ZIP_BASE_URL="${_7ZIP_DIST_BASE_URL}/${_7ZIP_VERSION}"
_7ZIP_BASE_NAME="7zip-${_7ZIP_VERSION}"

[ "${__ENABLE_DOWNLOAD_7ZIP}" = "true" ] && {
    mkdir -p "7zip/${_7ZIP_BASE_NAME}"
    cd "7zip/${_7ZIP_BASE_NAME}" || exit $?

    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-arm.exe"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-arm64.exe"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-extra.7z"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-arm.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-arm64.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-x64.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-linux-x86.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-mac.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-src.7z"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-src.tar.xz"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-x64.exe"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}-x64.msi"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}.exe"
    my_wget "${_7ZIP_BASE_URL}/7z${_7ZIP_VERSION/./}.msi"
    my_wget "${_7ZIP_BASE_URL}/lzma${_7ZIP_VERSION/./}.7z"
    my_wget "${_7ZIP_BASE_URL}/7zr.exe"

    my_wget "https://github.com/ip7z/7zip/archive/refs/tags/${_7ZIP_VERSION}.tar.gz" "" --no-verbose --content-disposition
    my_wget "https://github.com/ip7z/7zip/archive/refs/tags/${_7ZIP_VERSION}.zip" "" --no-verbose --content-disposition

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo '7ZIP download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_RUBY_INSTALLER_WIN}" = "true" ] && {
    mkdir -p "rubyinstaller"
    cd "rubyinstaller" || exit $?

    # ruby-4.0
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-4.0.3-1-x64.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-4.0.3-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-4.0.3-1/rubyinstaller-devkit-4.0.3-1-x64.exe"
    # ruby-3.4    
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x64.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x86.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-3.4.9-1-x86.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-devkit-3.4.9-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.9-1/rubyinstaller-devkit-3.4.9-1-x86.exe"
    # ruby-3.3
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x64.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x86.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-3.3.11-1-x86.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-devkit-3.3.11-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.11-1/rubyinstaller-devkit-3.3.11-1-x86.exe"
    # ruby-3.2
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x64.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x86.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-3.2.11-1-x86.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-devkit-3.2.11-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.11-1/rubyinstaller-devkit-3.2.11-1-x86.exe"
    # ruby-2.7
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x64.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x86.7z"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x86.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-devkit-2.7.8-1-x64.exe"
    my_wget "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-devkit-2.7.8-1-x86.exe"
    # ruby-2.3
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-doc-chm.7z"
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-i386-mingw32.7z"
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/ruby-2.3.3-x64-mingw32.7z"
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/rubyinstaller-2.3.3.exe"
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/ruby-2.3.3/rubyinstaller-2.3.3-x64.exe"
    # DevKit 4.7.2 (20130224, Ruby 2.0 Edition)
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/devkit-4.7.2/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
    my_wget "https://github.com/oneclick/rubyinstaller/releases/download/devkit-4.7.2/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'RUBY_INSTALLER_WIN download was disabled' >>"${_ARTIFACTS}/stderr.txt"

[ "${__ENABLE_DOWNLOAD_CHROME}" = "true" ] && {
    mkdir -p "google-chrome"
    cd "google-chrome" || exit $?
    GoogleChromeStandaloneEnterprise64="https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
    GoogleChromeStandaloneEnterprise="https://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"
    ChromeStandaloneSetup64="https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BFDC21362-D83A-7CF4-7354-10A215B91416%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3D-arch_x64-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup64.exe"
    ChromeStandaloneSetup="https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BFDC21362-D83A-7CF4-7354-10A215B91416%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3D-arch_x86-statsdef_1%26installdataindex%3Dempty/chrome/install/ChromeStandaloneSetup.exe"

    my_wget "${GoogleChromeStandaloneEnterprise64}"
    # my_wget "${GoogleChromeStandaloneEnterprise}"
    # my_wget "${ChromeStandaloneSetup64}"
    # my_wget "${ChromeStandaloneSetup}"

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'CHROME download was disabled' >>"${_ARTIFACTS}/stderr.txt"


[ "${__ENABLE_DOWNLOAD_TMP}" = "true" ] && {
    mkdir "tmp"
    cd "tmp" || exit $?

    # my_wget "https://jpsoft.com/all-downloads/all-downloads.html"
    # my_wget "https://en.wikipedia.org/api/rest_v1/page/pdf/TCP_hole_punching" ""  --no-verbose --user-agent="Mozilla/5.0" --content-disposition
    # my_wget "https://en.wikipedia.org/api/rest_v1/page/pdf/Cranelift" ""  --no-verbose --user-agent="Mozilla/5.0" --content-disposition

    # my_wget "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    # my_wget "https://download.sysinternals.com/files/PSTools.zip"

    # my_wget "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe"
    # my_wget "https://www.nuget.org/api/v2/package/Git-Windows-Minimal/2.54.0" "git-windows-minimal.2.54.0.nupkg"
    # my_wget "https://www.nuget.org/api/v2/package/GitForWindows/2.54.0" "gitforwindows.2.54.0.nupkg"

    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-amd64.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-arm64.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-windows-4.0-amd64.exe.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-gogit-windows-4.0-amd64.exe.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-linux-386.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-gogit-windows-4.0-386.exe.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-windows-4.0-386.exe.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-1.26.1-freebsd14-amd64.xz"
    # my_wget "https://github.com/go-gitea/gitea/releases/download/v1.26.1/gitea-src-1.26.1.tar.gz"

    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/dokan.zip"
    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/DokanSetup.exe"
    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/DokanSetupDbg.exe"
    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_ARM64.msi"
    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_x64.msi"
    # my_wget "https://github.com/dokan-dev/dokany/releases/download/v2.3.1.1000/Dokan_x86.msi"
    # my_wget "https://github.com/dokan-dev/dokan-dotnet/releases/download/v2.3.0.3/DokanNet.2.3.0.3.nupkg"

    # my_wget "https://github.com/jrsoftware/issrc/releases/download/is-6_7_1/innosetup-6.7.1.exe"
    # my_wget "https://github.com/jrsoftware/issrc/releases/download/is-7_0_0_2/innosetup-7.0.0-preview-3-x64.exe"
    # my_wget "https://github.com/jrsoftware/issrc/releases/download/is-7_0_0_2/innosetup-7.0.0-preview-3-x86.exe"

    # my_wget 'https://clients2.google.com/service/update2/crx?response=redirect&os=Linux&arch=x86-64&os_arch=x86-64&prod=chromecrx&prodchannel=unknown&prodversion=148.0.7778.97&acceptformat=crx3&x=id%3Dmmhpicejjhcogggmjagbbhgffbckmeic%26uc' 'mmhpicejjhcogggmjagbbhgffbckmeic.crx' --no-verbose --referer='https://chrome.google.com/webstore/detail/mmhpicejjhcogggmjagbbhgffbckmeic?hl=en' --user-agent='Mozilla/5.0 148.0.7778.97'

	# my_wget "https://github.com/tinygo-org/tinygo/releases/download/v0.41.1/tinygo0.41.1.linux-amd64.tar.gz"
    # my_wget "https://github.com/tinygo-org/tinygo/releases/download/v0.41.1/tinygo0.41.1.windows-amd64.zip"


    # my_wget "https://bun.com/blog/bun-v1.3.14/" "1.3.14.html"
    # my_wget "https://bun.com/blog/bun-v1.3.13/" "1.3.13.html"
	# my_wget "https://bun.com/blog/bun-v1.3.12/" "1.3.12.html"
	# my_wget "https://bun.com/blog/bun-v1.3.11/" "1.3.11.html"
	# my_wget "https://bun.com/blog/" "blog.html"

    # get_node_api_docs "26.2.0"
    # get_node_api_docs "24.16.0"
    # get_node_api_docs "22.22.3"





# /**********

my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/growth-banner-partial.87daefc4480bc9b2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/growth-banner-partial.87daefc4480bc9b2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99753-f2dd8cba1a51fae0.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/70785.1e46f17bb6015cb2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/70785.1e46f17bb6015cb2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99753-f2dd8cba1a51fae0.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/70785.1e46f17bb6015cb2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99753-f2dd8cba1a51fae0.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/70785.1e46f17bb6015cb2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99753-f2dd8cba1a51fae0.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99753-f2dd8cba1a51fae0.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/growth-banner-partial.87daefc4480bc9b2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/growth-banner-partial.87daefc4480bc9b2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-33454-a9e3bfd7b2bdce5b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-33454-a9e3bfd7b2bdce5b.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-33454-a9e3bfd7b2bdce5b.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-33454-a9e3bfd7b2bdce5b.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/5158-869ec20e1fbbf0a5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/26660-fc1ee22cceacaaef.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/84259-9cfe0a9dd2551f1d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-pulse-e4cda9f97e10302f.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-pulse.3564a22124ef481a.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/12868-5ea40b704f8d3c5b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-contributors-chart-4b5dd94ad487fb8a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-contributors-chart.00087b2eb3543a96.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/22454-439a4d5be7220025.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/community-840205e3843a529b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/40975-51774138914ccd3f.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-traffic-4446b833cd54fbba.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-traffic.9147d573157ff985.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-commit-activity-1dec2ed2a04cbb38.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-code-frequency-4cc1cef10eb76aac.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repos-code-frequency.7f30349eb999dbb2.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-80299-cb3da7814aa337f4.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-80299-cb3da7814aa337f4.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-80299-cb3da7814aa337f4.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-80299-cb3da7814aa337f4.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/forks-f356171c11a7d654.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/91916-450c1f016f72552b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/62235-0f823ceefb55a81d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/65692-7971849ecac60a94.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/actions-metrics-5d8036e80c4999db.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/actions-metrics.0c6b640cabfcb444.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/91916-450c1f016f72552b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/62235-0f823ceefb55a81d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/65692-7971849ecac60a94.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/actions-metrics-5d8036e80c4999db.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/actions-metrics.0c6b640cabfcb444.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/84638-c3125f51ca262ab2.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repo-agents-eeaea98c90e50d3d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repo-agents.470e41da9db5b82a.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/pull-requests-bdf727fe7c51d7e2.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/copilot-code-review-217c7a1abb27f2d0.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/45775-15add331c937bbe5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/1030-8e701d2e4fba6a27.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/18233-54d39c5ce7a5714c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/diffs-cbcc81f94c429cf8.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/76198-9ce8b799a0ec5a95.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/pull-requests-list-457bfcb4ffe6752c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/90501-6e0e1c9ec878cfa9.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/structured-issues-a1fb895cbc7e3cbd.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/94590-90c4a4d00db8e159.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/62751-a1364419ab1be681.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/63887-b38e3f4f1d4b3698.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/issues-react-2d7497e029fc6588.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/63887.0b2073584ed3fd57.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/issues-react.6b02621312e3865b.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/77343.e5e12995d42b85c6.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/7021.2bb9a5abb14ffbab.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/4861.303ec184c9a5bfff.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/65076-22657653318e9260.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/85734-014b6b998b3d3b28.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/73696-2c9a018834696454.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-88830-a42e73725de9bd4b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/34619-d8b77c3e1384d962.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/86088-9b88404c40758ade.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-77343-0201f93d83a51176.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/55182-d822f186eb446cac.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-7021-b856c694a50c75fa.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-39648-42c58292ff3d02f8.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-IssueIndexPage-ce99c0977f27b2c6.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-7890-7ecde402f3a1da42.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-IssueDashboardCustomViewPage-f2a4a7960a847dad.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-IssueDashboardKnownViewPage-e00486cba042031c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-IssueDashboardPage-739868c3d779b21c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-IssueViewsPage-b766ca2d5b88d758.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-RepositoryLabelIndexPage-f4ea4166f58401ca.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-48364-a5e88440b9e9d2e9.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-RepositoryMilestoneIndexPage-924a178c76edce7b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-RepositoryMilestonePage-f9ebac289764e9cf.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-RepositoryProjectsPage-388455c7193c0cfb.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-issue-new-IssueRepoNewChoosePage-d0ce982d8f316261.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-issue-new-IssueRepoNewPage-6e2e6ec95fa30825.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-53872-3edc1f968c9824d5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-milestone-edit-RepositoryMilestoneEditPage-f8e43c2b79329793.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-milestone-new-RepositoryMilestoneNewPage-db6357d407d1201b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-views-new-RepositoryViewNewPage-eb3e4cffba31e4b7.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-dynamic-github-ui--issues-react--pages-views-show-RepositorySavedViewPage-7983ba6c65c4b813.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/77343.e5e12995d42b85c6.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/7021.2bb9a5abb14ffbab.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/49327.0e03a8cb05bf5597.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/45949.87ceb0509f8bb832.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/5757.b924132c75cb817b.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/54431.c29fa76ca21f4215.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/91062.cc745f1e730fd27d.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/49218.4d478cee89da11ec.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/47286.7bcdd17fce34002b.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/34450.28da1e9f0ccac6a5.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/2857.948dd016f3c71176.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20976.f45bf3c2d71227e6.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/53872.8e979ceb23666340.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/38493.a64a267289c1bbb5.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/36615.40c8407ee74214ef.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-react-profiling-9293ef1077b1fb4d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-react-profiling-9293ef1077b1fb4d.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-react-profiling-9293ef1077b1fb4d.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-react-profiling-9293ef1077b1fb4d.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=1' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43688.626d881943906072.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-43688-22f1d8a0a604bc81.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=2' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/20401-c5f09b66faaad58c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/51976-0ee86672498abf63.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-59651-b55e76f3e6497712.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/3550-59d66c978aac9b7e.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/59204-8e14c8acf0bdd68a.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/chunk-91739-d2c5e93c9d302f6c.js?&r=3' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/67005-c472b1b6a010a7ad.js?&r=3' '' --no-verbose --continue
# **********/


    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TMP download was disabled' >>"${_ARTIFACTS}/stderr.txt"

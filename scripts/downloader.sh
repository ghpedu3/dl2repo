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

_dir="github.githubassets.com/assets"
mkdir -p "${_dir}"
pushd "${_dir}"

my_wget 'https://github.githubassets.com/assets/light-4fded0090af0ad58.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/dark-06381ff23d863842.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-primitives-b39ad27f3538ace3.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-tailwind-compatible-f6d3d8f030269244.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/global-9c8f61f9f58ad7b2.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/github-be05a7e2c0ccd82f.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/tailwind-d018ebb1340f097f.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repository-5c3491d57145b94f.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/code-34e10031edc15af1.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/wp-runtime-e8b206e20d6d7bbb.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/fetch-utilities-b82d70fb3b7c15af.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/78205-a328faf42e1fde9e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/85924-1f0f5f61600f9c8e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/34646-0b1ef764f04384f8.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/environment-d69fe59c085ecc72.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/runtime-helpers-6e561c87b9671d53.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/296-b57454e133edfa64.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/96232-069a02c82c8693ee.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/57131-79aa62319c40af83.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/816-774d14a8cd9b309c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/79280-d76a66e0574d2c2d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/81683-58949462db0c5675.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/46740-4421ca06d57312cc.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/82097-deb8524559e82c88.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/30058-edeab9486bacdd1a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/github-elements-aa06f97004324c94.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/element-registry-c07fced853e9f5bc.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/react-core-dadcfce67bf6932a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/react-lib-e93338a8d08b8bb9.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/79039-f2b81734929d0b15.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/88475-92437d3f8c9a9747.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/2887-d67f71d8e1d3e1d8.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/26533-318ac47648fb7752.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/46477-596c4ee4da73ac9a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/34771-52ff9a0204045b56.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/33232-a61b173cd548f3cb.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/46287-fc23b9847d26823b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/28000-450a3042fe455862.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/89627-12a64f4329866bd1.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/55682-a358ec7c2f348fcf.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/49029-3a132de206358025.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/99328-82a96596275fbd3e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/behaviors-eb258e42b23869c8.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/react-core.bdacde97e4ec0e99.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/61272-d797d8a9ce83f9c1.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/notifications-global-be20ba1998b9a752.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/57639-ed467af96719bd33.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/778-a664589d50af677a.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/70206-61154d4f392ace98.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/19930-9d606db64e5e8a82.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/repositories-a46ab7774ff6ab75.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-react-d152c207c2235650.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/octicons-react-fa41822493eeb852.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/97698-c2ef7228d0c1e6c7.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/24949-7df9a84e133032e5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/68751-3dce390992441fd6.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/26958-b75de923c35f85c1.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/437-910fdcc156bd331b.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/29844-c0bd6ecd0a224f40.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/15272-37128cbcef9c407d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/90017-ec023615229a20a1.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/24564-14df7faa28380ddf.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/5507-0ce7a9ba512e9ca3.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/24520-3be16f0458effc22.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/25164-4185d9d47e586cea.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/41417-be5311ec2e064599.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/45442-5001a7084436fa0f.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/10944-8d6b43dc7e129f90.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/87954-50e37877c32c3e36.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/65354-1edcfc5ed9f583c7.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/58636-2058123be0cade25.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/5015-8d2ffcf3d8794a71.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/82345-797380966dc35469.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/40145-ff486a4594e63459.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/58246-4ba5ac2265364faa.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/96522-0be17c3c4593a419.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/12612-30dde4e195f84e7d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/98356-721f5a5b43ebdf7f.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/37494-8ad7eb20aa952a1d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/68469-79baed2a4e2068eb.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/74444-caa64168e8e77f1c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/40828-b87e73333d92bc0d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/32033-7092ee28456d0c9c.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/75740-96f680cbcbf41dde.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/63000-72d947f3c46087f0.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/6849-49346f11d81ad429.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/30914-7ba0116fd9aa8391.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/1334-b006fc225cccabf7.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/79407-e53b8892ea29c60d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/72955-e275eec42ae0ca34.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/78816-604d6a256503eea0.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/11059-3123361cd25d417f.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/19838-e41ffea284ea4cfe.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/91982-07d37e59d7185ef3.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/2204-cb10cab94072aae5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/68212-a1d5f5bbacc287f0.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/34469-ca354f16681e6315.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/15151-d56fdcef6cbca06e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/12377-eef88ceef1792a7d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/87894-46788aff18f38cc3.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/21625-bbb75aec387a2192.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/12912-cd6be88c5b08760d.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/23550-cc333fdff19339e4.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/29689-8b05ad0c1915d6e1.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/69317-44118410b3ec70e5.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/19824-1aec924fde1baf1e.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/43623-64217aa7fc715cb2.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/79625-a7e68e4d59374e94.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/97562-9a810293bc84d9d9.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/2165-ae2934ba54284866.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/14197-127bdbfb2dcc3ea2.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/commits-c057a8c06a5b4725.js' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-react-css.ac981de652dc3db9.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/6849.c5c7d862d1c4d2f6.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/78816.c5f3d1eba97d6b93.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/12377.183edf4eb71e673b.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/69317.14cbd3a8e68217e8.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/14197.cd99a0d2c53a83f0.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/commits.ef7d505ac700c3b7.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-react-css.ac981de652dc3db9.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/keyboard-shortcuts-dialog.17facd6dcac95d36.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/global-nav-bar.7fd3d877f3f31ae9.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/primer-react-css.ac981de652dc3db9.module.css' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/assets/apple-touch-icon-144x144-b882e354c005.png' '' --no-verbose --continue

popd
_dir="github.githubassets.com/favicons"
mkdir -p "${_dir}"
pushd "${_dir}"

my_wget 'https://github.githubassets.com/favicons/favicon.svg' '' --no-verbose --continue
my_wget 'https://github.githubassets.com/favicons/favicon.png' '' --no-verbose --continue

popd
_dir="avatars.githubusercontent.com/u"
mkdir -p "${_dir}"
pushd "${_dir}"

my_wget 'https://avatars.githubusercontent.com/u/164553489?v=4&size=64' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/278781274?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/17734409?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/13602871?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/39903?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/42860321?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/1609021?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/279198639?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/34997667?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/280062030?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/13135287?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/13602871?v=4&size=32' '' --no-verbose --continue
my_wget 'https://avatars.githubusercontent.com/u/17734409?v=4&size=32' '' --no-verbose --continue

popd

# **********/


    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TMP download was disabled' >>"${_ARTIFACTS}/stderr.txt"

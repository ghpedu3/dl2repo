#!/bin/bash

# direct link base
#   https://raw.githubusercontent.com/ghpedu3/test/refs/heads/main/artifacts/
__ENABLE_DOWNLOAD_NODE="false"
__ENABLE_DOWNLOAD_DENO="false"
__ENABLE_DOWNLOAD_CRYSTAL_LANG="false"
__ENABLE_DOWNLOAD_ELECTRON="false"
__ENABLE_DOWNLOAD_QJSNG="false"
__ENABLE_DOWNLOAD_MOZ_JSSHELL="false"
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
__ENABLE_DOWNLOAD_VSCODIUM="false"
__ENABLE_DOWNLOAD_MSDEF="false"
__ENABLE_DOWNLOAD_FORGEJO="false"
__ENABLE_DOWNLOAD_GITEA="false"
__ENABLE_DOWNLOAD_GITHUB_CLI="false"
__ENABLE_DOWNLOAD_7ZIP="false"
__ENABLE_DOWNLOAD_SUMATRA_PDF="false"
__ENABLE_DOWNLOAD_RUBY_INSTALLER_WIN="false"
__ENABLE_DOWNLOAD_TMP="true"



archive_folder() {
    local FOLDER=''
	local ARC_NAME=''

	[ "${1:+#}#" = "#" ] && {
		echo Folder path not specified
		return 1;
	}
	FOLDER="${1}"
	[ -d "${FOLDER}" ] || {
	    echo "The specified path '${FOLDER}' does not exist or is not a directory"
	    return 1
	}
	shift

	[ "${1:+#}#" = "#" ] && {
		ARC_NAME="${FOLDER##*/}.tar.xz"
	} || {
	    ARC_NAME"${1##*/}"
	    [ "${MNAME:+#}#" = "#" ] && {
		  echo The specified archive name is not valid
		  return 1;
	    }
	    ARC_NAME="${ARC_NAME}.tar.xz"
	}

	echo "tar -cJf '${ARC_NAME}' '${FOLDER}'"
	tar -cJf "${ARC_NAME}" "${FOLDER}" && {
	    rm -rf "${FOLDER}"
	    local SIZE=0
	    SIZE=$(stat -c%s "${ARC_NAME}")
	    [ ${SIZE} -gt $((49 * 1024 * 1024)) ] && {
	        echo "split --bytes=49MiB --numeric-suffixes=1 '${ARC_NAME}' '${ARC_NAME}.part'"
	        split --bytes=49MiB --numeric-suffixes=1 "${ARC_NAME}" "${ARC_NAME}.part"
	        rm "${ARC_NAME}"
	    }
	    true
	} || rm -rf "${FOLDER}"
}


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

get_en_wikipedia_pdf() {
    
    local CONST_USER_AGENT="Mozilla/5.0"
    local ARTICLES=()
    [ "${@:+#}#" = "#" ] && {
        echo At least 1 article must be specified
        return 1;
    }
    ARTICLES=("$@")

    mkdir wikipedia-pdf && pushd wikipedia-pdf || return 1
    
    for article in "${ARTICLES[@]}"; do
        my_wget "https://en.wikipedia.org/api/rest_v1/page/pdf/${article}" ""  --no-verbose --user-agent="${CONST_USER_AGENT}" --content-disposition
        sleep 1s
    done
    popd
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
_DENO_VERSION="2.8.0"
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


_CRYSTAL_LANG_DIST_BASE_URL="https://github.com/crystal-lang/crystal/releases/download"
_CRYSTAL_LANG_VERSION="1.20.2"
_CRYSTAL_LANG_BASE_URL="${_CRYSTAL_LANG_DIST_BASE_URL}/${_CRYSTAL_LANG_VERSION}"
_CRYSTAL_LANG_BASE_NAME="crystal-${_CRYSTAL_LANG_VERSION}"

[ "${__ENABLE_DOWNLOAD_CRYSTAL_LANG}" = "true" ] && {
    mkdir -p "crystal-lang/${_CRYSTAL_LANG_BASE_NAME}"
    cd "crystal-lang/${_CRYSTAL_LANG_BASE_NAME}" || exit $?
    
    for slug in \
        '1-linux-aarch64-bundled.tar.gz' \
        '1-linux-aarch64.tar.gz' \
        '1-linux-x86_64-bundled.tar.gz' \
        '1-linux-x86_64.tar.gz' \
        'docs.tar.gz' \
        'windows-aarch64-gnu-unsupported.zip' \
        'windows-x86_64-gnu-unsupported.zip' \
        'windows-x86_64-msvc-unsupported.exe'
    do
        my_wget "${_CRYSTAL_LANG_BASE_URL}/crystal-${_CRYSTAL_LANG_VERSION}-${slug}"
    done
    
    # my_wget "https://github.com/crystal-lang/crystal/archive/refs/tags/${_CRYSTAL_LANG_VERSION}.tar.gz" "" --no-verbose --content-disposition

    mirror_site_wget 'https://crystal-lang.org/reference/' 'crytal-lang_reference'

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'CRYSTAL_LANG download was disabled' >>"${_ARTIFACTS}/stderr.txt"



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
_QJSNG_VERSION="0.15.0"
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


_MOZ_JSSHELL_DIST_BASE_URL="https://ftp.mozilla.org/pub/firefox/releases"
_MOZ_JSSHELL_VERSION="151.0.1"
_MOZ_JSSHELL_BASE_URL="${_MOZ_JSSHELL_DIST_BASE_URL}/${_MOZ_JSSHELL_VERSION}/jsshell"
_MOZ_JSSHELL_BASE_NAME="jsshell-${_MOZ_JSSHELL_VERSION}"

[ "${__ENABLE_DOWNLOAD_MOZ_JSSHELL}" = "true" ] && {
    mkdir -p "jsshell/${_MOZ_JSSHELL_BASE_NAME}"
    cd "jsshell/${_MOZ_JSSHELL_BASE_NAME}" || exit $?
    
    for slug in \
        'jsshell-linux-aarch64.zip' \
        'jsshell-linux-x86_64.zip' \
        'jsshell-mac.zip' \
        'jsshell-win32.zip' \
        'jsshell-win64-aarch64.zip' \
        'jsshell-win64.zip'
    do
        my_wget "${_MOZ_JSSHELL_BASE_URL}/${slug}"
    done

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'MOZ_JSSHELL download was disabled' >>"${_ARTIFACTS}/stderr.txt"



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


_BUN_CANARY_COMMIT="49c97de6b38192db015d26619e5acd26332c80b6"
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



_VSCODIUM_DIST_BASE_URL="https://github.com/VSCodium/vscodium/releases/download"
_VSCODIUM_VERSION="1.121.03429"
_VSCODIUM_BASE_URL="${_VSCODIUM_DIST_BASE_URL}/${_VSCODIUM_VERSION}"
_VSCODIUM_BASE_NAME="vscodium-${_VSCODIUM_VERSION}"

[ "${__ENABLE_DOWNLOAD_VSCODIUM}" = "true" ] && {
    mkdir -p "vscodium/${_VSCODIUM_BASE_NAME}"
    cd "vscodium/${_VSCODIUM_BASE_NAME}" || exit $?

    # win-x64
    true && {
        ## User Installer
        my_wget "${_VSCODIUM_BASE_URL}/VSCodiumUserSetup-x64-${_VSCODIUM_VERSION}.exe"

        ## System Installer
        my_wget "${_VSCODIUM_BASE_URL}/VSCodiumSetup-x64-${_VSCODIUM_VERSION}.exe"

        ## .zip
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-win32-x64-${_VSCODIUM_VERSION}.zip"

        ## .msi - updates enabled
        # my_wget "${_VSCODIUM_BASE_URL}/VSCodium-x64-${_VSCODIUM_VERSION}.msi"

        ## .msi - updates disabled
        # my_wget "${_VSCODIUM_BASE_URL}/VSCodium-x64-updates-disabled-${_VSCODIUM_VERSION}.msi"

        ## Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-win32-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## Web Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-web-win32-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## CLI
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-cli-win32-x64-${_VSCODIUM_VERSION}.tar.gz"
    }

    # linux-x64
    true && {
        ## .deb
        # my_wget "${_VSCODIUM_BASE_URL}/codium_${_VSCODIUM_VERSION}_amd64.deb"

        ## .rpm
        # my_wget "${_VSCODIUM_BASE_URL}/codium-${_VSCODIUM_VERSION}-el8.x86_64.rpm"

        ## .tar.gz
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-linux-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## AppImage
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-${_VSCODIUM_VERSION}.glibc2.30-x86_64.AppImage"
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-${_VSCODIUM_VERSION}.glibc2.30-x86_64.AppImage.zsync"

        ## Snap
        # my_wget "${_VSCODIUM_BASE_URL}/codium_${_VSCODIUM_VERSION}_amd64.snap"

        ## Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-linux-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## Web Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-web-linux-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## CLI
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-cli-linux-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## Alphine Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-alpine-x64-${_VSCODIUM_VERSION}.tar.gz"

        ## Alphine Web Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-web-alpine-x64-${_VSCODIUM_VERSION}.tar.gz"
    }

    # win-arm64
    false && {
        ## User Installer
        my_wget "${_VSCODIUM_BASE_URL}/VSCodiumUserSetup-arm64-${_VSCODIUM_VERSION}.exe"

        ## System Installer
        my_wget "${_VSCODIUM_BASE_URL}/VSCodiumSetup-arm64-${_VSCODIUM_VERSION}.exe"

        ## .zip
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-win32-arm64-${_VSCODIUM_VERSION}.zip"

        ## CLI
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-cli-win32-arm64-${_VSCODIUM_VERSION}.tar.gz"
    }

    # linux-arm64
    true && {
        ## .deb
        # my_wget "${_VSCODIUM_BASE_URL}/codium_${_VSCODIUM_VERSION}_arm64.deb"

        ## .rpm
        # my_wget "${_VSCODIUM_BASE_URL}/codium-${_VSCODIUM_VERSION}-el8.aarch64.rpm"

        ## .tar.gz
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-linux-arm64-${_VSCODIUM_VERSION}.tar.gz"

        ## Snap
        # my_wget "${_VSCODIUM_BASE_URL}/codium_${_VSCODIUM_VERSION}_arm64.snap"

        ## Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-linux-arm64-${_VSCODIUM_VERSION}.tar.gz"

        ## Web Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-web-linux-arm64-${_VSCODIUM_VERSION}.tar.gz"

        ## CLI
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-cli-linux-arm64-${_VSCODIUM_VERSION}.tar.gz"

        ## Alphine Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-alpine-arm64-${_VSCODIUM_VERSION}.tar.gz"

        ## Alphine Web Host
        my_wget "vscodium-reh-web-alpine-arm64-${_VSCODIUM_VERSION}.tar.gz"
    }

    # linux-arm32
    false && {
        ## .deb
        my_wget "${_VSCODIUM_BASE_URL}/codium_${_VSCODIUM_VERSION}_armhf.deb"

        ## .rpm
        my_wget "${_VSCODIUM_BASE_URL}/codium-${_VSCODIUM_VERSION}-el8.armv7hl.rpm"

        ## .tar.gz
        my_wget "${_VSCODIUM_BASE_URL}/VSCodium-linux-armhf-${_VSCODIUM_VERSION}.tar.gz"

        ## Remote Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-linux-armhf-${_VSCODIUM_VERSION}.tar.gz"

        ## Web Host
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-reh-web-linux-armhf-${_VSCODIUM_VERSION}.tar.gz"

        ## CLI
        my_wget "${_VSCODIUM_BASE_URL}/vscodium-cli-linux-armhf-${_VSCODIUM_VERSION}.tar.gz"
    }

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'VSCODIUM download was disabled' >>"${_ARTIFACTS}/stderr.txt"



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


_FORGEJO_DIST_BASE_URL="https://codeberg.org/forgejo/forgejo/releases/download"
_FORGEJO_VERSION="15.0.2"
_FORGEJO_BASE_URL="${_FORGEJO_DIST_BASE_URL}/v${_FORGEJO_VERSION}"
_FORGEJO_BASE_NAME="forgejo-${_FORGEJO_VERSION}"

[ "${__ENABLE_DOWNLOAD_FORGEJO}" = "true" ] && {
    mkdir -p "forgejo/${_FORGEJO_BASE_NAME}"
    cd "forgejo/${_FORGEJO_BASE_NAME}" || exit $?
    
    for slug in \
        "forgejo-${_FORGEJO_VERSION}-linux-amd64.xz" \
        "forgejo-${_FORGEJO_VERSION}-linux-arm-6.xz" \
        "forgejo-${_FORGEJO_VERSION}-linux-arm64.xz" \
        "forgejo-src-${_FORGEJO_VERSION}.tar.gz"
    do
        my_wget "${_FORGEJO_BASE_URL}/${slug}"
    done

    # my_wget "https://codeberg.org/forgejo/forgejo/archive/v${_FORGEJO_VERSION}.tar.gz" "" --no-verbose --content-disposition
   
    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'FORGEJO download was disabled' >>"${_ARTIFACTS}/stderr.txt"


_GITEA_DIST_BASE_URL="https://github.com/go-gitea/gitea/releases/download"
_GITEA_VERSION="1.26.1"
_GITEA_BASE_URL="${_GITEA_DIST_BASE_URL}/v${_GITEA_VERSION}"
_GITEA_BASE_NAME="gitea-${_GITEA_VERSION}"

[ "${__ENABLE_DOWNLOAD_GITEA}" = "true" ] && {
    mkdir -p "gitea/${_GITEA_BASE_NAME}"
    cd "gitea/${_GITEA_BASE_NAME}" || exit $?
    
    for slug in \
        "gitea-${_GITEA_VERSION}-linux-amd64.xz" \
        "gitea-${_GITEA_VERSION}-linux-386.xz" \
        "gitea-${_GITEA_VERSION}-linux-arm64.xz" \
        "gitea-${_GITEA_VERSION}-windows-4.0-amd64.exe.xz" \
        "gitea-${_GITEA_VERSION}-gogit-windows-4.0-amd64.exe.xz" \
        "gitea-${_GITEA_VERSION}-windows-4.0-386.exe.xz" \
        "gitea-${_GITEA_VERSION}-gogit-windows-4.0-386.exe.xz" \
        "gitea-${_GITEA_VERSION}-freebsd14-amd64.xz" \
        "gitea-src-${_GITEA_VERSION}.tar.gz"
    do
        my_wget "${_GITEA_BASE_URL}/${slug}"
    done
   
    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'GITEA download was disabled' >>"${_ARTIFACTS}/stderr.txt"


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


_SUMATRA_PDF_DIST_BASE_URL="https://www.sumatrapdfreader.org/dl/rel"
_SUMATRA_PDF_VERSION="3.6.1"
_SUMATRA_PDF_BASE_URL="${_SUMATRA_PDF_DIST_BASE_URL}/${_SUMATRA_PDF_VERSION}"
_SUMATRA_PDF_BASE_NAME="sumatrapdf-${_SUMATRA_PDF_VERSION}"
[ "${__ENABLE_DOWNLOAD_SUMATRA_PDF}" = "true" ] && {
    mkdir -p "sumatrapdf/${_SUMATRA_PDF_BASE_NAME}"
    cd "sumatrapdf/${_SUMATRA_PDF_BASE_NAME}" || exit $?

    local REFERER='https://www.sumatrapdfreader.org/downloadafter'
    for slug in \
        '-64-install.exe' \
        '-arm64-install.exe' \
        '-install.exe' \
        '-64.zip' \
        '-arm64.zip' \
        '.zip'
    do
        my_wget "${_SUMATRA_PDF_BASE_URL}/SumatraPDF-${_SUMATRA_PDF_VERSION}${slug}" "" --no-verbose --referer="${REFERER}" --user-agent="Mozilla/5.0"
    done

    # my_wget "https://github.com/sumatrapdfreader/sumatrapdf/archive/refs/tags/${_SUMATRA_PDF_VERSION}rel.tar.gz" "" --no-verbose --content-disposition

    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'SUMATRA_PDF download was disabled' >>"${_ARTIFACTS}/stderr.txt"


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
    # my_wget "https://en.wikipedia.org/api/rest_v1/page/pdf/JSONP" ""  --no-verbose --user-agent="Mozilla/5.0" --content-disposition

    # get_en_wikipedia_pdf JSON_Web_Signature JSON_Web_Encryption Single_sign-on Identity_provider API_key Access_token Basic_access_authentication Digest_access_authentication Claims-based_identity CBOR Web_storage

    # my_wget "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    # my_wget "https://download.sysinternals.com/files/PSTools.zip"

    # my_wget "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe"
    # my_wget "https://www.nuget.org/api/v2/package/Git-Windows-Minimal/2.54.0" "git-windows-minimal.2.54.0.nupkg"
    # my_wget "https://www.nuget.org/api/v2/package/GitForWindows/2.54.0" "gitforwindows.2.54.0.nupkg"


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

    # my_wget 'https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.26/AutoHotkey_2.0.26_setup.exe'
    # my_wget 'https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.26/AutoHotkey_2.0.26.zip'
    # my_wget 'https://github.com/AutoHotkey/Ahk2Exe/releases/download/Ahk2Exe1.1.37.02a2/Ahk2Exe1.1.37.02a2.zip'


    false && {
        # my_wget https://www.rarlab.com/download.htm
        # my_wget https://www.rarlab.com/rar_add.htm
        # my_wget https://www.rarlab.com/rarnew.htm

        my_wget https://www.rarlab.com/rar/unrarsrc-7.2.6.tar.gz
        my_wget https://www.rarlab.com/rar/unrardll-722.exe
        my_wget https://www.rarlab.com/rar/unrarw64.exe
        my_wget https://www.rarlab.com/rar/winrar-x64-722.exe
        my_wget https://www.rarlab.com/rar/rar-android-720.131.apk
        my_wget https://www.rarlab.com/rar/rarlinux-x64-722.tar.gz
        my_wget https://www.rarlab.com/rar/rarbsd-x64-722.tar.gz
    }


    false && {
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/SDKRef.pdf'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/SHA256SUMS'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/UserManual.pdf'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/VBoxGuestAdditions_7.2.8.iso'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/VirtualBox-7.2.8-173730-Win.exe'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/VirtualBox-7.2.8.tar.bz2'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/VirtualBoxSDK-7.2.8-173730.zip'
        my_wget 'https://download.virtualbox.org/virtualbox/7.2.8/Oracle_VirtualBox_Extension_Pack-7.2.8-173730.vbox-extpack'
    }

    # /**********


    # **********/

    . "${GITHUB_WORKSPACE}/scripts/scratch.sh"
    cd "${_ARTIFACTS}"
} 2>&1 | tee "${_ARTIFACTS}/stderr.txt" || echo 'TMP download was disabled' >>"${_ARTIFACTS}/stderr.txt"

__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__root__=$(cd ${__dir__}/../../.. ; pwd)

function cerbero(){
     ${__root__}/commands/cerbero.sh $@
}

commit='-b 0.1'
version=1.12.3
arch=x86_64
platform=windows
[ "x$(uname)" == "xLinux" } && platform=linux

__home__=$(cerbero --cerbero-home-directory)
cerbero --load-cerbero  "${commit}"  &&
cerbero --load-cerbero-pkg-src &&
cerbero -c config/win64.cbc bootstrap

release_repo=$__root__/releases

build_tool_repo=$release_repo/gstreamer-build_tools-$platform-$arch-version
[ ! -d  $build_tool_repo ] && mkdir -p $build_tool_repo

cerbero -c config/win64.cbc cpm-pack --type package --build-tools  --output-dir $build_tool_repo
cerbero -c config/win64.cbc cpm-pack pkg-config      --build-tools --output-dir $build_tool_repo

if [ $platform == "windows" ]; then
    mv $__home__/build/build-tools $__home__/build/build-tools.origin
fi

cerbero -c config/win64.cbc cpm-install build_tools-$platform-$arch-$version.tar.bz2 --build-tools --repo $build_tool_repo

cerbero -c config/win64.cbc package base --tarball





 
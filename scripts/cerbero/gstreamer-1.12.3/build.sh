__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__root__=$(cd ${__dir__}/../../.. ; pwd)

function cerbero(){
     ${__root__}/commands/cerbero.sh $@
}

commit='-b 0.1'

#cerbero --load-cerbero  "${commit}"  &&
#cerbero --load-cerbero-pkg-src &&
#cerbero -c config/win64.cbc bootstrap
version=1.12.3
release_repo=$__root__/releases
[ ! -d  $release_repo ] && mkdir -p $release_repo

#cerbero -c config/win64.cbc cpm-pack --build-tools --type package --output-dir $release_repo
#cerbero -c config/win64.cbc cpm-pack pkg-config --build-tools --output-dir $release_repo

build_tool_repo=$release_repo/gstreamer-$version-win64-build_tools
#[ ! -d  $build_tool_repo ] && mkdir -p $build_tool_repo
#
#cerbero -c config/win64.cbc cpm-pack pkg-config --build-tools --output-dir $build_tool_repo
#cerbero -c config/win64.cbc cpm-pack --type package --build-tools --output-dir $build_tool_repo


#cerbero -c config/win64.cbc cpm-install gstreamer-build-tools-windows-x86_64-1.12.3.tar.bz2 --build-tools --repo $build_tool_repo

cerbero -c config/win64.cbc package base --tarball





 
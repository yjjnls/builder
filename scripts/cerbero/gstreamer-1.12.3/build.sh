__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootd__=$(cd ${__dir__}/../../../.. ; pwd)
source ${__rootd__}/commands/_utils.sh

GSTREAMER_VERSION=1.12.3
GSTREAMER_CERBERO_PKG_TARBALL=cerbero-${GSTREAMER_VERSION}.tar.gz
CAC_LOCATION=${__dir__}/cerbero.cac

function _copy(){
src=$1
dst=$2
if [ -f $src ]; then
    cp $src $dst
else
    if [ "$dst" == "." ]; then
	    
    wget --no-check-certificate $src $dst
fi

}
cd ${__rootd__}


if [ ! -d cerbero.build ];then
   git clone git@github.com:Mingyiz/cerbero.git -b 0.1 cerbero.build
fi

[ ! -d cerbero.build ] && echo 'can not load cerbero repos' && exit 1

cd cerbero.build

_copy $CAC_LOCATION .

git config user.email Mingyi.Z@outlook.com
git config user.name  Mingyi

git config --global user.email zhangmingyi@kedacom.com
git config --global user.name  Mingyi



[ ! -d ~tmp ] && mkdir ~tmp 

if [ ! -f ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL} ] ; then
    server=http://172.16.0.119/WMS/mirrors/gstreamer.freedesktop.org
	url=${server}/data/pkg/src/${GSTREAMER_VERSION}/${GSTREAMER_CERBERO_PKG_TARBALL}
    wget $url -O ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL}
fi

if [ ! -d sources ]; then
   echo "extracting ${GSTREAMER_CERBERO_PKG_TARBALL}"
   tar xf ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL} -C ~tmp/
   mv  -f ~tmp/cerbero-${GSTREAMER_VERSION}/sources sources
fi
[[ !- cerbero.build || ! -d sources ]] && echo 'load resource failed.' && exit 1

./cerbero-uninstalled -c config/win64.cbc bootstrap &&
./cerbero-uninstalled -c config/win64.cbc package base --tarball &&
./cerbero-uninstalled -c config/win64.cbc gstreamer-1.0 --tarball &&


 
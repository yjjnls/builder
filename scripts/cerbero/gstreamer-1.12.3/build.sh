__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootd__=$(cd ${__dir__}/../../.. ; pwd)
source ${__rootd__}/commands/_utils.sh

CERBERO_CONFIG=${__rootd__}/config.ini
GSTREAMER_VERSION=1.12.3
GSTREAMER_CERBERO_PKG_TARBALL=cerbero-${GSTREAMER_VERSION}.tar.gz
CAC_LOCATION=${__dir__}/cerbero.cac

if [ "x$(uname)" == "xLinux" ];then
    CERBERO_BUILD_DIR=$(__getconfig $CERBERO_CONFIG 'dir.lin')
else
    CERBERO_BUILD_DIR=$(__getconfig $CERBERO_CONFIG 'dir.win')
fi


function _copy(){
src=$1
dst=$2
if [ -f $src ]; then
    cp $src $dst
else
	    
    wget --no-check-certificate $src $dst
fi

}

cd ${__rootd__}

function _setup(){

	if [ ! -d cerbero.build ];then
	   git clone git@github.com:Mingyiz/cerbero.git -b 0.1 cerbero.build
	fi

	[ ! -d cerbero.build ] && echo 'can not load cerbero repos' && exit 1

	cd cerbero.build

	#_copy $CAC_LOCATION .

	git config user.email Mingyi.Z@outlook.com
	git config user.name  Mingyi

	git config --global user.email zhangmingyi@kedacom.com
	git config --global user.name  Mingyi

	cd ${__rootd__}

	[ ! -d ~tmp ] && mkdir ~tmp 


	if [ ! -d cerbero.build/sources ]; then
		if [ ! -f ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL} ] ; then
			server=http://172.16.0.119/WMS/mirrors/gstreamer.freedesktop.org
			server=https://gstreamer.freedesktop.org
			url=${server}/data/pkg/src/${GSTREAMER_VERSION}/${GSTREAMER_CERBERO_PKG_TARBALL}
			wget --no-check-certificate $url -O ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL} 
		fi
		echo "extracting ${GSTREAMER_CERBERO_PKG_TARBALL}"
		tar xf ~tmp/${GSTREAMER_CERBERO_PKG_TARBALL} -C ~tmp/
		mv  -f ~tmp/cerbero-${GSTREAMER_VERSION}/sources cerbero.build/sources
	fi


	[[ ! -d cerbero.build || ! -d cerbero.build/sources ]] && echo 'load resource failed.' && exit 1

	cd cerbero.build

}

#bootstrap
./cerbero-uninstalled -c config/win64.cbc bootstrap
./cerbero-uninstalled -c config/win64.cbc 
#./cerbero-uninstalled -c config/win64.cbc package base --tarball &&
./cerbero-uninstalled -c config/win64.cbc package gstreamer-1.0 --tarball 


 
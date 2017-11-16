#!/bin/bash
__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootdir__=$(cd ${__dir__}/../.. ; pwd)
__libdir__=$(cd $__rootdir__/commands/lib; pwd )
__config__=$__rootdir__/config.ini

function check(){
    
    if [ $? -ne 0 ]; then
	   echo "[Fail] $1"
	   exit 1	
	else
	   echo "[OK] $1"
	   return 0
	fi
}


inifile=$($__libdir__/inifile)
config=$($inifile.open $__config__)

cbc=
home=
if [ "x$(uname)" == "xLinux" ]; then
   cbc=linux-x86-64
   home=$($config.get cerbero home.linux)
else
   cbc=win64
   home=$($config.get cerbero home.windows)
fi

[ "x$1" == "x--debug" ] && cbc=${cbc}d
cbc=config/${cbc}.cbc

_CONFIG="-c $cbc"
_ARCH=x86_64
_PLATFORM=windows
_RELEASE_DIR=${__rootdir__}/releases
_VERSION=1.12.3


if [ "x$(uname)" == "xLinux" ] ; then
   _PLATFORM=linux
fi

cerbero=$( $__libdir__/cerbero -c $cbc -i $__config__)
#
# clear previous build
#

function cerbero_sh(){
     ${__rootdir__}/commands/cerbero.sh $@
}

function cerberovar(){
	klass=$1
	key=$2
	cerbero_sh ${_CONFIG} cpm-query --${klass}var ${key} 2>&1 | awk -v var="${klass}.${key}" -F ['='] '{  if( $1==var) print $2}'
}

function exitif(){
   if [ $1 -ne 0 ] ; then
      ret=$1
	  shift
      echo $@
	  exit $ret
   fi
}

_CERBERO_HOME=$(cerbero_sh --cerbero-home-directory)
_PREFIX=$(cerberovar config prefix)
_BUILD_TOOLS_RELEASE_NAME=gstreamer-build_tools-${_PLATFORM}-${_ARCH}-${_VERSION}
_BASE_RELEASE_NAME=gstreamer-base-${_PLATFORM}-${_ARCH}-${_VERSION}
_GSTREAMER_RELEASE_NAME=gstreamer-${_PLATFORM}-${_ARCH}-${_VERSION}

function _load(){
	
	cerbero_sh --load-cerbero-pkg-src
	exitif $? "Load cerbero bundle package source failed!"
}

function _bootstrap(){
	cerbero_sh ${_CONFIG} bootstrap
	exitif $? "bootstrap failed!"

	build_tools_dir=$(cerberovar config build_tools_prefix)

	bkdir=${build_tools_dir}.${_PLATFORM}-${_ARCH}-${_VERSION}@$(date +%Y%m%d%H%M%S)

	rdir=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
	[ -d $rdir ] && rm -rf $rdir
	mkdir -p $rdir &&
	cerbero_sh ${_CONFIG} cpm-pack --type package --build-tools  --output-dir $rdir 
	#    cerbero ${_CONFIG} cpm-pack pkg-config     --build-tools --output-dir $rdir
	exitif $? "Pack for build-tools failed"
	mv ${build_tools_dir} ${bkdir}   
	echo "        ======== build tools compiled ! ========"
	
}

function _install_build_tools(){
	tarball=build_tools-${_PLATFORM}-${_ARCH}-${_VERSION}.tar.bz2
	repo=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
	if [ ! -f $repo/$tarball ]; then
		repo=$(cerbero_sh --get-config release repo)
		if [ "x$repo" == "x" ]; then
			exitif 1 "can not find release repo"
		fi
		repo=${repo}/${_BUILD_TOOLS_RELEASE_NAME}
	fi
	
	cerbero_sh ${_CONFIG} cpm-install ${tarball} --repo $repo --build-tools
	exitif $? "install gstreamer build tools failed."
	echo "        ======== build tools installed ! ========"
   
}

function _build_base(){
	_load

	_install_build_tools

	[ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
	# cerbero_sh ${_CONFIG} bootstrap --build-tools-disable &&
	# _install_build_tools &&
	cerbero_sh ${_CONFIG} package base --tarball &&
	rdir=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}
	[ ! -d $rdir ] && rm -rf $rdir
	mkdir $rdir
	cerbero_sh ${_CONFIG} cpm-pack base --type sdk --output-dir $rdir

	exitif $? "build gstreamer base sdk failed."
	echo "        ======== base compiled ! ========"

}
function _install_base(){
	repo=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}

	if [ ! -f $repo/Build.yaml ]; then
		repo=$(cerbero_sh --get-config release repo)
		if [ "x$repo" == "x" ]; then
			exitif 1 "can not find release repo"
		fi
		repo=${repo}/${_BASE_RELEASE_NAME}
	fi
	
	cerbero_sh ${_CONFIG} cpm-install base --type build --repo $repo
	exitif $? "install gstreamer base failed."
	echo "        ======== base installed ! ========"
   
}

function _build_gstreamer(){
	_load

	_install_base
   
	#[ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
	rdir=${_RELEASE_DIR}/${_GSTREAMER_RELEASE_NAME}
	[ ! -d $rdir ] && rm -rf $rdir
	mkdir $rdir

	#cerbero ${_CONFIG} bootstrap --build-tools-disable &&
	#_install_build_tools &&
	#_install_base &&   
	#cerbero ${_CONFIG} package gstreamer-1.0 --tarball &&
	cerbero_sh ${_CONFIG} cpm-pack gstreamer-1.0 --type sdk --output-dir $rdir

	exitif $? "build gstreamer base sdk failed."
	echo "        ======== gstreamer compiled ! ========"

}

# prefix=$($cerbero.get_config prefix)
# [ -d $prefix ] && rm -rf $prefix

# build_tools_prefix=$($cerbero.get_config build_tools_prefix)
# [ -d $build_tools_prefix ] && rm -rf $build_tools_prefix

# pkgname=$($cerbero.build_tools_pkg_name)
# repo=$($cerbero.release_repo build_tools)
# echo -e "
# prefix : $prefix
# build_tools_prefix : $build_tools_prefix
# pkgname : $pkgname
# repo : $repo


# _load

_bootstrap

_build_base

_build_gstreamer

echo "        ======== DONE ! ========"
# "
# echo $repo
# exit 0
#$cerbero.run bootstrap --cpm-install  --build-tools-disable
# $cerbero.run cpm-install  $pkgname --repo $repo --build-tools
# check "install $pkgname at $repo"

# for name in  base gstreamer
# do
#    repo=$($cerbero.release_repo $name)
#    $cerbero.run cpm-install  --repo $repo --type build
#    check "install $name SDK at $repo"   
# done
# echo "SDK install completed!"

# rdir=$($cerbero.release_dir )/$($cerbero.release_tag base)
# [ -d $rdir ] && rm -rf $rdir
# mkdir -p $rdir/tarball

# cache=$($cerbero.get_config home_dir)/$($cerbero.get_config cache_file )
# [ -f $cache ] && rm -rf $cache

# $cerbero.run package base --tarball -o $rdir/tarball
# check "Build base"
# $cerbero.run cpm-pack base --type sdk --output-dir $rdir
# check "Pack base"

# rdir=$($cerbero.release_dir )/$($cerbero.release_tag gstreamer)
# [ -d $rdir ] && rm -rf $rdir
# mkdir -p $rdir/tarball

# $cerbero.run package gstreamer --tarball -o $rdir/tarball
# check "Build gstreamer"
# $cerbero.run cpm-pack gstreamer --type sdk --output-dir $rdir
# check "Pack gstreamer"



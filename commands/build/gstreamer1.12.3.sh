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

# _CONFIG="-c $cbc"
# _ARCH=x86_64
# _PLATFORM=windows
# _RELEASE_DIR=${__rootdir__}/releases
# _VERSION=1.12.3
# if [ "x$(uname)" == "xLinux" ] ; then
#    _PLATFORM=linux
# fi

cerbero=$( $__libdir__/cerbero -c $cbc -i $__config__)
#
# clear previous build
#


function load(){
	$cerbero.load_cerbero_pkg_src
	check "Load cerbero bundle package source"
}

function bootstrap(){
	$cerbero.run bootstrap --build-tools-disable
	check "Cerbero bootstrap"
}

	# prefix=$($cerbero.get_config prefix)
	# [ -d $prefix ] && rm -rf $prefix

	# build_tools_prefix=$($cerbero.get_config build_tools_prefix)
	# [ -d $build_tools_prefix ] && rm -rf $build_tools_prefix

	# pkgname=$($cerbero.build_tools_pkg_name)
	# repo=$($cerbero.release_repo build_tools)

	# $cerbero.run cpm-install  $pkgname --repo $repo --build-tools
	# check "install $pkgname at $repo"
function clean(){
	prefix=$($cerbero.get_config prefix)
	[ -d $prefix ] && rm -rf $prefix
}

function install(){
	for i in $@; 
	do
		repo=$($cerbero.release_repo $i)
	 	if [ $i == "build_tools" ];  then
			pkgname=$($cerbero.build_tools_pkg_name)
			$cerbero.run cpm-install  $pkgname --repo $repo --build-tools
		else
			$cerbero.run cpm-install  --repo $repo --type build
		fi
		check "install $i SDK at $repo" 
	done
}

function build_tools(){
	# bootstrap

	rdir=$($cerbero.release_dir )/$($cerbero.release_tag build_tools)
	[ -d $rdir ] && rm -rf $rdir
	# mkdir -p $rdir/tarball



	build_tools_prefix=$($cerbero.get_config build_tools_prefix)
	[ -d $build_tools_prefix ] && rm -rf $build_tools_prefix

	# $cerbero.run package base --tarball -o $rdir/tarball
	# check "Build base"
	$cerbero.run cpm-pack --type package --build-tools  --output-dir $rdir 
	$cerbero.run cpm-pack pkg-config     --build-tools --output-dir $rdir

}

function build_base(){
	install build_tools

	rdir=$($cerbero.release_dir )/$($cerbero.release_tag base)
	[ -d $rdir ] && rm -rf $rdir
	mkdir -p $rdir/tarball

	cache=$($cerbero.get_config home_dir)/$($cerbero.get_config cache_file )
	[ -f $cache ] && rm -rf $cache

	$cerbero.run package base --tarball -o $rdir/tarball
	check "Build base"
	$cerbero.run cpm-pack base --type sdk --output-dir $rdir
	check "Pack base"

}

function build_gstreamer(){
	install build_tools base

	rdir=$($cerbero.release_dir )/$($cerbero.release_tag gstreamer-1.0)
	[ -d $rdir ] && rm -rf $rdir
	mkdir -p $rdir/tarball

	cache=$($cerbero.get_config home_dir)/$($cerbero.get_config cache_file )
	[ -f $cache ] && rm -rf $cache

	$cerbero.run package gstreamer-1.0 --tarball -o $rdir/tarball
	check "Build gstreamer-1.0"
	$cerbero.run cpm-pack gstreamer-1.0 --type sdk --output-dir $rdir
	check "Pack gstreamer-1.0"
}
# -------------------------------------------------------------
load

# build_base

echo "        ======== DONE ! ========"
# 	cerbero_sh ${_CONFIG} bootstrap
# 	exitif $? "bootstrap failed!"

# 	build_tools_dir=$(cerberovar config build_tools_prefix)

# 	bkdir=${build_tools_dir}.${_PLATFORM}-${_ARCH}-${_VERSION}@$(date +%Y%m%d%H%M%S)

# 	rdir=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
# 	[ -d $rdir ] && rm -rf $rdir
# 	mkdir -p $rdir &&
# 	cerbero_sh ${_CONFIG} cpm-pack --type package --build-tools  --output-dir $rdir 
# 	cerbero_sh ${_CONFIG} cpm-pack pkg-config     --build-tools --output-dir $rdir
# 	exitif $? "Pack for build-tools failed"
# 	mv ${build_tools_dir} ${bkdir}   
# 	echo "        ======== build tools compiled ! ========"
	
# }

# function _install_build_tools(){
# 	tarball=build_tools-${_PLATFORM}-${_ARCH}-${_VERSION}.tar.bz2
# 	repo=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
# 	if [ ! -f $repo/$tarball ]; then
# 		repo=$(cerbero_sh --get-config release repo)
# 		if [ "x$repo" == "x" ]; then
# 			exitif 1 "can not find release repo"
# 		fi
# 		repo=${repo}/${_BUILD_TOOLS_RELEASE_NAME}
# 	fi
	
# 	cerbero_sh ${_CONFIG} cpm-install ${tarball} --repo $repo --build-tools
# 	exitif $? "install gstreamer build tools failed."
# 	echo "        ======== build tools installed ! ========"
   
# }

# function _build_base(){
# 	_load

# 	_install_build_tools

# 	[ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
# 	# cerbero_sh ${_CONFIG} bootstrap --build-tools-disable &&
# 	# _install_build_tools &&
# 	cerbero_sh ${_CONFIG} package base --tarball &&
# 	rdir=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}
# 	[ ! -d $rdir ] && rm -rf $rdir
# 	mkdir $rdir
# 	cerbero_sh ${_CONFIG} cpm-pack base --type sdk --output-dir $rdir

# 	exitif $? "build gstreamer base sdk failed."
# 	echo "        ======== base compiled ! ========"

# }
# function _install_base(){
# 	repo=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}

# 	if [ ! -f $repo/Build.yaml ]; then
# 		repo=$(cerbero_sh --get-config release repo)
# 		if [ "x$repo" == "x" ]; then
# 			exitif 1 "can not find release repo"
# 		fi
# 		repo=${repo}/${_BASE_RELEASE_NAME}
# 	fi
	
# 	cerbero_sh ${_CONFIG} cpm-install base --type build --repo $repo
# 	exitif $? "install gstreamer base failed."
# 	echo "        ======== base installed ! ========"
   
# }

# function _build_gstreamer(){
# 	echo '---1------'
# 	_load
# 	echo '----2-----'

# 	_install_base
   
# 	#[ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
# 	echo '---------'
# 	cerbero_sh ${_CONFIG} package gstreamer-1.0 --tarball &&
# 	rdir=${_RELEASE_DIR}/${_GSTREAMER_RELEASE_NAME}
# 	echo '---------------'
# 	[ ! -d $rdir ] && rm -rf $rdir
# 	mkdir $rdir

# 	#cerbero ${_CONFIG} bootstrap --build-tools-disable &&
# 	#_install_build_tools &&
# 	#_install_base &&   
# 	# cerbero_sh ${_CONFIG} package gstreamer-1.0 --tarball &&
# 	cerbero_sh ${_CONFIG} cpm-pack gstreamer-1.0 --type sdk --output-dir $rdir

# 	exitif $? "build gstreamer base sdk failed."
# 	echo "        ======== gstreamer compiled ! ========"

# }



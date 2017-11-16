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

#
#
#
# echo -e "
# HOME : $home
# config : $__config__
# cerbero config : $cbc
# "
#
cerbero=$( $__libdir__/cerbero -c $cbc -i $__config__)
#
# clear previous build
#

prefix=$($cerbero.get_config prefix)
[ -d $prefix ] && rm -rf $prefix

build_tools_prefix=$($cerbero.get_config build_tools_prefix)
[ -d $build_tools_prefix ] && rm -rf $build_tools_prefix

pkgname=$($cerbero.build_tools_pkg_name)
repo=$($cerbero.release_repo build_tools)
# echo -e "
# prefix : $prefix
# build_tools_prefix : $build_tools_prefix
# pkgname : $pkgname
# repo : $repo

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

rdir=$($cerbero.release_dir )/$($cerbero.release_tag base)
[ -d $rdir ] && rm -rf $rdir
mkdir -p $rdir/tarball

cache=$($cerbero.get_config home_dir)/$($cerbero.get_config cache_file )
[ -f $cache ] && rm -rf $cache

$cerbero.run package base --tarball -o $rdir/tarball
check "Build base"
$cerbero.run cpm-pack base --type sdk --output-dir $rdir
check "Pack base"

rdir=$($cerbero.release_dir )/$($cerbero.release_tag gstreamer)
[ -d $rdir ] && rm -rf $rdir
mkdir -p $rdir/tarball

$cerbero.run package gstreamer --tarball -o $rdir/tarball
check "Build gstreamer"
$cerbero.run cpm-pack gstreamer --type sdk --output-dir $rdir
check "Pack gstreamer"



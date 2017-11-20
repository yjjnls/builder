#!/bin/bash
__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__root__=$(cd ${__dir__}/../.. ; pwd)

#----------------------------------#
#      initilaize vars             # 
#----------------------------------#
_VERSION=               
_TAG=
_BRANCH=
_RELEASE_DIR=${__root__}/releases
_LOAD=No
_BOOTSTRAP=Yes
_BASE=No
_GSTREAMER=No

_ARCH=x86_64
_PLATFORM=windows
_CONFIG="-c config/win64.cbc"

if [ "x$(uname)" == "xLinux" ] ; then
   _PLATFORM=linux
fi

function cerbero(){
     ${__root__}/commands/cerbero.sh $@
}

function cerberovar(){
	klass=$1
	key=$2
	cerbero ${_CONFIG} cpm-query --${klass}var ${key} 2>&1 | awk -v var="${klass}.${key}" -F ['='] '{  if( $1==var) print $2}'
}

function exitif(){
   if [ $1 -ne 0 ] ; then
      ret=$1
	  shift
      echo $@
	  exit $ret
   fi
}

function argparse(){

USAGE='Usage: gstreamer [OPTION]...
Build GStreamer package

Mandatory arguments to long options are mandatory.
  --version                  version of the gstreamer.
  --branch                   gstreamer branch (for debug only)
  --tag                      tag of the cerbero used to build
  --release-dir              directory where the package build to be stored
  --disable                  disable some build part 
                                load : skip load cerbero repo and pkg src
                                bootstrap : skip bootstrap of the cerbero
                                base : skip gstreamer base SDK build
                                gstreamer : skip gstreamer SDK build
'

while ( [ ! -z $1 ] )
do
    opt=$1
	shift
    case $opt in
	   --version)
	   _VERSION=$1
	   shift	   
	;;
	   
       --release-dir)
	   _RELEASE_DIR=$1
	   shift
	;;
	   
	   --tag)
	   _TAG=$1
	   shift
	;;
	   
	   --branch)
	   _BRANCH=$1
	   shift
	;;
	   --disable)
	   item=$1
	   shift
	   case $item in
	      load) _LOAD=No ;;
		  bootstrap) _BOOTSTRAP=No ;;
		  base) _BASE=No ;;
		  gstreamer) _GSTREAMER=No ;;
		  *) 
		  echo "Invalid disable option $item"
		  echo $USAGE
		  exit 1
	   ;;
	   esac
	;;	  
	   
	   -h|--help)
	   echo $USAGE
	;;
	   *)
	   echo "Invalid option $opt"
	   echo $USAGE
	   exit 1
	 ;;
	 esac
done

[ -z $_VERSION ] && echo "null version!" && exit 1
[[ -z $_BRANCH && -z $_TAG ]] && echo "tag or branch must be choiced to set version!" && exit 1


echo "    ==========================="
echo "                               "
echo "    version    : $_VERSION     "
echo "    branch     : $_BRANCH      "
echo "    tag        : $_TAG         "
echo "    release dir: $_RELEASE_DIR "
echo "    load       : $_LOAD        "
echo "    bootstrap  : $_BOOTSTRAP   "
echo "    base       : $_BASE        "
echo "    gstreamer  : $_GSTREAMER   "
echo "                               "
echo "    ==========================="


}

#----------------------------------------#
# load vars according command option     #
#----------------------------------------#
argparse $@

_CERBERO_HOME=$(cerbero --cerbero-home-directory)
_PREFIX=$(cerberovar config prefix)
_BUILD_TOOLS_RELEASE_NAME=gstreamer-build_tools-${_PLATFORM}-${_ARCH}-${_VERSION}
_BASE_RELEASE_NAME=gstreamer-base-${_PLATFORM}-${_ARCH}-${_VERSION}
_GSTREAMER_RELEASE_NAME=gstreamer-${_PLATFORM}-${_ARCH}-${_VERSION}

#
# functions
#

function _load(){
    if [ ! -z $_TAG ] ; then
	    cerbero --load-cerbero  "--tag $_TAG"	
	else
	    cerbero --load-cerbero  "-b $_BRANCH"
	fi
	exitif $? "Load cerbero failed!"
	
	cerbero --load-cerbero-pkg-src
	exitif $? "Load cerbero bundle package source failed!"
}

function _bootstrap(){
#    cerbero ${_CONFIG} bootstrap
#    exitif $? "bootstrap failed!"
   build_tools_dir=$(cerberovar config build_tools_prefix)

   bkdir=${build_tools_dir}.${_PLATFORM}-${_ARCH}-${_VERSION}@$(date +%Y%m%d%H%M%S)
   
   #[ -d $bkdir ] && rm -rf $bkdir

   #make build-tools package
	
	
   rdir=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
   
   [ -d $rdir ] && rm -rf $rdir
   mkdir -p $rdir &&
   echo '------------------'
   echo $rdir
   cerbero ${_CONFIG} cpm-pack --type package --build-tools  --output-dir $rdir &&
   cerbero ${_CONFIG} cpm-pack pkg-config     --build-tools --output-dir $rdir
   exitif $? "Pack for build-tools failed"
   mv ${build_tools_dir} ${bkdir}   	
}

function _install_build_tools(){
   tarball=build_tools-${_PLATFORM}-${_ARCH}-${_VERSION}.tar.bz2
   repo=${_RELEASE_DIR}/${_BUILD_TOOLS_RELEASE_NAME}
   if [ ! -f $repo/$tarball ]; then
      repo=$(cerbero --get-config release repo)
	  if [ "x$repo" == "x" ]; then
	     exitif 1 "can not find release repo"
	  fi
	  repo=${repo}/${_BUILD_TOOLS_RELEASE_NAME}
   fi
   
   cerbero ${_CONFIG} cpm-install ${tarball} --repo $repo --build-tools
   exitif $? "install gstreamer build tools failed."
   
}

function _build_base(){
   [ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
   cerbero ${_CONFIG} bootstrap --build-tools-disable &&
   _install_build_tools &&
   cerbero ${_CONFIG} package base --tarball &&
   rdir=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}
   [ ! -d $rdir ] && rm -rf $rdir
   mkdir $rdir
   cerbero ${_CONFIG} cpm-pack base --type sdk --output-dir $rdir

   exitif $? "build gstreamer base sdk failed."

}
function _install_base(){
   repo=${_RELEASE_DIR}/${_BASE_RELEASE_NAME}

   if [ ! -f $repo/Build.yaml ]; then
      repo=$(cerbero --get-config release repo)
	  if [ "x$repo" == "x" ]; then
	     exitif 1 "can not find release repo"
	  fi
	  repo=${repo}/${_BASE_RELEASE_NAME}
   fi
   
   cerbero ${_CONFIG} cpm-install base --type build --repo $repo
   exitif $? "install gstreamer base failed."
   
}



function _build_gstreamer(){
   
   #[ -d $_PREFIX ] && mv $_PREFIX ${_PREFIX}@$(date +%Y%m%d%H%M%S)
   rdir=${_RELEASE_DIR}/${_GSTREAMER_RELEASE_NAME}
   [ ! -d $rdir ] && rm -rf $rdir
   mkdir $rdir

   #cerbero ${_CONFIG} bootstrap --build-tools-disable &&
   #_install_build_tools &&
   #_install_base &&   
   #cerbero ${_CONFIG} package gstreamer-1.0 --tarball &&
   cerbero ${_CONFIG} cpm-pack gstreamer-1.0 --type sdk --output-dir $rdir

   exitif $? "build gstreamer base sdk failed."

}

#----------------------------------#
#         Main                     # 
#----------------------------------#
if [ "$_LOAD" == "Yes" ] ; then
  _load
  exitif $? "load cerbero failed."
fi

if [ "$_BOOTSTRAP" == "Yes" ] ; then
   _bootstrap
   exitif $? "bootstrap failed"
fi 

if [ "$_BASE" == "Yes" ]; then
   _build_base
   exitif $? "build gstreamer base SDK failed"
fi 

if [ "$_GSTREAMER" == "Yes" ] ;then
  _build_gstreamer
  exitif $? "build gstreamer base SDK failed"
fi


echo "        ======== DONE ! ========"


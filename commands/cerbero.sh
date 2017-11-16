__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootd__=$(cd ${__dir__}/.. ; pwd)
__cerbero_home__=$CERBERO_HOME
__cerbero_config__=$CERBERO_CONFIG

[ -z $__cerbero_config__ ] && __cerbero_config__=${__rootd__}/config.ini

if [ ! -f $__cerbero_config__ ] ; then
    echo "$__cerbero_config__ not exist!"
	exit 1
fi

function error(){
    echo $@
}
function warn(){
    echo $@
}


function get_conf(){
	section=$1
	key=$2
	filename=$__cerbero_config__

	awk -F '=' '/\['"$section"'\]/{a=1}a==1&&$1~/'"$key"'/{gsub(/[[:blank:]]*/,"",$2);printf("%s",$2) ;exit}' $filename
}


if [ -z ${__cerbero_home__} ]; then
	if [ "x$(uname)" == "xLinux" ];then
		__cerbero_home__=$(get_conf cerbero home.linux )
	else
	echo
		__cerbero_home__=$(get_conf cerbero home.windows )
	fi
fi

function load_cerbero(){

	if [ ! -d ${__cerbero_home__} ]; then
	   git clone $(get_conf cerbero repo) $@ ${__cerbero_home__}
	fi
	
	
	if [ ! -d ${__cerbero_home__} ] ; then
	   error 'can not load cerbero repos $(get_conf cerbero repo) to ${__cerbero_home__}'
	   return 1
	fi
	
	val=$(get_conf git user.name)
	[ ! -z $val ] &&  git config user.name $val
	
	val=$(get_conf git user.email)
	[ ! -z $val ] &&  git config user.email $val
	
	return 0



}

function gstreamer_version(){
	cd ${__cerbero_home__}
	./cerbero-uninstalled packageinfo gstreamer-1.0 2>&1 | awk '{if( $1== "Version:") print $2; }'
}

function load_cerbero_pkg_src(){
    version=$1
	ext=$2
	cd ${__cerbero_home__}
	
	[ -z $version ] && version=$( gstreamer_version )
	[ -z $ext ] && ext=tar.gz

	[ ! -d ~tmp ] && mkdir ~tmp 
	
	tarball=cerbero-${version}.${ext}


	if [ ! -d sources ]; then
		if [ ! -f ~tmp/${tarball} ] ; then
		    repo=$(get_conf cerbero gstreamer-bundle-source-repo)
			[ -z $repo ] && repo=https://gstreamer.freedesktop.org/data/pkg/src
			url=${repo}/${version}/${tarball}
			wget --no-check-certificate $url -O ~tmp/${tarball} 
		fi
		
		echo "extracting ${tarball}"
		tar vxf ~tmp/${tarball} -C ~tmp/
		if [ ! -d ~tmp/cerbero-${version}/sources ] ; then
			mkdir ~tmp/cerbero-${version}/sources
		fi
		mv  -f ~tmp/cerbero-${version}/sources ${__cerbero_home__}/sources
	fi


	[[  ! -d ${__cerbero_home__}/sources ]] && error 'load resource failed.' && return 1
	return 0

}

case "$1" in
	--get-config)    
	shift
	section=$1
	key=$1
	get_conf $section $key $__cerbero_config__
	;;

	--cerbero-home-directory)
	echo ${__cerbero_home__}
	;;

	--load-cerbero)
	shift
	load_cerbero $@
	;;

	--load-cerbero-pkg-src)
	shift
	load_cerbero_pkg_src $@
	;;

	*) 
	cd ${__cerbero_home__}
	./cerbero-uninstalled $@
esac

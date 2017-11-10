


__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootdir__=$(cd ${__dir__}/../.. ; pwd)
__libdir__=$(cd $__rootdir__/commands/lib; pwd )
__config__=$__rootdir__/config.ini





libcerbero=$( $__libdir__/cerbero )

cbc=config/win64.cbc
cerbero=$($libcerbero.open $__config__ $cbc)

pkgname=$($cerbero.build_tools_pkg_name)
repo=$($cerbero.release_repo build_tools)
$cerbero.run cpm-install  $pkgname --repo $repo --build-tools

for name in  base gstreamer
do
   echo "start install $name"
   repo=$($cerbero.release_repo $name)
   echo "repo: $repo"
   $cerbero.run cpm-install  --repo $repo --type build  
   
   if [ $? -ne 0 ]; then
       echo install $name failed !
	   exit 1
   fi
   echo $name install done!
done

$cerbero.run package ribbon --tarball

rdir=$($cerbero.release_dir )
rtag=$($cerbero.release_tag ribbon)
[ -d $rdir/$rtag ] && rm -rf $rdir/$rtag
mkdir -p $rdir/$rtag &&
$cerbero.run cpm-pack ribbon --type sdk --output-dir $rdir/$rtag


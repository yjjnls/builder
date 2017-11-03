__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootd__=$(cd ${__dir__}/../../.. ; pwd)
source ${__rootd__}/commands/_utils.sh
if [ ! -d ${__rootd__}/cerbero.build ];then
   git clone git@github.com:Mingyiz/cerbero.git -b 0.1 cerbero.build
fi

cd ${__rootd__}/cerbero.build
cp ${__dir__}/cerbero.cac .
git config user.email Mingyi.Z@outlook.com
git config user.name  Mingyi

git config --global user.email zhangmingyi@kedacom.com
git config --global user.name  Mingyi

repo=$(__getconfig ${__rootd__}/config.ini build-tools-windows-x86_64 repo)
filename=$(__getconfig ${__rootd__}/config.ini build-tools-windows-x86_64 filename)


cerbero_pkg=cerbero-1.12.3.tar.gz
if [ ! -f ${__rootd__}/~tmp/$cerbero_pkg ] ; then
	wget http://172.16.0.119/WMS/mirrors/gstreamer.freedesktop.org/data/pkg/src/1.12.3/$cerbero_pkg -O ${__rootd__}/~tmp/$cerbero_pkg
fi

if [ ! -d sources ]; then
   tar vxf ${__rootd__}/~tmp/$cerbero_pkg -C ${__rootd__}/~tmp/
   mv -f ${__rootd__}/~tmp/cerbero-1.12.3/sources .
fi
./cerbero-uninstalled -c config/win64.cbc bootstrap &&
./cerbero-uninstalled -c config/win64.cbc package base --tarball &&
./cerbero-uninstalled -c config/win64.cbc gstreamer-1.0 --tarball &&
./cerbero-uninstalled -c config/win64.cbc ribbon --tarball
echo done

 
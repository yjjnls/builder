
d=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
rootd=$(cd ${d}/../../.. ; pwd)

[ "_CERBERO_BUILDER_COMMAN_UTILS_LOAD" != "YES"] && source ${rootd}/commands/_utils.sh
function get_cerbero_build_directory(){
   confpath=$rootd/config.ini
   if [ "x$(uname)" == "xLinux" ];then
       __getconfig()
   
   
}










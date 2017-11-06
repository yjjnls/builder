__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__root__=$(cd ${__dir__}/../../.. ; pwd)

function cerbero(){
     ${__root__}/commands/cerbero.sh $@
}

commit='-b 0.1'

cerbero --load-cerbero  "${commit}"  &&
cerbero --load-cerbero-pkg-src &&
cerbero -c config/win64.cbc bootstrap

 
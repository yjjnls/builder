__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__root__=$(cd ${__dir__}/../.. ; pwd)


function cerbero{
    cerberod=$__root__/cerbero.custom
	if [ ! -d $cerberod ]; then
	   
	fi
}

#cerbero.sh bootstrap load cerbero from git or tarball
#           and install related package according config

#cerbero.sh configure project-dir [--debug]
#cerbero.sh compile project-dir [--debug]
#cerbero.sh check project-dir [--debug]
#cerbero.sh install project-dir [--debug]
#cerbero.sh build project-dir [--debug]

#cerbero.sh  package SDK [--debug] #package sdk in cusume package
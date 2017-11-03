__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
sys=$(uname)
if [ "$(uname)" == "Linux" ]; then
    echo "linux"

else
MSYSTEM=msys
#export PS1='\[\033]0;$MSYSTEM:\w\007
#\033[32m\]\u@\h \[\033[33m\w\033[0m\]
#$ '
source /usr/etc/profile
HOME=$USERPROFILE

cd $__dir__
#export PATH=/usr/bin:$PATH
fi


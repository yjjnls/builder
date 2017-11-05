if [ "x$MSYSTEM" == "xmsys" ]; then
__dir__=$(cd $(/usr/bin/dirname ${BASH_SOURCE[0]}); pwd )

source /usr/etc/profile
HOME=$USERPROFILE
cd $__dir__

else

echo Linux System

fi


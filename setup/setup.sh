type cmake
[ $? -ne 0 ] && echo "Please install cmake" && exit/b 1

type git
[ $? -ne 0 ] && echo "Please install git" && exit/b 1

type python
[ $? -ne 0 ] && echo "Please install Python" && exit/b 1

pip show pyyaml
[ $? -ne 0 ] && pip install pyyaml

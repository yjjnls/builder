

_CERBERO_BUILDER_COMMAN_UTILS_LOAD="YES"
#http://www.jb51.net/article/53259.htm
function __getconfig(){

	filename=$1
	section=$2
	key=$3
	#这里面的的SECTION的变量需要先用双引号，再用单引号，我想可以这样理解，
	#单引号标示是awk里面的常量，因为$为正则表达式的特殊字符，双引号，标示取变量的值
	#{gsub(/[[:blank:]]*/,"",$2)去除值两边的空格内容
	awk -F '=' '/\['"$section"'\]/{a=1}a==1&&$1~/'"$key"'/{gsub(/[[:blank:]]*/,"",$2);printf("%s",$2) ;exit}' $filename
}
#getconfig $1 $2 $3
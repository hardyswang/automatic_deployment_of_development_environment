#!/bin/bash
#这个脚本主要时完成线网代码到研发代码文件之间配置的转换
#文件有3中操作，插入字符串(insert string)、替换文件(replace file)、配置PHP常量(set constant)
#所有的配置设置都在本目录的rd_ut_set.csv文件
#csv文件各列表示的配置如下
#    1                 2                    3                               4                            5
#    INSERT_STRING     插入的文件路径       <<str>>查找的代码<</str>>       <<str>>插入的代码<</str>>    描述
#    SET_CONSTANT      配置的文件           配置的常量                      配置的值                     描述
#    REPLACE_FILE      被覆盖的文件         覆盖的文件                      描述  
#    COMMENTED_CODE    要注释的文件         <<str>>注释的代码<</str>>       描述        


#获取到各个配置文件路径
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
CONFIG_CSV=${SHELL_PATH}"/rd_ut_set.csv"

#获取EPG目录位置
FILE_PATH=$(cd ..; pwd)
INC_PATH=${FILE_PATH}"/inc/"
BESTV_INC_FILE=${INC_PATH}"bestv_constant.php"
CONF_PATH=${FILE_PATH}"/view/conf/"

#CSV文件，第一列为SET_CONSTANT执行此函数，各列的意思
# 操作，配置文件，定义的常量，定义的常量的值，描述
set_constant_fun(){
    LINE=${1}
    CONFIG_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    VARIABLE=`echo ${LINE} | awk -F ',' '{print $3}'`
    VALUE=`echo ${LINE} | awk -F ',' '{print $4}'`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $5}'`

    #去除变量两边的空格
    CONFIG_FILE=$(echo ${CONFIG_FILE})
    VARIABLE=$(echo ${VARIABLE})
    VALUE=$(echo ${VALUE})
    DESCRIPTION=$(echo ${DESCRIPTION})

    echo ${DESCRIPTION}
    echo "define('"${VARIABLE}"',"${VALUE}")"
    echo ""
    #由于防止字符串中有“/”,用“#”代替“/”
    sed -i  s#define\([\'\"]${VARIABLE}[\'\"],\.*\)#define\(\'${VARIABLE}\',\ ${VALUE}\)# ${FILE_PATH}${CONFIG_FILE}

}

#CSV文件，第一列为INSERT_STRING,各列的意思
# 操作，插入的文件，插入到第几行，插入的字符，描述
insert_string_fun(){
    LINE=${1}

    INSERT_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    #获取<<str>>...<</str>>之间的数据
    FIND_CODE=`echo ${LINE#*<<str>>}`
    FIND_CODE=`echo ${FIND_CODE%%<</str>>*}`
    INSERT_STRING=`echo ${LINE##*<<str>>}`
    INSERT_STRING=`echo ${INSERT_STRING%<</str>>*}`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $NF}'`   #获取最后一列数据
   
    INSERT_FILE=$(echo ${INSERT_FILE})
    INSERT_LINE=$((`grep -n ${FIND_CODE} ${FILE_PATH}${INSERT_FILE} | awk -F ':' '{print $1}'`+1))  #获取带代码的行数+1
    INSERT_STRING=$(echo ${INSERT_STRING})
    DESCRIPTION=$(echo ${DESCRIPTION})

    echo ${DESCRIPTION}
    echo "在文件 EPG_PATH"${INSERT_FILE}" 第 "${INSERT_LINE}" 行插入字符串"${INSERT_STRING}
    echo ""

    if [ -z "`grep ${INSERT_STRING} ${FILE_PATH}${INSERT_FILE}`" ]
    then
        sed -i ${INSERT_LINE}i${INSERT_STRING} ${FILE_PATH}${INSERT_FILE}
    fi   
}

#CSV文件，第一列为REPLACE_FILE,
# 操作，要覆盖的文件，覆盖的文件，描述
replace_file_fun(){
    LINE=${1}
    
    OLD_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    NEW_FILE=`echo ${LINE} | awk -F ',' '{print $3}'`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $4}'`
    
    OLD_FILE=$(echo ${OLD_FILE})
    NEW_FILE=$(echo ${NEW_FILE})
    DESCRIPTION=$(echo ${DESCRIPTION})

    echo ${DESCRIPTION}
    NEW_FILE_PATH=${SHELL_PATH}${NEW_FILE}
    OLD_FILE_PATH=${FILE_PATH}${OLD_FILE}
    echo "."${NEW_FILE}" 覆盖 EPG_PATH"${OLD_FILE}
    echo ""    
    # -f为强制替换
    cp -f ${NEW_FILE_PATH} ${OLD_FILE_PATH}
    
}

#CSV文件，第一列为COMMENTED_CODE,
# 操作，注释文件的路径，注释的代码，描述
commented_code_fun(){
    LINE=${1}
    
    COMMENTED_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    #获取<<str>>...<</str>>之间的数据
    COMMENTED_CODE=`echo ${LINE##*<<str>>}`
    COMMENTED_CODE=`echo ${COMMENTED_CODE%%<</str>>*}`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $4}'`
    
    COMMENTED_FILE=$(echo ${COMMENTED_FILE})
    COMMENTED_CODE=$(echo ${COMMENTED_CODE})
    DESCRIPTION=$(echo ${DESCRIPTION})
        
    echo ${DESCRIPTION}
    echo "注释代码"`grep -n "${COMMENTED_CODE}" ${FILE_PATH}${COMMENTED_FILE}`
    echo ""
    if [ -z "`grep "//.*"${COMMENTED_CODE} ${FILE_PATH}${COMMENTED_FILE}`" ]    #注意在命令的两边加""转化为字符串
    then 
        sed -i "s#.*${COMMENTED_CODE}#//&#g" ${FILE_PATH}${COMMENTED_FILE}
    fi 
}


#读取csv信息
while read LINE
do
    if [ -z `echo ${LINE} | grep '####'` ]
    then
        #获取字符并清楚空格
        OP=$(echo `echo ${LINE} | awk -F ',' '{print $1}'`)
        case ${OP} in
        "SET_CONSTANT" )
            set_constant_fun ${LINE} ;;   
        "INSERT_STRING" )
            insert_string_fun ${LINE} ;;
        "REPLACE_FILE" )
            replace_file_fun ${LINE} ;;
        "COMMENTED_CODE" )
            commented_code_fun ${LINE} ;;
        esac
    else
        echo "######################################"${LINE}"####################################################################################################"
       echo ""    
    fi

done<${CONFIG_CSV}

echo "############################################################################################################################################"


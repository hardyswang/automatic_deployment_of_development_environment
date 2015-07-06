#!/bin/bash
#����ű���Ҫʱ����������뵽�з������ļ�֮�����õ�ת��
#�ļ���3�в����������ַ���(insert string)���滻�ļ�(replace file)������PHP����(set constant)
#���е��������ö��ڱ�Ŀ¼��rd_ut_set.csv�ļ�
#csv�ļ����б�ʾ����������
#    1                 2                    3                               4                            5
#    INSERT_STRING     ������ļ�·��       <<str>>���ҵĴ���<</str>>       <<str>>����Ĵ���<</str>>    ����
#    SET_CONSTANT      ���õ��ļ�           ���õĳ���                      ���õ�ֵ                     ����
#    REPLACE_FILE      �����ǵ��ļ�         ���ǵ��ļ�                      ����  
#    COMMENTED_CODE    Ҫע�͵��ļ�         <<str>>ע�͵Ĵ���<</str>>       ����        


#��ȡ�����������ļ�·��
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
CONFIG_CSV=${SHELL_PATH}"/rd_ut_set.csv"

#��ȡEPGĿ¼λ��
FILE_PATH=$(cd ..; pwd)
INC_PATH=${FILE_PATH}"/inc/"
BESTV_INC_FILE=${INC_PATH}"bestv_constant.php"
CONF_PATH=${FILE_PATH}"/view/conf/"

#CSV�ļ�����һ��ΪSET_CONSTANTִ�д˺��������е���˼
# �����������ļ�������ĳ���������ĳ�����ֵ������
set_constant_fun(){
    LINE=${1}
    CONFIG_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    VARIABLE=`echo ${LINE} | awk -F ',' '{print $3}'`
    VALUE=`echo ${LINE} | awk -F ',' '{print $4}'`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $5}'`

    #ȥ���������ߵĿո�
    CONFIG_FILE=$(echo ${CONFIG_FILE})
    VARIABLE=$(echo ${VARIABLE})
    VALUE=$(echo ${VALUE})
    DESCRIPTION=$(echo ${DESCRIPTION})

    echo ${DESCRIPTION}
    echo "define('"${VARIABLE}"',"${VALUE}")"
    echo ""
    #���ڷ�ֹ�ַ������С�/��,�á�#�����桰/��
    sed -i  s#define\([\'\"]${VARIABLE}[\'\"],\.*\)#define\(\'${VARIABLE}\',\ ${VALUE}\)# ${FILE_PATH}${CONFIG_FILE}

}

#CSV�ļ�����һ��ΪINSERT_STRING,���е���˼
# ������������ļ������뵽�ڼ��У�������ַ�������
insert_string_fun(){
    LINE=${1}

    INSERT_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    #��ȡ<<str>>...<</str>>֮�������
    FIND_CODE=`echo ${LINE#*<<str>>}`
    FIND_CODE=`echo ${FIND_CODE%%<</str>>*}`
    INSERT_STRING=`echo ${LINE##*<<str>>}`
    INSERT_STRING=`echo ${INSERT_STRING%<</str>>*}`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $NF}'`   #��ȡ���һ������
   
    INSERT_FILE=$(echo ${INSERT_FILE})
    INSERT_LINE=$((`grep -n ${FIND_CODE} ${FILE_PATH}${INSERT_FILE} | awk -F ':' '{print $1}'`+1))  #��ȡ�����������+1
    INSERT_STRING=$(echo ${INSERT_STRING})
    DESCRIPTION=$(echo ${DESCRIPTION})

    echo ${DESCRIPTION}
    echo "���ļ� EPG_PATH"${INSERT_FILE}" �� "${INSERT_LINE}" �в����ַ���"${INSERT_STRING}
    echo ""

    if [ -z "`grep ${INSERT_STRING} ${FILE_PATH}${INSERT_FILE}`" ]
    then
        sed -i ${INSERT_LINE}i${INSERT_STRING} ${FILE_PATH}${INSERT_FILE}
    fi   
}

#CSV�ļ�����һ��ΪREPLACE_FILE,
# ������Ҫ���ǵ��ļ������ǵ��ļ�������
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
    echo "."${NEW_FILE}" ���� EPG_PATH"${OLD_FILE}
    echo ""    
    # -fΪǿ���滻
    cp -f ${NEW_FILE_PATH} ${OLD_FILE_PATH}
    
}

#CSV�ļ�����һ��ΪCOMMENTED_CODE,
# ������ע���ļ���·����ע�͵Ĵ��룬����
commented_code_fun(){
    LINE=${1}
    
    COMMENTED_FILE=`echo ${LINE} | awk -F ',' '{print $2}'`
    #��ȡ<<str>>...<</str>>֮�������
    COMMENTED_CODE=`echo ${LINE##*<<str>>}`
    COMMENTED_CODE=`echo ${COMMENTED_CODE%%<</str>>*}`
    DESCRIPTION=`echo ${LINE} | awk -F ',' '{print $4}'`
    
    COMMENTED_FILE=$(echo ${COMMENTED_FILE})
    COMMENTED_CODE=$(echo ${COMMENTED_CODE})
    DESCRIPTION=$(echo ${DESCRIPTION})
        
    echo ${DESCRIPTION}
    echo "ע�ʹ���"`grep -n "${COMMENTED_CODE}" ${FILE_PATH}${COMMENTED_FILE}`
    echo ""
    if [ -z "`grep "//.*"${COMMENTED_CODE} ${FILE_PATH}${COMMENTED_FILE}`" ]    #ע������������߼�""ת��Ϊ�ַ���
    then 
        sed -i "s#.*${COMMENTED_CODE}#//&#g" ${FILE_PATH}${COMMENTED_FILE}
    fi 
}


#��ȡcsv��Ϣ
while read LINE
do
    if [ -z `echo ${LINE} | grep '####'` ]
    then
        #��ȡ�ַ�������ո�
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


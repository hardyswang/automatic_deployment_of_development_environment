#自动部署研发环境

这个脚本主要时完成线网代码到研发代码文件之间配置的转换

```
文件有3中操作，
插入字符串(insert string)、
替换文件(replace file)、
配置PHP常量(set constant)
所有的配置设置都在本目录的rd_ut_set.csv文件

```

|操作|路径|||描述|
|---|---|---|---|---|
| INSERT_STRING| 插入的文件路径|\<\<str\>\>查找的代码\<\</str\>\> | \<\<str>>插入的代码\<\</str\>\>|描述|      
|SET_CONSTANT|  配置的文件| 配置的常量|   配置的值 |描述|
|REPLACE_FILE| 被覆盖的文件 |覆盖的文件| |描述  |
|COMMENTED_CODE  |  要注释的文件   | \<\<str\>\>注释的代码\<\</str\>\> ||  描述 |
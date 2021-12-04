# 宏替换工具
[English](README-EN.MD) | 简体中文

这是一个为编程语言加入define宏定义的工具，用于实现对不同版本、不同平台进行区分，实现原理是利用宏注释不需要的代码，该工具理论上适用于任何编程语言。  

## 使用方式
### 1.在代码中加入宏注释
```
    // #ifdef WINDOWS
    print("hello windows");
    // #endif

    // #ifdef WEB
    print("hello web");
    // #endif
```
### 2.在代码所在目录运行findtool工具，并定义宏：WINDOWS
这个命令可直接在本项目上操作来查看效果
```
    definetool -define WINDOWS 
```

在编译时若没有此宏，会将define与endif之间的内容进行/**/注释，若有宏，则进行解除注释。

宏内定义的内容不要使用多行注释


## 命令使用
-define 定义宏  
-exdir 排除文件夹  
-h 查看帮助  

## 不足与限制
1. 在#define与#endif之间不要使用多行注释/**/，yaml文件中#define与#endif之间不要使用#注释
2. #与define之间不能出现空格
3. 代码替换不会备份，若担心代码丢失请先备份代码

## 默认排除文件夹：  
bin build .git .svn debug release

## 打赏作者
打赏留言备注项目名+您的名字，您将出现在影子项目的赞助列表~
https://afdian.net/@fengdeyingzi

# definetool
English | [简体中文](README.md)

This is a tool for adding define macro definition to programming languages. It is used to distinguish different versions and platforms. The implementation principle is to annotate unnecessary code by using define macros. This tool is theoretically applicable to any programming language. 

## Mode of use
### 1.Add macro comments to your code
```
    // #ifdef WINDOWS
    print("hello windows");
    // #endif

    // #ifdef WEB
    print("hello web");
    // #endif
```
### 2.Run findtool in the directory where the code is located and define the macro: WINDOWS
This command can be operated directly on this project to view the effect
```
    definetool -define WINDOWS 
```

If there is no macro during compilation, the content between define and ENDIF will be /* */ annotated. If there is a macro, it will be uncommented.

Do not use multiline comments for the content defined in the macro


## Command to use
-define     Ding Yihong  
-exdir      Exclude folders  
-h View     help  

## Deficiencies and limitations
1. Do not use multiline comments /* */, between #define and #endif, and do not use # comments between #define and #endif in yaml files
2. #Spaces cannot appear between and define
3. The code before replacement will be backed up as a .bak file, but it is recommended to back up the code before replacement

## Default exclude folder:  
bin build .git .svn debug release

## Reward me
Reward the message, note the project name + your name, and you will appear in the sponsorship list of the shadow project~
https://afdian.net/@fengdeyingzi

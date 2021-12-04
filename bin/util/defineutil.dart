// ignore_for_file: file_names

import 'dart:io';
import 'dart:math';

import 'FileUtil.dart';

class DefineUtil {
  List<String> exdirList = ["bin", "build", ".git", ".svn", "debug", "release"];
  List<String> definesList = []; //要开启的宏
  List<String> fileNameList = [".dart", ".yaml", ".java", ".kt",".go",".rs",".js",".ts",".php",".cs",".swift",".py"];
  List<File> codeList = [];
  //要开启的宏定义名字
  String defineName = "WINDOWS";

  List<int> define = "#ifdef".codeUnits;
  List<int> endif = "#endif".codeUnits;
  String dirpath = "";

  //初始化
  DefineUtil(this.dirpath,
     {
    List<String>? exdir,
    List<String>? defines,
  }) {
    if (exdir != null) {
      exdirList = exdir;
    }
    if (defines != null) {
      definesList = defines;
    }
  }

  //获取需要定义的文件列表
  void _doFileListDir(String path) {
    Directory dir = Directory(path);
    List<FileSystemEntity> listFile = dir.listSync();
    for (int i = 0; i < listFile.length; i++) {
      var file = listFile[i];
      FileStat stat = file.statSync();
      if (stat.type == FileSystemEntityType.directory) {
        _doFileListDir(file.path);
      } else if (stat.type == FileSystemEntityType.file) {
        var endName = FileUtil.getEndName(file.path);
        if (fileNameList.contains(endName)) {
          List<int> data = FileUtil.readData(file.path);
          if(isCon(data, "#ifdef".codeUnits)){
            File filebak = File(file.path+".bak");
            if(!filebak.existsSync()){
              filebak.createSync();
            }
            if(data.length>0){
              FileUtil.writeToFileData(data, filebak.path);
            }
            codeList.add(File(file.path));
          }
          
        }
      }
    }
  }


  //判断List指定位置是否和list2一致
  bool strcmp(List<int> list, int index, List<int> list2) {
    bool iscmp = true;
    for (int i = 0; i < min(list.length, list2.length); i++) {
      if (list[i + index] != list2[i]) {
        iscmp = false;
        break;
      }
    }
    return iscmp;
  }

  //判断是否为空格
  bool isSpace(int c) {
    if (c == " ".codeUnitAt(0) || c == "\t".codeUnitAt(0)) {
      return true;
    }
    return false;
  }

  //判断是否为有效宏变量
  bool isDefineName(int c) {
    if ((c >= "a".codeUnitAt(0) && c <= "z".codeUnitAt(0)) ||
        (c >= "A".codeUnitAt(0) || c <= "Z".codeUnitAt(0)) ||
        (c >= "0".codeUnitAt(0) || c <= "9".codeUnitAt(0)) ||
        c == "_".codeUnitAt(0)) {
      return true;
    }
    return false;
  }

  //获取list指定位置的变量
  List<int> getListDefineName(List<int> list, int index) {
    List<int> listTemp = [];
    for (int i = 0; i < list.length - index; i++) {
      if (isDefineName(list[index + i])) {
        listTemp.add(list[index + i]);
      } else {
        break;
      }
    }
    return listTemp;
  }

//获取到endif之间的代码
  List<int> getEndIfList(List<int> list, int index) {
    // List<int> buffer = [];
    int type = 0;
    int end = 0;
    for (int i = index; i < list.length; i++) {
      int c = list[i];
      switch (type) {
        case 0: // /
          if (c == "/".codeUnitAt(0)) {
            type = 1;
            end = index - 1;
          }

          break;
        case 1: // /
          if (c == "/".codeUnitAt(0)) {
            type = 2;
          } else {
            type = 0;
          }

          break;
        case 2: // space
          if (isSpace(c)) {
          } else if (c == "#".codeUnitAt(0)) {
            if (strcmp(list, i, endif)) {
              return list.sublist(0, end);
            } else {}
          } else {}
          break;
        case 3:
          break;
        case 4:
          break;
      }
    }
    return list;
  }

//判断list中是否存在list2
  bool isCon(List<int> list, List<int> list2) {
    int type = 0;
    int i2 = 0;
    for (int i = 0; i < list.length; i++) {
      switch (type) {
        case 0:
          if (list2[i2] == list[i]) {
            i2++;
            if (i2 == list2.length) {
              return true;
            }
          } else {
            i2 = 0;
          }
          break;
      }
    }
    return false;
  }

  bool isConList(List<int> list, List<String> list2) {
    for(int i=0;i<list2.length;i++){
      var item = list2[i].codeUnits;
      if(isCon(list, item)){
        return true;
      }
    }
    return false;
  }

//判断到endif区间是否有注释
  bool isConComment(List<int> list, int index) {
    List<int> listTemp = getEndIfList(list, index);
    if (isCon(listTemp, "/*".codeUnits)) {
      return true;
    }
    return false;
  }

  //转换一个文件，以/*注释方式
  //去除注释没有检测结束符endif
  //添加注释没有检测是否已存在注释
  List<int> definedFile1(List<int> data) {
    int type = 0;
    // List<int> data = FileUtil.readData(filepath);

    int start = 0;
    List<int> buffer = [];
    bool isDelComment = false; //是否需要去除注释
    bool isAddComment = true; //是否需要添加注释
//是否在宏定义内
    List<int> defineKey = [];
    for (int i = 0; i < data.length; i++) {
      int c = data[i];
      print("c=$c type=$type");
      switch (type) {
        case 0:
          if (c == "/".codeUnitAt(0)) {
            type = 1;
            start = i - 2;
          } else {
            type = 0;
          }
          buffer.add(c);
          break;
        case 1:
          if (c == "/".codeUnitAt(0)) {
            type = 2;
          } else {
            type = 0;
          }
          buffer.add(c);
          break;
        case 2:
          if (c == "#".codeUnitAt(0)) {
            if (strcmp(data, i, define)) {
              print("检测到define");
              type = 3;
              i += define.length - 1;
              buffer.addAll(define);
            } else if (strcmp(data, i, endif)) {
              if (isAddComment) {
                buffer.insert(start, "/".codeUnitAt(0));
                buffer.insert(start, "*".codeUnitAt(0));
              }
              isDelComment = false;
              isAddComment = false;
              type = 0;
            } else {
              buffer.add(c);
            }
          } else if (!isSpace(c)) {
            type = 0;
            buffer.add(c);
          } else {
            buffer.add(c);
          }

          break;
        case 3: //开始获取宏定义变量
          if (c == " ".codeUnitAt(0)) {
            type = 4;
          } else {
            type = 0;
          }
          buffer.add(c);
          break;
        case 4: //开始获取宏定义变量
          if (isDefineName(c)) {
            start = i;
            defineKey = getListDefineName(data, i);
            if (strcmp(defineKey, 0, defineName.codeUnits)) {
              type = 0;

              isAddComment = false;
              if (!isConComment(data, i)) {
                isDelComment = false;
              } else {
                isDelComment = true;
              }
            } else {
              isDelComment = false;
              start = i;
              type = 0;
              //判断是否有注释
              if (!isConComment(data, i)) {
                isAddComment = true;
                buffer.add("/".codeUnitAt(0));
                buffer.add("*".codeUnitAt(0));
              } else {
                isAddComment = false;
              }
            }
          } else if (c == "\n".codeUnitAt(0)) {
            type = 0;
          }
          buffer.add(c);
          break;
        case 5: //开启define
          if (c == "/".codeUnitAt(0)) {
            type = 6;
          }
          buffer.add(c);
          break;
        case 6: //检测*
          if (c == "*".codeUnitAt(0) && isDelComment) {
            if (isDelComment) {
              buffer.removeAt(buffer.length - 1); //去除/*
            } else {
              buffer.add(c);
            }

            type = 7;
          } else if (c == "/".codeUnitAt(0)) {
            buffer.add(c);
            type = 5;
            // type = 0; //不允许出现单行注释
          } else if (c == "\n".codeUnitAt(0)) {
            type = 5;
          } //判断是否有宏
          else if (c == "#".codeUnitAt(0)) {
            if (strcmp(data, i, define)) {
              print("检测到define");
              type = 3;
              i += define.length - 1;
              buffer.addAll(define);
            } else if (strcmp(data, i, endif)) {
              isDelComment = false;
              isAddComment = false;
              type = 0;
            } else {
              buffer.add(c);
            }
          } else {
            buffer.add(c);
            type = 5;
          }

          break;
        case 7: //检测* 用于去除*/
          if (c == "*".codeUnitAt(0)) {
            type = 8;
          }
          buffer.add(c);
          break;
        case 8: //检测/ 用于去除*/
          if (c == "/".codeUnitAt(0) && isDelComment) {
            type = 9;
            if (isDelComment) {
              buffer.removeAt(buffer.length - 1);
              type = 0;
            } else {
              buffer.add(c);
            }
          } else if (c == "\n".codeUnitAt(0)) {
            type = 0;
          } else {
            type = 7;
            buffer.add(c);
          }

          break;
        case 9: // 检测/ 用于寻找结束标志endif
          if (c == "/".codeUnitAt(0)) {
            type = 10;
          }
          buffer.add(c);
          break;
        case 10: // /
          if (c == "/".codeUnitAt(0)) {
            type = 11;
          } else {
            type = 10;
          }
          buffer.add(c);
          break;
        case 11: // #
          if (c == "#".codeUnitAt(0)) {
            if (strcmp(data, i, endif)) {
              type = 19;
              i += endif.length - 1;
              buffer.addAll(endif);
            } else {
              buffer.add(c);
            }
          } else if (c == "\n".codeUnitAt(0)) {
            type = 9;
            buffer.add(c);
          } else {
            buffer.add(c);
          }
          break;
        case 15: //关闭define
          if (c == "\n".codeUnitAt(0)) {
            type = 16;
            buffer.add(c);
            buffer.add("/".codeUnitAt(0));
            buffer.add("*".codeUnitAt(0));
          } else {
            buffer.add(c);
          }

          break;
        case 16: // 寻找endif
          if (c == "/".codeUnitAt(0)) {
            type = 17;
            start = i - 3;
          }
          buffer.add(c);
          break;
        case 17: // /
          if (c == "/".codeUnitAt(0)) {
            type = 18;
          } else if (c == "\n".codeUnitAt(0)) {
            type = 16;
          } else {
            type = 16;
          }
          buffer.add(c);
          break;
        case 18: // #
          if (c == "#".codeUnitAt(0)) {
            if (strcmp(data, i, endif)) {
              type = 19;
              i += endif.length - 1;
              buffer.insert(start, "/".codeUnitAt(0));
              buffer.insert(start, "*".codeUnitAt(0));
              buffer.addAll(endif);
            } else {
              buffer.add(c);
            }
          } else if (c == "\n".codeUnitAt(0)) {
            type = 16;
            buffer.add(c);
          } else {
            buffer.add(c);
          }
          break;
        case 19: // \n
          if (c == "\n".codeUnitAt(0)) {
            type = 0;
          }
          buffer.add(c);
      }
    }
    return buffer;
  }

//将代码分割成多行list
  List<List<int>> splitCode(List<int> data) {
    List<List<int>> lines = [];
    List<int> temp = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i] != "\n".codeUnitAt(0)) {
        temp.add(data[i]);
      } else {
        lines.add(temp);
        temp = [];
      }
    }
    if (temp.isNotEmpty) {
      lines.add(temp);
    }
    return lines;
  }

  List<int> definedFile11(List<int> data) {
    List<int> buffer = [];
    List<List<int>> lines = splitCode(data);
    bool isDelComment = false; //是否需要去除注释
    bool isAddComment = false; //是否需要添加注释
//是否在宏定义内
    List<int> upline = [];
    for (int i = 0; i < lines.length - 1; i++) {
      List<int> curline = lines[i];
      List<int> nextline = lines[i + 1];
      if (isCon(curline, "#ifdef".codeUnits) && !isCon(curline, "\"".codeUnits)) {
        if (isConList(curline, definesList)) {
          print("第${i+1}行 去除注释");
          isDelComment = true;
          isAddComment = false;
          //删除下一行的/*
          if (isCon(nextline, "/*".codeUnits)) {
            nextline.removeAt(0);
            nextline.removeAt(0);
          }
        } else {
          isDelComment = false;
          isAddComment = true;
          print("第${i+1}行 找到#ifdef");
          if (!isCon(nextline, "/*".codeUnits)) {
            nextline.insertAll(0, "/*".codeUnits);
          }
        }
      } else if (isCon(curline, "#endif".codeUnits) && !isCon(curline, "\"".codeUnits)) {
        if (isAddComment && !isCon(upline, "*/".codeUnits)) {
          upline.addAll("*/".codeUnits);
        }
        if (isDelComment && isCon(upline, "*/".codeUnits)) {
          if(upline[upline.length-1] == "\r".codeUnitAt(0)){
              upline.removeLast();
              upline.removeLast();
              upline.removeLast();
            }else{
              upline.removeLast();
              upline.removeLast();
            }
          
        }
      }
      upline = curline;
    }
    for (int i = 0; i < lines.length; i++) {
      buffer.addAll(lines[i]);
      buffer.add("\n".codeUnitAt(0));
    }
    return buffer;
  }

  //转换一个文件，以#注释方式
  List<int> definedFile22(List<int> data) {
    List<int> buffer = [];
    List<List<int>> lines = splitCode(data);
    
    int endindex = 0; //endif所在的行
    for (int i = 0; i < lines.length; i++) {
      List<int> curline = lines[i];
      List<int> nextline = lines[i];
      if(i!=lines.length-1){
        nextline = lines[i+1];
      }
      if (isCon(curline, "#ifdef".codeUnits) && !isCon(curline, "\"".codeUnits)) {
        for (int j = i; j < lines.length; j++) {
          if (isCon(lines[j], "#endif".codeUnits) && !isCon(curline, "\"".codeUnits)) {
            endindex = j;
            break;
          }
        }
        if (isConList(curline, definesList)) {
          print("第${i+1}行 去除注释");
          //删除#
          for (int j = i + 1; j < endindex; j++) {
            nextline = lines[j];
            if (isCon(nextline, "#".codeUnits)) {
              nextline.removeAt(0);
            }
          }
        } else {
          print("第${i+1}行 找到#ifdef");
          for (int j = i + 1; j < endindex; j++) {
            nextline = lines[j];
            if (!isCon(nextline, "#".codeUnits)) {
              nextline.insertAll(0, "#".codeUnits);
            }
          }
        }
      }
    }
    for (int i = 0; i < lines.length; i++) {
      buffer.addAll(lines[i]);
      buffer.add("\n".codeUnitAt(0));
    }
    return buffer;
  }

  //开始执行转换
  void start() {
    _doFileListDir(dirpath);
    
    for(int i=0;i<codeList.length;i++){
      print("\n"+codeList[i].path);
      var endName = FileUtil.getEndName(codeList[i].path);
      List<int> data = FileUtil.readData(codeList[i].path);
      if(endName == ".yaml"){
        List<int> temp = definedFile22(data);
        FileUtil.writeToFileData(temp, codeList[i].path);
      }else{
        List<int> temp = definedFile11(data);
        FileUtil.writeToFileData(temp, codeList[i].path);
      }
    }
  }
}

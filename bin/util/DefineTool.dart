import 'dart:convert';
import 'dart:io';
import '../util/CodeParse.dart';
import '../util/FileUtil.dart';
/*
利用代码解析实现宏定义工具
实现思路是解析注释里面的#ifdef #ifndef #else #endif
然后根据define的值来生成新代码 
*/

class DefineTool {
  //忽略列表
  List<String> exdirList = ["bin", "build", ".git", ".svn", "debug", "release"];
  //要开启的宏
  List<String> definesList = []; 
  //扫描文件类型
  List<String> fileNameList = [".dart", ".yaml", ".yml", ".podspec", ".java", ".kt", ".go",".rs",".js",".ts",".php",".cs",".swift",".py"];
  //扫描后的文件列表
  List<File> codeList = [];

  //设置宏
  void setDefines(List<String> defines){
    definesList = defines;
  }

  void start(){
    //获取当前路径
    String path = Directory.current.path;
    //获取需要定义的文件列表
    _doFileListDir(path);
    //遍历代码进行解析，并生成新代码
    for(int i=0;i<codeList.length;i++){
      print(codeList[i].path);
      var endName = FileUtil.getEndName(codeList[i].path);
      File file = codeList[i];
      List<int> data = FileUtil.readData(file.path);
      String code = utf8.decode(data);
      String newCode = defineCode(code);
      //
      File filebak = File(file.path+".bak");
            if(!filebak.existsSync()){
              filebak.createSync();
            }
            if(data.isNotEmpty){
              filebak.writeAsBytesSync(data);
            }
      if(endName == ".yaml" || endName == ".yml" || endName == ".podspec"){
        List<int> temp = definedFile22(data);
        FileUtil.writeToFileData(temp, codeList[i].path);
      }else{
        file.writeAsStringSync(newCode);
      }
      
    }
  }
  
    //获取需要定义的文件列表
  void _doFileListDir(String path) {
    Directory dir = Directory(path);
    List<FileSystemEntity> listFile = dir.listSync();
    //循环扫描需要转换的代码
    for (int i = 0; i < listFile.length; i++) {
      var file = listFile[i];
      FileStat stat = file.statSync();
      if (stat.type == FileSystemEntityType.directory) {
        _doFileListDir(file.path);
      } else if (stat.type == FileSystemEntityType.file) {
        var endName = FileUtil.getEndName(file.path);
        if (fileNameList.contains(endName)) {
          List<int> data = FileUtil.readData(file.path);
          String code = utf8.decode(data);
          if(code.contains("#ifdef") || code.contains("#else") || code.contains("#endif") || code.contains("#ifndef")){
            codeList.add(File(file.path));
          }
        }
      }
    }
    //当前状态
    int defineState = 0; //0表示未定义 1表示ifdef 2表示ifndef
    //遍历代码进行解析，并生成新代码
    for(int i=0;i<codeList.length;i++){
      File file = codeList[i];
      List<int> data = FileUtil.readData(file.path);
      String code = utf8.decode(data);
      
      
    }
  }
  //寻找下一行的KeyWordItem
  KeyWordItem? getNextLineWordItem(CodeParseUtil parseUtil, KeyWordItem item) {
    int index = parseUtil.list_keyWordItems.indexOf(item);
    index += 1;
    bool isNextLine = false;
    for (; index < parseUtil.list_keyWordItems.length; index++) {
      KeyWordItem keyWordItem = parseUtil.list_keyWordItems[index];
      KeyWordItem? nextItem = null;
      if(index<parseUtil.list_keyWordItems.length-1){
        nextItem = parseUtil.list_keyWordItems[index+1];
      }
      if(isNextLine && keyWordItem.type == KeyWordType.TYPE_ANNOTATION){
        return parseUtil.list_keyWordItems[index-1];
      }
      if(nextItem!=null && nextItem.type == KeyWordType.TYPE_BLOCK_ANNOTATION && keyWordItem.type == KeyWordType.TYPE_LINE){
        return nextItem;
      }
      if(isNextLine){
        return keyWordItem;
      }
      if (keyWordItem.type == KeyWordType.TYPE_LINE) {
        isNextLine = true;
      }
    }
    return null;
  }
  //寻找上一行的KeyWordItem
  KeyWordItem? getForwardLineWordItem(CodeParseUtil parseUtil, KeyWordItem item) {
    int index = parseUtil.list_keyWordItems.indexOf(item);
    index -= 1;
    bool isNextLine = false;
    
    for (; index >= 0; index--) {
      // print("index "+index.toString()+" "+parseUtil.list_keyWordItems[index].type.toString()+" "+parseUtil.list_keyWordItems[index].word);
      KeyWordItem keyWordItem = parseUtil.list_keyWordItems[index];
      if(isNextLine){
        return keyWordItem;
      }

      if (keyWordItem.type == KeyWordType.TYPE_LINE && keyWordItem.word.contains("/*")) {
        return keyWordItem;
      }
      else if(keyWordItem.word.contains("*/")){
        return keyWordItem;
      }
      else if(keyWordItem.type == KeyWordType.TYPE_LINE){
        isNextLine = true;
      }
    }
    return null;
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

  //判断list中是否存在list2
  bool isCon(List<int> list, List<int> list2,{bool isFirst=false}) {
    int type = 0;
    int i2 = 0;
    if(!isFirst){
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
    }else{
      for (int i = 0; i < list.length; i++) {
      switch (type) {
        case 0:
          if(list[i] == " ".codeUnitAt(0)){
            continue;
          }else{
            type = 1;
            i--;
          }
          break;
        case 1:
          if (list2[i2] == list[i]) {
            i2++;
            if (i2 == list2.length) {
              return true;
            }
          } else {
            i2 = 0;
            return false;
          }
          break;
      }
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
            if (isCon(nextline, "#".codeUnits,isFirst: true)) {
              nextline.removeAt(0);
            }
          }
        } else {
          print("第${i+1}行 找到#ifdef");
          for (int j = i + 1; j < endindex; j++) {
            nextline = lines[j];
            if (!isCon(nextline, "#".codeUnits,isFirst: true)) {
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

  //解析代码并生成新代码
  String defineCode(String codeText){
    //当前状态
    int defineState = 0; //0表示未定义 1表示ifdef 2表示ifndef
    //是否包含
    bool isContains = false;
    //是否加注释
    bool isAddAnnotation = false;
    //是否去除注释
    
    bool isRemoveAnnotation = false;
    
    CodeParseUtil parseUtil = CodeParseUtil();
      parseUtil.parseCode(codeText);
      // print(parseUtil.toStringColor());
      for(int i=0;i<parseUtil.list_keyWordItems.length;i++){
        KeyWordItem keyWordItem = parseUtil.list_keyWordItems[i];
        //判断是否是单行注释
        if(keyWordItem.type == KeyWordType.TYPE_ANNOTATION){
          //判断是否是ifdef
          if(keyWordItem.word.contains("#ifdef")){
            isContains = false;
            defineState = 1;
            // List<String> dlist = keyWordItem.word.split(" ");
            print("dlist "+ keyWordItem.word+","+definesList.toString());
            if(definesList.length>=1){
              for(int n=0;n<definesList.length;n++){
              //   String define = dlist[n];
                if(keyWordItem.word.contains(definesList[n]) && !isContains){
                  isContains = true;
                  print("isContains = true;");
                }
              }
              //如果包含则对后面的内容去除注释
              if(isContains){
                isContains = true;
                var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
                if(wordItem!.word.startsWith("/*")){
                  wordItem.word = wordItem.word.substring(2,wordItem.word.length);
                  isRemoveAnnotation = true;
                }
              }else{  //否则加上注释
                isContains = false;
                var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
                print("加上注释："+wordItem!.word);
                if(!wordItem.word.startsWith("/*")){
                  if(wordItem.type == KeyWordType.TYPE_LINE){
                    wordItem.word = wordItem.word+"/*";
                  }else{
                    wordItem.word = "/*"+wordItem.word;
                  }
                  isAddAnnotation = true;
                }
              }
            }
          }else if(keyWordItem.word.contains("#ifndef")){
            defineState = 2;
            isContains = false;
            // List<String> ndlist = keyWordItem.word.split(" ");
            if(definesList.length>=1){
              for(int n=0;n<definesList.length;n++){
                String define = definesList[n];
                if(keyWordItem.word.contains(define) && !isContains){
                  isContains = true;
                }
              }
              //如果包含则对后面的内容加上注释
              if(isContains){
                isContains = true;
                var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
                if(!wordItem!.word.startsWith("/*")){
                  if(wordItem.type == KeyWordType.TYPE_LINE){
                    wordItem.word = wordItem.word+"/*";
                  }else{
                    wordItem.word = "/*"+wordItem.word;
                  }
                  
                  isAddAnnotation = true;
                }
              }else{  //否则去除注释
                isContains = false;
                var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
                if(wordItem!.word.startsWith("/*")){
                  wordItem.word = wordItem.word.substring(2,wordItem.word.length);
                  isRemoveAnnotation = true;
                }
              }
            }
          }else if(keyWordItem.word.contains("#else")){
            if(isAddAnnotation){
              var wordItem = getForwardLineWordItem(parseUtil, keyWordItem);
              wordItem!.word = wordItem.word+"*/";
              isAddAnnotation = false;
            }
            else if(isRemoveAnnotation){
              // print("去除注释");
              var wordItem = getForwardLineWordItem(parseUtil, keyWordItem);
              if(wordItem!.word.endsWith("*/")){
                wordItem.word = wordItem.word.substring(0,wordItem.word.length-2);
              }
              isRemoveAnnotation = false;
            }
            if(defineState == 1){
              defineState = 2;
            }else if(defineState == 2){
              defineState = 1;
            }
            // print("defineState "+defineState.toString()+" isContains "+isContains.toString());
            //如果当前是define并且包含，则去除注释
            if(defineState == 1 && isContains){
              var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
              if(wordItem!.word.startsWith("/*")){
                wordItem.word = wordItem.word.substring(2,wordItem.word.length);
                isRemoveAnnotation = true;
                // print("else 去除注释");
              }
            }
            else if(defineState == 1 && !isContains){
              var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
              if(!wordItem!.word.startsWith("/*")){
                if(wordItem.type == KeyWordType.TYPE_LINE){
                  wordItem.word = wordItem.word+"/*";
                }else{
                  wordItem.word = "/*"+wordItem.word;
                }
                
                isAddAnnotation = true;
                // print("else 加上注释"+wordItem!.word);
              }
            }
            else if(defineState == 2 && isContains){ //如果当前是ndefine并且包含，则加上注释
              
              var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
              if(!wordItem!.word.startsWith("/*")){
                if(wordItem.type == KeyWordType.TYPE_LINE){
                  wordItem.word = wordItem.word+"/*";
                }else{
                wordItem.word = "/*"+wordItem.word;
                }
                isAddAnnotation = true;
                // print("else 加上注释");
              }
            }else if(defineState == 2 && !isContains){
              var wordItem = getNextLineWordItem(parseUtil, keyWordItem);
              if(wordItem!.word.startsWith("/*")){
                wordItem.word = wordItem.word.substring(2,wordItem.word.length);
                isRemoveAnnotation = true;
                // print("else 去除注释");
              }
            }
            
          }else if(keyWordItem.word.contains("#endif")){
            defineState = 0;
            // print("isAddAnnotation "+isAddAnnotation.toString()+" isRemoveAnnotation "+isRemoveAnnotation.toString());
            if(isAddAnnotation){
              var wordItem = getForwardLineWordItem(parseUtil, keyWordItem);
              wordItem!.word = wordItem.word+"*/";
              isAddAnnotation = false;
              // print("endif 加上注释"+wordItem!.word);
            }
            else if(isRemoveAnnotation){
              var wordItem = getForwardLineWordItem(parseUtil, keyWordItem);
              if(wordItem!.word.endsWith("*/")){
                wordItem.word = wordItem.word.substring(0,wordItem.word.length-2);
              }
              isRemoveAnnotation = false;
              // print("endif 去除注释");
            }
          }
        }
      }
      
      return parseUtil.toString();
  }

}
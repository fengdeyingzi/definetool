

class CodeParseUtil {
  String code="";
  List<KeyWordItem> list_keyWordItems=[];

  CodeParseUtil() {
    list_keyWordItems = [];
  }

//分析代码
  void parseCode(String code) {
    this.code = code;
    int type = 0;
    int uptype = 0;
    int start = 0;
    int end = code.length;
    StringBuffer builder_cur = StringBuffer();
    StringBuffer builder_type = StringBuffer();
    int leve = 0;
    bool isR = false;
    for (int i = 0; i < code.length; i++) {
      String c = code[i];
      if(uptype!=type){
        builder_type.write("\x1B[32m"+type.toString()+"\x1B[0m");
        uptype = type;
      }
      builder_type.write("\x1B[35m"+c+"\x1B[0m");
      
      switch (type) {
        case 0:
          if(c == '\r'){
            isR = true;
          }
          else if (c == '\n') {
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.word = c;
            if(isR){
              item.word = "\r\n";
              isR = false;
            }
            item.type = KeyWordType.TYPE_LINE;
            list_keyWordItems.add(item);
          } else if (c == '/') {
            builder_cur.write(c);
            type = 2;
          } else if (c == '\"') {
            builder_cur.write(c);
            type = 5;
          } else if (c == '\'') {
            builder_cur.write(c);
            type = 6;
          } 
          else if (isOperators(c)) {
            KeyWordItem item = KeyWordItem();
            item.word = c;
            item.leve = leve;
            item.type = KeyWordType.TYPE_CHAR;
            list_keyWordItems.add(item);
          } else if (isNumber(c)) {
            builder_cur.write(c);
            type = 1;
          } else if (isLetter(c)) {
            builder_cur.write(c);
            type = 3;
          } else {
            KeyWordItem item = KeyWordItem();
            if (c == '{'){
            leve++;
          }
          else if (c == '}'){
            leve--;
          }
            item.leve = leve;
            item.word = c;
            item.type = KeyWordType.TYPE_CHAR;
            list_keyWordItems.add(item);
          }
          break;
        case 1: //数字
          if (isNumber(c)) {
            builder_cur.write(c);
          } else {
            KeyWordItem item2 = KeyWordItem();
            item2.leve = leve;
            item2.word = builder_cur.toString();
            builder_cur.clear();
            item2.type = KeyWordType.TYPE_FINAL;
            list_keyWordItems.add(item2);

            if (isOperators(c)) {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              list_keyWordItems.add(item);
            } else if (c == '\r' || c == '\n') {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_LINE;
              type = 0;
              list_keyWordItems.add(item);
            } else if (c == ';') {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              type = 0;
              list_keyWordItems.add(item);
            } else {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              type = 0;
              list_keyWordItems.add(item);
            }
          }

          break;
        case 2: //注释
          if (c == '*') {
            builder_cur.write(c);
            type = 11;
          } else if (c == '/') {
            builder_cur.write(c);
            type = 10;
          } else {
            builder_cur.write(c);
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.word = builder_cur.toString();
            builder_cur.clear();
            item.type = KeyWordType.TYPE_CHAR;
            list_keyWordItems.add(item);
            type = 0;
          }
          break;
        case 3: //字母
          if (isLetter(c)) {
            builder_cur.write(c);
          } else {
            KeyWordItem item2 = KeyWordItem();
            item2.leve = leve;
            item2.word = builder_cur.toString();
            builder_cur.clear();
            item2.type = KeyWordType.TYPE_VAR;
            list_keyWordItems.add(item2);
            if (isOperators(c)) {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              list_keyWordItems.add(item);
              type = 0;
            } else if (c == '\r' || c == '\n') {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_LINE;
              type = 0;
              list_keyWordItems.add(item);
            } else if (c == ';') {
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              type = 0;
              list_keyWordItems.add(item);
            } else if(c == '\"'){
              builder_cur.write(c);
              type = 5;
            }
             else {
              if(c == '{'){
                leve++;
              }else if(c == '}'){
                leve--;
              }
              KeyWordItem item = KeyWordItem();
              item.leve = leve;
              item.word = c;
              item.type = KeyWordType.TYPE_CHAR;
              type = 0;
              list_keyWordItems.add(item);
            }
          }

          break;
        case 5: //双引号
          if (c == '\\') {
            builder_cur.write(c);
            //跳过一个字符解析
            type = 7;
          } else if (c == '\"') {
            builder_cur.write(c);
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.type = KeyWordType.TYPE_STRING;
            item.word = builder_cur.toString();
            list_keyWordItems.add(item);
            builder_cur.clear();
            type = 0;
          } else {
            builder_cur.write(c);
          }
          break;
        case 6: //单引号
          if (c == '\\') {
            builder_cur.write(c);
            //跳过一个字符解析
            type = 8;
          } else if (c == '\'') {
            builder_cur.write(c);
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.type = KeyWordType.TYPE_STRING;
            item.word = builder_cur.toString();
            list_keyWordItems.add(item);
            builder_cur.clear();
            type = 0;
          } else {
            builder_cur.write(c);
          }
          break;
        case 7:
          builder_cur.write(c);
          type = 5;
          break;
        case 8:
          builder_cur.write(c);
          type = 6;
          break;
        case 10: //解析单行注释
          if (c == '\n') {
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.word = builder_cur.toString();
            builder_cur.clear();
            item.type = KeyWordType.TYPE_ANNOTATION;
            list_keyWordItems.add(item);
            type = 0;
            addLine(c);
          } else if (c == '\r') {
            KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.word = builder_cur.toString();
            builder_cur.clear();
            item.type = KeyWordType.TYPE_ANNOTATION;
            list_keyWordItems.add(item);
            type = 0;
            addLine(c);
          } else {
            builder_cur.write(c);
          }
          break;
        case 11: //多行注释

          if (c == '/') {
            if (builder_cur.length > 2 && builder_cur.toString()[builder_cur.length - 1] == '*') {
              builder_cur.write(c);
              type = 0;
              KeyWordItem item = KeyWordItem();
              item.word = builder_cur.toString();
              builder_cur.clear();
              item.type = KeyWordType.TYPE_BLOCK_ANNOTATION;
              list_keyWordItems.add(item);
            } else {
              builder_cur.write(c);
            }
          } else {
            builder_cur.write(c);
          }
          break;
      }
    
    
    }
    if(builder_cur.length>0){
      KeyWordItem item = KeyWordItem();
            item.leve = leve;
            item.type = KeyWordType.TYPE_STRING;
            item.word = builder_cur.toString();
            list_keyWordItems.add(item);
            builder_cur.clear();
    }
    // print("测试：" + builder_type.toString());

    // print("解析完成：" + list_keyWordItems.toString());
  }

  @override
  String toString() {
    StringBuffer builder = StringBuffer();
    for (int i = 0; i < list_keyWordItems.length; i++) {
      KeyWordItem item = list_keyWordItems[i];
      builder.write(item.word);
    }
    return builder.toString();
  }


  String toStringColor() {
    /*
      print('\x1B[31mThis is a red text\x1B[0m');
  print('\x1B[32mThis is a green text\x1B[0m');
  print('\x1B[33mThis is a yellow text\x1B[0m');
  print('\x1B[34mThis is a blue text\x1B[0m');
  print('\x1B[35mThis is a magenta text\x1B[0m');
  print('\x1B[36mThis is a cyan text\x1B[0m');
  print('\x1B[1mThis is a bold text\x1B[0m');
  */
    StringBuffer builder = StringBuffer();
    for (int i = 0; i < list_keyWordItems.length; i++) {
      KeyWordItem item = list_keyWordItems[i];
      if(item.word=="\r\n"){
        builder.write("换行符"+"\n");
      }
      // if(item.word == "\r" || item.word=="\n"){
      //   builder.write("换行");
      // }
      if(item.type == KeyWordType.TYPE_ANNOTATION){
        builder.write("\x1B[32m${item.word}\x1B[0m");
      }else if(item.type == KeyWordType.TYPE_VAR){
        builder.write("\x1B[34m${item.word}\x1B[0m");
      }else if(item.type == KeyWordType.TYPE_FINAL){
        builder.write("\x1B[32m${item.word}\x1B[0m");
      }else if(item.type == KeyWordType.TYPE_FUNCTION){
        builder.write("\x1B[31m${item.word}\x1B[0m");
      }else if(item.type == KeyWordType.TYPE_CHAR || item.type == KeyWordType.TYPE_STRING){
        builder.write("\x1B[35m${item.word}\x1B[0m");
      }
      else{
        builder.write(item.word);
      }
      // builder.write("--"+item.type.toString());
      
    }
    return builder.toString();
  }

//去除代码中的注释
  void clearAnnotation() {
    for (int i = list_keyWordItems.length - 1; i >= 0; i--) {
      KeyWordItem item = list_keyWordItems[i];
      if (item.type == KeyWordType.TYPE_ANNOTATION) {
        list_keyWordItems.removeAt(i);
      }
    }
    // print("解析完成：" + list_keyWordItems.toString());
  }

  void mixUp(Map<String, String> mixParams) {
    mixParams.forEach((key, value) {
      for (int i = 0; i < list_keyWordItems.length; i++) {
        KeyWordItem item = list_keyWordItems[i];
        if (item.word == key &&
            (item.type == KeyWordType.TYPE_FUNCTION ||
                item.type == KeyWordType.TYPE_VAR)) {
          item.word = value;
        }
      }
    });
  }

  void addLog(String formatStr) {
    String name = "Name";
    int index = 0;
    int leve = 0;
    bool hasIF = false; //在分号后是否有if语句
    for (int i = 0; i < list_keyWordItems.length; i++) {
      KeyWordItem item = list_keyWordItems[i];
      if (item.word == "if") {
        hasIF = true;
      } else if (item.type == KeyWordType.TYPE_FUNCTION ||
          item.type == KeyWordType.TYPE_VAR) {
        name = item.word;
      }
      if (item.word == "{") {
        leve++;
      } else if (item.word == "}") {
        leve++;
      } else if (item.type == KeyWordType.TYPE_LINE) {}
      if (item.word == ";" && leve > 0) {
        KeyWordItem logitem = KeyWordItem();
        logitem.type = KeyWordType.TYPE_FUNCTION;
        String str = "$formatStr";
        str = str.replaceFirst("{tag}", "LogTag");
        str = str.replaceFirst("{index}", "$index");
        str = str.replaceFirst("{name}", name);
        logitem.word = str;
        i++;
        if (!hasIF) {
          list_keyWordItems.insert(i, logitem);
        } else {
          // print("换行 ");
        }

        index++;
        hasIF = false;
      }
    }
  }

  void clearLog(String formatStr) {
    String name = "Name";
    int index = 0;
    int leve = 0;
    bool hasIF = false; //在分号后是否有if语句
    for (int i = 0; i < list_keyWordItems.length; i++) {
      KeyWordItem item = list_keyWordItems[i];
      if (item.word == "if") {
        hasIF = true;
      } else if (item.type == KeyWordType.TYPE_FUNCTION ||
          item.type == KeyWordType.TYPE_VAR) {
        name = item.word;
      }
      if (item.word == "{") {
        leve++;
      } else if (item.word == "}") {
        leve++;
      } else if (item.type == KeyWordType.TYPE_LINE) {}

      if (item.word == ";" && leve > 0) {
        KeyWordItem logitem = KeyWordItem();
        logitem.type = KeyWordType.TYPE_FUNCTION;
        String str = "$formatStr";
        str = str.replaceFirst("{tag}", "LogTag");
        str = str.replaceFirst("{index}", "$index");
        str = str.replaceFirst("{name}", name);
        logitem.word = str;
        i++;
        if (!hasIF) {
          list_keyWordItems.insert(i, logitem);
        } else {
          // print("换行 ");
        }

        index++;
        hasIF = false;
      }
    }
  }

  void addChar(String c) {
    KeyWordItem item = KeyWordItem();
    item.type = KeyWordType.TYPE_CHAR;
    item.word = c;
    list_keyWordItems.add(item);
  }
  void addLine(String c){
    KeyWordItem item = KeyWordItem();
    item.type = KeyWordType.TYPE_LINE;
    item.word = c;
    list_keyWordItems.add(item);
  }

  bool isNumber(String c) {
    if (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) {
      return true;
    }
    return false;
  }

  bool isLetter(String c) {
    if ((c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) || c == '_') {
      return true;
    }
    return false;
  }

  bool isOperators(String c) {
    if (c == '+' ||
        c == '-' ||
        c == '<' ||
        c == '>' ||
        c == '=' ||
        c == '*' ||
        c == '/' ||
        c == '^' ||
        c == '|' ||
        c == '&' ||
        c == '\$' ||
        c == '#' ||
        c == '%' ||
        c == '@' ||
        c == '!' ||
        c == '?' ||
        c == ':') {
      return true;
    }
    return false;
  }
}

enum KeyWordType {
  TYPE_VAR, //字母 变量（没有区分变量类型和变量名，没有判断关键字，需要后期处理）
  TYPE_FINAL, //常量
  TYPE_FUNCTION, //方法
  TYPE_CHAR, //字符（没有区分运算符和字符串）
  TYPE_STRING, //字符串
  TYPE_ANNOTATION, //单行注释
  TYPE_BLOCK_ANNOTATION, //块注释
  TYPE_LINE, //换行符
}

class KeyWordItem {
  KeyWordType type;
  String word;
  int leve=0;

  KeyWordItem({this.type = KeyWordType.TYPE_CHAR, this.word = ""});
}
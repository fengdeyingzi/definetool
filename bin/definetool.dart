import 'util/defineutil.dart';

/*
宏定义替换工具
风的影子 编写

*/
void main(List<String> arguments) {
//    #ifdef WEB
/*  print('Hello web!');*/
//    #endif
//    #ifdef WINDOWS
  print("Hello windows");
//    #endif

  print("宏定义替换工具");
  print("风的影子 编写");
  print("https://github.com/fengdeyingzi/definetool");

  String dir = "";
  // if (arguments.length >= 1) {
  //   dir = arguments[0];
  // }
  bool isDefine = false;
  bool isExDir = false;
  List<String>? defineList;
  List<String>? exDirList;
  for (int i = 0; i < arguments.length; i++) {
    String item = arguments[i];
    if (item == "-define") {
      isDefine = true;
      isExDir = false;
      defineList = [];
    } else if (item == "-exdir") {
      isExDir = true;
      isDefine = false;
      exDirList = [];
    } else if (item == "-h") {
      print("""
-define     定义宏  
-exdir      排除文件夹  
-h          查看帮助

示例：definetool -define WINDOWS 
      """);
    } else {
      if (isDefine) {
        defineList?.add(item);
      }
      if (isExDir) {
        exDirList?.add(item);
      }
    }
  }
  DefineUtil util = DefineUtil(dir, exdir: exDirList, defines: defineList);
  util.start();
}

import 'package:basic_utils/basic_utils.dart';
class BNT{
  static String toBNT(String amount){
    return (double.parse(amount)/1000000).toStringAsFixed(2);
  }
  static String seperator(String str){
    var db = double.parse(str).toString();
    var split = db.split(".");
    var rev = StringUtils.reverse(split[0]);
    var sep = StringUtils.addCharAtPosition(rev, ",", 3, repeat: true);
    var seq = StringUtils.reverse(sep);
    return seq+"."+split[1];
  }
}
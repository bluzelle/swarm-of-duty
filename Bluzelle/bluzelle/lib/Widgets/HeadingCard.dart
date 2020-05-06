import 'package:bluzelle/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget{
  final String first;
  final String second;
  HeaderTitle({@required this.first,@required this.second});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,5,0,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(first, style: TextStyle(fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold),),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.02,
          ),
          Text(second, style: TextStyle(fontSize: 25,color: secondAppTheme, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

}
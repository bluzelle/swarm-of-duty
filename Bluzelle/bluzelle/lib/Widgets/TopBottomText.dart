import 'package:bluzelle/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopBottom extends StatelessWidget{
  final String first;
  final String second;
  final FontWeight weight;
  final double size;
  TopBottom({@required this.first,@required this.second, this.weight, this.size});
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(0,5,0,0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(first, style: TextStyle(fontSize: size,color: Colors.black, fontWeight: weight),),
          SizedBox(
            width: MediaQuery.of(context).size.height*0.015,
          ),
          Text(second, style: TextStyle(fontSize: size,color: secondAppTheme, fontWeight: weight),),
        ],
      ),
    );
  }

}
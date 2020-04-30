import 'package:bluzelle/BlzData.dart';
import 'package:bluzelle/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutBluezelle extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.9,
                  child: Image.asset("logoblue.png")),
            ],
          ),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,10),
                    child: Text("What is Bluzelle?", style: TextStyle(fontSize:25, fontWeight: FontWeight.bold, color: appTheme),),
                  ),
                  Text(aboutBlz,textAlign: TextAlign.justify, style: TextStyle(color: Colors.black87),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,0,10),
                    child: Text("How to buy BLZ tokens?", style: TextStyle(fontSize:25, fontWeight: FontWeight.bold, color: appTheme),),
                  ),
                  Text(buyBlz,textAlign: TextAlign.justify, style: TextStyle(color: Colors.black87),),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}
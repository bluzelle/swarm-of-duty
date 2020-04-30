import 'package:bluzelle/Models/DelegationInfo.dart';
import 'package:bluzelle/Screens/DelegationInfo.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ValidatorCardStats extends StatelessWidget{
  final String name;
  final String commission;
  final String address;
  ValidatorCardStats({this.commission, this.address, this.name});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0,5,5,5),
        child: FlatButton(
          onPressed: (){
            Navigator.pushNamed(
              context,
              DelegationInfo.routeName,
              arguments: DelegationInfoModel(
                  name: name,
                  address: address,
                  commission: commission
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width*0.92,
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: _circle(name.substring(0,1), context) ,
                      title: Text(name),
                      subtitle: Text(address),
                      isThreeLine: true,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.6,
                    child: Divider(
                      thickness: 1,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  _circle(String str, BuildContext ctx){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.12,
      height: 100,
      child: Center(
        child: Text(str),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
}
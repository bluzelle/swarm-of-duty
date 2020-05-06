import 'package:bluzelle/Models/RedelegationAmountModel.dart';
import 'package:bluzelle/Models/RelegationSelection.dart';
import 'package:bluzelle/Screens/RedelegationAmount.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RedelegationCard extends StatelessWidget{
  final String name;
  final String commission;
  final String address;
  final RedelegationSelectionModel srcInfo;
  RedelegationCard({this.commission, this.address, this.name, this.srcInfo});

  @override
  Widget build(BuildContext context) {
    print("widget:"+srcInfo.delegatorAddress);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0,5,5,5),
        child: FlatButton(
          onPressed: (){
            Navigator.popAndPushNamed(
              context,
              RedelegationAmount.routeName,
              arguments: RedelegationAmountModel(
                  srcAddress: srcInfo.srcAddress,
                  srcName: srcInfo.name,
                  delegatorAddress: srcInfo.delegatorAddress,
                  desCommission: commission,
                destAddress: address,
                destName: name,
                  totalAmount: srcInfo.amount
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width*0.92,
            child: Container(

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: _circle(name.substring(0,1), context) ,
                  title: Text(name),
                  subtitle: Text("Commission : $commission"),
                  isThreeLine: true,
                ),
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
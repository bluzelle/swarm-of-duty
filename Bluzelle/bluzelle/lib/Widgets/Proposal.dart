import 'package:bluzelle/Models/Proposal.dart';
import 'package:bluzelle/Screens/ProposalDetails.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:flutter/material.dart';

class ProposalsWidget extends StatelessWidget{
  final Proposal model;
  Function refresh;
  ProposalsWidget({this.model, this.refresh});
  @override
  Widget build(BuildContext context) {
    String deposit = BNT.seperator(BNT.toBNT(model.total_deposit[0].amount));
    String status = model.proposal_status;
    return Container(
      width: MediaQuery.of(context).size.width*0.92,
      child: Container(

        child: FlatButton(
          onPressed: ()async {
           await  Navigator.pushNamed(
              context,
              ProposalInfo.routeName,
              arguments: model,
            );
          },
          child: Column(
            children: <Widget>[
              ListTile(
                leading: _circle(model.content.value.title.substring(0,1), context) ,
                title: Text(model.content.value.title),
                subtitle: Text("Deposit : $deposit Status: $status"),
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

import 'package:bluzelle/Models/ProposalDepositModel.dart';
import 'package:bluzelle/Screens/ProposalDepositTx.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Constants.dart';
class ProposalDepositConfirm extends StatefulWidget{
  static const routeName = '/proposalDepositConfirm';
  @override
  ProposalDepositConfirmState createState() => new ProposalDepositConfirmState();
}
class ProposalDepositConfirmState extends State<ProposalDepositConfirm>{
  String delegatorAddress="";
  bool loading = true;
  ProposalDepositModel args;
  String bal = "0";

  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      setState(() {
        loading =false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: nearlyWhite,
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "Proposal", second: "Details",)
        ),
        body: loading?_loader():ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(16,8,8,8),
                child: Text(args.model.content.value.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),)
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(args.model.content.value.description, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Deposit you are making: ", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(args.amount)+" BNT", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: ()async{

                  setState(() {
                    loading =true;
                  });
                  String tx =await BluzelleTransactions.proposalDeposit(args.model.id, args.amount);
                  Navigator.popAndPushNamed(
                      context,
                      ProposalDepositTx.routeName,
                      arguments: ProposalDepositModel(
                          model: args.model,
                          amount: args.amount,
                          balance: args.balance,
                          tx: tx
                      )

                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Confirm Deposit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  _loader(){
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}
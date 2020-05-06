import 'package:bluzelle/Models/SendTokenModel.dart';
import 'package:bluzelle/Screens/SendTokenTx.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Constants.dart';
class SendTokenConfirm extends StatefulWidget{
  static const routeName = '/sendTokenConfirm';
  @override
  SendTokenConfirmsState createState() => new SendTokenConfirmsState();
}
class SendTokenConfirmsState extends State<SendTokenConfirm> {
  String delegatorAddress = "";
  bool placingOrder = true;
  bool addr = false;
  SendTokenModel args;



  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute
          .of(context)
          .settings
          .arguments;
      setState(() {
        placingOrder = false;
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
            actionsIconTheme: IconThemeData(color: Colors.black),
            iconTheme: IconThemeData(color: Colors.black),
            title: HeaderTitle(first: "Transfer", second: "BNT",)
        ),
        body: placingOrder ? _loader() : ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Confirm", style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8,),
                    child: Text("Transfer", style: TextStyle(color: appTheme,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Your address: ",
                        style: TextStyle(color: Colors.black,)),
                    Text(
                        args.dAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Receiver Address ",
                        style: TextStyle(color: Colors.black,)),
                    Text(args.dAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Your Balance",
                        style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(args.balance), style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        "Amount to Transfer: ", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(args.amount), style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () async {
                  setState(() {
                    placingOrder = true;
                  });
                  String tx = await BluzelleTransactions.sendTokens(args.dAddress, args.amount);
                  print(tx);
                  Navigator.popAndPushNamed(
                    context,
                    SendTokenTx.routeName,
                    arguments: SendTokenModel(
                      amount: args.amount,
                      balance: args.balance,
                      dAddress: args.dAddress,
                      sAddress: args.sAddress,
                      tx: tx,
                    )
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child: Text('Make Transaction', style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  _loader() {
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}
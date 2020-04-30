import 'dart:convert';

import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/ConfirmToTransactionNewStake.dart';
import 'package:bluzelle/Models/NewStakeToConfirm.dart';
import 'package:bluzelle/Screens/TransactionNewStake.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
class NewStakeConfirmation extends StatefulWidget{
  static const routeName = '/newStakeConfirmation';
  @override
  NewStakeConfirmationState createState() => new NewStakeConfirmationState();
}
class NewStakeConfirmationState extends State<NewStakeConfirmation>{
  String delegatorAddress="";
  bool placingOrder = false;
  bool balance = false;
  String bal = "0";
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });
    Response resp = await BluzelleWrapper.getBalance(prefs.getString("address"));
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    BalanceWrapper model = new BalanceWrapper.fromJson(json);
    setState(() {
      if(model.result.isEmpty){
        bal = "0";
      }else {
        bal = BNT.toBNT(model.result[0].amount);
      }
    });
  }
  @override
  void initState() {
    _getAddress();
  }
  @override
  Widget build(BuildContext context) {
    final HomeToNewStakeConfirm args = ModalRoute.of(context).settings.arguments;
    // TODO: implement build
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: nearlyWhite,
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "New", second: "Delegation",)
        ),
        body: placingOrder?_loader():ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16,8,8,8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Confirm", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                    child: Text("Details", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Delegator Address: ", style: TextStyle(color: Colors.black,)),
                    Text(delegatorAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Validator Name: ", style: TextStyle(color: Colors.black,)),
                    Text(args.name, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Validator address: ", style: TextStyle(color: Colors.black,)),
                    Text(args.address, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Commission: ", style: TextStyle(color: Colors.black,)),
                    Text(args.commission, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Your Balance", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(bal)+ " BNT", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Amount to Stake", style: TextStyle(color: Colors.black,)),
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
                onPressed: ()async {
                  setState(() {
                    placingOrder=true;
                  });
                  var tx = await BluzelleTransactions.sendDelegation(args.amount, args.address);
                  print(tx);
                  Navigator.pushNamed(
                    context,
                    TransactionNewStake.routeName,
                    arguments: ConfirmToTranscation(
                        name: args.name,
                        address: args.address,
                        commission: args.commission,
                        amount: args.amount,
                        tx: tx,
                      delAddr: args.delAddr
                    ),
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Confirm Stake', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
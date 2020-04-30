import 'dart:convert';

import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/HomeToNewStake.dart';
import 'package:bluzelle/Models/NewStakeToConfirm.dart';
import 'package:bluzelle/Screens/NewStakeConfirmation.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class NewStake extends StatefulWidget{
  static const routeName = '/newStake';
  @override
  NewStakeState createState() => new NewStakeState();
}
class NewStakeState extends State<NewStake>{
  String delegatorAddress="";
  bool placingOrder = false;
  bool balance = false;
  String bal = "0";
  TextEditingController _amount= new TextEditingController();
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
        bal ="0";
      }
      else{
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
    final HomeToNewStake args = ModalRoute.of(context).settings.arguments;
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
                    child: Text("Delegation", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
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
                    Text(BNT.seperator(bal) +"BNT", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                autovalidate: true,
                validator: (val) => (val!=""?double.parse(val)<double.parse(bal):true)
                    ? null
                    : 'Please enter a valid amount',
                decoration: InputDecoration(
                  hintText: "Amount to Stake",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Note: If you are already a delegator to this validator, this action will add specified tokens to you existing stake amount"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: (){
                  if(_amount.text==0.toString()){
                    Toast.show("Invalid amount",context, duration: Toast.LENGTH_LONG);
                    return;
                  }

                  Navigator.popAndPushNamed(
                    context,
                    NewStakeConfirmation.routeName,
                    arguments: HomeToNewStakeConfirm(
                        name: args.name,
                        address: args.address,
                        commission: args.commission,
                        amount: _amount.text
                    ),
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Stake', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
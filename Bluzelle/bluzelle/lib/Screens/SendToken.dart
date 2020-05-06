import 'dart:convert';

import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/HomeToNewStake.dart';
import 'package:bluzelle/Models/SendTokenModel.dart';
import 'package:bluzelle/Screens/SendTokenConfirm.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class SendTokens extends StatefulWidget{
  static const routeName = '/sendToken';
  @override
  SendTokensState createState() => new SendTokensState();
}
class SendTokensState extends State<SendTokens>{
  String delegatorAddress="";
  bool placingOrder = false;
  bool balance = false;
  String bal = "0";
  TextEditingController _amount= new TextEditingController();
  TextEditingController _address= new TextEditingController();
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });
    print(delegatorAddress);
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
            title: HeaderTitle(first: "Transfer", second: "BNT",)
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
                    child: Text("Transfer", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
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
                    Text("Your Balance: ", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(bal)+" BNT", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: TextFormField(
                controller: _address,
                keyboardType: TextInputType.text,
                autovalidate: true,
                validator: (val) => (val!=""?val.length ==47:true)
                    ? null
                    : 'Please enter a valid amount',
                decoration: InputDecoration(
                  hintText: "Address of receiver ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20,10,20,10),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                autovalidate: true,
                validator: (val) => (val!=""?double.parse(val)<double.parse(bal):true)
                    ? null
                    : 'Please enter a valid amount',
                decoration: InputDecoration(
                  hintText: "Amount to Trnasfer",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),


            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: (){
                  if(double.parse(_amount.text)>double.parse(bal)||_amount.text==""){
                    Toast.show("Invalid amount",context, duration: Toast.LENGTH_LONG);
                    return;
                  }
                  if(_address.text.length !=47){
                    Toast.show("Invalid address",context, duration: Toast.LENGTH_LONG);
                    return;
                  }
                  print(delegatorAddress.length);
                  Navigator.popAndPushNamed(
                    context,
                    SendTokenConfirm.routeName,
                    arguments: SendTokenModel(
                      sAddress: delegatorAddress,
                      dAddress: _address.text,
                      amount: _amount.text,
                      balance: bal,
                    )
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Transact', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
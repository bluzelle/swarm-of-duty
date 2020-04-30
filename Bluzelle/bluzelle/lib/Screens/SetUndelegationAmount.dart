
import 'package:bluzelle/Models/ToWithdrawConfirmation.dart';
import 'package:bluzelle/Screens/UndelegateConfirmation.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class SetUndelegationAmount extends StatefulWidget{
  static const routeName = '/setUndelegationAmount';
  @override
  SetUndelegationAmountState createState() => new SetUndelegationAmountState();
}
class SetUndelegationAmountState extends State<SetUndelegationAmount>{
  String delegatorAddress="";
  bool placingOrder = false;
  ToWithdrawConfirmation args;
  TextEditingController _amount = TextEditingController();
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });

  }
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      _getAddress();
      setState(() {
        placingOrder= false;
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
            title: HeaderTitle(first: "Undelegate", second: "Validator",)
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
                    child: Text("Withdrawl", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                    child: Text("Information", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
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
                    Text("Total Amount", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(args.amount), style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                autovalidate: true,
                validator: (val) => (val!=""?double.parse(val)<double.parse(args.amount):true)
                    ? null
                    : 'Please enter a valid amount',
                decoration: InputDecoration(
                  hintText: "Amount to Withdraw",
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
                    if(double.parse(_amount.text)>double.parse(args.amount)||_amount.text==""){
                      Toast.show("Invalid Input", context,);
                      return;
                    }

                      Navigator.popAndPushNamed(
                        context,
                        UndelegateConfirmation.routeName,
                        arguments: ToWithdrawConfirmation(
                            name: args.name,
                            address: args.address,
                            commission: args.commission,
                            amount: _amount.text
                        ),
                      );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Undelegate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
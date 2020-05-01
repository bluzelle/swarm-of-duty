import 'package:bluzelle/Screens/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sacco/network_info.dart';
import 'package:sacco/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';

class Login extends StatelessWidget{
  static const routeName  = "/login";
  TextEditingController _mnemonic = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nearlyWhite,
        elevation: 0,
        brightness: Brightness.light,
      ),
      backgroundColor: nearlyWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logoblue.png"),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _mnemonic,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  maxLines: null,
                  validator: (val) => (val.isEmpty||val.split(" ").length==24)
                      ? null
                      : 'Invalid Mnemonic',
                  decoration: InputDecoration(
                    hintText: "Enter Your Mnemonic",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: ()async{
                  var str =_mnemonic.text;
                  if(str.split(" ").length !=24 ){
                    Toast.show("Invalid Phrase", context, duration: Toast.LENGTH_LONG);
                    return;
                  }
                  var  networkInfo = NetworkInfo( bech32Hrp: "bluzelle", lcdUrl: "http://testnet.public.bluzelle.com:1317", defaultTokenDenom: "ubnt");

                  final mn = str.split(" ");
                  final wallet = Wallet.derive(mn,  networkInfo);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString(mnemonic, str);
                  await prefs.setString(prefAddress,wallet.bech32Address);
                  Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (r) => false);
                },
                color: Colors.red,
                child: Text("Continue",style: TextStyle(color: Colors.white),),
              )

            ],
          ),
        ),
      ),
    );
  }

}
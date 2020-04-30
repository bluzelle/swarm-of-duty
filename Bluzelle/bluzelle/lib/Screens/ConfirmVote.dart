
import 'package:bluzelle/Models/VoteModel.dart';
import 'package:bluzelle/Screens/VoteTx.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import '../Constants.dart';
class ConfirmVote extends StatefulWidget{
  static const routeName = '/confirmVote';
  @override
  ConfirmVoteState createState() => new ConfirmVoteState();
}
class ConfirmVoteState extends State<ConfirmVote>{
  String delegatorAddress="";
  bool loading = true;
  VoteModel args;
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
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Confirm", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                    child: Text("Vote", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                  ),

                ],
              ),
            ),
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
                    Text("Your Vote ", style: TextStyle(color: Colors.black,)),
                    Text(args.vote, style: TextStyle(color: Colors.grey,))
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
                   String tx =await BluzelleTransactions.vote(args.model.id, args.vote);
                  Navigator.popAndPushNamed(
                      context,
                      VoteTx.routeName,
                      arguments: VoteModel(
                          model: args.model,
                          vote: args.vote,
                          tx: tx
                      )

                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Cast the Vote', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
import 'package:bluzelle/Models/NewProposalModel.dart';
import 'package:bluzelle/Screens/NewProposalTx.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Constants.dart';
class NewProposalConfirmation extends StatefulWidget{
  static const routeName = '/newProposalConfirmation';
  @override
  NewProposalConfirmationState createState() => new NewProposalConfirmationState();
}
class NewProposalConfirmationState extends State<NewProposalConfirmation>{

  NewProposalModel args;
  bool _loading = true;
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      setState(() {
        _loading = false;
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
            title: HeaderTitle(first: "New", second: "Proposal",)
        ),
        body: _loading?_loader():ListView(
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
                    child: Text("Proposal", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
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
                    Text("Title", style: TextStyle(color: Colors.black,)),
                    Text(args.title, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Description ", style: TextStyle(color: Colors.black,)),
                    Text(args.description, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Deposit ", style: TextStyle(color: Colors.black,)),
                    Text(BNT.seperator(args.stake)+" BNT", style: TextStyle(color: Colors.grey,))
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
                    _loading  =true;
                  });
                  String tx =await BluzelleTransactions.newProposal(args.description, args.title, args.stake);
                  Navigator.popAndPushNamed(
                    context,
                    NewProposalTx.routeName,
                    arguments: NewProposalModel(
                      stake: args.stake,
                      description: args.description,
                      title: args.title,
                      tx: tx,
                    )
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Confirm', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
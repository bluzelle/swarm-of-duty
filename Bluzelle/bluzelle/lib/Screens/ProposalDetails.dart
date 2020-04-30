import 'dart:convert';

import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/Proposal.dart';
import 'package:bluzelle/Models/ProposalDepositModel.dart';
import 'package:bluzelle/Models/UserVoteWrapper.dart';
import 'package:bluzelle/Models/VoteModel.dart';
import 'package:bluzelle/Screens/ConfirmVote.dart';
import 'package:bluzelle/Screens/ProposalDepositConfirm.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
class ProposalInfo extends StatefulWidget{
  static const routeName = '/proposalInfo';
  @override
  ProposalInfoState createState() => new ProposalInfoState();
}
class ProposalInfoState extends State<ProposalInfo>{
  TextEditingController _amount = TextEditingController();
  String delegatorAddress="";
  bool depositing =false;
  bool loading = true;
  Proposal args;
  String bal = "0";
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });
    Response resp = await BluzelleWrapper.getBalance(delegatorAddress);
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    print(json);
    BalanceWrapper model = new BalanceWrapper.fromJson(json);
    setState(() {
      if(model.result.isEmpty){
        bal = "0.0";
      }else {
        bal = BNT.toBNT(model.result[0].amount);
      }
      loading = false;
    });
  }
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      _getAddress();
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
              child: Text(args.content.value.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),)
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(args.content.value.description, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            args.proposal_status=="DepositPeriod"? Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Deposits: ", style: TextStyle(color: Colors.black,)),
                    Text(BNT.toBNT(args.total_deposit[0].amount)+" BNT", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ): SizedBox(height: 0,),
            args.proposal_status!="DepositPeriod"&&args.proposal_status!="VotingPeriod"?Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Votes: ", style: TextStyle(color: Colors.black,)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("Yes: "+args.final_tally_result.yes, style: TextStyle(color: Colors.grey,)),
                          Text("No: "+args.final_tally_result.no, style: TextStyle(color: Colors.grey,)),
                          Text("Abstain: "+args.final_tally_result.abstain, style: TextStyle(color: Colors.grey,)),
                          Text("No With Veto: "+args.final_tally_result.no_with_veto, style: TextStyle(color: Colors.grey,)),
                        ],
                      ),
                    )
                  ],
                )
            ):SizedBox(height: 0,),
            args.proposal_status == "VotingPeriod"?FutureBuilder(
              future : BluzelleWrapper.castedVote(args.id, delegatorAddress),
              builder: (BuildContext context, snapshot){
                try{
                  if(snapshot.error==null){
                    print("status error");
                    if(snapshot.data.statusCode == 404){
                      print("status 404");
                      return SizedBox(
                        height: 0,
                      );
                    }
                    else{
                      print("status not 404");
                      String body = utf8.decode(snapshot.data.bodyBytes);
                      final json = jsonDecode(body);
                      UserVoteWrapper model = UserVoteWrapper.fromJson(json);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(30,8,8,8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("You have casted:"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(model.result.option),
                            )
                          ],
                        ),
                      );

                    }
                  }
                  else{
                    print("status not error");
                    return SizedBox(
                      height: 0,
                    );
                  }
                }
                catch(e){
                  print(e);
                  return SizedBox(
                    height: 0,
                  );
                }

              },
            ):SizedBox(height: 0,),
            args.proposal_status=="DepositPeriod"? Padding(
                padding: const EdgeInsets.fromLTRB(30,8,30,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    depositing?SizedBox(height: 0,):RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: (){
                       setState(() {
                         depositing =true;
                       });
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:Text('Make a deposit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    depositing?Padding(
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
                    ):SizedBox(height: 0,),
                    depositing?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            onPressed: (){
                              Navigator.of(context).popAndPushNamed(
                                ProposalDepositConfirm.routeName,
                                arguments: ProposalDepositModel(
                                  model: args,
                                  amount: _amount.text,
                                  balance: bal,
                                )
                              );
                            },
                            padding: EdgeInsets.all(12),
                            color: appTheme,
                            child:Text('Deposit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ):SizedBox(height: 0,),
                  ],
                )
            ):SizedBox(height: 0,) ,
            args.proposal_status=="VotingPeriod"?Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Vote or change Vote", style: TextStyle(color: Colors.black,)),
                  ],
                )
            ):SizedBox(height: 0,) ,
            args.proposal_status=="VotingPeriod"?
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: (){
                        Navigator.of(context).popAndPushNamed(
                            ConfirmVote.routeName,
                            arguments: VoteModel(
                              model: args,
                              vote : "Yes"
                            )
                        );
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:SizedBox(
                          width: MediaQuery.of(context).size.width*0.3,
                          child: Center(child: Text('Yes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                      )
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: (){
                        Navigator.of(context).popAndPushNamed(
                            ConfirmVote.routeName,
                            arguments: VoteModel(
                                model: args,
                                vote : "No"
                            )
                        );
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:SizedBox(
                          width: MediaQuery.of(context).size.width*0.3,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.3,
                              child: Center(child: Text('No', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                          )
                      ),
                    ),

                  ],
                ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     RaisedButton(
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(24),
                       ),
                       onPressed: (){
                         Navigator.of(context).popAndPushNamed(
                             ConfirmVote.routeName,
                             arguments: VoteModel(
                                 model: args,
                                 vote : "Abstain"
                             )
                         );
                       },
                       padding: EdgeInsets.all(12),
                       color: appTheme,
                       child:SizedBox(
                           width: MediaQuery.of(context).size.width*0.3,
                           child: Center(child: Text('Abstain', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                       )
                     ),
                     RaisedButton(
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(24),
                       ),
                       onPressed: (){
                         Navigator.of(context).popAndPushNamed(
                             ConfirmVote.routeName,
                             arguments: VoteModel(
                                 model: args,
                                 vote : "NowithVeto"
                             )
                         );
                       },
                       padding: EdgeInsets.all(12),
                       color: appTheme,
                       child:SizedBox(
                           width: MediaQuery.of(context).size.width*0.3,
                           child: Center(child: Text('No With Veto', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                       )
                     ),

                   ],
                 ),

              ],
            ) :
            SizedBox(height: 0,),

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
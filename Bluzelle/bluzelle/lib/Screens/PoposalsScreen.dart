import 'dart:convert';
import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Models/ProposalListModel.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/Proposal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'NewProposal.dart';
class ProposalListTab extends StatefulWidget {
  Function refresh;
  @override
  ProposalListState createState() => ProposalListState();
}

class ProposalListState extends State<ProposalListTab> with
    AutomaticKeepAliveClientMixin {

    var _loadingData;
 @override
 void initState() {
   super.initState();
   widget.refresh =(){
     setState(() {
       _loadingData = BluzelleWrapper.proposalList();
     });
   };
   _loadingData = BluzelleWrapper.proposalList();


  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),
        FutureBuilder(
          future: _loadingData,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.3,
                    ),
                    Center(child: SpinKitCubeGrid(size:50, color: appTheme)),
                  ],
                ),
              );
            } else if (snapshot.error != null) {
              print(snapshot.error);
              return Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.3,
                      ),
                      Center(
                        child: Text('Something went wrong :('),
                      ),
                    ],
                  ));
            }else {
              String body = utf8.decode(snapshot.data.bodyBytes);
              final json = jsonDecode(body);
              ProposalListModel model = new ProposalListModel.fromJson(json);
              if(model.result.length==0){
                return Center(
                  child: Text("No Proposals So far")
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,0,8,25),
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(width:MediaQuery.of(context).size.width*0.7,
                          child: Center(child: Text("ADD NEW PROPOSAL"))),
                      onPressed: (){
                        Navigator.pushNamed(context, NewProposal.routeName);
                      },
                      
                      borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.builder(
                      shrinkWrap: true,
                      cacheExtent: 100,
                      itemCount: model.result.length,
                      itemBuilder: (BuildContext ctx, int index ){

                        return ProposalsWidget(
                          model: model.result[model.result.length -1 - index],
                          refresh: widget.refresh,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}
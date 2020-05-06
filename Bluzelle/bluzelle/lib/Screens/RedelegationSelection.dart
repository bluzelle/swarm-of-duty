import 'dart:convert';

import 'package:bluzelle/Models/RelegationSelection.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:bluzelle/Widgets/RedelegationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Constants.dart';
class RedelegationSelection extends StatefulWidget{
  static const routeName = '/redelegationSelection';
  @override
  RedelegationSelectionState createState() => new RedelegationSelectionState();
}
class RedelegationSelectionState extends State<RedelegationSelection>{

  RedelegationSelectionModel args;

  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      print(args.delegatorAddress);
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
            title: HeaderTitle(first: "Redelegate", second: "Stake",)
        ),
        body:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16,8,8,8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Select", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                    child: Text("Validator", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                  ),

                ],
              ),
            ),
            FutureBuilder(
              future: BluzelleWrapper.getValidatorList(),
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
                  ValidatorList model = new ValidatorList.fromJson(json);
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      cacheExtent: 100,
                      itemCount: model.result.length,
                      itemBuilder: (BuildContext ctx, int index ){
                        if(model.result[index].operator_address==args.srcAddress){
                          return SizedBox(
                            height: 0,
                          );
                        }
                        return RedelegationCard(
                          commission: model.result[index].commission.commission_rates.rate,
                          name: model.result[index].description.moniker,
                          address: model.result[index].operator_address,
                          srcInfo: args,
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        )
    );
  }
}
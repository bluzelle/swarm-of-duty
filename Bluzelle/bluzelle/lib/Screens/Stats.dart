import 'dart:convert';
import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/BondedNotBondedWrapper.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/BNT.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Utils/HexColor.dart';
import 'package:bluzelle/Widgets/CurvePainter.dart';
import 'package:bluzelle/Widgets/ValidatorCardStats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';

class Stats extends StatefulWidget{
  Function refresh;
  @override
  StatsState createState() => StatsState();
}
class StatsState extends State<Stats>with AutomaticKeepAliveClientMixin{
  String balance = "123";
  String unbondedStake = "123";
  String bondedStake = "321";
  bool loading = false;
  bool error = false;
  String address;
  ValidatorList valList;
  getInfo()async {
    setState(() {
      error =false;
      loading = true;
    });
    Response pools = await BluzelleWrapper.getPool();
    String body = utf8.decode(pools.bodyBytes);
    final json = jsonDecode(body);
    BondedNotBondedWrapper model = new BondedNotBondedWrapper.fromJson(json);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("address");
    Response balModel = await BluzelleWrapper.getBalance(address);
    String body1 = utf8.decode(balModel.bodyBytes);
    final json1 = jsonDecode(body1);
    Response delegations = await BluzelleWrapper.getDelegations(address);
    String delBody = utf8.decode(delegations.bodyBytes);
    final delJson = jsonDecode(delBody);
    BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
    valList = ValidatorList.fromJson(delJson);
    bondedStake = BNT.toBNT(model.result.bonded_tokens);
    unbondedStake = BNT.toBNT(model.result.not_bonded_tokens);
    if(balanceWrapper.result.isEmpty){
      balance = "0.0";
    }else {
      balance = BNT.toBNT(balanceWrapper.result[0].amount);
    }
    setState(() {
      loading = false;
      this.address = address;
    });
  }
  _curveAngle(){
    double bstake= double.parse(bondedStake);
    double ustake = double.parse(unbondedStake);
    int sum = (bstake+ustake).toInt();
    if (sum ==0){
      return 0;
    }
    double maticDiff = (sum - ustake.toInt())/sum;
    double  angle = (360.0*maticDiff);
    print(angle);
    return angle;
  }

  @override
  void initState() {
    try {
      getInfo();
    } catch(e){
      setState(() {
        error = true;
      });
    }
    widget.refresh = (){
      try {
        getInfo();
      } catch(e){
        setState(() {
          error = true;
        });
      }
    };
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return error?Center(
      child: Text("Something went wrong :("),
    ):loading==true?Center(
      child: SpinKitCubeGrid(size:50, color: appTheme),
    ):ListView(
      children: <Widget>[
        Card(
          elevation: 0,
          color: nearlyWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Container(
            width: MediaQuery.of(context).size.width*0.9,
            //height: MediaQuery.of(context).size.height*0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black,
                Colors.black87
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),

            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0,5,5,35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,5,5,4),
                        child: Text("Account",style: TextStyle(fontSize:25,color: Colors.white70, fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,5,5,4),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                            width: MediaQuery.of(context).size.width*0.2,
                            child: Image.asset("logo.png"))
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Text("Balance: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Text(BNT.seperator(balance)+" BNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.8,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,0,8,0),
                            child: Text(address, overflow: TextOverflow.ellipsis , textAlign: TextAlign.start , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Card(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            //height: MediaQuery.of(context).size.height*0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                HexColor("#00264d"),
                HexColor("#003366"),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),

            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0,8,5,15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,20,5,6),
                        child: Text("Staking Pools",style: TextStyle(fontSize:25,color: Colors.white70, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),

                  SizedBox(
                  //  height: MediaQuery.of(context).size.height*0.25,
                    width: MediaQuery.of(context).size.width*0.83,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                child: Text("Bonded Stake: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,8,15),
                                child: Text(BNT.seperator(bondedStake)+" BNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                child: Text("Unbonded Stake: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                child: Text(BNT.seperator(unbondedStake) +" BNT", overflow: TextOverflow.ellipsis , textAlign: TextAlign.start , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                              ),
                            ],
                          ),

                          CustomPaint(
                            painter: CurvePainter(
                                colors: [
                                  Colors.greenAccent,
                                  Colors.green,
                                  Colors.lightGreen
                                ],
                                angle: _curveAngle()
                            ),
                            child: SizedBox(
                              width: 108,
                              height: 108,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16,5,5,10),
          child: Text("Delegations",style: TextStyle(fontSize:25,color: grey, fontWeight: FontWeight.bold),),
        ),
        valList.result.length==0?Padding(
          padding: const EdgeInsets.fromLTRB(16,25,15,16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Text("No Delegations",style: TextStyle(fontSize:20,color: grey, fontWeight: FontWeight.normal),)),
            ],
          ),
        ):SizedBox(height: 0,),
        ListView.builder(
            itemCount: valList.result.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index){
              return ValidatorCardStats(address: valList.result[index].operator_address,name: valList.result[index].description.moniker,commission: valList.result[0].commission.commission_rates.max_rate,);
            }
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

}
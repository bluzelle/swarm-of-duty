import 'package:http/http.dart' as http;

class BluzelleWrapper{
  static const String baseUrl = "http://testnet.private.bluzelle.com:1317";
  static Future<http.Response> getValidatorList() async {
    const url = baseUrl+"/staking/validators";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getBalance(String address) async {
    var url = baseUrl+"/bank/balances/"+address;
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getPool() async {
    var url = baseUrl+"/staking/pool";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getDelegations(String address) async {
    var url = baseUrl+"/staking/delegators/$address/validators";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> delegationInfo(String delAddress, String valAddress) async {
    var url = baseUrl+"/distribution/delegators/$delAddress/rewards/$valAddress";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> delegatedAmount(String delAddress, String valAddress) async {
    var url = baseUrl+"/staking/delegators/$delAddress/delegations/$valAddress";
    print(url);
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> proposalList() async {
    var url = baseUrl+"/gov/proposals";
    print(url);
    var resp = await http.get(url);
    print(resp.body);
    return resp;
  }
  static Future<http.Response> castedVote(String id, String address) async {
    var url = baseUrl+"/gov/proposals/$id/votes/$address";
    print(url);
    var resp = await http.get(url);
    print(resp.body);
    return resp;
  }


}
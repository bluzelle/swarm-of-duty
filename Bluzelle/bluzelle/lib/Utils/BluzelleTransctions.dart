import 'package:sacco/sacco.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluzelleTransactions {
  static var  networkInfo = NetworkInfo(bech32Hrp: "bluzelle", lcdUrl: "http://testnet.private.bluzelle.com:1317", defaultTokenDenom: "ubnt");

  static sendTokens(String addr, String amount)async {
    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
      type: "cosmos-sdk/MsgSend",
      value: {
        "from_address": wallet.bech32Address,
        "to_address": addr,
        "amount": [
          {"denom": "ubnt", "amount": _stake.toString()}
        ],
      },
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
    fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    print(stdTx);

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return result.hash;
    } else {
      print("Tx send error: ${result.error.errorMessage}"
      );
      return result.error.errorMessage;
    }

  }
  static Future<String> sendDelegation(String amount, String validator)async {
    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
      type: "cosmos-sdk/MsgDelegate",
      value: {
        "amount": {
          "amount": _stake.toString(),
          "denom": "ubnt"
        },
        "delegator_address": wallet.bech32Address,
        "validator_address": validator
      },
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>withdrawReward(String delegator, String validator)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
      type: "cosmos-sdk/MsgWithdrawDelegationReward",
      value: {
        "delegator_address": wallet.bech32Address,
        "validator_address": validator
      }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>undelegate(String delegator, String validator, String amount)async {
    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
        type: "cosmos-sdk/MsgUndelegate",
        value: {
          "amount": {
            "amount": _stake.toString(),
            "denom": "ubnt"
          },
          "delegator_address": delegator,
          "validator_address": validator
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>redelegate(String srcValidator, String destValidator, String delegator,String amount)async {
    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
        type: "cosmos-sdk/MsgBeginRedelegate",
        value:{
          "amount": {
            "amount": _stake.toString(),
            "denom": "ubnt"
          },
          "delegator_address": delegator,
          "validator_dst_address": destValidator,
          "validator_src_address": srcValidator
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>newProposal(String description, String title, String stake)async {
    int _stake = (1000000*double.parse(stake)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
        type: "cosmos-sdk/MsgSubmitProposal",
        value:{
          "content": {
            "type": "cosmos-sdk/TextProposal",
            "value": {
              "title": title,
              "description": description
            }
          },
          "initial_deposit": [
            {
              "amount": _stake.toString(),
              "denom": "ubnt"
            }
          ],
          "proposer": wallet.bech32Address
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>proposalDeposit(String id, String stake)async {
    int _stake = (1000000*double.parse(stake)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
        type: "cosmos-sdk/MsgDeposit",
        value:{
          "amount": [
            {
              "amount":_stake.toString() ,
              "denom": "ubnt"
            }
          ],
          "depositor": wallet.bech32Address,
          "proposal_id": id
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
      fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>vote(String id, String vote)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seed= prefs.getString("mnemonic");
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    final message = StdMsg(
        type: "cosmos-sdk/MsgVote",
        value: {
          "option": vote,	// Yes, No, NowithVeto, Abstain
          "proposal_id": id,
          "voter": wallet.bech32Address
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
      fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
}

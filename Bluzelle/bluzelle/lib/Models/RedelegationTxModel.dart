class RedelegationTxModel {
  final String srcAddress;
  final String srcName;
  final String delegatorAddress;
  final String destName;
  final String destAddress;
  final String totalAmount;
  final String newAmount;
  final String desCommission;
  final String tx;
  RedelegationTxModel({this.tx,this.srcAddress, this.srcName, this.delegatorAddress,this.destAddress, this.desCommission,this.destName,this.totalAmount, this.newAmount});
}
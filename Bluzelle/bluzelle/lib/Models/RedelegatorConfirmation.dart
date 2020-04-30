
class RedelegationConfirmationModel {
  final String srcAddress;
  final String srcName;
  final String delegatorAddress;
  final String destName;
  final String destAddress;
  final String totalAmount;
  final String newAmount;
  final String desCommission;
  RedelegationConfirmationModel({this.srcAddress, this.srcName, this.delegatorAddress,this.destAddress, this.desCommission,this.destName,this.totalAmount, this.newAmount});
}
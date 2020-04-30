import 'package:json_annotation/json_annotation.dart';

import 'Balance.dart';
part 'CurrentDelegation.g.dart';

@JsonSerializable(nullable: false)
class CurrentDelegationCommission{
  final String delegator_address;
  final String validator_address;
  final String shares;
  final String height;
  final Balance balance;
  CurrentDelegationCommission({this.delegator_address, this.validator_address, this.height, this.shares, this.balance});
  factory CurrentDelegationCommission.fromJson(Map<String, dynamic> json) => _$CurrentDelegationCommissionFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentDelegationCommissionToJson(this);
}
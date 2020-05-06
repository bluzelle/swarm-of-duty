import 'package:bluzelle/Models/Commission.dart';
import 'package:bluzelle/Models/ValidatorDescription.dart';
import 'package:json_annotation/json_annotation.dart';  
part 'Validator.g.dart';

@JsonSerializable(nullable: false)
class Validator{
  final String operator_address;
  final String consensus_pubkey;
  final bool jailed;
  final int status;
  final String tokens;
  final String delegator_shares;
  final String unbonding_height;
  final String unbonding_time;
  final String min_self_delegation;
  final Commission commission;
  final ValidatorDescription description;
  Validator({this.status,this.commission,this.consensus_pubkey,this.delegator_shares,this.description,this.jailed,this.min_self_delegation,this.operator_address,this.tokens,this.unbonding_height,this.unbonding_time});
  factory Validator.fromJson(Map<String, dynamic> json) => _$ValidatorFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorToJson(this);
}
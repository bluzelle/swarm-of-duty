import 'package:json_annotation/json_annotation.dart';
part 'ProposalDeposits.g.dart';

@JsonSerializable(nullable: false)
class ProposalDeposits{
  final String denom;
  final String amount;
  ProposalDeposits({this.denom, this.amount});
  factory ProposalDeposits.fromJson(Map<String, dynamic> json) => _$ProposalDepositsFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalDepositsToJson(this);
}
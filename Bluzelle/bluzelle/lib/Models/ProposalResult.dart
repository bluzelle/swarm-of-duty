import 'package:json_annotation/json_annotation.dart';
part 'ProposalResult.g.dart';

@JsonSerializable(nullable: false)
class ProposalResult{
  final String yes;
  final String abstain;
  final String no;
  final String no_with_veto;
  ProposalResult({this.yes, this.abstain, this.no, this.no_with_veto,});
  factory ProposalResult.fromJson(Map<String, dynamic> json) => _$ProposalResultFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalResultToJson(this);
}
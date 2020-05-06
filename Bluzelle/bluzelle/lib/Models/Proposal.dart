import 'package:bluzelle/Models/ProposalContent.dart';
import 'package:bluzelle/Models/ProposalDeposits.dart';
import 'package:bluzelle/Models/ProposalResult.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Proposal.g.dart';

@JsonSerializable(nullable: false)
class Proposal{
  final ProposalContent content;
  final String id;
  final String proposal_status;
  final ProposalResult final_tally_result;
  final String submit_time;
  final List<ProposalDeposits> total_deposit;
  final String deposit_end_time;
  final String voting_end_time;
  final String voting_start_time;
  Proposal({this.content, this.id,  this.deposit_end_time, this.voting_end_time, this.proposal_status,this.final_tally_result,this.submit_time,this.total_deposit,this.voting_start_time,});
  factory Proposal.fromJson(Map<String, dynamic> json) => _$ProposalFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalToJson(this);
}
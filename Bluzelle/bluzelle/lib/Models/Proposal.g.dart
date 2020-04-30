// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proposal _$ProposalFromJson(Map<String, dynamic> json) {
  return Proposal(
    content: ProposalContent.fromJson(json['content'] as Map<String, dynamic>),
    id: json['id'] as String,
    deposit_end_time: json['deposit_end_time'] as String,
    voting_end_time: json['voting_end_time'] as String,
    proposal_status: json['proposal_status'] as String,
    final_tally_result: ProposalResult.fromJson(
        json['final_tally_result'] as Map<String, dynamic>),
    submit_time: json['submit_time'] as String,
    total_deposit: (json['total_deposit'] as List)
        .map((e) => ProposalDeposits.fromJson(e as Map<String, dynamic>))
        .toList(),
    voting_start_time: json['voting_start_time'] as String,
  );
}

Map<String, dynamic> _$ProposalToJson(Proposal instance) => <String, dynamic>{
      'content': instance.content,
      'id': instance.id,
      'proposal_status': instance.proposal_status,
      'final_tally_result': instance.final_tally_result,
      'submit_time': instance.submit_time,
      'total_deposit': instance.total_deposit,
      'deposit_end_time': instance.deposit_end_time,
      'voting_end_time': instance.voting_end_time,
      'voting_start_time': instance.voting_start_time,
    };

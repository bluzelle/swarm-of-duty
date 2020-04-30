// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProposalResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalResult _$ProposalResultFromJson(Map<String, dynamic> json) {
  return ProposalResult(
    yes: json['yes'] as String,
    abstain: json['abstain'] as String,
    no: json['no'] as String,
    no_with_veto: json['no_with_veto'] as String,
  );
}

Map<String, dynamic> _$ProposalResultToJson(ProposalResult instance) =>
    <String, dynamic>{
      'yes': instance.yes,
      'abstain': instance.abstain,
      'no': instance.no,
      'no_with_veto': instance.no_with_veto,
    };

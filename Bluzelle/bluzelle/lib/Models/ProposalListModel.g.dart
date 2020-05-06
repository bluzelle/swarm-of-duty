// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProposalListModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalListModel _$ProposalListModelFromJson(Map<String, dynamic> json) {
  return ProposalListModel(
    result: (json['result'] as List)
        .map((e) => Proposal.fromJson(e as Map<String, dynamic>))
        .toList(),
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$ProposalListModelToJson(ProposalListModel instance) =>
    <String, dynamic>{
      'height': instance.height,
      'result': instance.result,
    };

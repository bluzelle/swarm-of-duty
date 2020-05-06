// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProposalContent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalContent _$ProposalContentFromJson(Map<String, dynamic> json) {
  return ProposalContent(
    type: json['type'] as String,
    value: ProposalValue.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ProposalContentToJson(ProposalContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };

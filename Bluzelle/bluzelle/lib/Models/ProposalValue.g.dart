// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProposalValue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalValue _$ProposalValueFromJson(Map<String, dynamic> json) {
  return ProposalValue(
    description: json['description'] as String,
    title: json['title'] as String,
  );
}

Map<String, dynamic> _$ProposalValueToJson(ProposalValue instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
    };

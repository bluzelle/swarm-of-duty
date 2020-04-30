// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ValidatorList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidatorList _$ValidatorListFromJson(Map<String, dynamic> json) {
  return ValidatorList(
    result: (json['result'] as List)
        .map((e) => Validator.fromJson(e as Map<String, dynamic>))
        .toList(),
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$ValidatorListToJson(ValidatorList instance) =>
    <String, dynamic>{
      'result': instance.result,
      'height': instance.height,
    };

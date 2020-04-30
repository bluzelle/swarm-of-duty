// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CurrentDelegationWrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentDelegationWrapper _$CurrentDelegationWrapperFromJson(
    Map<String, dynamic> json) {
  return CurrentDelegationWrapper(
    height: json['height'] as String,
    result: CurrentDelegationCommission.fromJson(
        json['result'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CurrentDelegationWrapperToJson(
        CurrentDelegationWrapper instance) =>
    <String, dynamic>{
      'height': instance.height,
      'result': instance.result,
    };

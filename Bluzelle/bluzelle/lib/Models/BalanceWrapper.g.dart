// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BalanceWrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceWrapper _$BalanceWrapperFromJson(Map<String, dynamic> json) {
  return BalanceWrapper(
    height: json['height'] as String,
    result: (json['result'] as List)
        .map((e) => Balance.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$BalanceWrapperToJson(BalanceWrapper instance) =>
    <String, dynamic>{
      'height': instance.height,
      'result': instance.result,
    };

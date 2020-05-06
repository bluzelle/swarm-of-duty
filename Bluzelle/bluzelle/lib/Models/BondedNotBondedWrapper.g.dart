// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BondedNotBondedWrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BondedNotBondedWrapper _$BondedNotBondedWrapperFromJson(
    Map<String, dynamic> json) {
  return BondedNotBondedWrapper(
    result: BondedNotBonded.fromJson(json['result'] as Map<String, dynamic>),
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$BondedNotBondedWrapperToJson(
        BondedNotBondedWrapper instance) =>
    <String, dynamic>{
      'result': instance.result,
      'height': instance.height,
    };

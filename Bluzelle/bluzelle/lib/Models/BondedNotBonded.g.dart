// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BondedNotBonded.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BondedNotBonded _$BondedNotBondedFromJson(Map<String, dynamic> json) {
  return BondedNotBonded(
    not_bonded_tokens: json['not_bonded_tokens'] as String,
    bonded_tokens: json['bonded_tokens'] as String,
  );
}

Map<String, dynamic> _$BondedNotBondedToJson(BondedNotBonded instance) =>
    <String, dynamic>{
      'not_bonded_tokens': instance.not_bonded_tokens,
      'bonded_tokens': instance.bonded_tokens,
    };

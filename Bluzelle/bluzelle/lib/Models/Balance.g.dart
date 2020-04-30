// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Balance _$BalanceFromJson(Map<String, dynamic> json) {
  return Balance(
    denom: json['denom'] as String,
    amount: json['amount'] as String,
  );
}

Map<String, dynamic> _$BalanceToJson(Balance instance) => <String, dynamic>{
      'denom': instance.denom,
      'amount': instance.amount,
    };

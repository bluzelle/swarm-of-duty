// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CurrentDelegation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentDelegationCommission _$CurrentDelegationCommissionFromJson(
    Map<String, dynamic> json) {
  return CurrentDelegationCommission(
    delegator_address: json['delegator_address'] as String,
    validator_address: json['validator_address'] as String,
    height: json['height'] as String,
    shares: json['shares'] as String,
    balance: Balance.fromJson(json['balance'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CurrentDelegationCommissionToJson(
        CurrentDelegationCommission instance) =>
    <String, dynamic>{
      'delegator_address': instance.delegator_address,
      'validator_address': instance.validator_address,
      'shares': instance.shares,
      'height': instance.height,
      'balance': instance.balance,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Validator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Validator _$ValidatorFromJson(Map<String, dynamic> json) {
  return Validator(
    status: json['status'] as int,
    commission: Commission.fromJson(json['commission'] as Map<String, dynamic>),
    consensus_pubkey: json['consensus_pubkey'] as String,
    delegator_shares: json['delegator_shares'] as String,
    description: ValidatorDescription.fromJson(
        json['description'] as Map<String, dynamic>),
    jailed: json['jailed'] as bool,
    min_self_delegation: json['min_self_delegation'] as String,
    operator_address: json['operator_address'] as String,
    tokens: json['tokens'] as String,
    unbonding_height: json['unbonding_height'] as String,
    unbonding_time: json['unbonding_time'] as String,
  );
}

Map<String, dynamic> _$ValidatorToJson(Validator instance) => <String, dynamic>{
      'operator_address': instance.operator_address,
      'consensus_pubkey': instance.consensus_pubkey,
      'jailed': instance.jailed,
      'status': instance.status,
      'tokens': instance.tokens,
      'delegator_shares': instance.delegator_shares,
      'unbonding_height': instance.unbonding_height,
      'unbonding_time': instance.unbonding_time,
      'min_self_delegation': instance.min_self_delegation,
      'commission': instance.commission,
      'description': instance.description,
    };

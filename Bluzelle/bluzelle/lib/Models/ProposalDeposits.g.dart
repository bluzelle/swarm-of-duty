// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProposalDeposits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalDeposits _$ProposalDepositsFromJson(Map<String, dynamic> json) {
  return ProposalDeposits(
    denom: json['denom'] as String,
    amount: json['amount'] as String,
  );
}

Map<String, dynamic> _$ProposalDepositsToJson(ProposalDeposits instance) =>
    <String, dynamic>{
      'denom': instance.denom,
      'amount': instance.amount,
    };

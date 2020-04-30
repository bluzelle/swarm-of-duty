// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CommissionRates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommissionRates _$CommissionRatesFromJson(Map<String, dynamic> json) {
  return CommissionRates(
    max_rate: json['max_rate'] as String,
    rate: json['rate'] as String,
    max_change_rate: json['max_change_rate'] as String,
  );
}

Map<String, dynamic> _$CommissionRatesToJson(CommissionRates instance) =>
    <String, dynamic>{
      'rate': instance.rate,
      'max_rate': instance.max_rate,
      'max_change_rate': instance.max_change_rate,
    };

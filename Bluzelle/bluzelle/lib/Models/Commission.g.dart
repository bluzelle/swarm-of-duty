// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Commission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Commission _$CommissionFromJson(Map<String, dynamic> json) {
  return Commission(
    commission_rates: CommissionRates.fromJson(
        json['commission_rates'] as Map<String, dynamic>),
    update_time: json['update_time'] as String,
  );
}

Map<String, dynamic> _$CommissionToJson(Commission instance) =>
    <String, dynamic>{
      'commission_rates': instance.commission_rates,
      'update_time': instance.update_time,
    };

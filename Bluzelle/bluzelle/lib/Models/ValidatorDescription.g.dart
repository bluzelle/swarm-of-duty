// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ValidatorDescription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidatorDescription _$ValidatorDescriptionFromJson(Map<String, dynamic> json) {
  return ValidatorDescription(
    details: json['details'] as String,
    identity: json['identity'] as String,
    moniker: json['moniker'] as String,
    security_contact: json['security_contact'] as String,
    website: json['website'] as String,
  );
}

Map<String, dynamic> _$ValidatorDescriptionToJson(
        ValidatorDescription instance) =>
    <String, dynamic>{
      'moniker': instance.moniker,
      'identity': instance.identity,
      'website': instance.website,
      'details': instance.details,
      'security_contact': instance.security_contact,
    };

import 'package:json_annotation/json_annotation.dart';
part 'ValidatorDescription.g.dart';

@JsonSerializable(nullable: false)
class ValidatorDescription{
  final String moniker;
  final String identity;
  final String website;
  final String details;
  final String security_contact;
  ValidatorDescription({this.details,this.identity, this.moniker, this.security_contact, this.website});
  factory ValidatorDescription.fromJson(Map<String, dynamic> json) => _$ValidatorDescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorDescriptionToJson(this);
}
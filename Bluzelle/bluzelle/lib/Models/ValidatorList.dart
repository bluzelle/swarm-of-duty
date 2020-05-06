import 'package:bluzelle/Models/Validator.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ValidatorList.g.dart';

@JsonSerializable(nullable: false)
class ValidatorList{
  final List<Validator> result;
  final String height;
  ValidatorList({this.result, this.height});
  factory ValidatorList.fromJson(Map<String, dynamic> json) => _$ValidatorListFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorListToJson(this);
}
import 'package:bluzelle/Models/BondedNotBonded.dart';
import 'package:json_annotation/json_annotation.dart';
part 'BondedNotBondedWrapper.g.dart';

@JsonSerializable(nullable: false)
class BondedNotBondedWrapper{
  final BondedNotBonded result;
  final String height;
  BondedNotBondedWrapper({this.result, this.height});
  factory BondedNotBondedWrapper.fromJson(Map<String, dynamic> json) => _$BondedNotBondedWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$BondedNotBondedWrapperToJson(this);
}
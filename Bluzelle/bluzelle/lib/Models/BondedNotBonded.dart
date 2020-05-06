import 'package:json_annotation/json_annotation.dart';
part 'BondedNotBonded.g.dart';

@JsonSerializable(nullable: false)
class BondedNotBonded{
  final String not_bonded_tokens;
  final String bonded_tokens;
  BondedNotBonded({this.not_bonded_tokens, this.bonded_tokens});
  factory BondedNotBonded.fromJson(Map<String, dynamic> json) => _$BondedNotBondedFromJson(json);
  Map<String, dynamic> toJson() => _$BondedNotBondedToJson(this);
}
import 'package:json_annotation/json_annotation.dart';
part 'Balance.g.dart';

@JsonSerializable(nullable: false)
class Balance{
  final String denom;
  final String amount;
  Balance({this.denom, this.amount});
  factory Balance.fromJson(Map<String, dynamic> json) => _$BalanceFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceToJson(this);
}
import 'package:bluzelle/Models/Balance.dart';
import 'package:json_annotation/json_annotation.dart';
part 'BalanceWrapper.g.dart';

@JsonSerializable(nullable: false)
class BalanceWrapper{
  final String height;
  final List<Balance> result;
  BalanceWrapper({this.height, this.result});
  factory BalanceWrapper.fromJson(Map<String, dynamic> json) => _$BalanceWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceWrapperToJson(this);
}
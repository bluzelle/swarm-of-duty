import 'package:bluzelle/Models/CommissionRates.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Commission.g.dart';

@JsonSerializable(nullable: false)
class Commission{
  final CommissionRates commission_rates;
  final String update_time;
  Commission({this.commission_rates, this.update_time});
  factory Commission.fromJson(Map<String, dynamic> json) => _$CommissionFromJson(json);
  Map<String, dynamic> toJson() => _$CommissionToJson(this);
}
import 'package:json_annotation/json_annotation.dart';
part 'CommissionRates.g.dart';

@JsonSerializable(nullable: false)
class CommissionRates{
  final String rate;
  final String max_rate;
  final String max_change_rate;
  CommissionRates({this.max_rate, this.rate, this.max_change_rate});
  factory CommissionRates.fromJson(Map<String, dynamic> json) => _$CommissionRatesFromJson(json);
  Map<String, dynamic> toJson() => _$CommissionRatesToJson(this);
}
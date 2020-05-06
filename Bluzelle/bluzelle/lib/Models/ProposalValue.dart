
import 'package:json_annotation/json_annotation.dart';
part 'ProposalValue.g.dart';

@JsonSerializable(nullable: false)
class ProposalValue{
  final String title;
  final String description;
  ProposalValue({this.description, this.title});
  factory ProposalValue.fromJson(Map<String, dynamic> json) => _$ProposalValueFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalValueToJson(this);
}
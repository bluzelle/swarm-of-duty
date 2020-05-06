import 'package:bluzelle/Models/ProposalValue.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ProposalContent.g.dart';

@JsonSerializable(nullable: false)
class ProposalContent{
  final String type;
  final ProposalValue value;
  ProposalContent({this.type, this.value});
  factory ProposalContent.fromJson(Map<String, dynamic> json) => _$ProposalContentFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalContentToJson(this);
}
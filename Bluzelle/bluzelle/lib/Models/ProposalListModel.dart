import 'package:bluzelle/Models/Proposal.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ProposalListModel.g.dart';

@JsonSerializable(nullable: false)
class ProposalListModel{
  final String height;
  final List<Proposal> result;
  ProposalListModel({this.result, this.height});
  factory ProposalListModel.fromJson(Map<String, dynamic> json) => _$ProposalListModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProposalListModelToJson(this);
}
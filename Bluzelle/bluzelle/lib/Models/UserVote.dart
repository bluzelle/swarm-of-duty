import 'package:json_annotation/json_annotation.dart';
part 'UserVote.g.dart';

@JsonSerializable(nullable: false)
class UserVote{
  final String proposal_id;
  final String voter;
  final String option;
  UserVote({this.proposal_id,this.option,this.voter});
  factory UserVote.fromJson(Map<String, dynamic> json) => _$UserVoteFromJson(json);
  Map<String, dynamic> toJson() => _$UserVoteToJson(this);
}
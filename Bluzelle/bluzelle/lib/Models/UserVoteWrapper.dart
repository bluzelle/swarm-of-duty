import 'package:json_annotation/json_annotation.dart';

import 'UserVote.dart';
part 'UserVoteWrapper.g.dart';

@JsonSerializable(nullable: false)
class UserVoteWrapper{
  final String height;
  final UserVote result;
  UserVoteWrapper({this.result,this.height});
  factory UserVoteWrapper.fromJson(Map<String, dynamic> json) => _$UserVoteWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$UserVoteWrapperToJson(this);
}
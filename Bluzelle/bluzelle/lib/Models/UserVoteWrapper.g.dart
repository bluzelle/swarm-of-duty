// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserVoteWrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVoteWrapper _$UserVoteWrapperFromJson(Map<String, dynamic> json) {
  return UserVoteWrapper(
    result: UserVote.fromJson(json['result'] as Map<String, dynamic>),
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$UserVoteWrapperToJson(UserVoteWrapper instance) =>
    <String, dynamic>{
      'height': instance.height,
      'result': instance.result,
    };

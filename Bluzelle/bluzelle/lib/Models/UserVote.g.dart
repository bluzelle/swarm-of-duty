// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserVote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserVote _$UserVoteFromJson(Map<String, dynamic> json) {
  return UserVote(
    proposal_id: json['proposal_id'] as String,
    option: json['option'] as String,
    voter: json['voter'] as String,
  );
}

Map<String, dynamic> _$UserVoteToJson(UserVote instance) => <String, dynamic>{
      'proposal_id': instance.proposal_id,
      'voter': instance.voter,
      'option': instance.option,
    };

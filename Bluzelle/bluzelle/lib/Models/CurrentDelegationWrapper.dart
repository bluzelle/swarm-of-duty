import 'package:json_annotation/json_annotation.dart';

import 'CurrentDelegation.dart';
part 'CurrentDelegationWrapper.g.dart';

@JsonSerializable(nullable: false)
class CurrentDelegationWrapper{
  final String height;
  final CurrentDelegationCommission result;
  CurrentDelegationWrapper({this.height, this.result});
  factory CurrentDelegationWrapper.fromJson(Map<String, dynamic> json) => _$CurrentDelegationWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentDelegationWrapperToJson(this);
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevel _$GameLevelFromJson(Map<String, dynamic> json) => GameLevel(
  hints: json['hints'],
  sourceWord: json['sourceWord'] as String,
  targetWords: (json['targetWords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  validWords: (json['validWords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  world: (json['world'] as num?)?.toInt() ?? 0,
  subWorld: (json['subWorld'] as num?)?.toInt() ?? 0,
  level: (json['level'] as num?)?.toInt() ?? 0,
  rubyReward: (json['rubyReward'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$GameLevelToJson(GameLevel instance) => <String, dynamic>{
  'hints': instance.hints,
  'sourceWord': instance.sourceWord,
  'targetWords': instance.targetWords,
  'validWords': instance.validWords,
  'world': instance.world,
  'subWorld': instance.subWorld,
  'level': instance.level,
  'rubyReward': instance.rubyReward,
};

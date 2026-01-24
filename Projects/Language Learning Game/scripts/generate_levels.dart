import 'dart:io';
import 'dart:convert';
import 'package:word_game_practice_languages/services/level_generator.dart';

/// Script to pre-generate all levels and save them to JSON files
/// Run this script before production to generate consistent levels for all users
Future<void> main() async {
  print('🚀 Starting level pre-generation...');

  // Create levels directory if it doesn't exist
  final levelsDir = Directory('assets/levels');
  if (!await levelsDir.exists()) {
    await levelsDir.create(recursive: true);
  }

  int totalLevels = 0;
  int successfulLevels = 0;

  // Generate levels for each world
  for (int world = 0; world < 7; world++) {
    print('\n📁 Generating World $world levels...');

    for (int subWorld = 0; subWorld < 5; subWorld++) {
      print('  📂 SubWorld $subWorld...');

      for (int level = 0; level < 18; level++) {
        totalLevels++;

        try {
          // Generate the level
          final gameLevel =
              await LevelGenerator.generateLevel(world, subWorld, level);

          if (gameLevel != null) {
            // Convert to JSON
            final levelData = {
              'world': world,
              'subWorld': subWorld,
              'level': level,
              'hints': gameLevel.hints,
              'sourceWord': gameLevel.sourceWord,
              'targetWords': gameLevel.targetWords,
              'validWords': gameLevel.validWords,
              'generatedAt': DateTime.now().toIso8601String(),
            };

            // Save to file
            final fileName = 'level_${world}_${subWorld}_$level.json';
            final file = File('assets/levels/$fileName');
            await file.writeAsString(json.encode(levelData));

            successfulLevels++;

            // Progress indicator
            if (level % 6 == 0) {
              print('    ✅ Level $level generated');
            }
          } else {
            print('    ❌ Failed to generate level $level');
          }
        } catch (e) {
          print('    ❌ Error generating level $level: $e');
        }
      }
    }
  }

  print('\n🎉 Level generation complete!');
  print('📊 Statistics:');
  print('   Total levels: $totalLevels');
  print('   Successful: $successfulLevels');
  print('   Failed: ${totalLevels - successfulLevels}');
  print(
      '   Success rate: ${(successfulLevels / totalLevels * 100).toStringAsFixed(1)}%');

  // Generate index file for faster loading
  await _generateIndexFile();

  print('\n✅ All done! Levels saved to assets/levels/');
  print('💡 Don\'t forget to run "flutter pub get" to refresh assets');
}

/// Generate an index file that lists all available levels
Future<void> _generateIndexFile() async {
  print('\n📋 Generating level index...');

  final levelsDir = Directory('assets/levels');
  final files = await levelsDir
      .list()
      .where((entity) =>
          entity is File &&
          entity.path.endsWith('.json') &&
          !entity.path.endsWith('index.json'))
      .toList();

  final index = <String, dynamic>{
    'generatedAt': DateTime.now().toIso8601String(),
    'totalLevels': files.length,
    'levels': <Map<String, dynamic>>[],
  };

  for (final file in files) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final parts = fileName.replaceAll('.json', '').split('_');

    if (parts.length >= 4) {
      index['levels'].add({
        'world': int.parse(parts[1]),
        'subWorld': int.parse(parts[2]),
        'level': int.parse(parts[3]),
        'fileName': fileName,
      });
    }
  }

  // Sort levels by world, subWorld, level
  (index['levels'] as List).sort((a, b) {
    final worldCompare = (a['world'] as int).compareTo(b['world'] as int);
    if (worldCompare != 0) return worldCompare;

    final subWorldCompare =
        (a['subWorld'] as int).compareTo(b['subWorld'] as int);
    if (subWorldCompare != 0) return subWorldCompare;

    return (a['level'] as int).compareTo(b['level'] as int);
  });

  final indexFile = File('assets/levels/index.json');
  await indexFile.writeAsString(json.encode(index));

  print('📋 Index file generated with ${files.length} levels');
}

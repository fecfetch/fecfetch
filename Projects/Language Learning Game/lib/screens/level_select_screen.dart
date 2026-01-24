import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/game_level.dart';
import 'game_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';

class LevelSelectScreen extends StatefulWidget {
  final int world;
  
  const LevelSelectScreen({super.key, required this.world});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int selectedSubWorld = 0;
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    // Get the singleton instance of AudioService
    _audioService = AudioService();
    
    // Play background music
    _audioService.playBackgroundMusic(AudioService.levelMusic);
  }
  
  @override
  void dispose() {
    // Stop background music when leaving the screen
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getCefrLevel(widget.world)} - ${AppLocalizations.of(context)!.selectLevel}'),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6DD5FA),
              Color(0xFF2980B9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Sub-world tabs
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: WorldData.numSubWorlds,
                  itemBuilder: (context, subWorldIndex) {
                    return _buildSubWorldTab(context, subWorldIndex);
                  },
                ),
              ),
              
              // Levels grid
              Expanded(
                child: Consumer<ProgressProvider>(
                  builder: (context, progress, child) {
                    return _buildLevelsGrid(context, progress, selectedSubWorld);
                  },
                ),
              ),
              
              // Next Sub-world Button
              if (selectedSubWorld < WorldData.numSubWorlds - 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSubWorld++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2980B9),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.nextChapter,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubWorldTab(BuildContext context, int subWorldIndex) {
    bool isSelected = selectedSubWorld == subWorldIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ChoiceChip(
        label: Text(AppLocalizations.of(context)!.chapterWithNumber(subWorldIndex + 1)),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              selectedSubWorld = subWorldIndex;
            });
          }
        },
        backgroundColor: Colors.white.withOpacity(0.3),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2980B9) : const Color.fromARGB(255, 102, 102, 102),
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2980B9) : const Color.fromARGB(255, 102, 102, 102).withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelsGrid(BuildContext context, ProgressProvider progress, int subWorld) {
    final numLevels = WorldData.getNumLevels(widget.world, subWorld);
    
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: numLevels,
      itemBuilder: (context, index) {
        final isUnlocked = progress.isLevelUnlocked(widget.world, subWorld, index);
        return _buildLevelButton(context, index, isUnlocked, subWorld);
      },
    );
  }

  Widget _buildLevelButton(BuildContext context, int levelIndex, bool isUnlocked, int subWorld) {
    final colors = _getWorldColors(widget.world);
    return InkWell(
      onTap: isUnlocked
          ? () {
              // Play button sound effect
              _audioService.playSoundEffect(AudioService.buttonSound);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    world: widget.world,
                    subWorld: subWorld,
                    level: levelIndex,
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: isUnlocked ? colors : [Colors.grey.shade600, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: colors.last.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: isUnlocked
              ? Text(
                  '${levelIndex + 1}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                  size: 32,
                ),
        ),
      ),
    );
  }

  List<Color> _getWorldColors(int worldIndex) {
    const worldColors = [
      [Color(0xFF43A047), Color(0xFF66BB6A)], // A1 - Green
      [Color(0xFF1E88E5), Color(0xFF42A5F5)], // A2 - Blue
      [Color(0xFFF4511E), Color(0xFFFB8C00)], // B1 - Orange
      [Color(0xFFD81B60), Color(0xFFE91E63)], // B2 - Pink
      [Color(0xFF8E24AA), Color(0xFFAB47BC)], // C1 - Purple
      [Color(0xFF00838F), Color(0xFF00ACC1)], // C2 - Cyan
      [Color(0xFF546E7A), Color(0xFF78909C)], // Mixed - Blue Grey
    ];
    return worldColors[worldIndex % worldColors.length];
  }

  String _getCefrLevel(int worldIndex) {
    const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2', 'MIX'];
    return cefrLevels[worldIndex % cefrLevels.length];
  }
}
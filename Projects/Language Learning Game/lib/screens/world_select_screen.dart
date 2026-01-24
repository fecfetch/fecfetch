import 'package:flutter/material.dart';
import 'level_select_screen.dart';
import '../l10n/app_localizations.dart';

class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectLevel),
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
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          itemCount: 7, // 7 worlds
          itemBuilder: (context, index) {
            return _buildWorldCard(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildWorldCard(BuildContext context, int worldIndex) {
    final cefrLevel = _getCefrLevel(worldIndex);
    final worldName = _getWorldName(context, worldIndex);
    final colors = _getWorldColors(worldIndex);
    final icon = _getWorldIcon(worldIndex);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelSelectScreen(world: worldIndex),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cefrLevel,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWorldName(context, worldIndex),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
            ],
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

  IconData _getWorldIcon(int worldIndex) {
    const worldIcons = [
      Icons.school_outlined,
      Icons.lightbulb_outline,
      Icons.explore_outlined,
      Icons.psychology_outlined,
      Icons.auto_stories_outlined,
      Icons.workspace_premium_outlined,
      Icons.blender_outlined,
    ];
    return worldIcons[worldIndex % worldIcons.length];
  }

  String _getCefrLevel(int worldIndex) {
    const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2', 'MIX'];
    return cefrLevels[worldIndex % cefrLevels.length];
  }

  String _getWorldName(BuildContext context, int worldIndex) {
    final worldNames = {
      0: AppLocalizations.of(context)!.beginner,
      1: AppLocalizations.of(context)!.elementary,
      2: AppLocalizations.of(context)!.intermediate,
      3: AppLocalizations.of(context)!.upperIntermediate,
      4: AppLocalizations.of(context)!.advanced,
      5: AppLocalizations.of(context)!.proficient,
      6: AppLocalizations.of(context)!.mixedLevels,
    };
    return worldNames[worldIndex]!;
  }
}
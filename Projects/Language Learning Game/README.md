# Word Chef Flutter

A Flutter implementation of the Word Chef word puzzle game, converted from Unity.

## Game Overview

Word Chef is a word puzzle game where players form words by connecting letters arranged in a circle. Players drag their finger to connect letters and form words to complete each level.

## Features Implemented

### Core Game Mechanics
- **Circular Letter Layout**: Letters arranged in a circle that players can connect
- **Drag-to-Connect**: Touch/mouse drag functionality to form words
- **Word Validation**: Checks formed words against target and bonus word lists
- **Progress System**: Multi-world, sub-world, and level progression
- **Hint System**: Spend rubies to get hints for target words
- **Shuffle Function**: Rearrange letters in the circle

### Game Structure
- **7 Worlds** with **5 Sub-worlds** each
- **12-19 levels** per sub-world
- **Progressive unlocking** system
- **Ruby currency** system for hints and rewards

### UI Components
- **Home Screen**: Main menu with play, settings, and about options
- **World Select**: Grid of available worlds with unlock status
- **Level Select**: Grid of levels within selected world/sub-world
- **Game Screen**: Main gameplay with letter circle, word grid, and current word display
- **Progress Tracking**: Visual indicators for completed words and levels

### Technical Features
- **State Management**: Provider pattern for game state and progress
- **Local Storage**: SharedPreferences for saving progress and settings
- **Custom Painting**: Custom painter for letter circle and connection lines
- **Responsive Design**: Adapts to different screen sizes
- **Gesture Recognition**: Advanced touch/drag detection for word formation

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── game_level.dart      # Level data model
├── providers/
│   ├── game_state_provider.dart    # Game state management
│   └── progress_provider.dart      # Progress and save data
├── screens/
│   ├── home_screen.dart           # Main menu
│   ├── world_select_screen.dart   # World selection
│   ├── level_select_screen.dart   # Level selection
│   └── game_screen.dart           # Main gameplay
├── widgets/
│   ├── letter_circle.dart         # Circular letter layout with drag
│   ├── word_grid.dart            # Target words display
│   └── current_word_display.dart  # Current word being formed
└── services/
    └── level_service.dart         # Level data loading
```

## How to Run

1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies
3. Run `flutter run -d chrome` for web or `flutter run` for mobile

## Game Mechanics

### Letter Circle
- Letters are arranged in a circle around the screen center
- Players drag from letter to letter to form words
- Visual feedback shows the connection path
- Shuffle button rearranges letter positions

### Word Formation
- Drag across letters to form words
- Current word is displayed at the top
- Valid target words are revealed in the word grid
- Bonus words award extra rubies

### Progression
- Complete all target words to finish a level
- Earn 5 rubies for completing levels
- Unlock next level/sub-world/world progressively
- Use hints (2 rubies) when stuck

## Future Enhancements

### Planned Features
- **Multi-language Support**: Language pair selection for learning
- **Sound Effects**: Audio feedback for actions
- **Animations**: Smooth transitions and celebrations
- **More Levels**: Expanded level content
- **Statistics**: Track performance and progress
- **Achievements**: Unlock rewards for milestones

### Technical Improvements
- **Better Level Loading**: JSON-based level system
- **Improved Gestures**: More sophisticated drag detection
- **Performance**: Optimize rendering and state management
- **Accessibility**: Screen reader and keyboard support

## Original Unity Conversion

This Flutter app is converted from a Unity Word Chef game, maintaining the core gameplay mechanics while adapting to Flutter's widget-based architecture. The original game structure with worlds, sub-worlds, and levels has been preserved, along with the circular letter layout and word formation mechanics.

## Dependencies

- `flutter`: UI framework
- `provider`: State management
- `shared_preferences`: Local data storage
- `flutter_svg`: SVG asset support (planned)
- `audioplayers`: Sound effects (planned)

## License

This project is for educational and demonstration purposes.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/initial_language_selection_screen.dart';
import 'providers/game_state_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/language_provider.dart';
import 'providers/feature_timer_provider.dart';
import 'providers/ad_provider.dart';
import 'l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_service.dart';
import 'services/user_preferences_service.dart';
import 'services/audio_service.dart';
import 'package:workmanager/workmanager.dart';
import 'services/background_service.dart';
 
import 'dart:io' show Platform;

 void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services only on Android
  if (Platform.isAndroid) {
    // Initialize Workmanager (Dart-side scheduling remains, but native worker
    // will actually post notifications).
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      "1",
      backgroundTask,
      frequency: const Duration(minutes: 15),
    );
    // NOTE: Notifications are now posted by the native Worker (Kotlin).
    // We avoid initializing flutter_local_notifications here to prevent
    // release-time plugin/resource issues. If you need foreground permission
    // prompts, handle them in the UI where appropriate.
  }
  
  // Initialize audio service
  final audioService = AudioService();
  await audioService.init();
  
  runApp(WordChefApp(audioService: audioService));
}

class WordChefApp extends StatelessWidget {
  final AdService adService = AdService();
  final AudioService audioService;

  WordChefApp({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => FeatureTimerProvider()),
        ChangeNotifierProxyProvider<ProgressProvider, AdProvider>(
          create: (_) => AdProvider(adService: adService, progressProvider: ProgressProvider()),
          update: (_, progressProvider, __) => AdProvider(adService: adService, progressProvider: progressProvider),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Word Chef',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              fontFamily: 'Arial',
            ),
            // Localization support
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('de'), // German
              Locale('fr'), // French
              Locale('es'), // Spanish
              Locale('tr'), // Turkish
              Locale('hi'), // Hindi
              Locale('zh'), // Chinese
            ],
            locale: languageProvider.appLocale,
            home: AppInitializer(audioService: audioService),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// Widget to initialize app data before showing home screen
class AppInitializer extends StatefulWidget {
  final AudioService audioService;
  
  const AppInitializer({super.key, required this.audioService});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _hasSeenInitialScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.audioService.pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.audioService.isMusicEnabled()) {
        widget.audioService.resumeBackgroundMusic();
      }
    }
  }

  Future<void> _initializeApp() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    final featureTimerProvider =
        Provider.of<FeatureTimerProvider>(context, listen: false);

    // Initialize first app opening time
    await UserPreferencesService.instance.initializeFirstAppOpeningTime();

    // Check if the user has seen the initial language screen
    _hasSeenInitialScreen =
        await UserPreferencesService.instance.getHasSeenInitialLanguageScreen();

    // Load language settings first
    await languageProvider.loadLanguageSettings();

    // Load progress data
    await progressProvider.loadProgress();

    // Load feature timers
    await featureTimerProvider.loadTimers();
    
    // Load audio settings
    final isMusicEnabled = await UserPreferencesService.instance.getIsMusicEnabled();
    final areSoundEffectsEnabled = await UserPreferencesService.instance.getAreSoundEffectsEnabled();
    final musicVolume = await UserPreferencesService.instance.getMusicVolume();
    
    widget.audioService.setMusicEnabled(isMusicEnabled);
    widget.audioService.setSoundEffectsEnabled(areSoundEffectsEnabled);
    widget.audioService.setMusicVolume(musicVolume);

    final adProvider = Provider.of<AdProvider>(context, listen: false);
    await adProvider.adService.initialize();
    adProvider.adService.loadRewardedAd();
    adProvider.adService.loadInterstitialAd();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _hasSeenInitialScreen
        ? const HomeScreen()
        : const InitialLanguageSelectionScreen();
  }
}

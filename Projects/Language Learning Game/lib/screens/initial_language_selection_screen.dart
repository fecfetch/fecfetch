import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import '../services/user_preferences_service.dart';
import '../l10n/app_localizations.dart';

class InitialLanguageSelectionScreen extends StatefulWidget {
  const InitialLanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InitialLanguageSelectionScreen> createState() =>
      _InitialLanguageSelectionScreenState();
}

class _InitialLanguageSelectionScreenState
    extends State<InitialLanguageSelectionScreen> {
  SupportedLanguage? _selectedNativeLanguage;
  SupportedLanguage? _selectedTargetLanguage;

  @override
  void initState() {
    super.initState();
    // Initialize with null to ensure the user makes a selection.
    _selectedNativeLanguage = null;
    _selectedTargetLanguage = null;
  }

  Future<void> _continueToApp() async {
    if (_selectedNativeLanguage == null || _selectedTargetLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectBothLanguages),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedNativeLanguage == _selectedTargetLanguage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.languagesMustBeDifferent),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.setLanguages(
      nativeLanguage: _selectedNativeLanguage!,
      targetLanguage: _selectedTargetLanguage!,
    );

    await UserPreferencesService.instance.setHasSeenInitialLanguageScreen(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // The list of languages available for learning.
    final List<SupportedLanguage> targetLanguages = [
      SupportedLanguage.german,
      SupportedLanguage.english
    ];

    // The list of all available languages for native selection.
    final List<SupportedLanguage> nativeLanguages =
        languageProvider.availableNativeLanguages;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.language,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.languageSelection,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.languageSelectionDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                // Native Language Dropdown
                _buildDropdown(
                  title: AppLocalizations.of(context)!.myNativeLanguage,
                  value: _selectedNativeLanguage,
                  items: nativeLanguages
                      .where((lang) => lang != _selectedTargetLanguage)
                      .toList(),
                  onChanged: (language) {
                    if (language != null) {
                      setState(() {
                        _selectedNativeLanguage = language;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Target Language Dropdown
                _buildDropdown(
                  title: AppLocalizations.of(context)!.languageIWantToLearn,
                  value: _selectedTargetLanguage,
                  items: targetLanguages
                      .where((lang) => lang != _selectedNativeLanguage)
                      .toList(),
                  onChanged: (language) {
                    if (language != null) {
                      setState(() {
                        _selectedTargetLanguage = language;
                      });
                    }
                  },
                ),
                const SizedBox(height: 40),

                // Continue Button
                ElevatedButton(
                  onPressed: _continueToApp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required SupportedLanguage? value,
    required List<SupportedLanguage> items,
    required ValueChanged<SupportedLanguage?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SupportedLanguage>(
          value: value,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.selectLanguage,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((language) {
            return DropdownMenuItem(
              value: language,
              child: Text(language.nativeName),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
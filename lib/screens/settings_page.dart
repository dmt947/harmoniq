import 'package:flutter/material.dart';
import 'package:harmoniq/utils/app_constants.dart'; 
import 'package:harmoniq/main.dart'; 
import 'package:harmoniq/screens/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _selectedThemeMode = currentThemeMode.value;
  Locale? _selectedLocale = currentLocale.value;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    const String appVersion = '1.0.0';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle), 
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          
          _buildSectionTitle(localizations.themeSettings), 
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: _selectedThemeMode,
                  isExpanded: true,
                  icon: const Icon(Icons.palette),
                  onChanged: (ThemeMode? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        _selectedThemeMode = newValue;
                      });
                      currentThemeMode.value =
                          newValue; 
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        AppConstants.themeModeKey,
                        newValue.toString(),
                      ); 
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(localizations.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(localizations.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(localizations.themeDark), 
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sección de Idioma
          _buildSectionTitle(
            localizations.languageSettings,
          ), // Título localizado
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale?>(
                  value: _selectedLocale,
                  isExpanded: true,
                  icon: const Icon(Icons.language),
                  onChanged: (Locale? newValue) async {
                    setState(() {
                      _selectedLocale = newValue;
                    });
                    currentLocale.value =
                        newValue;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      AppConstants.localeKey,
                      newValue?.languageCode ?? '',
                    );
                  },
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(localizations.languageSystem),
                    ),
                    ...AppLocalizations.supportedLocales.map((locale) {
                      return DropdownMenuItem(
                        value: locale,
                        child: Text(
                          locale.languageCode,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          
          _buildSectionTitle(localizations.userProfile), 
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(localizations.viewEditProfile),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
            ),
          ),

          
          _buildSectionTitle(localizations.appInfo), 
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harmoniq',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.version}: $appVersion', 
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

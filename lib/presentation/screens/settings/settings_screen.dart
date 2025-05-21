import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/app/config/localization.dart';
import 'package:stock_manager/presentation/bloc/settings/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<ThemeMode>(
                value: state.themeMode,
                items: ThemeMode.values.map((mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(mode.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<SettingsBloc>().add(ThemeChanged(mode));
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Theme',
                ),
              ),
              DropdownButtonFormField<String>(
                value: state.locale.languageCode,
                items: AppLocalizations.supportedLocales.map((locale) {
                  return DropdownMenuItem<String>(
                    value: locale.languageCode,
                    child: Text(locale.languageCode.toUpperCase()),
                  );
                }).toList(),
                onChanged: (language) {
                  if (language != null) {
                    context.read<SettingsBloc>().add(LanguageChanged(language));
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Language',
                ),
              ),
              SwitchListTile(
                title: const Text('Offline Mode'),
                value: state.offlineModeEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(OfflineModeToggled(value));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stock_manager/presentation/bloc/settings/settings_bloc.dart';
// import 'package:stock_manager/app/config/localization.dart';
// import 'package:stock_manager/utils/constants/strings.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(Strings.settings),
//       ),
//       body: BlocBuilder<SettingsBloc, SettingsState>(
//         builder: (context, state) {
//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               ListTile(
//                 title: Text(Strings.theme),
//                 trailing: DropdownButton<ThemeMode>(
//                   value: state.themeMode,
//                   onChanged: (ThemeMode? newValue) {
//                     if (newValue != null) {
//                       context.read<SettingsBloc>().add(ThemeChanged(newValue));
//                     }
//                   },
//                   items: ThemeMode.values.map((ThemeMode mode) {
//                     return DropdownMenuItem<ThemeMode>(
//                       value: mode,
//                       child: Text(
//                         mode.toString().split('.').last,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               ListTile(
//                 title: Text(Strings.language),
//                 trailing: DropdownButton<String>(
//                   value: state.locale.languageCode,
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       context.read<SettingsBloc>().add(LanguageChanged(newValue));
//                     }
//                   },
//                   items: AppLocalizations.supportedLocales.map((Locale locale) {
//                     return DropdownMenuItem<String>(
//                       value: locale.languageCode,
//                       child: Text(locale.languageCode.toUpperCase()),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               SwitchListTile(
//                 title: Text(Strings.offlineMode),
//                 value: state.offlineModeEnabled,
//                 onChanged: (bool value) {
//                   context.read<SettingsBloc>().add(OfflineModeToggled(value));
//                 },
//               ),
//               ListTile(
//                 title: Text(Strings.syncNow),
//                 trailing: const Icon(Icons.sync),
//                 onTap: () {
//                   // Trigger sync
//                 },
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
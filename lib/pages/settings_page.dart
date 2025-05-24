// pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations?.language ?? 'Language',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: state.locale.languageCode,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'sw', child: Text('Swahili')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<LanguageCubit>().changeLanguage(value);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations?.theme ?? 'Theme',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      title: Text(state.isDarkMode
                          ? localizations?.darkMode ?? 'Dark Mode'
                          : localizations?.lightMode ?? 'Light Mode'),
                      value: state.isDarkMode,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(AppLocalizations.of(context)!.language,
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 BlocBuilder<LanguageCubit, LanguageState>(
//                   builder: (context, state) {
//                     return DropdownButton<String>(
//                       value: state.locale.languageCode,
//                       items: const [
//                         DropdownMenuItem(value: 'en', child: Text('English')),
//                         DropdownMenuItem(value: 'es', child: Text('Spanish')),
//                         DropdownMenuItem(value: 'fr', child: Text('French')),
//                         DropdownMenuItem(value: 'sw', child: Text('Swahili')),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) {
//                           context.read<LanguageCubit>().changeLanguage(value);
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(AppLocalizations.of(context)!.theme,
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 BlocBuilder<ThemeCubit, ThemeState>(
//                   builder: (context, state) {
//                     return SwitchListTile(
//                       title: Text(state.isDarkMode
//                           ? AppLocalizations.of(context)!.darkMode
//                           : AppLocalizations.of(context)!.lightMode),
//                       value: state.isDarkMode,
//                       onChanged: (_) =>
//                           context.read<ThemeCubit>().toggleTheme(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
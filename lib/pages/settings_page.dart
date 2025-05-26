import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stock_manager/config/env.dart';
import 'package:stock_manager/controllers/auth_controller.dart';
import 'package:stock_manager/utils/database_helper.dart';
import 'package:stock_manager/utils/sync_service.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Settings',// localizations?.settings ?? 'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildLanguageCard(context, localizations),
              const SizedBox(height: 16),
              _buildThemeCard(context, localizations),
              const SizedBox(height: 16),
              _buildSyncCard(context),
              const SizedBox(height: 16),
              _buildLogoutCard(context),
              const SizedBox(height: 80), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppLocalizations? localizations) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.language ?? 'Language',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: DropdownButton<String>(
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
                    underline: const SizedBox(),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, AppLocalizations? localizations) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.theme ?? 'Theme',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: ListTile(
                    title: Text(
                      state.isDarkMode
                          ? localizations?.darkMode ?? 'Dark Mode'
                          : localizations?.lightMode ?? 'Light Mode',
                    ),
                    trailing: Switch(
                      value: state.isDarkMode,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Synchronization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Last sync: Never',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await SyncService(
                    dbHelper: DatabaseHelper.instance,
                    apiUrl: Env.baseUrl,
                  ).syncAllData(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Sync Data Now',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.errorContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<AuthCubit>().logout();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
                (route) => false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 16),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// // pages/settings_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:stock_manager/config/env.dart';
// import 'package:stock_manager/controllers/auth_controller.dart';
// import 'package:stock_manager/utils/database_helper.dart';
// import 'package:stock_manager/utils/sync_service.dart';
// import '../controllers/language_controller.dart';
// import '../controllers/theme_controller.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(localizations?.language ?? 'Language',
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
//                 Text(localizations?.theme ?? 'Theme',
//                     style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 BlocBuilder<ThemeCubit, ThemeState>(
//                   builder: (context, state) {
//                     return SwitchListTile(
//                       title: Text(state.isDarkMode
//                           ? localizations?.darkMode ?? 'Dark Mode'
//                           : localizations?.lightMode ?? 'Light Mode'),
//                       value: state.isDarkMode,
//                       onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
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
//                 const Text('Data Synchronization',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await SyncService(
//                       dbHelper: DatabaseHelper.instance,
//                       apiUrl: Env.baseUrl,
//                     ).syncAllData(context);
//
//                   },
//                   child: const Text('Sync Data Now'),
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
//                 const Text('Leaving',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         context.read<AuthCubit>().logout();
//                         Navigator.pushNamedAndRemoveUntil(
//                           context,
//                           '/',
//                               (route) => false,
//                         );
//                       },
//                       child: Text('Logout'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// // *****************************
//
// // class SettingsPage extends StatelessWidget {
// //   const SettingsPage({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ListView(
// //       padding: const EdgeInsets.all(16),
// //       children: [
// //         Card(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(AppLocalizations.of(context)!.language,
// //                     style: Theme.of(context).textTheme.titleMedium),
// //                 const SizedBox(height: 8),
// //                 BlocBuilder<LanguageCubit, LanguageState>(
// //                   builder: (context, state) {
// //                     return DropdownButton<String>(
// //                       value: state.locale.languageCode,
// //                       items: const [
// //                         DropdownMenuItem(value: 'en', child: Text('English')),
// //                         DropdownMenuItem(value: 'es', child: Text('Spanish')),
// //                         DropdownMenuItem(value: 'fr', child: Text('French')),
// //                         DropdownMenuItem(value: 'sw', child: Text('Swahili')),
// //                       ],
// //                       onChanged: (value) {
// //                         if (value != null) {
// //                           context.read<LanguageCubit>().changeLanguage(value);
// //                         }
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         Card(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(AppLocalizations.of(context)!.theme,
// //                     style: Theme.of(context).textTheme.titleMedium),
// //                 const SizedBox(height: 8),
// //                 BlocBuilder<ThemeCubit, ThemeState>(
// //                   builder: (context, state) {
// //                     return SwitchListTile(
// //                       title: Text(state.isDarkMode
// //                           ? AppLocalizations.of(context)!.darkMode
// //                           : AppLocalizations.of(context)!.lightMode),
// //                       value: state.isDarkMode,
// //                       onChanged: (_) =>
// //                           context.read<ThemeCubit>().toggleTheme(),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
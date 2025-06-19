import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class AppDialogs {  /// Show help dialog with search instructions
  static void showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppConstants.primaryColor),
            const SizedBox(width: 8),
            Text(localizations.helpDialogTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.helpIntroText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(localizations.helpQrText),
              Text(
                localizations.helpQrDescription,
                style: const TextStyle(fontSize: AppConstants.mediumTextSize),
              ),
              const SizedBox(height: 8),
              Text(localizations.helpBarcodeText),
              Text(
                localizations.helpBarcodeDescription,
                style: const TextStyle(fontSize: AppConstants.mediumTextSize),
              ),
              const SizedBox(height: 8),
              Text(localizations.helpSerialText),
              Text(
                localizations.helpSerialDescription,
                style: const TextStyle(fontSize: AppConstants.mediumTextSize),
              ),
              Text(
                localizations.helpSerialExample,
                style: const TextStyle(
                  fontSize: AppConstants.mediumTextSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(localizations.helpGcnText),
              Text(
                localizations.helpGcnDescription,
                style: const TextStyle(fontSize: AppConstants.mediumTextSize),
              ),
              Text(
                localizations.helpGcnExample,
                style: const TextStyle(
                  fontSize: AppConstants.mediumTextSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.helpNoteText,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.understoodButton,
              style: const TextStyle(color: AppConstants.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
  /// Show about dialog with app information
  static void showAboutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.aboutDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(localizations.appVersion),
            const SizedBox(height: 8),
            Text(localizations.appDescription),
            const SizedBox(height: 8),
            Text(localizations.copyright),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.closeButton),
          ),
        ],
      ),
    );
  }
  /// Show logout confirmation dialog
  static void showLogoutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logoutDialogTitle),
        content: Text(localizations.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancelButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.logoutSuccessMessage),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
            ),
            child: Text(localizations.logoutButton),
          ),
        ],
      ),
    );
  }
  /// Show menu bottom sheet
  static void showMenuBottomSheet(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (context) => Container(
        padding: AppConstants.largePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home, color: AppConstants.primaryColor),
              title: Text(localizations.homeMenuItem),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppConstants.primaryColor),
              title: Text(localizations.searchMenuItem),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppConstants.primaryColor),
              title: Text(localizations.historyMenuItem),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppConstants.primaryColor),
              title: Text(localizations.languageMenuItem),
              onTap: () {
                Navigator.pop(context);
                showLanguageDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppConstants.primaryColor),
              title: Text(localizations.settingsMenuItem),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Show language selection dialog
  static void showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.languageDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
              title: Text(localizations.vietnamese),
              trailing: languageService.isVietnamese
                  ? const Icon(Icons.check, color: AppConstants.primaryColor)
                  : null,
              onTap: () {
                languageService.setLanguage(const Locale('vi', 'VN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text(localizations.english),
              trailing: languageService.isEnglish
                  ? const Icon(Icons.check, color: AppConstants.primaryColor)
                  : null,
              onTap: () {
                languageService.setLanguage(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.closeButton),
          ),
        ],
      ),
    );
  }
}

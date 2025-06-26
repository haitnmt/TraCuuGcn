import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import 'drawer_widgets.dart';

class AppDialogs {
  /// Show help dialog with search instructions
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
                SnackBar(content: Text(localizations.logoutSuccessMessage)),
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
  /// Build app drawer with search history and language selection
  static Widget buildAppDrawer(BuildContext context) {
    return DrawerWidgets.buildAppDrawer(context);
  }

}

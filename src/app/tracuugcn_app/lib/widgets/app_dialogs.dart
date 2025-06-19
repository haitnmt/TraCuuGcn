import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Drawer(
      width: isSmallScreen ? double.infinity : null,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search History Section
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          localizations.historyMenuItem,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        if (isSmallScreen) ...[
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.keyboard_double_arrow_left),
                            onPressed: () => Navigator.pop(context),
                            tooltip: localizations.closeButton,
                            color: AppConstants.primaryColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Placeholder for search history items
                        _buildHistoryItem(
                          context,
                          "BN-001234567",
                          languageService.isVietnamese
                              ? "2 giờ trước"
                              : "2 hours ago",
                        ),
                        _buildHistoryItem(
                          context,
                          "27-T-123456789",
                          languageService.isVietnamese
                              ? "1 ngày trước"
                              : "1 day ago",
                        ),
                        _buildHistoryItem(
                          context,
                          "QR-789123456",
                          languageService.isVietnamese
                              ? "3 ngày trước"
                              : "3 days ago",
                        ),
                        // Add more history items as needed
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.clear_all,
                            color: Colors.grey,
                          ),
                          title: Text(
                            languageService.isVietnamese
                                ? "Xóa lịch sử"
                                : "Clear History",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            // TODO: Implement clear history functionality
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Language Selection
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: AppConstants.primaryColor),
                    const SizedBox(width: 16),
                    Text(
                      localizations.languageMenuItem,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<Locale>(
                      value: languageService.locale,
                      underline: Container(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppConstants.primaryColor,
                      ),
                      items: [
                        DropdownMenuItem<Locale>(
                          value: const Locale('vi', 'VN'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇻🇳', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(localizations.vietnamese),
                            ],
                          ),
                        ),
                        DropdownMenuItem<Locale>(
                          value: const Locale('en', 'US'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇺🇸', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(localizations.english),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          languageService.setLanguage(newLocale);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        
            // Copyright
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.copyright,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(Icons.info_outline),
                    tooltip: localizations.aboutTooltip,
                    color: AppConstants.primaryColor,
                    onPressed: () => AppDialogs.showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build history item widget
  static Widget _buildHistoryItem(
    BuildContext context,
    String searchTerm,
    String timeAgo,
  ) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(searchTerm),
      subtitle: Text(
        timeAgo,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.search, color: AppConstants.primaryColor),
        onPressed: () {
          // TODO: Implement search with this term
          Navigator.pop(context);
        },
      ),
      onTap: () {
        // TODO: Implement search with this term
        Navigator.pop(context);
      },
    );
  }
}

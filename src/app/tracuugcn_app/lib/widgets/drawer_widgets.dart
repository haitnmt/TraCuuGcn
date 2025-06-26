import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import 'app_dialogs.dart';

class DrawerWidgets {
  /// Build the main app drawer
  static Widget buildAppDrawer(BuildContext context) {
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
              child: _buildSearchHistorySection(context, isSmallScreen),
            ),
            // Copyright with About icon
            _buildCopyrightSection(context),
          ],
        ),
      ),
    );
  }

  /// Build search history section
  static Widget _buildSearchHistorySection(BuildContext context, bool isSmallScreen) {
    final localizations = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);

    return Column(
      children: [
        // Header
        _buildHistoryHeader(context, localizations, isSmallScreen),
        // History list
        Expanded(
          child: _buildHistoryList(context, languageService),
        ),
      ],
    );
  }

  /// Build history header
  static Widget _buildHistoryHeader(
    BuildContext context,
    AppLocalizations localizations,
    bool isSmallScreen,
  ) {
    return Container(
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
    );
  }

  /// Build history list
  static Widget _buildHistoryList(BuildContext context, LanguageService languageService) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Placeholder for search history items
        _buildHistoryItem(
          context,
          "BN-001234567",
          languageService.isVietnamese ? "2 giờ trước" : "2 hours ago",
        ),
        _buildHistoryItem(
          context,
          "27-T-123456789",
          languageService.isVietnamese ? "1 ngày trước" : "1 day ago",
        ),
        _buildHistoryItem(
          context,
          "QR-789123456",
          languageService.isVietnamese ? "3 ngày trước" : "3 days ago",
        ),
        const Divider(),
        _buildClearHistoryItem(context, languageService),
      ],
    );
  }

  /// Build individual history item
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

  /// Build clear history item
  static Widget _buildClearHistoryItem(BuildContext context, LanguageService languageService) {
    return ListTile(
      leading: const Icon(
        Icons.clear_all,
        color: Colors.grey,
      ),
      title: Text(
        languageService.isVietnamese ? "Xóa lịch sử" : "Clear History",
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        // TODO: Implement clear history functionality
        Navigator.pop(context);
      },
    );
  }

  /// Build copyright section with about icon
  static Widget _buildCopyrightSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
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
            iconSize: 20,
            icon: const Icon(Icons.info_outline),
            tooltip: localizations.aboutTooltip,
            color: AppConstants.primaryColor,
            onPressed: () => AppDialogs.showAboutDialog(context),
          ),
        ],
      ),
    );
  }
}

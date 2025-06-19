import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import 'app_dialogs.dart';

class ActionButtons {
  /// Build regular image button for large screens
  static Widget buildImageButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.imageTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.imageFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultPadding.top),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.image,
            size: AppConstants.mediumIconSize,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Build regular QR button for large screens
  static Widget buildQRButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.qrTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.qrFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultPadding.top),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.qr_code_scanner,
            size: AppConstants.mediumIconSize,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Build regular send button for large screens
  static Widget buildSendButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.sendTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.searchFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.send,
            size: AppConstants.mediumIconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build mobile-specific image button with smaller icons
  static Widget buildMobileImageButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.imageTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.imageFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            Icons.image,
            size: AppConstants.smallIconSize,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Build mobile-specific QR button with smaller icons
  static Widget buildMobileQRButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.qrTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.qrFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            Icons.qr_code_scanner,
            size: AppConstants.smallIconSize,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Build mobile-specific send button with smaller icons
  static Widget buildMobileSendButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.sendTooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.searchFeatureMessage),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          ),
          child: const Icon(
            Icons.send,
            size: AppConstants.smallIconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build mobile-specific help button
  static Widget buildMobileHelpButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Tooltip(
      message: localizations.helpTooltip,
      child: InkWell(
        onTap: () => AppDialogs.showHelpDialog(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Icon(
            Icons.help_outline,
            size: AppConstants.smallIconSize,
            color: Colors.blue.shade600,
          ),
        ),
      ),
    );
  }

  /// Build action buttons row for large screens
  static Widget buildLargeScreenActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildImageButton(context),
        const SizedBox(width: 8),
        buildQRButton(context),
        const SizedBox(width: 8),
        buildSendButton(context),
      ],
    );
  }

  /// Build action buttons row for mobile screens
  static Widget buildMobileActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildMobileHelpButton(context),
        Row(
          children: [
            buildMobileImageButton(context),
            const SizedBox(width: 6),
            buildMobileQRButton(context),
            const SizedBox(width: 6),
            buildMobileSendButton(context),
          ],
        ),
      ],
    );
  }
}

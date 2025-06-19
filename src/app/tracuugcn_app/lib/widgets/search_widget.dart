import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../utils/responsive_utils.dart';
import 'action_buttons.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool showHelperText;

  const SearchWidget({
    super.key,
    required this.controller,
    required this.showHelperText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: ResponsiveUtils.getResponsiveMargin(context),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Builder(
        builder: (context) {
          final isMobile = ResponsiveUtils.isMobile(context);

          if (isMobile) {
            return _buildMobileLayout(context);
          } else {
            return _buildLargeScreenLayout(context);
          }
        },
      ),
    );
  }

  /// Build mobile layout with TextField above and buttons below
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMobileTextField(context),
        const SizedBox(height: 12),
        ActionButtons.buildMobileActionButtons(context),
      ],
    );
  }

  /// Build large screen layout with TextField and buttons in row, plus helper text
  Widget _buildLargeScreenLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLargeScreenTextField(context)),
            const SizedBox(width: 12),
            ActionButtons.buildLargeScreenActionButtons(context),
          ],
        ),
        if (showHelperText) ...[
          const SizedBox(height: 8),
          _buildHelperText(context),
        ],
      ],
    );
  }  /// Build TextField for mobile devices
  Widget _buildMobileTextField(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 1,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.searchFeatureMessage),
          ),
        );
      },
      decoration: InputDecoration(
        hintText: localizations.mobileSearchHintText,
        prefixIcon: const Icon(Icons.search, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
  /// Build TextField for large screens
  Widget _buildLargeScreenTextField(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.searchFeatureMessage),
          ),
        );
      },
      decoration: InputDecoration(
        hintText: localizations.searchHintText,
        prefixIcon: const Icon(Icons.search, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Build helper text for large screens
  Widget _buildHelperText(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        localizations.helperText,
        style: TextStyle(
          fontSize: AppConstants.smallTextSize,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

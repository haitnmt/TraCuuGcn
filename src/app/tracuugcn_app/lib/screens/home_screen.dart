import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';
import '../widgets/search_widget.dart';
import '../widgets/app_dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showHelperText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showHelperText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }
  /// Build the app bar with menu and action buttons
  AppBar _buildAppBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AppBar(
      title: Text(localizations.appTitle),
      centerTitle: true,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => AppDialogs.showMenuBottomSheet(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: localizations.aboutTooltip,
          onPressed: () => AppDialogs.showAboutDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: localizations.logoutTooltip,
          onPressed: () => AppDialogs.showLogoutDialog(context),
        ),
      ],
    );
  }

  /// Build the main body with background and content
  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.backgroundImage),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          opacity: 0.8,
        ),
      ),
      child: Stack(
        children: [
          _buildMainContent(context),
          _buildFloatingSearchWidget(),
        ],
      ),
    );
  }

  /// Build the main content with titles
  Widget _buildMainContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTitle1(context),
          const SizedBox(height: 12),
          _buildTitle2(context),
          const SizedBox(height: 4),
          _buildSubtitle(context),
        ],
      ),
    );
  }
  /// Build the first title
  Widget _buildTitle1(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Text(
      localizations.mainTitle1,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build the second title
  Widget _buildTitle2(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Text(
      localizations.mainTitle2,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build the subtitle with responsive text
  Widget _buildSubtitle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    
    return Text(
      isSmallScreen 
          ? localizations.mainSubtitleMobile 
          : localizations.mainSubtitle,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build the floating search widget positioned at bottom
  Widget _buildFloatingSearchWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SearchWidget(
        controller: _searchController,
        showHelperText: _showHelperText,
      ),
    );
  }
}

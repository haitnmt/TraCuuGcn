import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';
import '../widgets/search_widget.dart';
import '../widgets/drawer_widgets.dart';
import '../widgets/user_widgets.dart';
import '../auth/auth_manager.dart';
import '../auth/models/auth_user.dart';
import '../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showHelperText = false;
  bool _isAuthenticated = false;
  AuthUser? _currentUser;
  final AuthManager _authManager = AuthManager();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showHelperText = _searchController.text.isNotEmpty;
      });
    });
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      debugPrint("[HomeScreen] Checking authentication status...");
      final isAuth = await _authManager.isAuthenticated();
      debugPrint("[HomeScreen] Is authenticated: $isAuth");
      
      if (isAuth) {
        final user = await _authManager.getCurrentUser();
        debugPrint("[HomeScreen] Current user: $user");
        debugPrint("[HomeScreen] User displayName: ${user?.displayName}");
        debugPrint("[HomeScreen] User effectiveDisplayName: ${user?.effectiveDisplayName}");
        
        setState(() {
          _isAuthenticated = true;
          _currentUser = user;
        });
        debugPrint("[HomeScreen] State updated - isAuthenticated: $_isAuthenticated, currentUser: $_currentUser");
      } else {
        setState(() {
          _isAuthenticated = false;
          _currentUser = null;
        });
        debugPrint("[HomeScreen] State updated - not authenticated");
      }
    } catch (e) {
      debugPrint("[HomeScreen] Error checking auth status: $e");
      setState(() {
        _isAuthenticated = false;
        _currentUser = null;
      });
    }
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
      drawer: DrawerWidgets.buildAppDrawer(context), // Always show left drawer
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/auth-demo');
        },
        icon: const Icon(Icons.security),
        label: const Text('Auth Demo'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  /// Build the app bar with appropriate actions based on auth state
  AppBar _buildAppBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AppBar(
      title: Text(localizations.appTitle),
      centerTitle: false,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      // Explicitly ensure leading icon is shown (hamburger menu for left drawer)
      automaticallyImplyLeading: true,
      actions: _isAuthenticated ? _buildAuthenticatedActions(context) : _buildUnauthenticatedActions(context),
    );
  }

  /// Build actions for authenticated user
  List<Widget> _buildAuthenticatedActions(BuildContext context) {
    return [
      // Language switch
      _buildLanguageSwitch(),
      // User popup menu
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: UserWidgets.buildUserInfoPopup(
          context,
          _currentUser,
          _handleLogout,
        ),
      ),
    ];
  }

  /// Build actions for unauthenticated user
  List<Widget> _buildUnauthenticatedActions(BuildContext context) {
    return [
      // Language switch
      _buildLanguageSwitch(),
      // Login button
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Tooltip(
          message: AppLocalizations.of(context)!.loginButton,
          child: IconButton(
            onPressed: () => _handleLogin(context),
            icon: const Icon(Icons.login, color: Colors.white),
            splashRadius: 24,
          ),
        ),
      ),
    ];
  }

  /// Handle login button press - directly authenticate via browser
  Future<void> _handleLogin(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.all(24.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                localizations.loginInProgress,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Get current language and authenticate
      final languageService = Provider.of<LanguageService>(context, listen: false);
      final currentLanguage = languageService.locale.languageCode;
      
      await _authManager.authenticate(languageCode: currentLanguage);
      
      // Check if authentication was successful
      final isAuthenticated = await _authManager.isAuthenticated();
      
      // Close loading dialog
      if (mounted) navigator.pop();
      
      if (isAuthenticated) {
        // Refresh authentication status
        await _checkAuthenticationStatus();
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(localizations.loginSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(localizations.loginFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) navigator.pop();
      
      debugPrint("[HomeScreen] Login error: $e");
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations.loginError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    if (!mounted) return;
    
    final localizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await _authManager.logout();
      setState(() {
        _isAuthenticated = false;
        _currentUser = null;
      });
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations.logoutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("[HomeScreen] Logout error: $e");
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(localizations.logoutError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build the main body with background and content
  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.backgroundImage),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          opacity: 0.35,
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
    return Column(
      children: [
        // Spacer để đẩy content xuống khoảng 1/3 màn hình
        const Spacer(flex: 1),
        // Content chính
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTitle1(context),
                const SizedBox(height: 12),
                _buildTitle2(context),
                const SizedBox(height: 4),
                _buildSubtitle(context),
              ],
            ),
          ),
        ),
        // Spacer để cân bằng phần còn lại
        const Spacer(flex: 2),
      ],
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

  /// Build language switch button (VI/EN)
  Widget _buildLanguageSwitch() {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final isVietnamese = languageService.isVietnamese;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageButton(
                'VI',
                isVietnamese,
                () => languageService.setLanguage(const Locale('vi', 'VN')),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildLanguageButton(
                'EN',
                !isVietnamese,
                () => languageService.setLanguage(const Locale('en', 'US')),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual language button
  Widget _buildLanguageButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

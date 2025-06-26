import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../auth/models/auth_user.dart';
import '../l10n/app_localizations.dart';

class UserWidgets {
  /// Build user info popup menu (floating dropdown)
  static Widget buildUserInfoPopup(
    BuildContext context,
    AuthUser? currentUser,
    VoidCallback onLogout,
  ) {
    final localizations = AppLocalizations.of(context)!;
    
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 18,
        child: Text(
          _getUserInitials(currentUser),
          style: const TextStyle(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      itemBuilder: (BuildContext context) => [
        // User info header
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConstants.primaryColor,
                      radius: 20,
                      child: Text(
                        _getUserInitials(currentUser),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display name (thay cho fullName)
                          Text(
                            currentUser?.effectiveDisplayName ?? localizations.defaultUserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Username (thay cho email)
                          if (currentUser?.username != null)
                            Text(
                              '@${currentUser!.username}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                // User details
                if (currentUser?.email != null)
                  _buildInfoRow(
                    Icons.email_outlined,
                    localizations.emailLabel,
                    currentUser!.email,
                  ),
                
                if (currentUser?.roles != null && currentUser!.roles.isNotEmpty)
                  _buildInfoRow(
                    Icons.security_outlined,
                    localizations.roleLabel,
                    currentUser.roles.join(', '),
                  ),
                
                if (currentUser?.lastLogin != null)
                  _buildInfoRow(
                    Icons.access_time_outlined,
                    localizations.lastLoginLabel,
                    _formatLastLogin(context, currentUser!.lastLogin!),
                  ),
              ],
            ),
          ),
        ),
        
        // Divider
        const PopupMenuDivider(),
        
        // Logout option
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text(
                localizations.logoutButton,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'logout') {
          onLogout();
        }
      },
    );
  }

  /// Build info row for user details
  static Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Format last login time with localization
  static String _formatLastLogin(BuildContext context, DateTime lastLogin) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${localizations.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${localizations.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${localizations.minutesAgo}';
    } else {
      return localizations.justNow;
    }
  }

  /// Get user initials for avatar
  static String _getUserInitials(AuthUser? currentUser) {
    if (currentUser == null) return 'U';
    
    // Ưu tiên displayName
    if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
      final names = currentUser.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      } else if (names.isNotEmpty) {
        return names.first[0].toUpperCase();
      }
    }
    
    // Thứ hai là fullName
    if (currentUser.fullName != null && currentUser.fullName!.isNotEmpty) {
      final names = currentUser.fullName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      } else if (names.isNotEmpty) {
        return names.first[0].toUpperCase();
      }
    }
    
    // Cuối cùng là username
    if (currentUser.username.isNotEmpty) {
      return currentUser.username[0].toUpperCase();
    }
    
    return 'U';
  }
}

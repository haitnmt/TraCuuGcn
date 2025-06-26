import 'package:flutter/material.dart';
import '../auth/widgets/appauth_login_widget.dart';

class AuthDemoScreen extends StatelessWidget {
  const AuthDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAuthLoginWidget(
      onLoginSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onLoginError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

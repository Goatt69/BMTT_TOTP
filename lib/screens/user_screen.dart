import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../model/UserModel.dart';
import '../services/auth_service.dart';
import '../utils/auth.dart';
import 'login_screen.dart';

class UserScreen extends StatefulWidget {
  final User? currentUser;

  const UserScreen({super.key, this.currentUser});


  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? _currentUser;

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final result = await authService.userInfo();
    print('API Response: $result'); // Debug print

    if (result['success']) {
      print('User data: ${result['user']}'); // Debug print
      setState(() {
        _currentUser = User.fromJson(result['user']);
      });
      print('Current user after set: $_currentUser'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _currentUser?.avatarUrl != null
                      ? NetworkImage(_currentUser!.avatarUrl!)
                      : null,
                  child: _currentUser?.avatarUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser?.userName ?? '',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(_currentUser?.email ?? ''),
                const SizedBox(height: 32),

                // Enable 2 factor
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Auth.setupTotp();
                    if (result['success']) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('TOTP Secret Key'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Your secret key is:'),
                              shadcn.CodeSnippet(
                                code: '${result['secretKey']}',
                                mode: 'shell',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const shadcn.Icon(Icons.lock_outline,
                      color: Colors.white),
                  label: const Text('Setup 2FA',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final authService = AuthService();
                      final success = await authService.logout();
                      if (success) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (
                              context) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                        'Logout', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
}

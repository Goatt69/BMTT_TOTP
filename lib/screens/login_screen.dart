import 'package:flutter/material.dart';
import 'package:nhom4_bmtt_totp/screens/register_screen.dart';
import 'package:nhom4_bmtt_totp/screens/user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../utils/auth.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String value = '';

  @override
  void initState() {
    super.initState();
    _checkToken(); // Kiểm tra token khi mở màn hình
  }

  // Kiểm tra token trong SharedPreferences
  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      // Nếu token tồn tại, chuyển hướng đến MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserScreen()),
      );
    }
  }
  Widget buildValidationToast(BuildContext context, shadcn.ToastOverlay overlay) {
    return shadcn.SurfaceCard(
      child: shadcn.Basic(
        title: const Text('Validation Error'),
        subtitle: const Text('Vui lòng nhập đầy đủ thông tin'),
        trailing: shadcn.PrimaryButton(
            size: shadcn.ButtonSize.small,
            onPressed: () {
              overlay.close();
            },
            child: const Text('Close')
        ),
        trailingAlignment: Alignment.center,
      ),
    );
  }


  // Hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      shadcn.showToast(
        context: context,
        builder: buildValidationToast,
        location: shadcn.ToastLocation.bottomRight,
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result = await Auth.login(
        _usernameController.text,
        _passwordController.text
    );
    Widget buildToast(BuildContext context, shadcn.ToastOverlay overlay) {
      return shadcn.SurfaceCard(
        child: shadcn.Basic(
          title: const Text('Đăng nhập thất bại'),
          subtitle: Text('Kiểm tra tài khoản mật khẩu\n'  + result['message']  ?? 'Đăng nhập thất bại'),
          trailing: shadcn.PrimaryButton(
              size: shadcn.ButtonSize.small,
              onPressed: () {
                overlay.close();
              },
              child: const Text('Close')
          ),
          trailingAlignment: Alignment.center,
        ),
      );
    }
    if (result['success']) {
      if (result['twoFactorEnabled']) {
        String? totpCode = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enter 2FA Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shadcn.InputOTP(
                  onChanged: (value) {
                    setState(() {
                      this.value = value.otpToString();
                    });
                  },
                  children: [
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.separator,
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                    shadcn.InputOTPChild.character(allowDigit: true),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isLoading = false);
                },
                child: const Text('Cancel'),
              ),
              
              TextButton(
                onPressed: () => Navigator.pop(context, value),
                child: const Text('Verify'),
              ),
            ],
          ),
        );

        if (totpCode != null) {
          result = await Auth.loginWithTotp(
              _usernameController.text,
              _passwordController.text,
              totpCode
          );
        }
      }

      if (result['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', result['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserScreen()),
        );
      }
    }

    setState(() => _isLoading = false);

    if (!result['success']) {
      shadcn.showToast(
        context: context,
        builder: buildToast,
        location: shadcn.ToastLocation.bottomRight,
      );
    }
  }
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'TOTP demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Số điện thoại hoặc email',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons
                              .visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 50,

                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Text(

                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Thêm điều hướng đến màn hình đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (
                                    context) => const RegistrationScreen()),
                          );
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }


import 'package:autoshare/Customer/customer_home_page.dart';
import 'package:autoshare/Driver/driver_home_page.dart';
import 'package:autoshare/General/exit_pop_up.dart';
import 'package:autoshare/Login&Signup/registration.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoshare/services/api_service.dart';

class LoginPage extends StatefulWidget {
  final String? selectedRole;
  const LoginPage({super.key, this.selectedRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.selectedRole ?? 'customer';
  }

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await handlePopResult(context, didPop, result);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Account Type',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRoleCard(
                    role: 'customer',
                    iconWidget:
                        const Icon(Icons.person, size: 48, color: Colors.black),
                    label: 'Customer',
                  ),
                  const SizedBox(width: 32),
                  _buildRoleCard(
                    role: 'driver',
                    iconWidget: Image.asset(
                      'assets/Images/Auto.png',
                      height: 48,
                      width: 48,
                    ),
                    label: 'Driver',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _controllerEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        label: const Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            backgroundColor: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controllerPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        label: const Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            backgroundColor: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('No Account?'),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegistrationPage()),
                                );
                              },
                              child: const Text(
                                ' Signup',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed:_isLoading ? null : () async {
                            setState(() => _isLoading = true);
                            try {
                              if (_controllerEmail.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter email'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (_controllerPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter password'), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              try {
                                // Call login API with email, password and selected role
                                final result = await ApiService.login(
                                  email: _controllerEmail.text,
                                  password: _controllerPassword.text,
                                  role: selectedRole,
                                );

                                // Save session info to SharedPreferences
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('isLoggedIn', true);
                                await prefs.setString('userType', result['role']);
                                await prefs.setString('userName', result['name']);
                                await prefs.setString('userId', result['user_id']);

                                if (!context.mounted) return;

                                // Go to correct home page based on role
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => result['role'] == 'customer'
                                        ? const CustomerHomePage()
                                        : const DriverHomePage(),
                                  ),
                                  (route) => false,
                                );

                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } 
                            finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 254, 187, 38),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: _isLoading ?
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required Widget iconWidget,
    required String label,
  }) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 254, 187, 38)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 254, 187, 38)
                : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            iconWidget,
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 0),
                child: Icon(Icons.check_circle, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}

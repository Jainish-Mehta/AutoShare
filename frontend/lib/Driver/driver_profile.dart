import 'package:flutter/material.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [SizedBox()],
        ),
      ),
      appBar: AppBar(
        title: Text('Profile'),
      ),
      backgroundColor: Colors.deepPurple,
    );
  }
}

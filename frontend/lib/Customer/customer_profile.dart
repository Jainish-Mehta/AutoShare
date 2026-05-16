import 'package:flutter/material.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({super.key});
  @override
  CustomerProfileState createState() => CustomerProfileState();
}

class CustomerProfileState extends State<CustomerProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(decoration: BoxDecoration()),
    );
  }
}

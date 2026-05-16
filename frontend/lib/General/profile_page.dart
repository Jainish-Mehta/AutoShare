import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.userType,
  });
  final String userType;
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  String get name => widget.userType;

  String phone = '9573753933';
  String get email => '$name@gmail.com';
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _image = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: Stack(
                                children: [
                                  if (_image == null)
                                    const Center(
                                      child: Icon(Icons.person,
                                          size: 80, color: Colors.black),
                                    ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      iconSize: 25,
                                      onPressed: _pickImage,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Color.fromARGB(
                                                    255, 254, 187, 38)),
                                        shape: WidgetStateProperty.all(
                                            const CircleBorder()),
                                        padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(6)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: $name',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                                Text('Phone: $phone',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                                Text('Email: $email',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const Text('AutoShare Rewards Points: 500',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const Divider(color: Colors.grey),
                  const Text('Refer & Earn',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const Divider(color: Colors.grey),
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

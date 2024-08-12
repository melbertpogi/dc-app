import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfilePage extends StatefulWidget {
  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _username = '';
  String _email = '';
  String _homeAddress = '';

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _homeAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _email = user.email ?? '';
        _username = user.displayName ?? '';
      });

      try {
        DocumentSnapshot userProfile = await _firestore.collection('seller_profiles').doc(user.uid).get();
        if (userProfile.exists) {
          Map<String, dynamic>? data = userProfile.data() as Map<String, dynamic>?;
          if (data != null) {
            print('Fetched data: $data'); // Logging the fetched data
            setState(() {
              _username = data['username'] ?? _username;
              _email = data['email'] ?? _email;
              _homeAddress = data['homeAddress'] ?? _homeAddress;

              // Update controllers with fetched data
              _usernameController.text = _username;
              _emailController.text = _email;
              _homeAddressController.text = _homeAddress;
            });
          } else {
            print('Data is null');
          }
        } else {
          print('User profile does not exist.');
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    } else {
      print('No user is currently signed in.');
    }
  }

  Future<void> _saveProfile() async {
    if (_user != null) {
      try {
        await _firestore.collection('seller_profiles').doc(_user!.uid).set({
          'username': _usernameController.text,
          'email': _emailController.text,
          'homeAddress': _homeAddressController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully')),
        );
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile')),
        );
      }
    } else {
      print('No user is currently signed in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently signed in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $_email'),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
            TextFormField(
              enabled: false,
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _homeAddressController,
              decoration: InputDecoration(labelText: 'Home Address'),
              onChanged: (value) {
                setState(() {
                  _homeAddress = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

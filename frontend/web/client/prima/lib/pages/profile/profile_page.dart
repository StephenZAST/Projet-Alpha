import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prima/providers/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileProvider.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profile = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: ${profile['first_name']} ${profile['last_name']}'),
                  Text('Email: ${profile['email']}'),
                  Text('Phone: ${profile['phone']}'),
                  Text('Address: ${profile['address']}'),
                  Text('Role: ${profile['role']}'),
                  Text('Referral Code: ${profile['referral_code']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

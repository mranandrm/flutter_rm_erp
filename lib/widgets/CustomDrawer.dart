import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/LoginScreen.dart';
import '../services/AuthProvider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.authenticated) {
            return ListView(
              children: [
                ListTile(
                  title: Text('Login'),
                  leading: Icon(Icons.login),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login Screen')),
                    );
                  },
                ),
                ListTile(
                  title: Text('Register'),
                  leading: Icon(Icons.app_registration),
                  onTap: () {
                    Navigator.pop(context);

                  },
                ),
              ],
            );
          } else {
            print("custom drawer");
            print(auth.user.toString());
            String avatar = auth.user?.avatar as String;
            String name = auth.user?.name as String;
            String email = auth.user?.email as String;

            print(avatar);
            print(name);
            print(email);

            return ListView(
              children: [
                DrawerHeader(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                        radius: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        email,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Logout'),
                  leading: Icon(Icons.logout),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
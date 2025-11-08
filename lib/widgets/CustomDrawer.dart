import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/EmployeeAttendanceScreen.dart';
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
            String avatar = auth.user?.avatar ?? '';
            String name = auth.user?.name ?? 'Unknown';
            String email = auth.user?.email ?? 'No email';

            return ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                        radius: 30,
                      ),
                      SizedBox(height: 10),
                      Text(name, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      Text(email, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Employee Attendance'),
                  leading: Icon(Icons.calendar_today),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeAttendanceScreen(),

                      ),
                    );
                  },
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:device_info_plus/device_info_plus.dart';

import '../services/AuthProvider.dart';

class LoginScreen extends StatefulWidget {

  final String title;

  const LoginScreen({super.key, required this.title});

  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Get Device Info
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String _deviceName = '';

  void getDeviceName() async {

    try {

      if(Platform.isAndroid)
      {

        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        // e.g. "Moto G (4)"
        _deviceName = androidInfo.model;

      }
      else if(Platform.isIOS)
      {

        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        // e.g. "iPod7,1"
        _deviceName = iosInfo.utsname.machine;

      }

    }
    catch (e) {

    }

  }

  @override
  void initState() {

    // Initial Data
    _emailController.text = "avi@gmail.com";
    _passwordController.text = "password";

    getDeviceName();

    super.initState();
  }


  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                  controller: _emailController,
                  validator: (value) => value!.isEmpty ? 'Please enter valid email' : null
              ),
              TextFormField(
                  controller: _passwordController,
                  validator: (value) => value!.isEmpty ? 'Please enter password' : null
              ),
              TextButton(
                onPressed: () {

                  Map creds = {
                    'email' : _emailController.text,
                    'password' : _passwordController.text,
                    'device_name' : _deviceName ?? 'unknown'
                  };

                  if(_formKey.currentState!.validate())
                  {
                    print('ok');
                    print(_emailController.text);
                    print(_passwordController.text);


                    Provider.of<AuthProvider>(context, listen: false).login(creds: creds);

                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
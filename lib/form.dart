import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './utils/custom_alerts.dart';
import './constants/constants.dart';
import 'utils/validator.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({required this.gigId, required this.gigName});
  final String gigName, gigId;

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _key = GlobalKey();
  CustomValidator customValidator = CustomValidator();
  bool _isLoading = false;

  final Map<String, String> _authData = {
    'name': '',
    'phone': '',
    'email': '',
  };

  final CustomAlerts _alerts = CustomAlerts();

  Future<void> _putData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('registrations').doc().set({
        'courseId': widget.gigId,
        'courseName': widget.gigName,
        'uid': user!.uid,
        'userName': _authData['name'],
        'userPhone': _authData['phone'],
        'userEmail': _authData['email'],
      });
    } catch (error) {
      _alerts.showSnackBar('$error', context);
    }
  }

  Future<void> _register() async {
    try {
      Focus.of(context).unfocus();
    } catch (_) {}

    if (!_key.currentState!.validate()) {
      // Invalid!
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _key.currentState!.save();

    print(_authData);
    try {
      final _registrationData =
          await FirebaseFirestore.instance.collection('registrations').get();

      if (_registrationData
          .docs.isEmpty) // Check if there is any document in given collection
      {
        _putData(context);
        _alerts.showSnackBar(
          'Registration Successful',
          context,
          success: true,
        );
      } else {
        final _registrationStatus = _registrationData.docs.firstWhereOrNull(
            (e) => e['uid'] == user!.uid && e['courseId'] == widget.gigId);
        print(_registrationStatus?['courseId'] ?? 'null');

        if (_registrationStatus == null) {
          _putData(context);
          _alerts.showSnackBar(
            'Registration Successful',
            context,
            success: true,
          );
        } else {
          _alerts.showSnackBar(
            'Already Registered',
            context,
            success: true,
          );
        }
      }
    } catch (error) {
      _alerts.showSnackBar(
        '$error',
        context,
      );
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gigName),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _register,
          )
        ],
      ),
      body: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: TextFormField(
                validator: customValidator.validateName,
                onSaved: (value) {
                  _authData['name'] = value!.trim();
                },
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: TextFormField(
                validator: customValidator.validateMobile,
                onSaved: (value) {
                  _authData['phone'] = value!.trim();
                },
                decoration: const InputDecoration(
                  hintText: "Phone (e.g 3012345678)",
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: customValidator.validateEmail,
                onSaved: (value) {
                  _authData['email'] = value!.trim();
                },
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),
            ),
            const Divider(
              height: 1.0,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('Done'),
                  onPressed: _register,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

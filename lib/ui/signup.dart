import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import './widgets/custom_shape.dart';
import './widgets/customappbar.dart';
import './widgets/responsive_ui.dart';
import './widgets/textformfield.dart';
import '../constants/constants.dart';
import '../utils/custom_alerts.dart';
import '../utils/validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool checkBoxValue = false;
  double _height = 0;
  double _width = 0;
  double _pixelRatio = 0;
  bool _large = false;
  bool _medium = false;
  bool _isLoading = false;
  final Map<String, String> _authData = {
    'email': '',
    'firstname': '',
    'lastname': '',
    'mobile': '',
    'password': '',
  };

  final _auth = FirebaseAuth.instance;
  final CustomValidator customValidator = CustomValidator();
  final CustomAlerts _alerts = CustomAlerts();

  final GlobalKey<FormState> _formKey = GlobalKey();

  var _pickedImage;

  // void _showErrorDialog(String errorMessage) {
  //   showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //             title: Text('An error occurred'),
  //             content: Text(errorMessage),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text('OK'))
  //             ],
  //           ));
  // }

  Future<void> _pickUserImage() async {
    final ImagePicker _picker = ImagePicker();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Select an Image'),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 50,
                          maxWidth: 150);
                      if (image == null) {
                        return;
                      }
                      if (kIsWeb) {
                        // _pickedImage = await image.readAsBytes();
                        _pickedImage = image;
                      } else {
                        _pickedImage = File(image.path);
                      }
                      setState(() {
                        // _pickedImage = image;
                      });
                    },
                    child: const Text('Open Gallery')),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (photo == null) {
                        return;
                      }
                      if (kIsWeb) {
                        // _pickedImage = await photo.readAsBytes();
                        _pickedImage = photo;
                      } else {
                        _pickedImage = File(photo.path);
                      }
                      setState(() async {
                        // _pickedImage = photo;
                      });
                    },
                    child: const Text('Capture')),
              ],
            ));

    // Capture a photo
    //
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    if (!checkBoxValue) {
      _alerts.showSnackBar('Please accept terms and conditions', context);
      return;
    }
    if (_pickedImage == null) {
      _alerts.showSnackBar('Please select an image', context);
      return;
    }

    try {
      Focus.of(context).unfocus();
    } catch (_) {}

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      final _authResult = await _auth.createUserWithEmailAndPassword(
          email: _authData['email']!, password: _authData['password']!);

      try {
        final _ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(_authResult.user!.uid + '.jpg');


        if (kIsWeb) {
          print('----------- Web');
          await _ref.putData(await _pickedImage!.readAsBytes());
        } else {
          print('----------- Mobile');

          await _ref.putFile(_pickedImage!);
        }


        final imageUrl = await _ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_authResult.user!.uid)
            .set({
          'username': _authData['username'],
          'email': _authData['email'],
          'firstname': _authData['firstname'],
          'lastname': _authData['lastname'],
          'mobile': _authData['mobile'],
          'image_url': imageUrl
        });
      } catch (error) {
        _alerts.showSnackBar('$error', context);
      }
    } on FirebaseAuthException catch (e) {
      var errorMessage =
          e.message ?? 'Error occurred, please check your credentials!';
      _alerts.showSnackBar(errorMessage, context);
    } catch (error) {
      _alerts.showSnackBar('$error', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Material(
      child: Scaffold(
        body: Container(
          height: _height,
          width: _width,
          margin: const EdgeInsets.only(bottom: 5),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Opacity(opacity: 0.88, child: CustomAppBar()),
                clipShape(),
                form(),
                acceptTermsTextRow(),
                SizedBox(
                  height: _height / 35,
                ),
                button(),
                infoTextRow(),
                socialIconsRow(),
                //signInTextRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 8
                  : (_medium ? _height / 7 : _height / 6.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200]!, Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height / 12
                  : (_medium ? _height / 11 : _height / 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200]!, Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: _height / 5.5,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  spreadRadius: 0.0,
                  color: Colors.black26,
                  offset: Offset(1.0, 10.0),
                  blurRadius: 20.0),
            ],
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: _pickUserImage,
            child: _pickedImage == null
                ? Icon(
                    Icons.add_a_photo,
                    size: _large ? 40 : (_medium ? 33 : 31),
                    color: Colors.orange[200],
                  )
                : CircleAvatar(
                    radius: 60,
                    backgroundImage: kIsWeb
                        ? NetworkImage(_pickedImage.path) as ImageProvider
                        : FileImage(_pickedImage!),
                  ),
          ),
        ),
//        Positioned(
//          top: _height/8,
//          left: _width/1.75,
//          child: Container(
//            alignment: Alignment.center,
//            height: _height/23,
//            padding: EdgeInsets.all(5),
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color:  Colors.orange[100],
//            ),
//            child: GestureDetector(
//                onTap: (){
//                },
//                child: Icon(Icons.add_a_photo, size: _large? 22: (_medium? 15: 13),)),
//          ),
//        ),
      ],
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0, right: _width / 12.0, top: _height / 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            firstNameTextFormField(),
            SizedBox(height: _height / 60.0),
            lastNameTextFormField(),
            SizedBox(height: _height / 60.0),
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            phoneTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
          ],
        ),
      ),
    );
  }

  Widget firstNameTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      icon: Icons.person,
      hint: "First Name",
      validator: customValidator.validateName,
      onSaved: (value) {
        _authData['firstname'] = value!.trim();
      },
    );
  }

  Widget lastNameTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      icon: Icons.person,
      hint: "Last Name",
      validator: customValidator.validateName,
      onSaved: (value) {
        _authData['lastname'] = value!.trim();
      },
    );
  }

  Widget emailTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
      hint: "Email ID",
      validator: customValidator.validateEmail,
      onSaved: (value) {
        _authData['email'] = value!.trim();
      },
    );
  }

  Widget phoneTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.number,
      icon: Icons.phone,
      hint: "03012345678",
      validator: customValidator.validateMobile,
      onSaved: (value) {
        _authData['mobile'] = value!.trim();
      },
    );
  }

  Widget passwordTextFormField() {
    return CustomTextField(
      keyboardType: TextInputType.text,
      obscureText: true,
      icon: Icons.lock,
      hint: "Password",

      validator: customValidator.validatePasswordLength,
      onSaved: (value) {
        _authData['password'] = value!.trim();
      },
    );
  }

  Widget acceptTermsTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Checkbox(
              activeColor: Colors.orange[200],
              value: checkBoxValue,
              onChanged: (bool? newValue) {
                setState(() {
                  checkBoxValue = newValue!;
                });
              }),
          Text(
            "I accept all terms and conditions",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }

  Widget button() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
        foregroundColor: MaterialStateProperty.all(
          Colors.white,
        ),
        padding: MaterialStateProperty.all(const EdgeInsets.all(0.0)),
      ),
      onPressed: _isLoading ? null : _submit,
      child: Container(
        alignment: Alignment.center,
//        height: _height / 20,
        width: _large ? _width / 4 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200]!, Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: !_isLoading
            ? Text(
                'SIGN UP',
                style: TextStyle(fontSize: _large ? 14 : (_medium ? 12 : 10)),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget infoTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Or create using social media",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }

  Widget socialIconsRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 80.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/googlelogo.png"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/fblogo.jpg"),
          ),
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage("assets/images/twitterlogo.jpg"),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Already have an account?",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(SIGN_IN);

            },
            child: Text(
              "Sign in",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.orange[200],
                  fontSize: 19),
            ),
          )
        ],
      ),
    );
  }
}

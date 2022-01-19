import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sketch_to_real/common_ui_functions.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/screens/homepage.dart';
import 'package:sketch_to_real/services/authentication_service.dart';
import 'package:sketch_to_real/tools/custom_toast.dart';
import 'package:sketch_to_real/tools/loading.dart';

import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  // TextEditingController _addressController = TextEditingController();
  final _textFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: backgroundColorBoxDecoration(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _textFormKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Hero(
                              tag: "logo",
                              child: Image.asset(
                                logo,
                                height: 90,
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        edittedTextField(
                          hintText: "Enter a valid user name, min length 6",
                          controller: _userNameController,
                          isPass: false,
                          lablelText: "Username",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        edittedTextField(
                          hintText: "Enter a valid email address",
                          controller: _emailController,
                          isPass: false,
                          isEmail: true,
                          lablelText: "Email Address",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        edittedTextField(
                          hintText: "Enter a valid password, min length 6",
                          valText: 'Password Too Short',
                          controller: _passwordController,
                          isPass: true,
                          lablelText: "Password",
                          obscureText: _obscureText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        edittedTextField(
                          hintText: "Enter same password as above",
                          valText: 'Password Too Short',
                          controller: _confirmPasswordController,
                          isPass: true,
                          lablelText: "Confirm Password",
                          obscureText: _obscureText,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        edittedTextField(
                          hintText: "Enter a valid phone number",
                          controller: _phoneNoController,
                          isPass: false,
                          valText: 'Phone number Too Short',
                          lablelText: "Phone NUmber",
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () => _handleSignUp(context),
                            child: buildSignUpLoginButton(
                                context: context,
                                btnText: "SignUp",
                                assetImage: signUp,
                                color: containerColor,
                                hasIcon: true),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
// Move to Sign Up Page
                      ],
                    ),
                  ),
                ),
              ),
              _isLoading ? LoadingIndicator() : Container(),
            ],
          ),
        ),
        bottomSheet: buildSignUpLoginText(
            context: context,
            text1: "Don't have an account ",
            text2: "Sign Up",
            moveToLogIn: false),
      ),
    );
  }

  emailValidation(val) {
    if (val == null) {
      return null;
    }
    if (val.isEmpty) {
      return "Field is Empty";
    } else if (!val.contains("@") || val.trim().length < 4) {
      return "Invalid E-mail!";
    } else {
      return null;
    }
  }

  GlassContainer edittedTextField({
    String ?lablelText,
    String? hintText,
    bool? isEmail = false,
    bool ?obscureText = true,
    String? valText,
    int valLength = 6,
    TextEditingController? controller,
    bool ?isPass,
  }) {
    return GlassContainer(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
        ),
        child: TextFormField(
          obscureText: isPass! ? true : false,
          validator: (val) {
            if (!isEmail!) {
              if (val == null) {
                return null;
              }
              if (val.length < valLength) {
                return valText;
              } else {
                return null;
              }
            } else {
              return emailValidation(val);
            }
          },
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: isPass
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                  )
                : null,
            border: InputBorder.none,
            // filled: true,
            //  fillColor: Colors.white,
            labelText: lablelText,
            hintText: hintText,
          ),
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context) async {
    final _form = _textFormKey.currentState;
    if (_form == null) {
      return null;
    }
    if (_form.validate()) {
      setState(() {
        _isLoading = true;
      });
      // UserModel userModel = UserModel();

      User? _user = await AuthenticationService()
          .signUp(
              timestamp: DateTime.now().toString(),
              email: _emailController.text,
              isAdmin: false,
              password: _passwordController.text,
              userName: _userNameController.text)
          .onError((error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
        errorToast(message: "$error");
        return null;
      });
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
      if (_user != null) {
        successToast(message: 'Successfully Registered');
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: ((context) => HomePage())));
      }
    }
  }
}

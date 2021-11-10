import 'package:flutter/material.dart';
import 'package:sketch_to_real/common_ui_functions.dart';
import 'package:sketch_to_real/constants.dart';
import 'package:sketch_to_real/tools/loading.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  final _textFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: backgroundColorBoxDecoration(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Hero(
                          tag: "logo",
                          child: Image.asset(
                            logo,
                            height: 90,
                          )),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          forgetPassPageIcon,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Hero(
                        tag: "passFor",
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Form(
                      key: _textFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GlassContainer(
                          opacity: 0.5,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            validator: (String? val) {
                              if (val == null) {
                                return null;
                              }
                              if (val.isEmpty) {
                                return "Field is Empty";
                              } else if (!val.contains("@") ||
                                  val.trim().length < 4) {
                                return "Invalid E-mail!";
                              } else {
                                return null;
                              }
                            },
                            // onSaved: (val) => phoneNo = val,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              labelText: "E-mail",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Please enter your valid E-mail",
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => handleForgetPass(),
                      child: buildSignUpLoginButton(
                          context: context,
                          btnText: "Continue",
                          hasIcon: false,
                          textColor: Colors.white,
                          color: const Color(0xff387A53), assetImage: ''),
                    ),
                  ],
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
      ),
    );
  }

  getPass({
    required String email,
  }) async {}

  handleForgetPass() async {
    final FormState? _form = _textFormKey.currentState;

    if (_form == null) {
      return null;
    }
    if (_form.validate()) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

import 'package:cinema_frontend/model/Model.dart';
import 'package:cinema_frontend/model/objects/LoginState.dart';
import 'package:cinema_frontend/model/objects/User.dart';
import 'package:cinema_frontend/model/support/CustomTheme.dart';
import 'package:cinema_frontend/model/support/LoginResult.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Login extends StatefulWidget{

  final emailRegex = new RegExp(r"\S+@\S+");
  final phoneRegex = new RegExp(r"[0-9]{10}");
  final passwordRegex = new RegExp(r"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})");

  @override
  State<StatefulWidget> createState() => _LoginState();

}

class _LoginState extends State<Login> {

  Container _signInButton;
  Container _registrationButton;

  final _registrationFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  
  final TextEditingController _signInEmail = TextEditingController();
  final TextEditingController _signInPassword = TextEditingController();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _registrationEmail = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirmation = TextEditingController();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _signInButton = _confirmationButton("SIGN IN", _signInFormKey, true);
    _registrationButton = _confirmationButton("REGISTER", _registrationFormKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.login, color: Colors.white,),
                text: "Already have an account? SIGN IN",
              ),
              Tab(
                icon: Icon(Icons.person_add),
                text: "REGISTER",
              )
            ],
          ),
        ),
          body: TabBarView(
            children: [
              Stack(
                children: [
                  CustomTheme.background,
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Form(
                      key: _signInFormKey,
                      child: Column(
                        children: [
                          _validationBox("Email", "Enter your email", Icons.email,
                            controller: _signInEmail),
                          SizedBox(height:20),
                          _validationBox("Password", "Enter your password", Icons.lock,
                              controller: _signInPassword, isPassword: true),
                          SizedBox(height: 20),
                          _signInButton
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  CustomTheme.background,
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Form(
                      key: _registrationFormKey,
                      child: ListView(
                        children: [
                          _validationBox(
                            "First name", "Enter your first name", Icons.contact_page,
                            controller: _firstName),
                          SizedBox(height: 20),
                          _validationBox(
                            "Last name", "Enter your last name", Icons.contact_page,
                            controller: _lastName),
                          SizedBox(height: 20),
                          _validationBox("Phone number", "e.g. 3481935235", Icons.phone,
                            controller: _phone),
                          SizedBox(height: 20),
                          _validationBox("Email", "Enter your email", Icons.email,
                            controller: _registrationEmail),
                          SizedBox(height: 20),
                          _validationBox("Address", "e.g. Via Guglielmo Marconi 7", Icons.home,
                            controller: _address),
                          SizedBox(height: 20),

                          Divider(color: Colors.white, indent: 20, endIndent: 20,),

                          SizedBox(height: 20),
                          _validationBox("Password", "Enter your password", Icons.lock,
                              controller: _password, isPassword: true),
                          SizedBox(height: 20),
                          _validationBox("Repeat password", "Repeat password", Icons.lock,
                              controller: _passwordConfirmation, isPassword: true),
                          SizedBox(height: 20),
                          _registrationButton
                        ],
                      ),
                    )
                  ),
                ],
              ),
            ],
          )
      )
    );
  }

  _validationBox(title, hint, icon, {controller, isPassword = false}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline2,
          ),
          SizedBox(height: 10),
          Container(
              alignment: Alignment.centerLeft,
              decoration: CustomTheme.inputFieldDecoration,
              height: 60,
              child: TextFormField(
                  obscureText: isPassword,
                  controller: controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 14),
                      prefixIcon: Icon(icon, color: Colors.white),
                      hintText: hint,
                      hintStyle: CustomTheme.inputFieldHintStyle,
                      errorStyle: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).accentColor)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "  *Mandatory field";
                    }
                    if (controller == _password && !widget.passwordRegex.hasMatch(_password.text))
                      return "  Password must be at least 8 characters long and contain a capital letter, a number and a special character";
                    if (controller == _passwordConfirmation &&
                        value != _password.text)
                      return "  Passwords don\'t match!";
                    if ((controller == _signInEmail || controller == _registrationEmail) && !widget.emailRegex.hasMatch(value))
                      return "  Please enter a valid email address";
                    if (controller == _phone && !widget.phoneRegex.hasMatch(value))
                      return "  Please enter a valid phone number";
                    return null;
                  }
              )
          )
        ]
    );
  }

  _confirmationButton(text, key, enabled) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
          child: Container(
            child: Text(text)
          ),
        onPressed: !enabled ? null : () {
          if (!key.currentState.validate()) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(
                'Some of the values entered are not valid. Please correct and try again.')));
          }
          else if (key == _signInFormKey){
            setState(() {
              _signInButton = _loadingButton();
            });
            Model.sharedInstance.logIn(_signInEmail.text, _signInPassword.text).then((result) {
              switch(result) {
                case LoginResult.LOGGED:

                // aggiorna lo stato globale dell'applicazione con l'utente corrente
                  context.read<LoginState>().setLoginState(true);

                  Model.sharedInstance.getUserByEmail(_signInEmail.text)
                      .then((user) => Provider.of<LoginState>(context, listen: false).setCurrentUser(user));

                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text("Sign in successful!"),
                    content: Text("You can now select and purchase tickets"),
                    actions: [
                      TextButton(onPressed:() {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                          child: Text("OK"))
                    ],
                  ));
                  break;
                case LoginResult.ERROR_WRONG_CREDENTIALS:
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text("Sign in failed"),
                    content: Text("Your email or password are incorrect.\nPlease try again."),
                    actions: [
                      TextButton(
                        onPressed:() {
                          Navigator.of(context).pop();
                          _resetSignInButton();
                        },
                        child: Text("OK")
                      )
                    ],
                  ));
                  break;
                case LoginResult.ERROR_NOT_FULLY_SETUP:
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text("Sign in failed"),
                    content: Text("Your account is not fully setup.\nPlease check your inbox and follow the instruction."),
                    actions: [
                      TextButton(
                        onPressed:() {
                          Navigator.of(context).pop();
                          _resetSignInButton();
                        },
                        child: Text("OK")
                      )
                    ],
                  ));
                  break;
                default:
                  showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
                    title: Text("Sign in failed"),
                    content: Text("Sorry. There was an error while communicating with server.\nCheck your internet connection and try again."),
                    actions: [
                      TextButton(
                        onPressed:() {
                          Navigator.of(context).pop();
                          _resetSignInButton();
                        },
                        child: Text("OK")
                      )
                    ],
                  ));
              }
            }).onError((error, stackTrace) => showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("Sign in failed"),
              content: Text("Sorry. We couldn't find your account.\nIf you haven't got one, please register, else check your credentials and try again"),
              actions: [
                TextButton(
                  onPressed:() {
                    Navigator.of(context).pop();
                    _resetSignInButton();
                  },
                  child: Text("OK")
                )
              ],
            )));
          }
          else if (key == _registrationFormKey) {
            User user = new User(
                email: _registrationEmail.text,
                address: _address.text,
                phoneNumber: _phone.text,
                firstName: _firstName.text,
                lastName: _lastName.text
            );

            Model.sharedInstance.createUser(user, _password.text, "user")
                .then((value) {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: Text("Account successfully created!"),
                content: Text("Please sign in with your new credentials"),
                actions: [
                  TextButton(
                      onPressed:() {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text("OK")
                  )
                ],
              ));
            })
                .onError((error, stackTrace) => showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("ERROR"),
              content: Text("${error.toString()}"),
              actions: [
                TextButton(
                    onPressed:() {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK")
                )
              ],
            ))
            );
          }
        }
      ),
    );
  }

  void _resetSignInButton() {
    setState(() {
      _signInButton = _confirmationButton("SIGN IN", _signInFormKey, true);
    });
  }

  Container _loadingButton(){
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PLEASE WAIT", style: Theme.of(context).textTheme.headline2,),
            SizedBox(height: 10,),
            LinearProgressIndicator(color: Theme.of(context).accentColor,)
          ],
        ),
      ),
    );
  }

}
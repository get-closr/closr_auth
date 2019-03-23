import 'package:closrauth/utils/auth.dart';
import 'package:closrauth/utils/password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class PersonData {
  String username = '';
  String email = '';
  String password = '';
}

class LoginSignupScreen extends StatefulWidget {
  LoginSignupScreen({this.auth, this.onSignedIn, this.onSignedUp});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onSignedUp;

  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passworldFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FormMode _formMode = FormMode.LOGIN;
  String _status;
  PersonData person = PersonData();

  bool _isLoading;
  bool _autoValidate = false;
  bool _formWasEditted = false;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
      showInSnackBar('Please fix the rrors in red before submitting');
    } else {
      form.save();
      showInSnackBar('${person.username}');
    }
  }

  String _validatePassword(String value) {
    _formWasEditted = true;
    final FormFieldState<String> passwordField =
        _passworldFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.isEmpty)
      return 'Please enter a password.';
    if (passwordField.value != value) return 'The passwords don\'t match.';
    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEditted || form.validate()) return true;

    return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('This form has errors'),
                content: const Text('Really leave this form?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  )
                ],
              );
            }) ??
        false;
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //TODO: reorganize validateAndSubmit
  void _validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    if (_validateAndSave()) {
      try {
        if (_formMode == FormMode.LOGIN) {
          if (await widget.auth.signInEmail(person.email, person.password) == true) {
            person.username = await widget.auth.username();
            setState(() {
              _status = "Signed In";
            });
            if (person.username.length > 0 && person.username!=null) {
              widget.onSignedIn();
            }
          } else {
            setState(() {
              _status = "Could not sign in";
            });
          }
        } else {
          if (await widget.auth.signUpEmail(person.email, person.password) == true) {
            person.username = await widget.auth.username();
            setState(() {
              _status = "Signed up new user";
            });
            if (person.username.length > 0 && person.username != null) {
              widget.onSignedUp();
            }
          } else {
            setState(() {
              _status = "Sign up failed";
            });
          }
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
    _status = "Not Authenticated";
  }

  void _signInGoogle() async {
    if (await widget.auth.signInGoogle() == true) {
      person.username = await widget.auth.username();
      setState(() {
        _status = "Signed In";
      });
      //TODO: Check if user exists, return on Sign up or on Signed in.
      widget.onSignedIn();
    } else {
      setState(() {
        _status = "Could not sign in";
      });
    }
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  Widget _logo(logoSize) {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: logoSize,
        child: Image.asset(
          'lib/asset/images/Closr_grey_01.png',
        ),
      ),
    );
  }

  Widget _emailInput() {
    return TextFormField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "Email",
          icon: Icon(Icons.mail),
        ),
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        validator: (val) {
          if (val.isEmpty) return "Email can't be empty";
          if (!val.contains('@')) return "Email is not valid";
        },
        onSaved: (String value) => person.email = value);
  }

  Widget _passwordInput() {
    return _formMode == FormMode.LOGIN
        ? TextFormField(
            decoration:
                InputDecoration(hintText: "Password", icon: Icon(Icons.lock)),
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            validator: (value) =>
                value.isEmpty ? 'Password can\'t be empty,' : null,
            onSaved: (value) => person.password = value)
        : _passwordSignup();
  }

  Widget _passwordSignup() {
    return Column(
      children: <Widget>[
        PasswordField(
            fieldKey: _passworldFieldKey,
            helperText: 'No more than 8 characters.',
            labelText: 'Password *',
            onFieldSubmitted: (value) {
              setState(() {
                person.password = value;
              });
            }),
        Text(person.password),
        TextFormField(
          enabled: person.password != null && person.password.isNotEmpty,
          decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: "Confirm Password",
              icon: Icon(Icons.lock),
          ),
          maxLength: 8,
          obscureText: true,
          validator: _validatePassword,
        )
      ],
    );
  }

  Widget _primaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 20,
        child: RaisedButton(
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: Theme.of(context).buttonColor,
          child: _formMode == FormMode.LOGIN
              ? Text('Login'): Text('Create Account'),
          onPressed: _handleSubmitted,
        ),
      ),
    );
  }

  Widget _switchButton() {
    return FlatButton(
      child: _formMode == FormMode.LOGIN
          ? Text('Create an account')
          : Text('Have an account? Sign in'),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _socialSignIn() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SignInButton(Buttons.Google, onPressed: _signInGoogle),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            onWillPop: _warnUserAboutInvalidData,
            child: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.down,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(_status),
                  _logo(140.0),
                  _emailInput(),
                  _passwordInput(),
                  _primaryButton(),
                  _switchButton(),
                  Divider(
                    height: 5.0,
                  ),
                  Center(child: Text("OR")),
                  Divider(
                    height: 5.0,
                  ),
                  _socialSignIn(),
                ],
              ),
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;
    double width = media.width.toDouble();
    double padding = (width - 300) / 2;
    return Scaffold(
      body: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
            child: Column(
              children: <Widget>[
                _loginForm(),
              ],
            ),
          )),
    );
  }
}

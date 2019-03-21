import 'package:closrauth/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

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
  FormMode _formMode = FormMode.LOGIN;

  String _status;
  String _username;
  String _email;
  String _password;

  bool _isLoading;
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    if (_validateAndSave()) {
      try {
        if (_formMode == FormMode.LOGIN) {
          if (await widget.auth.signInEmail(_email, _password) == true) {
            _username = await widget.auth.username();
            setState(() {
              _status = "Signed In";
            });
            if (_username.length > 0 && _username != null) {
              widget.onSignedIn();
            }
          } else {
            setState(() {
              _status = "Could not sign in";
            });
          }
        } else {
          if (await widget.auth.signUpEmail(_email, _password) == true) {
            _username = await widget.auth.username();
            setState(() {
              _status = "Signed up new user";
            });
            if (_username.length > 0 && _username != null) {
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
      _username = await widget.auth.username();
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

  Widget _showLogo(logoSize) {
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

  Widget _showEmailInput() {
    return TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(hintText: "Email", icon: Icon(Icons.mail)),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty,' : null,
        onSaved: (value) => _email = value);
  }

  Widget _showPasswordInput() {
    return TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration:
            InputDecoration(hintText: "Password", icon: Icon(Icons.lock)),
        validator: (value) =>
            value.isEmpty ? 'Password can\'t be empty,' : null,
        onSaved: (value) => _password = value);
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 20,
        child: RaisedButton(
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: Theme.of(context).buttonColor,
          child: _formMode == FormMode.LOGIN
              ? Text(
                  'Login',
                )
              : Text(
                  'Create Account',
                ),
          onPressed: _validateAndSubmit,
        ),
      ),
    );
  }

  Widget _showSwitchButton() {
    return FlatButton(
      child: _formMode == FormMode.LOGIN
          ? Text('Create an account')
          : Text('Have an account? Sign in'),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showSocialSignIn() {
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
    return AccentColorOverride(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Text(_status),
                // Text(_username),
                _showLogo(150.0),
                _showEmailInput(),
                _showPasswordInput(),
                _showPrimaryButton(),
                _showSwitchButton(),
                Divider(
                  height: 5.0,
                ),
                Center(child: Text("OR")),
                Divider(
                  height: 5.0,
                ),
                _showSocialSignIn(),
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
          bottom: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // _showCircularProgress(),
                _loginForm(),
              ],
            ),
          )),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(accentColor: color),
    );
  }
}

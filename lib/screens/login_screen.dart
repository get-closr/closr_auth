// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:closr_auth/utils/auth.dart' as fbAuth;

class LoginSignupScreen extends StatefulWidget {
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  FormMode _formMode = FormMode.LOGIN;

  // String _username;
  String _status;

  String _email;
  String _password;
  String _errorMessage;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _status = "Not Authenticated";
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
          onPressed: () {},
          // onPressed: _validateAndSubmit,
        ),
      ),
    );
  }

  Widget _showSwitchButton() {
    return FlatButton(
      child: _formMode == FormMode.LOGIN
          ? Text('Create an account')
          : Text('Have an account? Sign in'),
      onPressed: () {},
      // onPressed: _formMode == FormMode.LOGIN ? _changeFormToSignUp: _changeFormToLogin,
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
          SignInButton(
            Buttons.Google,
            onPressed: () {},
          ),
          //TODO  figure out auth with FB. But low on priority
          SignInButton(
            Buttons.Facebook,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _showLogo(logoSize) {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: logoSize,
        child: Image.asset(
          'lib/asset/images/Closr_grey_01.png',
          color: Theme.of(context).primaryIconTheme.color,
        ),
      ),
    );
  }

  Widget _showBody() {
    return AccentColorOverride(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
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
                Text(_status),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: null,
                      child: Text("Sign In"),
                    ),
                    RaisedButton(
                      onPressed: null,
                      child: Text("Sign In Google"),
                    )
                  ],
                ),
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
    // double logoSize = width / 2.5;
    return Scaffold(
      body: SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // _showCircularProgress(),
                _showBody(),
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

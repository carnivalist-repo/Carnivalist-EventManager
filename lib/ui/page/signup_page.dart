import 'package:eventmanagement/bloc/signup/sign_up_bloc.dart';
import 'package:eventmanagement/bloc/signup/sign_up_state.dart';
import 'package:eventmanagement/bloc/user/user_bloc.dart';
import 'package:eventmanagement/intl/app_localizations.dart';
import 'package:eventmanagement/utils/extensions.dart';
import 'package:eventmanagement/utils/vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  @override
  createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _validate = false;
  bool visible = true;

  SignUpBloc _signUpBloc;
  UserBloc _userBloc;

  @override
  void initState() {
    super.initState();

    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(children: [
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(backgroundImage), fit: BoxFit.cover))),
      Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black.withOpacity(0.2),
          body: Form(key: _key, autovalidate: _validate, child: _signUpBody()))
    ]));
  }

  _signUpBody() => ListView(children: <Widget>[
        SizedBox(height: 40),
        Image.asset(logoImage, scale: 2.0),
        SizedBox(height: 40),
        Container(
            margin: EdgeInsets.all(20),
            child: Card(
                child: Container(
                    margin: EdgeInsets.only(
                        top: 15, bottom: 2, right: 15, left: 15),
                    child: Column(children: <Widget>[
                      Text(AppLocalizations
                          .of(context)
                          .titleSignUp,
                          textAlign: TextAlign.center,
                          style: (TextStyle(
                              fontSize: 19,
                              color: colorTitle,
                              fontFamily: montserratBoldFont))),
                      _firstNameInput(),
                      _phoneNoInput(),
                      _emailInput(),
                      _passwordInput(),
                      _confirmPasswordInput(),
                      SizedBox(height: 15),
                      _signUpButton(),
                      RawMaterialButton(
                          padding: EdgeInsets.all(10),
                          child: Text(
                              AppLocalizations
                                  .of(context)
                                  .labelSignUpAgreement,
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: colorTitle, fontSize: 10.0)),
                          onPressed: () {})
                    ])),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          InkWell(
              child: Container(
                  padding: EdgeInsets.all(0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          AppLocalizations
                              .of(context)
                              .labelAlredyAccount,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center)))),
          InkWell(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(AppLocalizations
                          .of(context)
                          .labelSignIn,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center))),
              onTap: () => Navigator.pop(context))
        ])
      ]);

  _firstNameInput() => BlocBuilder(
      bloc: _signUpBloc,
      builder: (BuildContext context, SignUpState state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: widget.inputField(_firstNameController,
              labelText: AppLocalizations
                  .of(context)
                  .inputHintFirstName,
              onChanged: _signUpBloc.nameInput,
              validation: validateName,
              keyboardType: TextInputType.text)));

  _phoneNoInput() => BlocBuilder(
      bloc: _signUpBloc,
      builder: (BuildContext context, SignUpState state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: widget.inputField(_phoneNoController,
              labelText: AppLocalizations
                  .of(context)
                  .inputHintPhoneNo,
              onChanged: _signUpBloc.mobileInput,
              maxLength: 10,
              validation: validateMobile,
              keyboardType: TextInputType.number)));

  _emailInput() => BlocBuilder(
      bloc: _signUpBloc,
      builder: (BuildContext context, SignUpState state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: widget.inputField(_emailController,
              labelText: AppLocalizations
                  .of(context)
                  .inputHintEmail,
              validation: validateEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: _signUpBloc.emailInput)));

  _passwordInput() => BlocBuilder(
      bloc: _signUpBloc,
      builder: (BuildContext context, SignUpState state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: widget.inputField(_passwordController,
              labelText: AppLocalizations
                  .of(context)
                  .inputHintPassword,
              onChanged: _signUpBloc.passwordInput,
              validation: validatePassword,
              maxLength: 20,
              obscureText: visible,
              inkWell: InkWell(
                  child:
                      Icon(visible ? Icons.visibility_off : Icons.visibility),
                  onTap: () => setState(() => visible = !visible)))));

  _confirmPasswordInput() => BlocBuilder(
      bloc: _signUpBloc,
      builder: (BuildContext context, SignUpState state) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: widget.inputField(_confirmPasswordController,
              labelText: AppLocalizations
                  .of(context)
                  .inputHintConfirmPassword,
              onChanged: _signUpBloc.passwordInput,
              obscureText: visible, validation: (confirmation) {
            return confirmation.isEmpty
                ? 'Confirm password is required'
                : confirmation.length < 4
                    ? 'Confirm password at least 4 characters'
                    : validationEqual(confirmation, _passwordController.text)
                        ? null
                        : 'Password and confirm password not match';
          },
              maxLength: 20,
              inkWell: InkWell(
                  child:
                      Icon(visible ? Icons.visibility_off : Icons.visibility),
                  onTap: () => setState(() => visible = !visible)))));

  _signUpButton() => GestureDetector(
      onTap: () => _signUpValidate(),
      child: Container(
          height: 40,
          width: 110.0,
          child: Align(
              alignment: Alignment.center,
              child: Text(AppLocalizations
                  .of(context)
                  .btnSignUp
                  .toUpperCase(),
                  style: new TextStyle(color: Colors.white, fontSize: 14.0))),
          decoration: buttonBg()));

  _signUpValidate() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      _signUpToApi();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  _signUpToApi() async {
    FocusScope.of(context).requestFocus(FocusNode());
    context.showProgress(context);

    _signUpBloc.signUp((results) {
      context.hideProgress(context);

      var signUpResponse = results;
      if (signUpResponse.code == apiCodeSuccess) {
        _userBloc.saveUserName(_firstNameController.text);
        _userBloc.saveEmail(_emailController.text);
        _userBloc.saveMobile(_phoneNoController.text);
        _userBloc.saveProfilePicture('');
        _userBloc.saveUserId('');
        _userBloc.savAuthToken(signUpResponse.token);
        _userBloc.saveIsLogin(true);
        _userBloc.getLoginDetails();

        Navigator.of(context).pushNamedAndRemoveUntil(
            bottomMenuRoute, (Route<dynamic> route) => false);
      } else {
        context.toast(signUpResponse.message);

        _phoneNoController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }
}

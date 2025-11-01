// ignore_for_file: file_names
import 'package:flutter_project/database/databse_helper.dart';
import 'package:flutter_project/class/Globals.dart';
import 'package:flutter_project/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  const AuthActionButton({super.key, required this.isLogin, required this.reload});
  final bool isLogin;
  final Function reload;

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final TextEditingController _userTextEditingController = TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController = TextEditingController(text: '');

  Future _signUp(context) async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: [],
    );
    await databaseHelper.insert(userToSave);
    widget.reload();
  }

  Future _signIn(context) async {
    // For now we don't have prediction; sign-in should validate against DB via caller if needed.
    // Here we simply close the sheet; integrate real auth as needed.
    Navigator.of(context).pop();
  }

  void _openSignSheet() {
    Scaffold.of(context).showBottomSheet((context) => signSheet(context));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openSignSheet,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withAlpha(26),
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'AUTH',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(Icons.login, color: Colors.white)
          ],
        ),
      ),
    );
  }

  Container signSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin
              ? Container(
                  child: const Text(
                    '請輸入帳號與密碼登入',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : Container(),
          Container(
            child: Column(
              children: [
                if (!widget.isLogin)
                  AppTextField(
                    controller: _userTextEditingController,
                    labelText: 'Your Name',
                  ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _passwordTextEditingController,
                  labelText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                widget.isLogin
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          await _signIn(context);
                        },
                        icon: const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : AppButton(
                        text: 'SIGN UP',
                        onPressed: () async {
                          await _signUp(context);
                        },
                        icon: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

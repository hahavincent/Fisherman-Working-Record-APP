import 'package:flutter_project/class/Globals.dart';
import 'package:flutter_project/widgets/app_button.dart';
import 'package:flutter_project/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet({super.key, required this.user});
  final User user;

  final _passwordController = TextEditingController();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      //登入成功!
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => Profile(
      //               user.user,
      //               imagePath: _cameraService.imagePath!,
      //             )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Welcome back, ${user.user}.',
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [
              SizedBox(height: 10),
              AppTextField(
                controller: _passwordController,
                labelText: "Password",
                isPassword: true,
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              AppButton(
                text: 'LOGIN',
                onPressed: () async {
                  _signIn(context, user);
                },
                icon: Icon(
                  Icons.login,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

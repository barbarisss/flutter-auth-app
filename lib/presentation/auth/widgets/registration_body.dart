import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_app/core/utils/colors.dart';
import 'package:flutter_auth_app/core/utils/icons.dart';
import 'package:flutter_auth_app/presentation/shared_widgets/custom_button.dart';
import 'package:flutter_auth_app/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistrationBody extends StatefulWidget {
  const RegistrationBody({super.key});

  @override
  State<RegistrationBody> createState() => _RegistrationBodyState();
}

class _RegistrationBodyState extends State<RegistrationBody> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  String _verificationCode = '';

  @override
  void dispose() {
    _numberController.dispose();
    _smsCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Text(
          'Регистрация нового аккаунта',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 40.h),
        CustomTextField(
          labelText: 'Номер телефона',
          inputType: InputType.phoneNumber,
          controller: _numberController,
        ),
        SizedBox(height: 40.h),
        CustomButtonWidget(
          title: 'Выслать SMS-код',
          isElevated: true,
          onPressed: () => phoneAuth(
            _numberController.text,
          ),
        ),
        SizedBox(height: 18.h),
        CustomButtonWidget(
          title: 'Выслать повторно',
          isElevated: false,
          onPressed: () {},
        ),
        SizedBox(height: 50.h),
        CustomTextField(
          labelText: 'Код из SMS',
          inputType: InputType.smsCode,
          controller: _smsCodeController,
        ),
        SizedBox(height: 46.h),
        const _CheckFieldWidget(),
        SizedBox(height: 46.h),
        CustomButtonWidget(
          title: 'Далее',
          isElevated: true,
          onPressed: () => signIn(
            _verificationCode,
            _smsCodeController.text,
          ),
        ),
      ],
    );
  }

  void phoneAuth(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          _verificationCode = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    print('успешнооо');
  }

  void signIn(String verificationCode, String smsCode) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
        verificationId: verificationCode,
        smsCode: smsCode,
      ))
          .then((value) async {
        if (value.user != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Юзер зареган')));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _CheckFieldWidget extends StatefulWidget {
  const _CheckFieldWidget({super.key});

  @override
  State<_CheckFieldWidget> createState() => RregisterCheckboxFieldStateWidget();
}

class RregisterCheckboxFieldStateWidget extends State<_CheckFieldWidget> {
  var isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: checkboxTap,
          child: SvgPicture.asset(
            isPressed ? AppIcons.checkboxPressed : AppIcons.checkboxEnabled,
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 18.h / 12.sp,
            ),
            children: const [
              TextSpan(
                text: 'Ознакомлен с ',
              ),
              TextSpan(
                text: 'Договором оферты',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: '\nи согласен на ',
              ),
              TextSpan(
                text: 'Рассылку',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void checkboxTap() {
    setState(() {
      isPressed = !isPressed;
    });
  }
}

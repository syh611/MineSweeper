import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final nicknameCtrl = TextEditingController();
  final loverNameCtrl = TextEditingController();
  String gender = 'female';

  Future<void> register() async {
    try {
      final auth = await Supabase.instance.client.auth.signUp(email: emailCtrl.text.trim(), password: pwdCtrl.text, data: {
        'nickname': nicknameCtrl.text.trim(),
        'gender': gender,
        'lover_alias': loverNameCtrl.text.trim(),
      });
      final uid = auth.user?.id;
      if (uid == null) return;

      await Supabase.instance.client.from('profiles').upsert({
        'id': uid,
        'nickname': nicknameCtrl.text.trim(),
        'gender': gender,
        'lover_alias': loverNameCtrl.text.trim().isEmpty ? null : loverNameCtrl.text.trim(),
      });
      if (mounted) context.go('/pairing');
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('创建账号')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CupertinoTextField(controller: emailCtrl, placeholder: '账号邮箱'),
            const SizedBox(height: 10),
            CupertinoTextField(controller: pwdCtrl, placeholder: '密码', obscureText: true),
            const SizedBox(height: 10),
            CupertinoTextField(controller: nicknameCtrl, placeholder: '昵称'),
            const SizedBox(height: 10),
            CupertinoSlidingSegmentedControl<String>(
              groupValue: gender,
              children: const {'female': Text('女'), 'male': Text('男')},
              onValueChanged: (v) => setState(() => gender = v ?? 'female'),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(controller: loverNameCtrl, placeholder: '给伴侣的专属称呼（可选）'),
            const SizedBox(height: 20),
            CupertinoButton.filled(onPressed: register, child: const Text('注册并继续')),
          ],
        ),
      ),
    );
  }
}

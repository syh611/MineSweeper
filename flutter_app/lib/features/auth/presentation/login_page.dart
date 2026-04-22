import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: emailCtrl.text.trim(), password: pwdCtrl.text);
      if (mounted) context.go('/tasks');
    } catch (e) {
      _toast('登录失败：$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _toast(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(title: const Text('提示'), content: Text(msg), actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('知道了'))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('恋爱任务簿')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CupertinoTextField(controller: emailCtrl, placeholder: '账号邮箱'),
              const SizedBox(height: 12),
              CupertinoTextField(controller: pwdCtrl, placeholder: '密码', obscureText: true),
              const SizedBox(height: 20),
              CupertinoButton.filled(onPressed: loading ? null : login, child: Text(loading ? '登录中...' : '登录')),
              CupertinoButton(onPressed: () => context.push('/register'), child: const Text('没有账号？去注册')),
            ],
          ),
        ),
      ),
    );
  }
}

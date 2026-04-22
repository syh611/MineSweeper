import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      if (mounted) context.go(hasSession ? '/tasks' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: Text('恋爱任务簿', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({super.key});

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final codeCtrl = TextEditingController();

  Future<void> bindPartner() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser!.id;
    final target = await client.from('profiles').select('id, gender').eq('pair_code', codeCtrl.text.trim()).maybeSingle();
    if (target == null) return;
    if (target['id'] == uid) return;

    await client.from('partner_links').insert([
      {'user_id': uid, 'partner_id': target['id'], 'partner_gender': target['gender']},
    ]);
    if (mounted) context.go('/tasks');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('配对绑定')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('输入另一半配对码，绑定后任务将只在你们之间流转。'),
              const SizedBox(height: 12),
              CupertinoTextField(controller: codeCtrl, placeholder: '输入配对码'),
              const SizedBox(height: 16),
              CupertinoButton.filled(onPressed: bindPartner, child: const Text('完成绑定')),
            ],
          ),
        ),
      ),
    );
  }
}

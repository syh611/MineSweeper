import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final aliasCtrl = TextEditingController();

  Future<void> saveAlias() async {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('profiles').update({'lover_alias': aliasCtrl.text.trim()}).eq('id', uid);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('个人资料')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CupertinoTextField(controller: aliasCtrl, placeholder: '伴侣专属称呼'),
              const SizedBox(height: 12),
              CupertinoButton.filled(onPressed: saveAlias, child: const Text('保存')),
            ],
          ),
        ),
      ),
    );
  }
}

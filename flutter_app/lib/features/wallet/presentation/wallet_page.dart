import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../tasks/data/task_repository.dart';

final walletProvider = FutureProvider((ref) async {
  final uid = ref.watch(supabaseClientProvider).auth.currentUser!.id;
  return ref.watch(supabaseClientProvider).from('wallets').select('*, user_streaks(*), user_badges(badge_id,badges(name,icon))').eq('user_id', uid).single();
});

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('货币')),
      child: SafeArea(
        child: ref.watch(walletProvider).when(
              data: (w) {
                final isFemale = w['currency_name'] == '菲币';
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('当前余额', style: TextStyle(color: CupertinoColors.systemGrey.resolveFrom(context))),
                        Text('${w['balance']} ${w['currency_name']}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isFemale ? AppTheme.roseGold : AppTheme.deepBlue)),
                        Text('累计获得 ${w['total_earned']}'),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(child: Text('连续完成：${w['user_streaks']['current_streak']} 天 / 最长 ${w['user_streaks']['longest_streak']} 天')),
                    const SizedBox(height: 12),
                    const Text('已解锁徽章', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
      ),
    );
  }
}

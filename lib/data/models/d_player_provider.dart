import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'd_player.dart';

final dPlayerProvider = FutureProvider<void>((ref) async {
  await DPlayer.loadData();
});

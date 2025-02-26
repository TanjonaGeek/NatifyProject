import 'package:natify/features/Storie/presentation/provider/state/storie_notifier.dart';
import 'package:natify/features/Storie/presentation/provider/state/storie_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final storieStateNotifier =
    StateNotifierProvider<StorieNotifier, StorieState>(
        (ref) => StorieNotifier());

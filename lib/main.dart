import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/ai_valuation/data/mock_valuation_repository.dart';
import 'features/ai_valuation/domain/repositories/valuation_repository.dart';
import 'features/lottery/data/local_coupon_repository.dart';
import 'features/lottery/domain/coupon_repository.dart';
import 'features/lottery/presentation/cubit/coupon_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        // Real API tayyor bo'lganda faqat shu qator o'zgaradi:
        // ApiValuationRepository(dio) <- ValuationRepository
        RepositoryProvider<ValuationRepository>(
          create: (_) => const MockValuationRepository(),
        ),
        RepositoryProvider<CouponRepository>(
          create: (_) => LocalCouponRepository(prefs),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CouponCubit(context.read<CouponRepository>())..load(),
          ),
        ],
        child: const AbozorChallengeApp(),
      ),
    ),
  );
}

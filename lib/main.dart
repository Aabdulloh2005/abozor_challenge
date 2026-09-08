import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'features/ai_valuation/data/mock_valuation_repository.dart';
import 'features/ai_valuation/domain/repositories/valuation_repository.dart';
import 'features/prizes/presentation/cubit/participation_cubit.dart';

void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        // Real API tayyor bo'lganda faqat shu qator o'zgaradi:
        // ApiValuationRepository(dio) <- ValuationRepository
        RepositoryProvider<ValuationRepository>(
          create: (_) => const MockValuationRepository(),
        ),
      ],
      child: BlocProvider(
        create: (_) => ParticipationCubit(),
        child: const AbozorChallengeApp(),
      ),
    ),
  );
}

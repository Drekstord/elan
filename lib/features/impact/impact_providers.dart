import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'domain/impact_summary.dart';

final impactSummaryProvider = Provider<ImpactSummary>(
  (ref) => ImpactSummary.of(ref.watch(coursesProvider).value ?? const []),
);

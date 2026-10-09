import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'domain/personal_records.dart';

final personalRecordsProvider = Provider<PersonalRecords>(
  (ref) => PersonalRecords.compute(ref.watch(coursesProvider).value ?? const []),
);

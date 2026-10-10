import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../features/courses/data/course_repository.dart';
import '../features/courses/domain/course.dart';
import 'backend/backend.dart';
import 'database/database.dart';
import 'legacy/legacy_import.dart';
import 'media/media_store.dart';
import 'sync/remote_gateway.dart';
import 'sync/sync_engine.dart';

// ---------------------------------------------------------------------
// Application
// ---------------------------------------------------------------------

/// Dossier de données de l'application, résolu dans `main` avant le démarrage.
final appDirectoryProvider = Provider<Directory>((ref) => throw UnimplementedError('appDirectoryProvider non fourni'));

/// Serveur auquel l'app est reliée, ouvert par la racine de l'app (app/server_root.dart).
final backendProvider = Provider<Backend>((ref) => throw UnimplementedError('backendProvider non fourni'));

final currentUserProvider = StreamProvider<BackendUser?>((ref) async* {
  final backend = ref.watch(backendProvider);
  yield backend.currentUser;
  yield* backend.userChanges;
});

final userIdProvider = Provider<String?>((ref) => ref.watch(currentUserProvider).value?.id);

// ---------------------------------------------------------------------
// Espace de l'utilisateur connecté (recréé si le compte change)
// ---------------------------------------------------------------------

String _requireUserId(Ref ref) => ref.watch(userIdProvider) ?? (throw StateError('Aucun utilisateur connecté'));

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.forUser(ref.watch(appDirectoryProvider), _requireUserId(ref));
  ref.onDispose(db.close);
  return db;
});

final mediaStoreProvider = Provider<MediaStore>(
  (ref) => MediaStore(Directory(p.join(ref.watch(appDirectoryProvider).path, 'media')), _requireUserId(ref)),
);

final remoteGatewayProvider = Provider<RemoteGateway>((ref) => ref.watch(backendProvider).gateway);

final syncEngineProvider = Provider<SyncEngine>(
  (ref) =>
      SyncEngine(ref.watch(databaseProvider), ref.watch(remoteGatewayProvider), media: ref.watch(mediaStoreProvider)),
);

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(
    ref.watch(databaseProvider),
    media: ref.watch(mediaStoreProvider),
    onLocalChange: () => ref.read(syncControllerProvider.notifier).schedule(),
  ),
);

final coursesProvider = StreamProvider<List<Course>>((ref) => ref.watch(courseRepositoryProvider).watchCourses());

final pendingCountProvider = StreamProvider<int>((ref) => ref.watch(courseRepositoryProvider).watchPendingCount());

/// Préparation de la session : reprise des données v1 puis première synchro.
/// Retourne le nombre de courses importées depuis la v1.
final sessionBootstrapProvider = FutureProvider<int>((ref) async {
  final imported = await LegacyImport.runIfNeeded(
    repository: ref.watch(courseRepositoryProvider),
    media: ref.watch(mediaStoreProvider),
  );
  unawaited(ref.read(syncControllerProvider.notifier).sync());
  return imported;
});

// ---------------------------------------------------------------------
// Synchronisation
// ---------------------------------------------------------------------

enum SyncPhase { idle, syncing, error }

class SyncState {
  final SyncPhase phase;
  final String? error;
  final DateTime? lastSuccess;

  const SyncState({this.phase = SyncPhase.idle, this.error, this.lastSuccess});

  SyncState copyWith({SyncPhase? phase, String? error, DateTime? lastSuccess}) =>
      SyncState(phase: phase ?? this.phase, error: error, lastSuccess: lastSuccess ?? this.lastSuccess);
}

class SyncController extends Notifier<SyncState> {
  static const Duration debounce = Duration(seconds: 2);

  Timer? _timer;
  bool _again = false;

  @override
  SyncState build() {
    final engine = ref.watch(syncEngineProvider);
    ref.onDispose(() => _timer?.cancel());
    engine.lastSuccess().then((last) {
      if (ref.mounted && last != null) state = state.copyWith(lastSuccess: last, error: state.error);
    });
    return const SyncState();
  }

  /// Synchro groupée quelques secondes après la dernière modification.
  void schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, sync);
  }

  Future<void> sync() async {
    _timer?.cancel();
    if (state.phase == SyncPhase.syncing) {
      _again = true;
      return;
    }
    final engine = ref.read(syncEngineProvider);
    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      do {
        _again = false;
        await engine.run();
      } while (_again);
      if (ref.mounted) state = state.copyWith(phase: SyncPhase.idle, lastSuccess: DateTime.now().toUtc());
    } catch (e) {
      if (ref.mounted) state = state.copyWith(phase: SyncPhase.error, error: describeSyncError(e));
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);

/// Fichier local d'une photo (téléchargée depuis le cloud si absente du cache).
final photoFileProvider = FutureProvider.family<File?, String>(
  (ref, key) => ref.watch(syncEngineProvider).photoFile(key),
);

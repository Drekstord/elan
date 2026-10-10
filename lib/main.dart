import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/server_root.dart';
import 'core/backend/backend.dart';
import 'core/server/server_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Serveur personnel choisi dans l'app, sinon celui de la compilation (config/supabase.json).
  final prefs = await SharedPreferences.getInstance();
  final store = ServerStore(prefs);
  final server = store.active;
  final backend = server == null ? null : await Backend.connect(server, prefs);
  final dataDir = await getApplicationSupportDirectory();

  runApp(ServerRoot(store: store, dataDir: dataDir, initial: server, initialBackend: backend));
}

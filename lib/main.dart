import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/server_root.dart';
import 'core/server/server_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');

  // Serveur personnel choisi dans l'app, sinon celui de la compilation (config/supabase.json).
  final store = ServerStore(await SharedPreferences.getInstance());
  final server = store.active;
  if (server != null) await connectTo(server);
  final dataDir = await getApplicationSupportDirectory();

  runApp(ServerRoot(store: store, dataDir: dataDir, initial: server));
}

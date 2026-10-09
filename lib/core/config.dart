/// Configuration injectée à la compilation :
///   flutter run --dart-define-from-file=config/supabase.json
///
/// La clé publishable est publique par conception : la sécurité repose sur
/// l'authentification et les politiques RLS côté Supabase.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') && !supabaseUrl.contains('VOTRE-PROJET') && supabaseKey.length > 20;

  static const String mediaBucket = 'course-media';
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gottani_mobile/app/app.dart';
import 'package:gottani_mobile/app/scope.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://xtonbuotgkrqivkingvn.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0b25idW90Z2tycWl2a2luZ3ZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA1MDY1MzUsImV4cCI6MjA0NjA4MjUzNX0.KJK7zoxh1HG3QvcLdRt9gaA7mA3eHZClIPQtJVyC8Hg';
Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) => {};
  }

  runApp(
    const AppScope(child: App()),
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gottani_mobile/app/app.dart';
import 'package:gottani_mobile/app/scope.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://xtonbuotgkrqivkingvn.supabase.co';
const supabaseKey = '';
Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) => {};
  }

  runApp(
    const AppScope(child: App()),
  );
}

# SQLite (sqlite3_flutter_libs) is loaded through JNI/FFI; keep its classes.
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Flutter plugin registrants are referenced by reflection.
-keep class io.flutter.plugins.** { *; }

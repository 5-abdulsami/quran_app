# SQLite (sqlite3_flutter_libs) is loaded through JNI/FFI; keep its classes.
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Flutter plugin registrants are referenced by reflection.
-keep class io.flutter.plugins.** { *; }

# Background recitation (audio_service / just_audio): the service, receiver and
# media session callbacks are reached from the manifest and the platform.
-keep class com.ryanheise.** { *; }

# R8 rules for the release build.
#
# Only what R8 cannot work out on its own belongs here. Everything reachable
# from the manifest or from Flutter's own entry points is already kept by the
# consumer rules the plugins ship.

# ML Kit face detection loads its detector implementations reflectively, so
# nothing in the bytecode points at them and R8 strips them. The failure is
# silent until a scan runs on a release build and the detector cannot be
# constructed.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.mlkit.**

# Crashlytics needs line numbers and source names to symbolicate a Dart or
# Java stack trace; without them a report points at an obfuscated frame.
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

# Flutter references Play Core for deferred components. This app ships no
# deferred components, so the classes are genuinely absent and the references
# are dead — R8 must be told rather than failing the build on them.
-dontwarn com.google.android.play.core.**

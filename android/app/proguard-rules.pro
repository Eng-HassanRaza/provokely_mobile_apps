# ProGuard rules for release minification
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class kotlinx.** { *; }
-keep class kotlin.** { *; }
-dontwarn kotlinx.**
-dontwarn kotlin.**
# Keep app package (adjust if you change applicationId)
-keep class com.example.provokely_app.** { *; }

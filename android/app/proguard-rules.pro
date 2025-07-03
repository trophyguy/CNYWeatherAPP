# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your model classes
-keep class com.example.cnyweatherapp.models.** { *; }

# Keep Gson stuff
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep XML parsing
-keep class org.xmlpull.** { *; }
-keep class org.xml.sax.** { *; }

# Keep HTTP client
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep Retrofit stuff
-keepattributes Signature
-keepattributes Exceptions
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# Keep your application class
-keep class com.example.cnyweatherapp.** { *; } 
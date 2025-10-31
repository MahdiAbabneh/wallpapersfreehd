# Keep OkHttp and Okio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep uCrop classes and its OkHttp client store
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Keep Retrofit (defensive)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }


# ProGuard rules for Rust Multiplatform Template Library
# These rules ensure that the Kotlin/JVM bindings work correctly after ProGuard/R8 optimization

# Keep all UniFFI generated classes and their methods
-keep class uniffi.** { *; }
-keepclassmembers class uniffi.** {
    *** *(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JNA classes used by UniFFI
-keep class com.sun.jna.** { *; }
-dontwarn com.sun.jna.**

# Keep callback interfaces
-keep interface uniffi.**$* { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep metadata for reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile


# Keep the NativeListener interface
-keep public interface com.who.zone.NativeListener {
    public abstract void onCapture(java.lang.String);
    public abstract void onMovement();
    public abstract void onFirstFrameNotify();
}

# Make sure any classes that implement the interface are kept as well
# Replace "MainActivity" with the appropriate implementing class if needed
-keep class com.who.zone.MainActivity$* {
    <methods>;
}
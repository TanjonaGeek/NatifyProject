# Empêche R8 de supprimer les classes Google Play Core
-keep class com.google.android.play.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Empêche la suppression des classes utilisées par Flutter pour les mises à jour Play Store
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.app.** { *; }

# Empêche la suppression des classes SplitInstallManager et des composants différés
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.ktx.** { *; }
-keepattributes *Annotation*
-keep class * extends android.app.Application { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.deferred.** { *; }
-keep class com.google.android.play.core.install.** { *; }
# Supprime les avertissements liés aux classes Play Core Tasks
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task


# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener


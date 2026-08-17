# Google Mobile Ads depends on WorkManager. Under AGP 9's full R8 mode,
# WorkManager's Room database implementation can otherwise be removed from a
# release build and crash before Flutter starts.
-keep class androidx.startup.** { *; }
-keep class * implements androidx.startup.Initializer
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.db.WorkDatabase_Impl { *; }
-keep class androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory { *; }

package com.haveabreak.have_a_break

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log

class UsageDatabase(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "usage_logs.db"
        private const val DATABASE_VERSION = 1
        private const val TABLE_NAME = "usage_events"
        private const val COLUMN_ID = "id"
        private const val COLUMN_PACKAGE = "package_name"
        private const val COLUMN_DURATION = "duration_seconds"
        private const val COLUMN_TIMESTAMP = "timestamp"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = ("CREATE TABLE " + TABLE_NAME + " ("
                + COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, "
                + COLUMN_PACKAGE + " TEXT, "
                + COLUMN_DURATION + " INTEGER, "
                + COLUMN_TIMESTAMP + " DATETIME DEFAULT CURRENT_TIMESTAMP)")
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    fun logUsage(packageName: String, duration: Int) {
        try {
            val db = this.writableDatabase
            val values = ContentValues()
            values.put(COLUMN_PACKAGE, packageName)
            values.put(COLUMN_DURATION, duration)
            db.insert(TABLE_NAME, null, values)
            db.close()
        } catch (e: Exception) {
            Log.e("UsageDatabase", "Failed to log usage: ${e.message}")
        }
    }
}

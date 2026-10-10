package fr.elan.course

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.time.LocalDate
import java.time.ZoneId

/**
 * Widget de l'écran d'accueil : prochaine course et son compte à rebours, kilomètres de l'année.
 * Les données viennent de l'app (canal « elan/widget », voir MainActivity) ; le compte à rebours
 * est recalculé ici chaque jour, à minuit, même si l'app n'est pas ouverte.
 */
class ElanWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = render(context)
        ids.forEach { manager.updateAppWidget(it, views) }
        scheduleMidnight(context)
    }

    override fun onDisabled(context: Context) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarms.cancel(midnightIntent(context))
    }

    companion object {
        private const val PREFS = "elan_widget"

        /** Enregistre les données envoyées par l'app puis redessine les widgets posés. */
        fun save(context: Context, nextTitle: String?, nextEpochDay: Long?, year: Int, yearKm: String) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().apply {
                putString("nextTitle", nextTitle)
                putLong("nextEpochDay", nextEpochDay ?: -1L)
                putInt("year", year)
                putString("yearKm", yearKm)
                apply()
            }
            refresh(context)
        }

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ElanWidget::class.java))
            if (ids.isNotEmpty()) ElanWidget().onUpdate(context, manager, ids)
        }

        private fun render(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val today = LocalDate.now(ZoneId.systemDefault())
            val title = prefs.getString("nextTitle", null)
            val days = prefs.getLong("nextEpochDay", -1L).let { if (it < 0) -1L else it - today.toEpochDay() }
            // Données d'une autre année (app pas ouverte depuis le 1er janvier) : rien de couru cette année.
            val km = if (prefs.getInt("year", 0) == today.year) prefs.getString("yearKm", "0") else "0"
            val kmLine = "$km km en ${today.year}"

            val views = RemoteViews(context.packageName, R.layout.elan_widget)
            val description: String
            if (title != null && days >= 0) {
                val countdown = if (days == 0L) "Aujourd'hui" else "J-$days"
                views.setTextViewText(R.id.widget_label, "PROCHAINE COURSE")
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_countdown, countdown)
                val when_ = when (days) {
                    0L -> "aujourd'hui"
                    1L -> "demain"
                    else -> "dans $days jours"
                }
                description = "Prochaine course : $title, $when_. $kmLine."
            } else {
                views.setTextViewText(R.id.widget_label, "ÉLAN")
                views.setTextViewText(R.id.widget_title, "Aucune course à venir")
                // Zone du compte à rebours laissée vide : les km restent en bas du widget.
                views.setTextViewText(R.id.widget_countdown, "")
                description = "Aucune course à venir. $kmLine."
            }
            views.setTextViewText(R.id.widget_km, kmLine)
            views.setContentDescription(R.id.widget_root, description)

            val open = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            views.setOnClickPendingIntent(R.id.widget_root, open)
            return views
        }

        private fun midnightIntent(context: Context): PendingIntent {
            val intent = Intent(context, ElanWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                val ids = AppWidgetManager.getInstance(context)
                    .getAppWidgetIds(ComponentName(context, ElanWidget::class.java))
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            return PendingIntent.getBroadcast(
                context,
                1,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }

        /** Réveil peu après minuit (inexact : sans permission spéciale ni batterie gaspillée). */
        private fun scheduleMidnight(context: Context) {
            val zone = ZoneId.systemDefault()
            val next = LocalDate.now(zone).plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() + 60_000L
            val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarms.set(AlarmManager.RTC, next, midnightIntent(context))
        }
    }
}

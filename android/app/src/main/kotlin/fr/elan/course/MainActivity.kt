package fr.elan.course

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Partage d'un fichier (image, classeur Excel…) via le menu système d'Android.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elan/share").setMethodCallHandler { call, result ->
            if (call.method == "openFile") {
                // Ouvre un justificatif (copie dans le cache) avec l'application adaptée.
                val openPath = call.argument<String>("path")
                if (openPath == null) {
                    result.error("ARGUMENT", "Chemin de fichier manquant", null)
                    return@setMethodCallHandler
                }
                val openUri = FileProvider.getUriForFile(this, "$packageName.fileprovider", File(openPath))
                val view = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(openUri, call.argument<String>("mime") ?: "*/*")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                try {
                    startActivity(Intent.createChooser(view, null))
                    result.success(null)
                } catch (e: Exception) {
                    result.error("OPEN", e.message, null)
                }
                return@setMethodCallHandler
            }
            if (call.method != "shareImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path == null) {
                result.error("ARGUMENT", "Chemin de fichier manquant", null)
                return@setMethodCallHandler
            }
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", File(path))
            val send = Intent(Intent.ACTION_SEND).apply {
                type = call.argument<String>("mime") ?: "image/png"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(send, call.argument<String>("title")))
            result.success(null)
        }

        // Widget de l'écran d'accueil : données envoyées par l'app (voir ElanWidget).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elan/widget").setMethodCallHandler { call, result ->
            if (call.method != "update") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            ElanWidget.save(
                this,
                call.argument<String>("nextTitle"),
                call.argument<Number>("nextEpochDay")?.toLong(),
                call.argument<Int>("year") ?: 0,
                call.argument<String>("yearKm") ?: "0",
            )
            result.success(null)
        }

        // Copie riche : HTML (tableaux, gras, listes) + texte brut pour les apps qui ignorent le HTML.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elan/clipboard").setMethodCallHandler { call, result ->
            if (call.method != "setRich") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val html = call.argument<String>("html")
            val text = call.argument<String>("text")
            if (html == null || text == null) {
                result.error("ARGUMENT", "html et text sont attendus", null)
                return@setMethodCallHandler
            }
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            clipboard.setPrimaryClip(ClipData.newHtmlText("ÉLAN", text, html))
            result.success(null)
        }
    }
}

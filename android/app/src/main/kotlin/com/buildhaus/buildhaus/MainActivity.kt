package com.buildhaus.buildhaus

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlin.math.max
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val downloadsChannel = "com.buildhaus.buildhaus/downloads"
    private val platformChannel = "com.buildhaus.buildhaus/platform"
    private val reqPickProfileImage = 4102
    private var pendingImageResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadsChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveToDownloads") {
                    val fileName = call.argument<String>("fileName")
                    val content = call.argument<String>("content")
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    if (fileName.isNullOrBlank() || content == null) {
                        result.error("INVALID_ARGS", "fileName and content required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val savedPath = saveFileToPublicDownloads(fileName, content, mimeType)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, platformChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openMaps" -> {
                        val query = call.argument<String>("query")?.trim()
                        if (query.isNullOrEmpty()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        result.success(openMaps(query))
                    }
                    "pickProfileImage" -> {
                        pendingImageResult?.success(null)
                        pendingImageResult = result
                        launchProfileImagePicker()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openMaps(query: String): Boolean {
        val encoded = Uri.encode(query)
        val geoUri = Uri.parse("geo:0,0?q=$encoded")

        // 1. Coba buka Google Maps secara langsung jika terpasang
        val googleMapsIntent = Intent(Intent.ACTION_VIEW, geoUri).apply {
            setPackage("com.google.android.apps.maps")
        }
        if (tryStartActivity(googleMapsIntent)) return true

        // 2. Fallback ke intent geo: generik / chooser peta
        val genericGeoIntent = Intent(Intent.ACTION_VIEW, geoUri)
        if (genericGeoIntent.resolveActivity(packageManager) != null) {
            val chooser = Intent.createChooser(genericGeoIntent, "Pilih Aplikasi Peta")
            if (tryStartActivity(chooser)) return true
            if (tryStartActivity(genericGeoIntent)) return true
        }

        // 3. Fallback ke tautan web Google Maps via browser
        val webUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded")
        val webIntent = Intent(Intent.ACTION_VIEW, webUri)
        return tryStartActivity(webIntent)
    }

    private fun tryStartActivity(intent: Intent): Boolean {
        return try {
            if (intent.action == Intent.ACTION_CHOOSER ||
                intent.resolveActivity(packageManager) != null
            ) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (_: Exception) {
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun launchProfileImagePicker() {
        try {
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            val chooser = Intent.createChooser(intent, "Pilih Foto Profil")
            startActivityForResult(chooser, reqPickProfileImage)
        } catch (_: Exception) {
            try {
                val pickIntent = Intent(
                    Intent.ACTION_PICK,
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                ).apply {
                    type = "image/*"
                }
                startActivityForResult(pickIntent, reqPickProfileImage)
            } catch (e: Exception) {
                val pending = pendingImageResult
                pendingImageResult = null
                pending?.error("IMAGE_PICKER_UNAVAILABLE", e.message, null)
            }
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != reqPickProfileImage) return

        val pending = pendingImageResult
        pendingImageResult = null
        if (pending == null) return

        if (resultCode != Activity.RESULT_OK) {
            pending.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            pending.success(null)
            return
        }

        Thread {
            try {
                val savedPath = decodeScaleAndSaveAvatar(uri)
                runOnUiThread {
                    pending.success(savedPath)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    pending.error("IMAGE_PROCESS_FAILED", e.message, null)
                }
            }
        }.start()
    }

    private fun decodeScaleAndSaveAvatar(uri: Uri): String? {
        val maxDim = 512
        val bounds = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        contentResolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, bounds)
        } ?: return null

        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
            return null
        }

        var sampleSize = 1
        while (bounds.outWidth / sampleSize > maxDim * 2 ||
            bounds.outHeight / sampleSize > maxDim * 2
        ) {
            sampleSize *= 2
        }

        val decodeOptions = BitmapFactory.Options().apply {
            inSampleSize = sampleSize
        }
        val decoded = contentResolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream, null, decodeOptions)
        } ?: return null

        val oriented = applyExifOrientation(uri, decoded)
        if (oriented !== decoded) {
            decoded.recycle()
        }

        val finalBitmap = scaleBitmapToMax(oriented, maxDim)
        if (finalBitmap !== oriented) {
            oriented.recycle()
        }

        return try {
            val outFile = File(filesDir, "user_avatar_${System.currentTimeMillis()}.jpg")
            FileOutputStream(outFile).use { fos ->
                val saved = finalBitmap.compress(Bitmap.CompressFormat.JPEG, 88, fos)
                fos.flush()
                if (!saved) {
                    throw IllegalStateException("Gagal mengompresi foto profil JPEG")
                }
            }

            filesDir.listFiles { file ->
                file.isFile &&
                    file.name.startsWith("user_avatar_") &&
                    file.name.endsWith(".jpg") &&
                    file.name != outFile.name
            }?.forEach { oldFile ->
                runCatching { oldFile.delete() }
            }

            outFile.absolutePath
        } finally {
            if (!finalBitmap.isRecycled) {
                finalBitmap.recycle()
            }
        }
    }

    private fun applyExifOrientation(uri: Uri, bitmap: Bitmap): Bitmap {
        val orientation = try {
            contentResolver.openInputStream(uri)?.use { stream ->
                ExifInterface(stream).getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL,
                )
            } ?: ExifInterface.ORIENTATION_NORMAL
        } catch (_: Exception) {
            ExifInterface.ORIENTATION_NORMAL
        }

        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.postScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.postScale(-1f, 1f)
            }
            else -> return bitmap
        }

        return try {
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (_: Exception) {
            bitmap
        }
    }

    private fun scaleBitmapToMax(bitmap: Bitmap, maxDim: Int): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val longest = max(width, height)
        if (longest <= maxDim || width <= 0 || height <= 0) {
            return bitmap
        }
        val scale = maxDim.toFloat() / longest.toFloat()
        val targetWidth = (width * scale).roundToInt().coerceAtLeast(1)
        val targetHeight = (height * scale).roundToInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
    }

    override fun onDestroy() {
        pendingImageResult = null
        super.onDestroy()
    }

    private fun saveFileToPublicDownloads(
        fileName: String,
        content: String,
        mimeType: String,
    ): String {
        val bytes = content.toByteArray(Charsets.UTF_8)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Gagal membuat entri MediaStore Download")
            resolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes)
                stream.flush()
            } ?: throw IllegalStateException("Gagal membuka stream file Download")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return "/storage/emulated/0/Download/$fileName"
        } else {
            @Suppress("DEPRECATION")
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!dir.exists()) dir.mkdirs()
            val outFile = File(dir, fileName)
            outFile.writeBytes(bytes)
            return outFile.absolutePath
        }
    }
}

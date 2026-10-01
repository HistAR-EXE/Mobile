package vn.histar.timelens

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isMockLocationEnabled" -> {
                    try {
                        @Suppress("DEPRECATION")
                        val allowMock = Settings.Secure.getInt(
                            contentResolver,
                            Settings.Secure.ALLOW_MOCK_LOCATION,
                            0,
                        )
                        result.success(allowMock != 0)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "vn.histar.timelens/native"
    }
}

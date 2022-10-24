package com.example.radio

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "orllewin.radio/play"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
     println("AndroidWorld - $call")

      if (call.method == "playStation") {
          val streamUrl = call.arguments.toString()
          println("AndroidWorld, play: $streamUrl")
        result.success(1)
        //result.error("STREAM_ERROR", "Could not play stream", null)
      }else{
        result.notImplemented()
      }
    }
  }
}

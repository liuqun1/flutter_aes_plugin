package com.byt.flutter_aes_plugin;

import android.util.Base64;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterAesPlugin */
public class FlutterAesPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_aes_zeropadding");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_aes_zeropadding");
    channel.setMethodCallHandler(new FlutterAesPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("aes")) {
////      result.success("Android " + android.os.Build.VERSION.RELEASE);
      HashMap<String,String> map = (HashMap<String, String>) call.arguments;
      result.success(encrypt(map.get("pw"),map.get("key"),map.get("iv")));
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public  String encrypt(String data,String key,String iv) {
    try {
      Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
      int blockSize = cipher.getBlockSize();
      byte[] dataBytes = data.getBytes();
      int plaintextLength = dataBytes.length;
      if (plaintextLength % blockSize != 0) {
        plaintextLength = plaintextLength + (blockSize - (plaintextLength % blockSize));
      }
      byte[] plaintext = new byte[plaintextLength];
      System.arraycopy(dataBytes, 0, plaintext, 0, dataBytes.length);
      SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(), "AES");
      IvParameterSpec ivspec = new IvParameterSpec(key.getBytes());
      cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec);
      byte[] encrypted = cipher.doFinal(plaintext);
      return Base64.encodeToString(encrypted,Base64.DEFAULT);
//            return Base64.getEncoder().encodeToString(encrypted);
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }
}

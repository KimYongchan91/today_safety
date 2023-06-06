package kr.co.todaysafety.today_safety

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    @RequiresApi(Build.VERSION_CODES.P)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        try {
            val packageInfo = packageManager.getPackageInfo(
                packageName, PackageManager.GET_SIGNING_CERTIFICATES
            )
            val signingInfo = packageInfo.signingInfo.apkContentsSigners

            for (signature in signingInfo) {
                val messageDigest = MessageDigest.getInstance("SHA")
                messageDigest.update(signature.toByteArray())
                val keyHash = String(Base64.encode(messageDigest.digest(), 0))
                Log.d("KeyHash", keyHash)
            }

        } catch (e: Exception) {
            Log.e("Exception", e.toString())
        }
    }
}
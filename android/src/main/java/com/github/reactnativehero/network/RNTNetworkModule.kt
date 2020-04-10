package com.github.reactnativehero.network

import com.facebook.react.bridge.*
import java.io.*
import java.math.BigInteger
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import java.util.*

class RNTNetworkModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val ERROR_CODE_FILE_NOT_FOUND = "1"
    }

    override fun getName(): String {
        return "RNTNetwork"
    }

    override fun getConstants(): Map<String, Any>? {

        val constants: MutableMap<String, Any> = HashMap()

        constants["DIRECTORY_CACHE"] = reactContext.cacheDir.absolutePath
        constants["DIRECTORY_DOCUMENT"] = reactContext.filesDir.absolutePath

        constants["ERROR_CODE_FILE_NOT_FOUND"] = ERROR_CODE_FILE_NOT_FOUND

        return constants

    }

    @ReactMethod
    fun download(url: String, promise: Promise) {


    }

}
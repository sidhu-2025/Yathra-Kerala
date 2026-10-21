package com.example.yathra_kerala_app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.yathrakerala/location"
    private val EVENT_CHANNEL = "com.yathrakerala/location_stream"
    private val PERMISSION_REQUEST_CODE = 4001

    private var pendingResult: MethodChannel.Result? = null
    private var locationEventSink: EventChannel.EventSink? = null
    private var locationManager: LocationManager? = null

    private val locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            val data = HashMap<String, Any>()
            data["lat"] = location.latitude
            data["lng"] = location.longitude
            data["accuracy"] = location.accuracy.toDouble()
            data["speed"] = (location.speed * 3.6).toDouble() // m/s to km/h
            data["bearing"] = location.bearing.toDouble()
            data["time"] = location.time
            data["provider"] = location.provider ?: "gps"
            data["isMock"] = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                location.isMock
            } else {
                @Suppress("DEPRECATION")
                location.isFromMockProvider
            }
            runOnUiThread {
                locationEventSink?.success(data)
            }
        }

        @Deprecated("Deprecated in Java")
        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    val fineGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    val coarseGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    val status = if (fineGranted) {
                        "precise"
                    } else if (coarseGranted) {
                        "approximate"
                    } else {
                        "denied"
                    }
                    result.success(status)
                }
                "requestPermission" -> {
                    val fineGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    if (fineGranted) {
                        result.success("precise")
                    } else {
                        pendingResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(
                                Manifest.permission.ACCESS_FINE_LOCATION,
                                Manifest.permission.ACCESS_COARSE_LOCATION
                            ),
                            PERMISSION_REQUEST_CODE
                        )
                    }
                }
                "isLocationServiceEnabled" -> {
                    val gps = locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
                    val network = locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) ?: false
                    result.success(gps || network)
                }
                "openLocationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                "openAppSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", packageName, null)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("APP_SETTINGS_ERROR", e.message, null)
                    }
                }
                "getCurrentPosition" -> {
                    val fineGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    val coarseGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    if (!fineGranted && !coarseGranted) {
                        result.error("PERMISSION_DENIED", "Location permission not granted", null)
                        return@setMethodCallHandler
                    }

                    var bestLocation: Location? = null
                    try {
                        val gpsLoc = locationManager?.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                        val netLoc = locationManager?.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
                        if (gpsLoc != null && netLoc != null) {
                            bestLocation = if (gpsLoc.time > netLoc.time || gpsLoc.accuracy < netLoc.accuracy) gpsLoc else netLoc
                        } else {
                            bestLocation = gpsLoc ?: netLoc
                        }
                    } catch (_: SecurityException) {}

                    if (bestLocation != null) {
                        val data = HashMap<String, Any>()
                        data["lat"] = bestLocation.latitude
                        data["lng"] = bestLocation.longitude
                        data["accuracy"] = bestLocation.accuracy.toDouble()
                        data["speed"] = (bestLocation.speed * 3.6).toDouble()
                        data["bearing"] = bestLocation.bearing.toDouble()
                        data["time"] = bestLocation.time
                        data["provider"] = bestLocation.provider ?: "gps"
                        result.success(data)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                locationEventSink = events
                startLocationUpdates()
            }

            override fun onCancel(arguments: Any?) {
                stopLocationUpdates()
                locationEventSink = null
            }
        })
    }

    private fun startLocationUpdates() {
        val fineGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        if (!fineGranted && !coarseGranted) return

        try {
            // Request updates from GPS Provider (highest accuracy, satellite-based)
            if (locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true) {
                locationManager?.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    1000L, // 1 second
                    1.0f,  // 1 meter
                    locationListener
                )
            }
            // Also request from Network Provider as initial fallback while GPS satellite lock is acquiring
            if (locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true) {
                locationManager?.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    2000L,
                    5.0f,
                    locationListener
                )
            }
        } catch (_: SecurityException) {}
    }

    private fun stopLocationUpdates() {
        try {
            locationManager?.removeUpdates(locationListener)
        } catch (_: Exception) {}
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val fineIndex = permissions.indexOf(Manifest.permission.ACCESS_FINE_LOCATION)
            val fineGranted = fineIndex != -1 && grantResults.getOrNull(fineIndex) == PackageManager.PERMISSION_GRANTED

            val coarseIndex = permissions.indexOf(Manifest.permission.ACCESS_COARSE_LOCATION)
            val coarseGranted = coarseIndex != -1 && grantResults.getOrNull(coarseIndex) == PackageManager.PERMISSION_GRANTED

            val status = if (fineGranted) {
                "precise"
            } else if (coarseGranted) {
                "approximate"
            } else {
                "denied"
            }
            pendingResult?.success(status)
            pendingResult = null
        }
    }

    override fun onDestroy() {
        stopLocationUpdates()
        super.onDestroy()
    }
}

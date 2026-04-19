package io.khode.telegram_login_flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.telegram.login.LoginData
import org.telegram.login.LoginError
import org.telegram.login.TelegramLogin
import java.net.ConnectException
import java.net.SocketTimeoutException
import java.net.UnknownHostException

/**
 * Android counterpart of the Flutter Telegram Login plugin.
 *
 * Bridges the [TelegramLogin] singleton from `org.telegram:login-sdk` to the
 * shared `telegram_login_flutter` method channel, mirroring the iOS plugin's
 * `configure` / `login` / `cancelLogin` / `handleUrl` surface and error codes.
 */
class TelegramLoginFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.NewIntentListener {

    private lateinit var channel: MethodChannel
    private val mainHandler = Handler(Looper.getMainLooper())

    private var activityBinding: ActivityPluginBinding? = null
    private var activity: Activity? = null

    private var isConfigured = false
    private var pendingLoginResult: Result? = null
    private var redirectUri: String? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telegram_login_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> handleConfigure(call, result)
            "login" -> handleLogin(result)
            "cancelLogin" -> handleCancelLogin(result)
            "handleUrl" -> handleUrlCall(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleConfigure(call: MethodCall, result: Result) {
        val clientId = call.argument<String>("clientId")
        val redirectUriArg = call.argument<String>("redirectUri")
        val scopesAny = call.argument<List<*>>("scopes")

        if (clientId.isNullOrBlank() || redirectUriArg.isNullOrBlank() || scopesAny == null) {
            result.error(
                "INVALID_ARGUMENTS",
                "Missing required configuration parameters",
                null,
            )
            return
        }

        val scopes = scopesAny.mapNotNull { it as? String }

        runOnMain {
            TelegramLogin.init(
                clientId = clientId,
                redirectUri = redirectUriArg,
                scopes = scopes,
            )
            isConfigured = true
            redirectUri = redirectUriArg
            result.success(null)
        }
    }

    private fun handleLogin(result: Result) {
        runOnMain {
            if (!isConfigured) {
                result.error(
                    "NOT_CONFIGURED",
                    "TelegramLogin.configure() was not called before login()",
                    null,
                )
                return@runOnMain
            }

            val host = activity
            if (host == null) {
                result.error(
                    "NO_ACTIVITY",
                    "Cannot start login without a foreground Activity",
                    null,
                )
                return@runOnMain
            }

            pendingLoginResult = result
            TelegramLogin.startLogin(host)
        }
    }

    private fun handleCancelLogin(result: Result) {
        runOnMain {
            val pending = pendingLoginResult
            if (pending == null) {
                result.success(false)
                return@runOnMain
            }
            pendingLoginResult = null
            pending.error(
                "CANCELLED",
                "The user cancelled the login",
                null,
            )
            result.success(true)
        }
    }

    private fun handleUrlCall(call: MethodCall, result: Result) {
        val urlString = call.argument<String>("url")
        val uri = urlString?.let { runCatching { Uri.parse(it) }.getOrNull() }
        if (uri == null) {
            result.error("INVALID_ARGUMENTS", "Invalid URL provided", null)
            return
        }
        runOnMain {
            forwardUri(uri)
            result.success(true)
        }
    }

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        bindActivity(binding)
        // Cold-start: the app may have been launched by the redirect Intent
        // directly, so the URI is already sitting on the Activity's intent.
        activity?.intent?.data?.let { forwardUri(it) }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unbindActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        bindActivity(binding)
    }

    override fun onDetachedFromActivity() {
        unbindActivity()
    }

    private fun bindActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    private fun unbindActivity() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
        activity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        intent.data?.let { forwardUri(it) }
        return false
    }

    // endregion

    /**
     * Forward a URL into the Telegram SDK, but only when a `login()` is in
     * flight and the URL plausibly matches the configured redirect URI.
     *
     * Matching the iOS plugin, any URI received without a pending login (for
     * example because the user already cancelled, or the Activity was launched
     * with some unrelated deep link) is silently ignored.
     */
    private fun forwardUri(uri: Uri) {
        if (pendingLoginResult == null) return
        if (!uriMatchesRedirect(uri)) return

        runOnMain {
            TelegramLogin.handleLoginResponse(
                uri = uri,
                onSuccess = { data -> deliverSuccess(data) },
                onError = { err -> deliverError(err) },
            )
        }
    }

    private fun uriMatchesRedirect(uri: Uri): Boolean {
        val configured = redirectUri?.let { runCatching { Uri.parse(it) }.getOrNull() } ?: return true
        if (configured.scheme != null && configured.scheme != uri.scheme) return false
        if (configured.host != null && configured.host != uri.host) return false
        return true
    }

    private fun deliverSuccess(data: LoginData) {
        val pending = pendingLoginResult ?: return
        pendingLoginResult = null
        pending.success(mapOf("idToken" to data.idToken))
    }

    private fun deliverError(err: LoginError) {
        val pending = pendingLoginResult ?: return
        pendingLoginResult = null
        val (code, message) = mapError(err.message)
        pending.error(code, message, null)
    }

    private fun runOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    companion object {
        private val HTTP_STATUS_REGEX = Regex("""^HTTP\s+(\d{3})\b""")

        /**
         * Map an Android SDK [LoginError.message] to the iOS-compatible
         * (code, message) pair consumed by the Dart layer's error mapping in
         * `telegram_login_flutter_method_channel.dart`.
         */
        internal fun mapError(message: String?): Pair<String, String> {
            val raw = message?.trim().orEmpty()

            val httpMatch = HTTP_STATUS_REGEX.find(raw)
            if (httpMatch != null) {
                val status = httpMatch.groupValues[1]
                return "SERVER_ERROR" to "Server error: $status"
            }

            if (raw.contains("No authorization code", ignoreCase = true)) {
                return "NO_AUTH_CODE" to raw
            }

            val lower = raw.lowercase()
            val networkNeedles = listOf(
                UnknownHostException::class.java.simpleName,
                SocketTimeoutException::class.java.simpleName,
                ConnectException::class.java.simpleName,
                "network error",
                "unable to resolve host",
                "failed to connect",
                "timeout",
            )
            if (networkNeedles.any { lower.contains(it.lowercase()) }) {
                return "NETWORK_ERROR" to raw.ifEmpty { "Network error" }
            }

            return "REQUEST_FAILED" to raw.ifEmpty { "Request failed" }
        }
    }
}

package io.khode.telegram_login

import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * Unit tests for the pure [TelegramLoginPlugin.mapError] helper that
 * translates an Android SDK `LoginError.message` into the iOS-compatible
 * (code, message) pair consumed by the Dart layer.
 */
internal class TelegramLoginPluginTest {

    @Test
    fun mapError_httpStatus_mapsToServerErrorWithParsedCode() {
        val (code, message) = TelegramLoginPlugin.mapError("HTTP 500: internal server error")
        assertEquals("SERVER_ERROR", code)
        assertEquals("Server error: 500", message)
    }

    @Test
    fun mapError_httpFourHundred_isAlsoServerError() {
        val (code, message) = TelegramLoginPlugin.mapError("HTTP 404: not found")
        assertEquals("SERVER_ERROR", code)
        assertEquals("Server error: 404", message)
    }

    @Test
    fun mapError_noAuthorizationCode_mapsToNoAuthCode() {
        val (code, _) = TelegramLoginPlugin.mapError("No authorization code in response URI")
        assertEquals("NO_AUTH_CODE", code)
    }

    @Test
    fun mapError_unknownHost_mapsToNetworkError() {
        val (code, _) = TelegramLoginPlugin.mapError("UnknownHostException: oauth.telegram.org")
        assertEquals("NETWORK_ERROR", code)
    }

    @Test
    fun mapError_socketTimeout_mapsToNetworkError() {
        val (code, _) = TelegramLoginPlugin.mapError("SocketTimeoutException: connect timed out")
        assertEquals("NETWORK_ERROR", code)
    }

    @Test
    fun mapError_genericNetworkError_mapsToNetworkError() {
        val (code, message) = TelegramLoginPlugin.mapError("Network error")
        assertEquals("NETWORK_ERROR", code)
        assertEquals("Network error", message)
    }

    @Test
    fun mapError_unknownMessage_fallsBackToRequestFailed() {
        val (code, message) = TelegramLoginPlugin.mapError("Something weird happened")
        assertEquals("REQUEST_FAILED", code)
        assertEquals("Something weird happened", message)
    }

    @Test
    fun mapError_nullMessage_fallsBackToRequestFailed() {
        val (code, message) = TelegramLoginPlugin.mapError(null)
        assertEquals("REQUEST_FAILED", code)
        assertEquals("Request failed", message)
    }
}

package twilio.flutter.twilio_conversations

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.twilio.conversations.ConversationListener
import com.twilio.conversations.ConversationsClient
import com.twilio.conversations.ErrorInfo
import com.twilio.conversations.StatusListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.listeners.ClientListener

/** TwilioConversationsPlugin */
class TwilioConversationsPlugin : FlutterPlugin {
    private lateinit var methodChannel: MethodChannel
    private lateinit var clientChannel: EventChannel
    private lateinit var loggingChannel: EventChannel
    private lateinit var notificationChannel: EventChannel

    companion object {
        @Suppress("unused")
        @JvmStatic
        lateinit var instance: TwilioConversationsPlugin

        @JvmStatic
        var client: ConversationsClient? = null

        lateinit var messenger: BinaryMessenger

        lateinit var clientListener: ClientListener

        var conversationChannels: HashMap<String, EventChannel> = hashMapOf()
        var conversationListeners: HashMap<String, ConversationListener> = hashMapOf()

        var loggingSink: EventChannel.EventSink? = null
        var notificationSink: EventChannel.EventSink? = null

        var handler = Handler(Looper.getMainLooper())
        var nativeDebug: Boolean = false
        val LOG_TAG = "Twilio_Conversations"

        @JvmStatic
        fun debug(msg: String) {
            if (nativeDebug) {
                Log.d(LOG_TAG, msg)
                handler.post(Runnable {
                    loggingSink?.success(msg)
                })
            }
        }
    }


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        instance = this
        messenger = flutterPluginBinding.binaryMessenger

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "twilio_conversations")
        val methodCallHandler = PluginMethodCallHandler(flutterPluginBinding.applicationContext)
        methodChannel.setMethodCallHandler(methodCallHandler)

        clientChannel = EventChannel(messenger, "twilio_conversations/client")
        clientChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Client eventChannel attached")
                clientListener = ClientListener()
                clientListener.events = events
                clientListener.onListen()
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Client eventChannel detached")
                clientListener.events = null
            }
        })

        loggingChannel = EventChannel(messenger, "twilio_conversations/logging")
        loggingChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Logging eventChannel attached")
                loggingSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Logging eventChannel detached")
                loggingSink = null
            }
        })

        notificationChannel = EventChannel(messenger, "twilio_conversations/notification")
        notificationChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Notification eventChannel attached")
                notificationSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioConversationsPlugin.onAttachedToEngine => Notification eventChannel detached")
                notificationSink = null
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        debug("TwilioConversationsPlugin.onDetachedFromEngine")
        methodChannel.setMethodCallHandler(null)
        clientChannel.setStreamHandler(null)
        loggingChannel.setStreamHandler(null)
        notificationChannel.setStreamHandler(null)
    }

    fun registerForNotification(call: MethodCall, result: MethodChannel.Result) {
        val token: String = call.argument("token")
                ?: return result.error("MISSING_PARAMS", "The parameter 'token' was not provided", null)

        client?.registerFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                sendNotificationEvent("registered", mapOf("result" to true))
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo?) {
                super.onError(errorInfo)
                sendNotificationEvent("registered", mapOf("result" to false), errorInfo)
                result.error("FAILED", "Failed to register for FCM notifications", errorInfo)
            }
        })
    }

    fun unregisterForNotification(call: MethodCall, result: MethodChannel.Result) {
        val token: String = call.argument("token")
                ?: return result.error("MISSING_PARAMS", "The parameter 'token' was not given", null)

        client?.unregisterFCMToken(ConversationsClient.FCMToken(token), object : StatusListener {
            override fun onSuccess() {
                sendNotificationEvent("deregistered", mapOf("result" to true))
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo?) {
                super.onError(errorInfo)
                sendNotificationEvent("deregistered", mapOf("result" to false), errorInfo)
                result.error("FAILED", "Failed to unregister for FCM notifications", errorInfo)
            }
        })
    }

    private fun sendNotificationEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        notificationSink?.success(Gson().toJson(eventData))
    }
}

import Flutter
import UIKit
import TwilioConversationsClient

public class SwiftTwilioConversationsPlugin: NSObject, FlutterPlugin {
    public static var instance: SwiftTwilioConversationsPlugin?
    public static var loggingSink: FlutterEventSink?
    public static var notificationSink: FlutterEventSink?
    
    public var client: TwilioConversationsClient?
    
    public static var clientListener: ClientListener?
    public static var conversationChannels: [String: FlutterEventChannel] = [:]
    public static var conversationListeners: [String: ConversationListener] = [:]
    
    public static var messenger: FlutterBinaryMessenger?
    private var methodChannel: FlutterMethodChannel?
    private var clientChannel: FlutterEventChannel?
    private var loggingChannel: FlutterEventChannel?
    private var notificationChannel: FlutterEventChannel?
    
    public static var reasonForTokenRetrieval: String?
    
    public static var nativeDebug = false
    
    public static func debug(_ msg: String) {
        if SwiftTwilioConversationsPlugin.nativeDebug {
            NSLog(msg)
            guard let loggingSink = loggingSink else {
                return
            }
            loggingSink(msg)
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        instance = SwiftTwilioConversationsPlugin()
        instance?.onRegister(registrar)
    }
    
    public func onRegister(_ registrar: FlutterPluginRegistrar) {
        SwiftTwilioConversationsPlugin.messenger = registrar.messenger()
        let pluginHandler = PluginMethodCallHandler()
        methodChannel = FlutterMethodChannel(name: "twilio_conversations", binaryMessenger: registrar.messenger())
        methodChannel?.setMethodCallHandler(pluginHandler.handle)

        clientChannel = FlutterEventChannel(name: "twilio_conversations/client", binaryMessenger: registrar.messenger())
        clientChannel?.setStreamHandler(ClientStreamHandler())

        loggingChannel = FlutterEventChannel(
            name: "twilio_conversations/logging", binaryMessenger: registrar.messenger())
        loggingChannel?.setStreamHandler(LoggingStreamHandler())

        notificationChannel = FlutterEventChannel(
            name: "twilio_conversations/notification", binaryMessenger: registrar.messenger())
        notificationChannel?.setStreamHandler(NotificationStreamHandler())

        registrar.addApplicationDelegate(self)
    }

    public func registerForNotification(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, _: Error?) in
                SwiftTwilioConversationsPlugin.debug("User responded to permissions request: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        SwiftTwilioConversationsPlugin.debug("Requesting APNS token")
                        SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "register"
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        flutterResult(nil)
    }

    public func unregisterForNotification(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                SwiftTwilioConversationsPlugin.debug("Requesting APNS token")
                SwiftTwilioConversationsPlugin.reasonForTokenRetrieval = "deregister"
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        flutterResult(nil)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftTwilioConversationsPlugin.debug("didRegisterForRemoteNotificationsWithDeviceToken => onSuccess: \((deviceToken as NSData).description)")
                if let reason = SwiftTwilioConversationsPlugin.reasonForTokenRetrieval {
                    if reason == "register" {
                        client?.register(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                            SwiftTwilioConversationsPlugin.debug("registered for notifications: \(result.isSuccessful)")
                            SwiftTwilioConversationsPlugin.sendNotificationEvent("registered", data: ["result": result.isSuccessful], error: result.error)
                        })
                    } else {
                        client?.deregister(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                            SwiftTwilioConversationsPlugin.debug("deregistered for notifications: \(result.isSuccessful)")
                            SwiftTwilioConversationsPlugin.sendNotificationEvent("deregistered", data: ["result": result.isSuccessful], error: result.error)
                        })
                    }
                }
    }
    
    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError
        error: Error) {
        SwiftTwilioConversationsPlugin.debug("didFailToRegisterForRemoteNotificationsWithError => onFail")
        SwiftTwilioConversationsPlugin.sendNotificationEvent("registered", data: ["result": false], error: error)
    }

    private static func sendNotificationEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = ["name": name, "data": data, "error": Mapper.errorToDict(error)] as [String: Any?]

        if let notificationSink = SwiftTwilioConversationsPlugin.notificationSink {
            notificationSink(Mapper.encode(eventData))
        }
    }

    class ClientStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            clientListener = ClientListener()
            SwiftTwilioConversationsPlugin.debug("ClientStreamHandler.onListen => Client eventChannel attached")
            clientListener?.events = events
            clientListener?.onListen()
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("ClientStreamHandler.onCancel => Client eventChannel detached")
            guard let clientListener = SwiftTwilioConversationsPlugin.clientListener else { return nil }
            clientListener.events = nil
            return nil
        }
    }
    
    class LoggingStreamHandler: NSObject, FlutterStreamHandler {
            func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                SwiftTwilioConversationsPlugin.debug("LoggingStreamHandler.onListen => Logging eventChannel attached")
                SwiftTwilioConversationsPlugin.loggingSink = events
                return nil
            }

            func onCancel(withArguments arguments: Any?) -> FlutterError? {
                SwiftTwilioConversationsPlugin.debug("LoggingStreamHandler.onCancel => Logging eventChannel detached")
                SwiftTwilioConversationsPlugin.loggingSink = nil
                return nil
            }
        }
    
    class NotificationStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("NotificationStreamHandler.onListen => Notification eventChannel attached")
            SwiftTwilioConversationsPlugin.notificationSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioConversationsPlugin.debug("NotificationStreamHandler.onCancel => Notification eventChannel detached")
            SwiftTwilioConversationsPlugin.notificationSink = nil
            return nil
        }
    }
}

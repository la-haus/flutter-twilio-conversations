import Foundation
import Flutter
import TwilioConversationsClient

public class PluginMethodCallHandler {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "debug": debug(call, result)
        case "create": create(call, result)
        case "registerForNotification": SwiftTwilioConversationsPlugin.instance?.registerForNotification(call, result)
        case "unregisterForNotification": SwiftTwilioConversationsPlugin.instance?.unregisterForNotification(call, result)

        case "ConversationClientMethods.updateToken": ConversationClientMethods.updateToken(call, result)
        case "ConversationClientMethods.shutdown": ConversationClientMethods.shutdown(call, result)

        case "ConversationMethods.join": ConversationMethods.join(call, result)
        case "ConversationMethods.leave": ConversationMethods.leave(call, result)
        case "ConversationMethods.typing": ConversationMethods.typing(call, result)
        case "ConversationMethods.setFriendlyName": ConversationMethods.setFriendlyName(call, result)
        case "ConversationMethods.getUnreadMessagesCount": ConversationMethods.getUnreadMessagesCount(call, result)

        case "ConversationsMethods.getConversation": ConversationsMethods.getConversation(call, result)
        case "ConversationsMethods.createConversation": ConversationsMethods.createConversation(call, result)
        case "ConversationsMethods.getMyConversations": ConversationsMethods.getMyConversations(call, result)

        case "MessageMethods.getMediaContentTemporaryUrl": MessageMethods.getMediaContentTemporaryUrl(call, result)

        case "MessagesMethods.sendMessage": MessagesMethods.sendMessage(call, result)
        case "MessagesMethods.getLastMessages": MessagesMethods.getLastMessages(call, result)
        case "MessagesMethods.getMessagesBefore": MessagesMethods.getMessagesBefore(call, result)
        case "MessagesMethods.setAllMessagesRead": MessagesMethods.setAllMessagesRead(call, result)
        case "MessagesMethods.setLastReadMessageIndex": MessagesMethods.setLastReadMessageIndex(call, result)
            
        case "ParticipantMethods.getUser": ParticipantMethods.getUser(call, result)

        case "ParticipantsMethods.getUsers": ParticipantsMethods.getUsers(call, result)
        case "ParticipantsMethods.getParticipantsList": ParticipantsMethods.getParticipantsList(call, result)
        case "ParticipantsMethods.addParticipantByIdentity": ParticipantsMethods.addParticipantByIdentity(call, result)
        case "ParticipantsMethods.removeParticipantByIdentity": ParticipantsMethods.removeParticipantByIdentity(call, result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func create(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        SwiftTwilioConversationsPlugin.debug("SwiftTwilioConversationsPlugin.create => called")
        
        guard let arguments = call.arguments as? [String: Any?] else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        guard let jwtToken = arguments["jwtToken"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }
        
        let properties = TwilioConversationsClientProperties()
        //TODO add region to properties
                
        TwilioConversationsClient.conversationsClient(withToken: jwtToken, properties: properties, delegate: SwiftTwilioConversationsPlugin.clientListener, completion: { (result: TCHResult, conversationsClient: TwilioConversationsClient?) in
            if result.isSuccessful {
                SwiftTwilioConversationsPlugin.debug("SwiftTwilioConversationsPlugin.create => ConversationsClient.create onSuccess: myIdentity is '\(conversationsClient?.user?.identity ?? "unknown")'")
                conversationsClient?.delegate = SwiftTwilioConversationsPlugin.clientListener
                SwiftTwilioConversationsPlugin.instance?.client = conversationsClient
                let clientDict = Mapper.conversationsClientToDict(conversationsClient)
                flutterResult(Mapper.encode(clientDict))
            } else {
                SwiftTwilioConversationsPlugin.debug("SwiftTwilioConversationsPlugin.create => ConversationsClient.create onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error creating client, Error: \(result.error.debugDescription)", details: nil))
            }
        })
    }

    private func debug(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let enableNative = arguments["native"] as? Bool else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'native' parameter", details: nil))
        }

        guard let enableSdk = arguments["sdk"] as? Bool else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'sdk' parameter", details: nil))
        }

        SwiftTwilioConversationsPlugin.nativeDebug = enableNative
        if enableSdk {
            TwilioConversationsClient.setLogLevel(TCHLogLevel.debug)
        }
        flutterResult(enableNative)
    }
}

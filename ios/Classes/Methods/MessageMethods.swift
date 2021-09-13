import Flutter
import TwilioConversationsClient

public class MessageMethods {
    public static func getMediaContentTemporaryUrl(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let messageIndex = arguments["messageIndex"] as? NSNumber,
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
                if result.isSuccessful, let conversation = conversation {
                    conversation.message(withIndex: messageIndex, completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful, let message = message {
                            message.getMediaContentTemporaryUrl(completion: { (result: TCHResult, url: String?) in
                                if result.isSuccessful, let url = url {
                                    flutterResult(url)
                                } else {
                                    SwiftTwilioConversationsPlugin.debug("MessageMethods.getMedia (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                                    flutterResult(FlutterError(code: "ERROR", message: "MessageMethods.getMedia (Message.Media.getMediaContentTemporaryUrl)", details: nil))
                                }
                            })
                        } else {
                            SwiftTwilioConversationsPlugin.debug("MessageMethods.getMedia (Messages.messageWithIndex) => onError: \(String(describing: result.error))")
                            flutterResult(FlutterError(code: "ERROR", message: "Error retrieving messages at index '\(messageIndex)' in conversation with sid '\(conversationSid)'", details: nil))
                        }
                    })
                } else {
                    flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
                }
        })
    }
}

import Flutter
import TwilioConversationsClient

public class ConversationMethods {
    public static func getUnreadMessagesCount(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getUnreadMessagesCount() { (result: TCHResult , count: NSNumber?) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        flutterResult(count)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving unread messages count for conversation with sid '\(conversationSid)', Error: \(result.error.debugDescription)", details: nil))
                    }
                }
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func join(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                conversation.join { (result: TCHResult) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (conversation.join) => onSuccess")
                        flutterResult(true)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (conversation.join) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error joining conversation (conversation.join) with sid \(conversationSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error joining conversation with sid \(conversationSid): \(String(describing: result.error))", details: nil))
            }
        })
    }
    
    public static func leave(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                conversation.leave { (result: TCHResult) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (conversation.leave) => onSuccess")
                        flutterResult(true)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (conversation.leave) => onError: \(result.error.debugDescription)")
                        flutterResult(FlutterError(code: "ERROR", message: "\(call.method) => Error leaving conversation (conversation.leave) with sid \(conversationSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "\(call.method) => Error leaving conversation with sid \(conversationSid): \(String(describing: result.error))", details: nil))
            }
        })
    }
    
    public static func setFriendlyName(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String,
              let friendlyName = arguments["friendlyName"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                conversation.setFriendlyName(friendlyName) { (result: TCHResult) in
                    if result.isSuccessful {
                        flutterResult(conversation.friendlyName)
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "\(call.method) => Error setting friendlyName for conversation with sid \(conversationSid): \(String(describing: result.error))", details: nil))
                    }
                }
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "\(call.method) => Error retrieving conversation with sid \(conversationSid): \(String(describing: result.error))", details: nil))
            }
        })
    }
    
    public static func typing(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing conversationSid", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                conversation.typing()
                flutterResult(nil)
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "\(call.method) => Error retrieving conversation with sid \(conversationSid): \(result.error?.description ?? "")", details: nil))
            }
        })
    }
}

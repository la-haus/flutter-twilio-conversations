import Flutter
import TwilioConversationsClient

public class ConversationsMethods {
    public static func createConversation(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let friendlyName = arguments["friendlyName"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'friendlyName' parameter", details: nil))
        }

        let conversationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName
        ]

        SwiftTwilioConversationsPlugin.instance?.client?.createConversation(options: conversationOptions, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                let conversationDict = Mapper.conversationToDict(conversation)
                flutterResult(Mapper.encode(conversationDict))
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error creating conversation with friendlyName '\(friendlyName)': \(String(describing: result.error))", details: nil))
            }
        })
    }
    
    public static func getMyConversations(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        let myConversations =  SwiftTwilioConversationsPlugin.instance?.client?.myConversations()
        let dict = Mapper.conversationsToDict(myConversations)
        flutterResult(Mapper.encode(dict))
    }

    public static func getConversation(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let conversationSidOrUniqueName = arguments["conversationSidOrUniqueName"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing 'conversationSidOrUniqueName' parameter", details: nil))
        }

        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSidOrUniqueName, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                flutterResult(Mapper.encode(Mapper.conversationToDict(conversation)))
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid or uniqueName '\(conversationSidOrUniqueName)'", details: nil))
            }
        })
    }

}

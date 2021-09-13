import Flutter
import TwilioConversationsClient

class ParticipantMethods {
    public static func getUser(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing arguments", details: nil))
        }

        guard let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing conversationSid", details: nil))
        }

        guard let participantSid = arguments["participantSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing participantSid", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                let participant = conversation.participants().first(where: {$0.sid == participantSid})
                participant?.subscribedUser() { result, user in
                    if result.isSuccessful {
                        flutterResult(Mapper.encode(Mapper.userToDict(user)))
                    } else {
                        flutterResult(nil)
                    }
                }
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
}

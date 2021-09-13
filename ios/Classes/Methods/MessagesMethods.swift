import Flutter
import TwilioConversationsClient

public class MessagesMethods {
    public static func sendMessage(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
            let conversationSid = arguments["conversationSid"] as? String,
            let options = arguments["options"] as? [String: Any?] else {
                return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        let messageOptions = TCHMessageOptions()
        
        if let messageBody = options["body"] as? String {
            messageOptions.withBody(messageBody)
        }
        if let input = options["inputPath"] as? String {
            guard let mimeType = options["mimeType"] as? String else {
                return flutterResult(FlutterError(code: "ERROR", message: "Missing 'mimeType' in MessageOptions", details: nil))
            }
            
            if let inputStream = InputStream(fileAtPath: input) {
                messageOptions.withMediaStream(inputStream, contentType: mimeType, defaultFilename: options["filename"] as? String,
                                               onStarted: {
                    // TODO
                                                
                },
                                               onProgress: { (bytes: UInt) in
                    // TODO
                                                
                },
                                               onCompleted: { (mediaSid: String) in
                    // TODO
                                                
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving file for upload from `\(input)`", details: nil))
            }
        }
        
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.sendMessage(with: messageOptions, completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful,
                       let message = message {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (Message.sendMessage) => onSuccess")
                        flutterResult(Mapper.encode(Mapper.messageToDict(message, conversationSid: conversationSid)))
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (Message.sendMessage) => onError: \(result.error.debugDescription)")
                        flutterResult(FlutterError(code: "ERROR", message: "Error sending message with options `\(String(describing: messageOptions))`", details: nil))
                    }
                })
            }
        })
    }

    public static func getMessagesBefore(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String,
              let index = arguments["index"] as? UInt,
              let count = arguments["count"] as? UInt else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesBefore(index, withCount: count, completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (Messages.getBefore) => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToDict(message, conversationSid: conversationSid)
                        }
                        flutterResult(Mapper.encode(messagesMap))
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) (Messages.getBefore) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving \(count) messages before message (index: \(index)) from conversation (sid: \(conversationSid))", details: nil))
                    }
                })
            }
        })
    }
    
    public static func getLastMessages(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let count = arguments["count"] as? UInt,
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getLastMessages(withCount: count, completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToDict(message, conversationSid: conversationSid)
                        }
                        flutterResult(Mapper.encode(messagesMap))
                    } else {
                        flutterResult(FlutterError(code: "ERROR", message: "Error retrieving last \(count) messages for conversation with sid '\(conversationSid)'", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func setAllMessagesRead(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setAllMessagesReadWithCompletion({ (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error setting all messages read for conversation (sid: \(conversationSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func setLastReadMessageIndex(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String,
              let lastReadMessageIndex = arguments["lastReadMessageIndex"] as? NSNumber else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setLastReadMessageIndex(lastReadMessageIndex, completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        flutterResult(count)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(result.error.debugDescription))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error setting last consumed message index (index: \(lastReadMessageIndex)) for conversation (sid: \(conversationSid))", details: nil))
                    }
                })
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
}

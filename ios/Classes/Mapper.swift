import Flutter
import TwilioConversationsClient

public class Mapper {
    public static func conversationsClientToDict(_ client: TwilioConversationsClient?) -> [String: Any] {
        return [
            "conversations": conversationsToDict(client?.myConversations()) as Any,
            "myIdentity": client?.user?.identity as Any,
            "connectionState": clientConnectionStateToString(client?.connectionState),
            "isReachabilityEnabled": client?.isReachabilityEnabled() as Any
        ]
    }
    
    public static func conversationsToDict(_ conversations: [TCHConversation]?) -> [[String: Any]?]? {
        return conversations?.map { conversationToDict($0) }
    }
    
    public static func conversationToDict(_ conversation: TCHConversation?) -> [String: Any]? {
        guard let conversation = conversation,
              let sid = conversation.sid else {
            return nil
        }
        
        if !SwiftTwilioConversationsPlugin.conversationChannels.keys.contains(sid) {
            SwiftTwilioConversationsPlugin.conversationChannels[sid] = FlutterEventChannel(name: "twilio_conversations/\(sid)", binaryMessenger: SwiftTwilioConversationsPlugin.messenger!)
            SwiftTwilioConversationsPlugin.conversationChannels[sid]?.setStreamHandler(ChannelStreamHandler(conversation))
        }
        
        return [
            "attributes": attributesToDict(conversation.attributes()) as Any,
            "createdBy": conversation.createdBy as Any,
            "dateCreated": dateToString(conversation.dateCreatedAsDate) as Any,
            "dateUpdated": dateToString(conversation.dateUpdatedAsDate) as Any,
            "friendlyName": conversation.friendlyName as Any,
            "lastMessageDate": dateToString(conversation.lastMessageDate) as Any,
            "lastMessageIndex": conversation.lastMessageIndex as Any,
            "lastReadMessageIndex": conversation.lastReadMessageIndex as Any,
            "sid": sid,
            "status": conversationStatusToString(conversation.status),
            "synchronizationStatus": conversationSynchronizationStatusToString(conversation.synchronizationStatus),
            "uniqueName": conversation.uniqueName as Any
        ]
    }
    
    public static func messageToDict(_ message: TCHMessage, conversationSid: String?) -> [String: Any?] {
        return [
            "sid": message.sid,
            "author": message.author,
            "dateCreated": message.dateCreated,
            "messageBody": message.body,
            "conversationSid": conversationSid,
            "participantSid": message.participantSid,
            "participant": participantToDict(message.participant, conversationSid: conversationSid),
            "messageIndex": message.index,
            "type": messageTypeToString(message.messageType),
            "hasMedia": message.hasMedia(),
            "media": mediaToDict(message, conversationSid),
            "attributes": attributesToDict(message.attributes())
        ]
    }
    
    public static func participantToDict(_ participant: TCHParticipant?, conversationSid: String?) -> [String: Any?]? {
        guard let participant = participant else {
            return nil
        }
        return [
            "sid": participant.sid,
            "conversationSid": conversationSid,
            "lastReadMessageIndex": participant.lastReadMessageIndex,
            "lastReadTimestamp": participant.lastReadTimestamp,
            "dateCreated": participant.dateCreated,
            "dateUpdated": participant.dateUpdated,
            "identity": participant.identity,
            "type": participantTypeToString(participant.type)
        ]
    }
    
    public static func userToDict(_ user: TCHUser?) -> [String: Any]? {
        guard let user = user else {
            return nil
        }
        return [
            "friendlyName": user.friendlyName as Any,
            "attributes": attributesToDict(user.attributes()) as Any,
            "identity": user.identity as Any,
            "isOnline": user.isOnline(),
            "isNotifiable": user.isNotifiable(),
            "isSubscribed": user.isSubscribed()
        ]
    }
    
    public static func mediaToDict(_ message: TCHMessage, _ conversationSid: String?) -> [String: Any?]? {
        if !message.hasMedia() {
            return nil
        }
        return [
            "sid": message.mediaSid,
            "fileName": message.mediaFilename,
            "type": message.mediaType,
            "size": message.mediaSize,
            "conversationSid": conversationSid,
            "messageIndex": message.index
        ]
    }
    
    public static func attributesToDict(_ attributes: TCHJsonAttributes?) -> [String: Any?]? {
        if let attr = attributes as TCHJsonAttributes? {
            if attr.isNull {
                return [
                    "type": "NULL",
                    "data": nil
                ]
            } else if attr.isNumber {
                return [
                    "type": "NUMBER",
                    "data": attr.number?.stringValue
                ]
            } else if attr.isArray {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.array as Any) else {
                    return nil
                }
                return [
                    "type": "ARRAY",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            } else if attr.isString {
                return [
                    "type": "STRING",
                    "data": attr.string
                ]
            } else if attr.isDictionary {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: attr.dictionary as Any) else {
                    return nil
                }
                return [
                    "type": "OBJECT",
                    "data": String(data: jsonData, encoding: String.Encoding.utf8)
                ]
            }
        }
        return nil
    }
    
    public static func dictToAttributes(_ dict: [String: Any?]) -> TCHJsonAttributes {
        return TCHJsonAttributes.init(dictionary: dict as [AnyHashable: Any])
    }
    
    public static func errorToDict(_ error: Error?) -> [String: Any?]? {
        if let error = error as NSError? {
            return [
                "code": error.code,
                "message": error.description
            ]
        }
        
        return nil
    }
    
    public static func conversationStatusToString(_ conversationStatus: TCHConversationStatus) -> String {
        let conversationStatusString: String
        
        switch conversationStatus {
        case .joined:
            conversationStatusString = "JOINED"
        case .notParticipating:
            conversationStatusString = "NOT_PARTICIPATING"
        @unknown default:
            conversationStatusString = "UNKNOWN"
        }
        
        return conversationStatusString
    }
    
    public static func clientConnectionStateToString(_ connectionState: TCHClientConnectionState?) -> String {
        var connectionStateString: String = "UNKNOWN"
        if let connectionState = connectionState {
            switch connectionState {
            case .unknown:
                connectionStateString = "UNKNOWN"
            case .disconnected:
                connectionStateString = "DISCONNECTED"
            case .connected:
                connectionStateString = "CONNECTED"
            case .connecting:
                connectionStateString = "CONNECTING"
            case .denied:
                connectionStateString = "DENIED"
            case .error:
                connectionStateString = "ERROR"
            case .fatalError:
                connectionStateString = "FATAL_ERROR"
            default:
                connectionStateString = "UNKNOWN"
            }
        }
        
        return connectionStateString
    }
    
    public static func clientSynchronizationStatusToString(_ syncStatus: TCHClientSynchronizationStatus?) -> String {
        var syncStateString: String = "UNKNOWN"
        if let syncStatus = syncStatus {
            switch syncStatus {
            case .started:
                syncStateString = "STARTED"
            case .completed:
                syncStateString = "COMPLETED"
            case .conversationsListCompleted:
                syncStateString = "CONVERSATIONS_COMPLETED"
            case .failed:
                syncStateString = "FAILED"
            @unknown default:
                syncStateString = "UNKNOWN"
            }
        }
        
        return syncStateString
    }
    
    public static func conversationSynchronizationStatusToString(_ syncStatus: TCHConversationSynchronizationStatus) -> String {
        let syncStatusString: String
        
        switch syncStatus {
        case .none:
            syncStatusString = "NONE"
        case .identifier:
            syncStatusString = "IDENTIFIER"
        case .metadata:
            syncStatusString = "METADATA"
        case .all:
            syncStatusString = "ALL"
        case .failed:
            syncStatusString = "FAILED"
        @unknown default:
            syncStatusString = "UNKNOWN"
        }
        
        return syncStatusString
    }
    
    public static func conversationUpdateToString(_ update: TCHConversationUpdate) -> String {
        switch update {
        case .attributes:
            return "ATTRIBUTES"
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .lastMessage:
            return "LAST_MESSAGE"
        case .lastReadMessageIndex:
            return "LAST_READ_MESSAGE_INDEX"
        case .state:
            return "STATE"
        case .status:
            return "STATUS"
        case .uniqueName:
            return "UNIQUE_NAME"
        case .userNotificationLevel:
            return "NOTIFICATION_LEVEL"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    public static func participantTypeToString(_ participantType: TCHParticipantType) -> String {
        let participantTypeString: String
        
        switch participantType {
        case .chat:
            participantTypeString = "CHAT"
        case .other:
            participantTypeString = "OTHER"
        case .sms:
            participantTypeString = "SMS"
        case .unset:
            participantTypeString = "UNSET"
        case .whatsapp:
            participantTypeString = "WHATSAPP"
        @unknown default:
            participantTypeString = "UNKNOWN"
        }
        
        return participantTypeString
    }
    
    public static func messageTypeToString(_ messageType: TCHMessageType) -> String {
        let messageTypeString: String
        
        switch messageType {
        case .media:
            messageTypeString = "MEDIA"
        case .text:
            messageTypeString = "TEXT"
        @unknown default:
            messageTypeString = "UNKNOWN"
        }
        
        return messageTypeString
    }
    
    public static func messageUpdateToString(_ update: TCHMessageUpdate) -> String {
        let updateString: String
        
        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .body:
            updateString = "BODY"
        case .deliveryReceipt:
            updateString = "DELIVERY_RECEIPT"
        @unknown default:
            updateString = "UNKNOWN"
        }
        
        return updateString
    }
    
    public static func participantUpdateToString(_ update: TCHParticipantUpdate) -> String {
        let updateString: String
        
        switch update {
        case .attributes:
            updateString = "ATTRIBUTES"
        case .lastReadMessageIndex:
            updateString = "LAST_READ_MESSAGE_INDEX"
        case .lastReadTimestamp:
            updateString = "LAST_READ_TIMESTAMP"
        @unknown default:
            updateString = "UNKNOWN"
        }
        
        return updateString
    }
    
    public static func userUpdateToString(_ update: TCHUserUpdate) -> String {
        switch update {
        case .friendlyName:
            return "FRIENDLY_NAME"
        case .attributes:
            return "ATTRIBUTES"
        case .reachabilityOnline:
            return "REACHABILITY_ONLINE"
        case .reachabilityNotifiable:
            return "REACHABILITY_NOTIFIABLE"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    public static func dateToString(_ date: Date?) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            return formatter.string(from: date)
        }
        return nil
    }
    
    class func encode(_ value: Any?) -> String? {
        guard let value = value else {
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("error encoding value")
            print(error.localizedDescription)
            return nil
        }
    }
    
    class ChannelStreamHandler: NSObject, FlutterStreamHandler {
        let conversation: TCHConversation
        
        init(_ conversation: TCHConversation) {
            self.conversation = conversation
        }
        
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            if let sid = conversation.sid {
                SwiftTwilioConversationsPlugin.debug("Mapper.conversationToDict => EventChannel for Conversation($\(String(describing: sid)) attached")
                SwiftTwilioConversationsPlugin.conversationListeners[sid] = ConversationListener(events)
                conversation.delegate = SwiftTwilioConversationsPlugin.conversationListeners[sid]
            }
            return nil
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            if let sid = conversation.sid {
                SwiftTwilioConversationsPlugin.debug("Mapper.conversationToDict => EventChannel for Conversation($\(String(describing: sid)) detached")
                conversation.delegate = nil
                SwiftTwilioConversationsPlugin.conversationListeners.removeValue(forKey: sid)
            }
            return nil
        }
    }
}

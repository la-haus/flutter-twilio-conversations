import Flutter
import SwiftyJSON
import TwilioConversationsClient

// swiftlint:disable file_length type_body_length
public class Mapper {
    static let TAG = "Mapper"

    public static func conversationsClientToPigeon(
        _ client: TwilioConversationsClient?) -> TWCONConversationClientData? {
        guard let client = client else {
            return nil
        }
        let result = TWCONConversationClientData()
        result.myIdentity = client.user?.identity
        result.connectionState = clientConnectionStateToString(client.connectionState)
        result.isReachabilityEnabled = NSNumber(value: client.isReachabilityEnabled())
        return result
    }

    public static func conversationsList(_ conversations: [TCHConversation]?) -> [TWCONConversationData]? {
        return conversations?.compactMap { conversationToPigeon($0) }
    }

    public static func conversationToPigeon(_ conversation: TCHConversation?) -> TWCONConversationData? {
        guard let conversation = conversation,
              let sid = conversation.sid else {
            return nil
        }

        if !SwiftTwilioConversationsPlugin.conversationListeners.keys.contains(sid) {
            debug("setupConversationListener => conversation: \(String(describing: conversation.sid))")
            SwiftTwilioConversationsPlugin.conversationListeners[sid] = ConversationListener(sid)
            conversation.delegate = SwiftTwilioConversationsPlugin.conversationListeners[sid]
        }

        let result = TWCONConversationData()
        result.attributes = attributesToPigeon(conversation.attributes())
        result.createdBy = conversation.createdBy
        result.dateCreated = dateToString(conversation.dateCreatedAsDate)
        result.dateUpdated = dateToString(conversation.dateUpdatedAsDate)
        result.friendlyName = conversation.friendlyName
        result.lastMessageDate = dateToString(conversation.lastMessageDate)
        result.lastMessageIndex = conversation.lastMessageIndex
        result.lastReadMessageIndex = conversation.lastReadMessageIndex
        result.sid = sid
        result.status = conversationStatusToString(conversation.status)
        result.synchronizationStatus = conversationSynchronizationStatusToString(conversation.synchronizationStatus)
        result.uniqueName = conversation.uniqueName
        return result
    }

    public static func messageToPigeon(_ message: TCHMessage, conversationSid: String?) -> TWCONMessageData {
        let result = TWCONMessageData()
        result.sid = message.sid
        result.author = message.author
        result.dateCreated = message.dateCreated
        result.dateUpdated = message.dateUpdated
        result.lastUpdatedBy = message.lastUpdatedBy
        result.messageBody = message.body
        result.conversationSid = conversationSid
        result.participantSid = message.participantSid
//        result.participant = participantToDict(message.participant, conversationSid: conversationSid)
        result.messageIndex = message.index
        result.type = messageTypeToString(message.messageType)
        result.hasMedia = NSNumber(value: message.hasMedia())
        result.media = mediaToPigeon(message, conversationSid)
        result.attributes = attributesToPigeon(message.attributes())
        return result
    }

    public static func participantToPigeon(
        _ participant: TCHParticipant?,
        conversationSid: String?) -> TWCONParticipantData? {
        guard let participant = participant else {
            return nil
        }

        let result = TWCONParticipantData()
        result.sid = participant.sid
        result.conversationSid = conversationSid
        result.lastReadMessageIndex = participant.lastReadMessageIndex
        result.lastReadTimestamp = participant.lastReadTimestamp
        result.dateCreated = participant.dateCreated
        result.dateUpdated = participant.dateUpdated
        result.identity = participant.identity
        result.type = participantTypeToString(participant.type)
        result.attributes = attributesToPigeon(participant.attributes())
        return result
    }

    public static func userToPigeon(_ user: TCHUser?) -> TWCONUserData? {
        guard let user = user else {
            return nil
        }
        let result = TWCONUserData()
        result.friendlyName = user.friendlyName
        result.attributes = attributesToPigeon(user.attributes())
        result.identity = user.identity
        result.isOnline = NSNumber(value: user.isOnline())
        result.isNotifiable = NSNumber(value: user.isNotifiable())
        result.isSubscribed = NSNumber(value: user.isSubscribed())
        return result
    }

    public static func mediaToPigeon(_ message: TCHMessage, _ conversationSid: String?) -> TWCONMessageMediaData? {
        if !message.hasMedia() {
            return nil
        }

        let result = TWCONMessageMediaData()
        result.sid = message.mediaSid
        result.fileName = message.mediaFilename
        result.type = message.mediaType
        result.size = NSNumber(value: message.mediaSize)
        result.conversationSid = conversationSid
        result.messageIndex = message.index
        result.messageSid = message.sid
        return result
    }

    public static func attributesToPigeon(_ attributes: TCHJsonAttributes?) -> TWCONAttributesData? {
        let result = TWCONAttributesData()
        result.type = "NULL"
        result.data = nil

            if let attr = attributes as TCHJsonAttributes? {
                if attr.isNumber {
                    result.type = "NUMBER"
                    result.data = attr.number?.stringValue
                } else if attr.isArray {
                    let jsonData = JSON(attr.array)
                    result.type = "ARRAY"
                    if #available(iOS 13.0, *) {
                        result.data = jsonData.rawString(options: .withoutEscapingSlashes)
                    } else {
                        // Fallback on earlier versions
                        result.data = jsonData.rawString()
                    }
                } else if attr.isString {
                    result.type = "STRING"
                    result.data = attr.string
                } else if attr.isDictionary {
                    let jsonData = JSON(attr.dictionary as Any)
                    result.type = "OBJECT"
                    if #available(iOS 13.0, *) {
                        result.data = jsonData.rawString(options: .withoutEscapingSlashes)
                    } else {
                        // Fallback on earlier versions
                        result.data = jsonData.rawString()
                    }
                }
            }
        debug("attributesToPigeon => \(result.data)")
        return result
    }

    public static func pigeonToAttributes(_ attributesData: TWCONAttributesData) throws -> TCHJsonAttributes? {
        var result: TCHJsonAttributes?
        do {
            switch attributesData.type {
            case "NULL":
                result = nil
            case "NUMBER":
                let number = NumberFormatter().number(from: attributesData.data!)
                result = TCHJsonAttributes(number: number!)
            case "ARRAY":
                guard let objectData = attributesData.data!.data(using: .utf8),
                      let array = try JSON(data: objectData).arrayObject else {
                    throw LocalizedConversionError.invalidData
                }

                result = TCHJsonAttributes(array: array)
            case "STRING":
                result = TCHJsonAttributes(string: attributesData.data!)
            case "OBJECT":
                guard let objectData = attributesData.data!.data(using: .utf8),
                      let object = try JSON(data: objectData).dictionaryObject else {
                    throw LocalizedConversionError.invalidData
                }

                result = TCHJsonAttributes(dictionary: object)
            default:
                throw LocalizedConversionError.invalidType
            }
        } catch let error {
            debug("pigeonToAttributes => ERROR \(error)")
            return nil
        }
        debug("pigeonToAttributes => \(result)")
        return result
    }

    public static func stringToNotificationLevel(_ level: String) -> TCHConversationNotificationLevel? {
        switch level {
        case "DEFAULT":
            return TCHConversationNotificationLevel.default
        case "MUTED":
            return TCHConversationNotificationLevel.muted
        default:
            return nil
        }
    }

    public static func errorToPigeon(_ error: TCHError) -> TWCONErrorInfoData {
        let errorInfoData = TWCONErrorInfoData()
        errorInfoData.code = NSNumber(value: error.code)
        errorInfoData.message = error.description
        return errorInfoData
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

    public static func conversationSynchronizationStatusToString(
        _ syncStatus: TCHConversationSynchronizationStatus) -> String {
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
        case .subject:
            updateString = "SUBJECT"
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

    private static func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}

enum LocalizedConversionError: LocalizedError {
    case invalidType
    case invalidData
}

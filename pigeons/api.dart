import 'package:pigeon/pigeon.dart';

class ConversationClientData {
  String? myIdentity;
  String? connectionState;
  bool? isReachabilityEnabled;
}

class PropertiesData {
  String? region;
}

class ConversationData {
  String? sid;
  AttributesData? attributes;
  String? uniqueName;
  String? friendlyName;
  String? status;
  String? synchronizationStatus;
  String? dateCreated;
  String? createdBy;
  String? dateUpdated;
  String? lastMessageDate;
  int? lastReadMessageIndex;
  int? lastMessageIndex;
}

class AttributesData {
  String? type;
  String? data;
}

class TokenData {
  String? token;
}

class MessageMediaData {
  String? sid;
  String? fileName;
  String? type;
  int? size;
  String? conversationSid;
  String? messageSid;
  int? messageIndex;
}

class MessageData {
  String? sid;
  int? messageIndex;
  String? author;
  String? subject;
  String? messageBody;
  String? type;
  bool? hasMedia;
  MessageMediaData? media;
  String? conversationSid;
  String? participantSid;
  String? dateCreated;
  String? dateUpdated;
  String? lastUpdatedBy;
  AttributesData? attributes;
}

class MessageOptionsData {
  String? body;
  AttributesData? attributes;
  String? mimeType;
  String? filename;
  String? inputPath;
  int? mediaProgressListenerId;
}

class ParticipantData {
  String? sid;
  String? conversationSid;
  String? type;
  AttributesData? attributes;
  String? dateCreated;
  String? dateUpdated;
  String? identity;
  int? lastReadMessageIndex;
  String? lastReadTimestamp;
}

class UserData {
  String? identity;
  AttributesData? attributes;
  String? friendlyName;
  bool? isNotifiable;
  bool? isOnline;
  bool? isSubscribed;
}

class MessageCount {
  int? count;
}

class ConversationUpdatedData {
  ConversationData? conversation;
  String? reason;
}

class ErrorInfoData {
  int? code;
  String? message;
  int? status;
}

@HostApi()
abstract class PluginApi {
  void debug(bool enableNative, bool enableSdk);

  @async
  ConversationClientData create(String jwtToken, PropertiesData properties);
}

@HostApi()
abstract class ConversationClientApi {
  @async
  void updateToken(String token);

  void shutdown();

  @async
  ConversationData createConversation(String friendlyName);

  @async
  List<ConversationData> getMyConversations();

  @async
  ConversationData getConversation(String conversationSidOrUniqueName);

  @async
  UserData getMyUser();

  @async
  void registerForNotification(TokenData tokenData);

  @async
  void unregisterForNotification(TokenData tokenData);
}

@HostApi()
abstract class ConversationApi {
  @async
  void join(String conversationSid);

  @async
  void leave(String conversationSid);

  @async
  void destroy(String conversationSid);

  @async
  void typing(String conversationSid);

  @async
  MessageData sendMessage(String conversationSid, MessageOptionsData options);

  @async
  bool addParticipantByIdentity(String conversationSid, String identity);

  @async
  bool removeParticipant(String conversationSid, String participantSid);

  @async
  bool removeParticipantByIdentity(String conversationSid, String identity);

  @async
  ParticipantData getParticipantByIdentity(
      String conversationSid, String identity);

  @async
  ParticipantData getParticipantBySid(
      String conversationSid, String participantSid);

  @async
  List<ParticipantData> getParticipantsList(String conversationSid);

  @async
  MessageCount getMessagesCount(String conversationSid);

  @async
  int getUnreadMessagesCount(String conversationSid);

  @async
  MessageCount advanceLastReadMessageIndex(
      String conversationSid, int lastReadMessageIndex);

  @async
  MessageCount setLastReadMessageIndex(
      String conversationSid, int lastReadMessageIndex);

  @async
  MessageCount setAllMessagesRead(String conversationSid);

  @async
  MessageCount setAllMessagesUnread(String conversationSid);

  @async
  int getParticipantsCount(String conversationSid);

  @async
  List<MessageData> getMessagesAfter(
      String conversationSid, int index, int count);

  @async
  List<MessageData> getMessagesBefore(
      String conversationSid, int index, int count);

  @async
  MessageData getMessageByIndex(String conversationSid, int messageIndex);

  @async
  List<MessageData> getLastMessages(String conversationSid, int count);

  @async
  bool removeMessage(String conversationSid, int messageIndex);

  @async
  void setAttributes(String conversationSid, AttributesData attributes);

  @async
  void setFriendlyName(String conversationSid, String friendlyName);

  @async
  void setNotificationLevel(String conversationSid, String notificationLevel);

  @async
  void setUniqueName(String conversationSid, String uniqueName);
}

@HostApi()
abstract class ParticipantApi {
  @async
  UserData getUser(String conversationSid, String participantSid);

  @async
  void setAttributes(
      String conversationSid, String participantSid, AttributesData attributes);

  @async
  void remove(String conversationSid, String participantSid);
}

@HostApi()
abstract class MessageApi {
  @async
  String getMediaContentTemporaryUrl(String conversationSid, int messageIndex);

  @async
  ParticipantData getParticipant(String conversationSid, int messageIndex);

  @async
  void setAttributes(
      String conversationSid, int messageIndex, AttributesData attributes);

  @async
  void updateMessageBody(
      String conversationSid, int messageIndex, String messageBody);
}

@HostApi()
abstract class UserApi {
  @async
  void setFriendlyName(String identity, String friendlyName);

  @async
  void setAttributes(String identity, AttributesData attributes);
}

@FlutterApi()
abstract class FlutterConversationClientApi {
  void error(ErrorInfoData errorInfoData);

  void conversationAdded(ConversationData conversationData);

  void conversationUpdated(ConversationUpdatedData event);

  void conversationDeleted(ConversationData conversationData);

  void clientSynchronization(String synchronizationStatus);

  void conversationSynchronizationChange(ConversationData conversationData);

  void connectionStateChange(String connectionState);

  void tokenAboutToExpire();

  void tokenExpired();

  void userSubscribed(UserData userData);

  void userUnsubscribed(UserData userData);

  void userUpdated(UserData userData, String reason);

  // Notification Events
  void addedToConversationNotification(String conversationSid);

  void newMessageNotification(String conversationSid, int messageIndex);

  void notificationSubscribed();

  void notificationFailed(ErrorInfoData errorInfoData);

  void removedFromConversationNotification(String conversationSid);

  void registered();

  void registrationFailed(ErrorInfoData errorInfoData);

  void deregistered();

  void deregistrationFailed(ErrorInfoData errorInfoData);

  // Conversation Api
  void messageAdded(String conversationSid, MessageData messageData);

  void messageUpdated(
      String conversationSid, MessageData messageData, String reason);

  void messageDeleted(String conversationSid, MessageData messageData);

  void participantAdded(
      String conversationSid, ParticipantData participantData);

  void participantUpdated(
      String conversationSid, ParticipantData participantData, String reason);

  void participantDeleted(
      String conversationSid, ParticipantData participantData);

  void typingStarted(String conversationSid, ConversationData conversationData,
      ParticipantData participantData);

  void typingEnded(String conversationSid, ConversationData conversationData,
      ParticipantData participantData);

  void synchronizationChanged(
      String conversationSid, ConversationData conversationData);
}

@FlutterApi()
abstract class FlutterLoggingApi {
  void logFromHost(String msg);
}

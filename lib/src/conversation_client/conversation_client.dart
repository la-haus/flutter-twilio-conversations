import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class ConversationClient extends FlutterConversationClientApi {
  Map<String, Conversation> conversations = <String, Conversation>{};

  String? myIdentity;
  ConnectionState connectionState = ConnectionState.UNKNOWN;

  bool _isReachabilityEnabled = false;
  bool get isReachabilityEnabled => _isReachabilityEnabled;

  final StreamController<String> _onAddedToConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for added to Conversation event.
  late Stream<String> onAddedToConversationNotification;

  final StreamController<Conversation> _onConversationAddedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when the current user has a conversation added to their conversation list, conversation status is not specified.
  late Stream<Conversation> onConversationAdded;

  final StreamController<Conversation> _onConversationDeletedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when one of the conversation of the current user is deleted.
  late Stream<Conversation> onConversationDeleted;

  final StreamController<ConnectionState> _onConnectionStateCtrl =
      StreamController<ConnectionState>.broadcast();

  /// Called when client connnection state has changed.
  late Stream<ConnectionState> onConnectionState;

  final StreamController<ClientSynchronizationStatus>
      _onClientSynchronizationCtrl =
      StreamController<ClientSynchronizationStatus>.broadcast();

  /// Called when client synchronization status changes.
  late Stream<ClientSynchronizationStatus> onClientSynchronization;

  final StreamController<Conversation>
      _onConversationSynchronizationChangeCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when conversation synchronization status changed.
  ///
  /// Use [Conversation.synchronizationStatus] to obtain new conversation status.
  late Stream<Conversation> onConversationSynchronizationChange;

  final StreamController<ConversationUpdatedEvent> _onConversationUpdatedCtrl =
      StreamController<ConversationUpdatedEvent>.broadcast();

  /// Called when the conversation is updated.
  ///
  /// [Conversation] synchronization updates are delivered via different callback.
  late Stream<ConversationUpdatedEvent> onConversationUpdated;

  final StreamController<ErrorInfo> _onErrorCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when an error condition occurs.
  late Stream<ErrorInfo> onError;

  final StreamController<NewMessageNotificationEvent>
      _onNewMessageNotificationCtrl =
      StreamController<NewMessageNotificationEvent>.broadcast();

  /// Called when client receives a push notification for new message.
  late Stream<NewMessageNotificationEvent> onNewMessageNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationRegisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationRegistered;

  final StreamController<String> _onRemovedFromConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for removed from conversation event.
  late Stream<String> onRemovedFromConversationNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationDeregisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationDeregistered;

  final StreamController<ErrorInfo> _onNotificationFailedCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when registering for push notifications fails.
  late Stream<ErrorInfo> onNotificationFailed;

  //#region Token events
  final StreamController<void> _onTokenAboutToExpireCtrl =
      StreamController<void>.broadcast();

  /// Called when token is about to expire soon.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  late Stream<void> onTokenAboutToExpire;

  final StreamController<void> _onTokenExpiredCtrl =
      StreamController<void>.broadcast();

  /// Called when token has expired.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  late Stream<void> onTokenExpired;

  final StreamController<User> _onUserSubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is subscribed to and will receive realtime state updates.
  late Stream<User> onUserSubscribed;

  final StreamController<User> _onUserUnsubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is unsubscribed from and will not receive realtime state updates anymore.
  late Stream<User> onUserUnsubscribed;

  final StreamController<UserUpdatedEvent> _onUserUpdatedCtrl =
      StreamController<UserUpdatedEvent>.broadcast();

  /// Called when user info is updated for currently loaded users.
  late Stream<UserUpdatedEvent> onUserUpdated;

  ConversationClient() {
    // Conversation events
    onConversationAdded = _onConversationAddedCtrl.stream;
    onConversationDeleted = _onConversationDeletedCtrl.stream;
    onConversationSynchronizationChange =
        _onConversationSynchronizationChangeCtrl.stream;
    onConversationUpdated = _onConversationUpdatedCtrl.stream;

    // Conversation client events
    onError = _onErrorCtrl.stream;
    onClientSynchronization = _onClientSynchronizationCtrl.stream;
    onConnectionState = _onConnectionStateCtrl.stream;
    onTokenExpired = _onTokenExpiredCtrl.stream;
    onTokenAboutToExpire = _onTokenAboutToExpireCtrl.stream;

    // User Events
    onUserSubscribed = _onUserSubscribedCtrl.stream;
    onUserUnsubscribed = _onUserUnsubscribedCtrl.stream;
    onUserUpdated = _onUserUpdatedCtrl.stream;

    // Push notification events
    onNewMessageNotification = _onNewMessageNotificationCtrl.stream;
    onAddedToConversationNotification =
        _onAddedToConversationNotificationCtrl.stream;
    onRemovedFromConversationNotification =
        _onRemovedFromConversationNotificationCtrl.stream;
    onNotificationDeregistered = _onNotificationDeregisteredCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;
    onNotificationRegistered = _onNotificationRegisteredCtrl.stream;

    FlutterConversationClientApi.setup(this);
  }

  void updateFromMap(Map<String, dynamic> json) {
    myIdentity = json['myIdentity'] as String;
    connectionState = EnumToString.fromString(
            ConnectionState.values, json['connectionState']) ??
        ConnectionState.UNKNOWN;
    _isReachabilityEnabled = json['isReachabilityEnabled'] ?? false;
  }

  /// Updates the authentication token for this client.
  Future<void> updateToken(String token) async {
    try {
      return TwilioConversations().conversationsClientApi.updateToken(token);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Shuts down the conversation client.
  ///
  /// This will dispose() the client after shutdown, so the client cannot be used after this call.
  Future<void> shutdown() async {
    try {
      TwilioConversations.conversationClient = null;
      FlutterConversationClientApi.setup(null);
      await TwilioConversations().conversationsClientApi.shutdown();
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  // TODO: test push notification registration/deregistration and delivery
  /// Registers for push notifications. Uses APNs on iOS and FCM on Android.
  ///
  /// Twilio iOS SDK handles receiving messages when app is in the background and displaying
  /// notifications.
  Future<void> registerForNotification(String? token) async {
    try {
      final tokenData = TokenData()..token = token;
      await TwilioConversations()
          .conversationsClientApi
          .registerForNotification(tokenData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Unregisters for push notifications.  Uses APNs on iOS and FCM on Android.
  Future<void> unregisterForNotification(String? token) async {
    try {
      final tokenData = TokenData()..token = token;
      await TwilioConversations()
          .conversationsClientApi
          .unregisterForNotification(tokenData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  //#region Conversations
  Future<Conversation?> createConversation(
      {required String friendlyName}) async {
    try {
      final result = await TwilioConversations()
          .conversationsClientApi
          .createConversation(friendlyName);
      if (result.sid == null) {
        return null;
      }

      updateConversationFromMap(
          Map<String, dynamic>.from(result.encode() as Map));
      return conversations[result.sid];
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<Conversation?> getConversation(
      String conversationSidOrUniqueName) async {
    try {
      final result = await TwilioConversations()
          .conversationsClientApi
          .getConversation(conversationSidOrUniqueName);
      final conversationMap = Map<String, dynamic>.from(result.encode() as Map);
      updateConversationFromMap(conversationMap);
      return conversations[result.sid];
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<User?> getMyUser() async {
    try {
      final userData =
          await TwilioConversations().conversationsClientApi.getMyUser();
      return User.fromPigeon(userData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<List<Conversation>> getMyConversations() async {
    try {
      final result = await TwilioConversations()
          .conversationsClientApi
          .getMyConversations();

      final conversationsMapList = result
          .whereType<
              ConversationData>() // converts list contents type to non-nullable
          .map((ConversationData c) =>
              Map<String, dynamic>.from(c.encode() as Map))
          .toList();

      for (var element in conversationsMapList) {
        updateConversationFromMap(element);
      }

      return conversations.values.toList();
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  void updateConversationFromMap(Map<String, dynamic> map) {
    var sid = map['sid'] as String;
    if (conversations[sid] == null) {
      conversations[sid] = Conversation.fromMap(map);
    } else {
      conversations[sid]?.updateFromMap(map);
    }
  }
  //#endregion

  @override
  void conversationAdded(ConversationData conversationData) {
    TwilioConversations.log('conversationAdded => $conversationData');
    final conversationSid = conversationData.sid;
    if (conversationSid == null) {
      return;
    }
    updateConversationFromMap(
        Map<String, dynamic>.from(conversationData.encode() as Map));
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      _onConversationAddedCtrl.add(conversation);
    }
  }

  @override
  void conversationUpdated(ConversationUpdatedData event) {
    TwilioConversations.log(
        'conversationUpdated => ${event.reason} sid: ${event.conversation?.sid}');
    final conversationData = event.conversation;
    final reasonString = event.reason;
    final reason = reasonString != null
        ? EnumToString.fromString(ConversationUpdateReason.values, reasonString)
        : null;
    final conversationSid = conversationData?.sid;

    if (conversationData == null || reason == null || conversationSid == null) {
      return;
    }

    final conversation = conversations[conversationSid];
    if (conversation != null) {
      updateConversationFromMap(
          Map<String, dynamic>.from(conversationData.encode() as Map));
      _onConversationUpdatedCtrl
          .add(ConversationUpdatedEvent(conversation, reason));
    }
  }

  @override
  void clientSynchronization(String synchronizationStatus) {
    final synchronizationStatusEnum = EnumToString.fromString(
            ClientSynchronizationStatus.values, synchronizationStatus) ??
        ClientSynchronizationStatus.UNKNOWN;
    _onClientSynchronizationCtrl.add(synchronizationStatusEnum);
  }

  @override
  void conversationDeleted(ConversationData conversationData) {
    final conversationSid = conversationData.sid;
    if (conversationSid == null) {
      return;
    }
    final conversation = conversations[conversationSid];
    conversations.remove(conversationSid);
    if (conversation != null) {
      _onConversationDeletedCtrl.add(conversation);
    }
  }

  @override
  void conversationSynchronizationChange(ConversationData conversationData) {
    final conversationSid = conversationData.sid;
    if (conversationSid == null) {
      return;
    }
    updateConversationFromMap(
        Map<String, dynamic>.from(conversationData.encode() as Map));
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      _onConversationSynchronizationChangeCtrl.add(conversation);
    }
  }

  @override
  void connectionStateChange(String connectionState) {
    var newConnectionState =
        EnumToString.fromString(ConnectionState.values, connectionState);

    if (newConnectionState == null) {
      TwilioConversations.log(
          'ConversationClient::connectionStateChange => failed to parse connectionState: $connectionState');
      return;
    }

    this.connectionState = newConnectionState;
    _onConnectionStateCtrl.add(this.connectionState);
  }

  @override
  void addedToConversationNotification(String conversationSid) {
    _onAddedToConversationNotificationCtrl.add(conversationSid);
  }

  @override
  void error(ErrorInfoData errorInfoData) {
    final code = errorInfoData.code;
    final status = errorInfoData.status;

    if (code == null) {
      //TODO: review required fields
      return;
    }
    final exception = ErrorInfo(code, errorInfoData.message, status);

    _onErrorCtrl.add(exception);
  }

  @override
  void newMessageNotification(String conversationSid, int messageIndex) {
    _onNewMessageNotificationCtrl
        .add(NewMessageNotificationEvent(conversationSid, messageIndex));
  }

  @override
  void notificationFailed(ErrorInfoData errorInfoData) {
    // TODO: review notification registration failure handling
    // Ensure we're not creating duplicate notifications on Android due to using
    // registered from register success listener, and notificationSubscribed from
    // conversation client listener.
    final code = errorInfoData.code;
    final status = errorInfoData.status;

    if (code == null) {
      //TODO: review required fields
      return;
    }
    final exception = ErrorInfo(code, errorInfoData.message, status);
    _onNotificationFailedCtrl.add(exception);
  }

  @override
  void removedFromConversationNotification(String conversationSid) {
    _onRemovedFromConversationNotificationCtrl.add(conversationSid);
  }

  @override
  void deregistered() {
    _onNotificationDeregisteredCtrl
        .add(NotificationRegistrationEvent(true, null));
  }

  @override
  void deregistrationFailed(ErrorInfoData errorInfoData) {
    final exception = ErrorInfo(
        errorInfoData.code ?? 0, errorInfoData.message, errorInfoData.status);

    _onNotificationDeregisteredCtrl
        .add(NotificationRegistrationEvent(false, exception));
  }

  @override
  void registered() {
    _onNotificationRegisteredCtrl
        .add(NotificationRegistrationEvent(true, null));
  }

  @override
  void registrationFailed(ErrorInfoData errorInfoData) {
    final exception = ErrorInfo(
        errorInfoData.code ?? 0, errorInfoData.message, errorInfoData.status);

    _onNotificationRegisteredCtrl
        .add(NotificationRegistrationEvent(false, exception));
  }

  @override
  void tokenAboutToExpire() {
    _onTokenAboutToExpireCtrl.add(null);
  }

  @override
  void tokenExpired() {
    _onTokenExpiredCtrl.add(null);
  }

  @override
  void notificationSubscribed() {
    // TODO: implement notificationSubscribed
    // Ensure we're not creating duplicate notifications on Android due to using
    // registered from register success listener, and notificationSubscribed from
    // conversation client listener.
  }

  @override
  void userSubscribed(UserData userData) {
    final user = User.fromPigeon(userData);
    _onUserSubscribedCtrl.add(user);
  }

  @override
  void userUnsubscribed(UserData userData) {
    final user = User.fromPigeon(userData);
    _onUserUnsubscribedCtrl.add(user);
  }

  @override
  void userUpdated(UserData userData, String reason) {
    final user = User.fromPigeon(userData);
    final reasonEnum = EnumToString.fromString(UserUpdateReason.values, reason);
    if (reasonEnum != null) {
      _onUserUpdatedCtrl.add(UserUpdatedEvent(user, reasonEnum));
    }
  }

  @override
  void messageAdded(String conversationSid, MessageData messageData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.messageAdded(messageData);
    }
  }

  @override
  void messageDeleted(String conversationSid, MessageData messageData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.messageDeleted(messageData);
    }
  }

  @override
  void messageUpdated(
      String conversationSid, MessageData messageData, String reason) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.messageUpdated(messageData, reason);
    }
  }

  @override
  void participantAdded(
      String conversationSid, ParticipantData participantData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.participantAdded(participantData);
    }
  }

  @override
  void participantDeleted(
      String conversationSid, ParticipantData participantData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.participantDeleted(participantData);
    }
  }

  @override
  void participantUpdated(
      String conversationSid, ParticipantData participantData, String reason) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.participantDeleted(participantData);
    }
  }

  @override
  void synchronizationChanged(
      String conversationSid, ConversationData conversationData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.synchronizationChanged(conversationData);
    }
  }

  @override
  void typingEnded(String conversationSid, ConversationData conversationData,
      ParticipantData participantData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.typingEnded(conversationData, participantData);
    }
  }

  @override
  void typingStarted(String conversationSid, ConversationData conversationData,
      ParticipantData participantData) {
    final conversation = conversations[conversationSid];
    if (conversation != null) {
      conversation.typingStarted(conversationData, participantData);
    }
  }
}

import 'package:twilio_conversations/twilio_conversations.dart';

class ParticipantUpdatedEvent {
  final Participant participant;

  final ParticipantUpdateReason reason;

  ParticipantUpdatedEvent(this.participant, this.reason)
      : assert(participant != null),
        assert(reason != null);
}

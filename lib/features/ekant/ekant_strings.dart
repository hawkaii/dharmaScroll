/// Every new word the chat and talk rooms show, in one place so the strings
/// can move to ARB files together when localisation lands.
abstract final class EkantStrings {
  // Door
  static const String writeLabel = 'Write';
  static const String speakLabel = 'Speak';
  static const String doorPrivacy =
      'Your words stay on this phone. Let them fade when you are done, or keep them.';
  static const String doorWaiting = 'Your last conversation is still here.';

  // Chat
  static const String sendLabel = 'Send';
  static const String writeHint = 'Write here';
  static const String answerHint = 'Answer, or say more';
  static const String youSaid = 'You said';
  static const String ekantSaid = 'Ekant';
  static const String reflecting = 'Ekant is reflecting';
  static const String copyLabel = 'Copy';
  static const String copiedLabel = 'Copied';
  static const String shareLabel = 'Share';
  static const String studyLabel = 'Read this verse';
  static const String failedNote = 'The room went quiet. Please try again.';
  static const String shareFooter = 'From Ekant, in DharmaScroll';

  /// Quiet starting points. Tapping one puts it in the box to edit.
  static const List<String> openingLines = <String>[
    'Work has been weighing on me.',
    'I cannot stop worrying.',
    'I feel alone today.',
    'I am angry and cannot let it go.',
  ];

  // Talk
  static const String stateConnecting = 'Getting ready';
  static const String stateIdle = 'Ready';
  static const String stateListening = 'Listening';
  static const String stateThinking = 'Thinking';
  static const String stateSpeaking = 'Speaking';
  static const String stateMuted = 'Muted';
  static const String stateFailed = 'Could not connect';
  static const String muteLabel = 'Mute';
  static const String unmuteLabel = 'Unmute';
  static const String endLabel = 'End';
  static const String chatLabel = 'Switch to chat';
  static const String handsFreeLabel = 'Hands-free';
  static const String pushLabel = 'Push to talk';
  static const String holdLabel = 'Hold to talk';
  static const String releaseLabel = 'Release when done';
  static const String youCaption = 'You';
  static const String ekantCaption = 'Ekant';
  static const String captionsEmpty = 'Words appear here as you speak.';
  static const String retryLabel = 'Try again';

  // Microphone explainer
  static const String micTitle = 'Use your microphone?';
  static const String micBody =
      'To talk, the phone needs to hear you. Sound is only used while this room is open. The room shows your words as you speak.';
  static const String micAllow = 'Allow microphone';
  static const String micNotNow = 'Not now';
  static const String micDenied =
      'The microphone is off. You can allow it in the phone settings, or write instead.';
}

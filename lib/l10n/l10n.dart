import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  /// The app's words in the chosen language.
  AppLocalizations get l => AppLocalizations.of(this);
}

/// The Gita's own names and labels, in the chosen language. Unknown names are
/// shown as they are.
extension GitaWords on AppLocalizations {
  /// Krishna, Arjuna, Sanjaya, Dhritarashtra.
  String person(String name) => switch (name) {
    'Krishna' => personKrishna,
    'Arjuna' => personArjuna,
    'Sanjaya' => personSanjaya,
    'Dhritarashtra' => personDhritarashtra,
    _ => name,
  };

  /// The name of a chapter (1 to 18), e.g. Karma Yoga.
  String yoga(int chapter) => switch (chapter) {
    1 => yoga1,
    2 => yoga2,
    3 => yoga3,
    4 => yoga4,
    5 => yoga5,
    6 => yoga6,
    7 => yoga7,
    8 => yoga8,
    9 => yoga9,
    10 => yoga10,
    11 => yoga11,
    12 => yoga12,
    13 => yoga13,
    14 => yoga14,
    15 => yoga15,
    16 => yoga16,
    17 => yoga17,
    _ => yoga18,
  };

  /// A situation tag from the verse data, e.g. `exam-stress`.
  String tag(String t) => switch (t) {
    'grief' => tagGrief,
    'loss' => tagLoss,
    'fear' => tagFear,
    'anxiety' => tagAnxiety,
    'anger' => tagAnger,
    'envy' => tagEnvy,
    'comparison' => tagComparison,
    'pride' => tagPride,
    'desire' => tagDesire,
    'greed' => tagGreed,
    'restlessness' => tagRestlessness,
    'doubt' => tagDoubt,
    'self-doubt' => tagSelfDoubt,
    'confusion' => tagConfusion,
    'loneliness' => tagLoneliness,
    'burnout' => tagBurnout,
    'failure' => tagFailure,
    'success' => tagSuccess,
    'exam-stress' => tagExamStress,
    'work-pressure' => tagWorkPressure,
    'duty-conflict' => tagDutyConflict,
    'procrastination' => tagProcrastination,
    'perfectionism' => tagPerfectionism,
    'focus' => tagFocus,
    'discipline' => tagDiscipline,
    'habits' => tagHabits,
    'patience' => tagPatience,
    'equanimity' => tagEquanimity,
    'detachment' => tagDetachment,
    'forgiveness' => tagForgiveness,
    'compassion' => tagCompassion,
    'kindness' => tagKindness,
    'gratitude' => tagGratitude,
    'humility' => tagHumility,
    'faith' => tagFaith,
    'surrender' => tagSurrender,
    'purpose' => tagPurpose,
    'mortality' => tagMortality,
    'change' => tagChange,
    'self-worth' => tagSelfWorth,
    'speech' => tagSpeech,
    'contentment' => tagContentment,
    'peace' => tagPeace,
    'hope' => tagHope,
    'learning' => tagLearning,
    _ => t.replaceAll('-', ' '),
  };

  /// Why points were given (the reason saved with each one).
  String pointReason(String reason) => switch (reason) {
    'hear' => reasonHear,
    'walk' => reasonWalk,
    'speak' => reasonSpeak,
    'sankalp' => reasonSankalp,
    _ => reason,
  };

  /// Month 1 to 12, short in English and in full in Hindi.
  String month(int m) => switch (m) {
    1 => month1,
    2 => month2,
    3 => month3,
    4 => month4,
    5 => month5,
    6 => month6,
    7 => month7,
    8 => month8,
    9 => month9,
    10 => month10,
    11 => month11,
    _ => month12,
  };

  /// One small intention for the first of [tags] that has one.
  String intentionFor(Iterable<String> tags) {
    for (final String t in tags) {
      final String? line = switch (t) {
        'grief' => intentionGrief,
        'loss' => intentionLoss,
        'fear' => intentionFear,
        'anxiety' => intentionAnxiety,
        'anger' => intentionAnger,
        'envy' => intentionEnvy,
        'comparison' => intentionComparison,
        'pride' => intentionPride,
        'desire' => intentionDesire,
        'greed' => intentionGreed,
        'restlessness' => intentionRestlessness,
        'doubt' => intentionDoubt,
        'self-doubt' => intentionSelfDoubt,
        'confusion' => intentionConfusion,
        'loneliness' => intentionLoneliness,
        'burnout' => intentionBurnout,
        'failure' => intentionFailure,
        'success' => intentionSuccess,
        'exam-stress' => intentionExamStress,
        'work-pressure' => intentionWorkPressure,
        'duty-conflict' => intentionDutyConflict,
        'procrastination' => intentionProcrastination,
        'perfectionism' => intentionPerfectionism,
        'focus' => intentionFocus,
        'discipline' => intentionDiscipline,
        'habits' => intentionHabits,
        'patience' => intentionPatience,
        'equanimity' => intentionEquanimity,
        'detachment' => intentionDetachment,
        'forgiveness' => intentionForgiveness,
        'compassion' => intentionCompassion,
        'kindness' => intentionKindness,
        'gratitude' => intentionGratitude,
        'humility' => intentionHumility,
        'faith' => intentionFaith,
        'surrender' => intentionSurrender,
        'purpose' => intentionPurpose,
        'mortality' => intentionMortality,
        'change' => intentionChange,
        'self-worth' => intentionSelfWorth,
        'speech' => intentionSpeech,
        'contentment' => intentionContentment,
        'peace' => intentionPeace,
        'hope' => intentionHope,
        'learning' => intentionLearning,
        _ => null,
      };
      if (line != null) return line;
    }
    return intentionDefault;
  }

  /// What Arjuna was feeling, when the Gita shows it for this situation.
  String? arjunaWas(String tag) => switch (tag) {
    'fear' || 'anxiety' => wasAfraid,
    'grief' || 'loss' => wasGrieving,
    'confusion' => wasLost,
    'doubt' => wasDoubtful,
    'duty-conflict' => wasTorn,
    'self-doubt' || 'failure' => wasHeartLost,
    _ => null,
  };

  /// Quiet starting points for Ekant. Tapping one puts it in the box to edit.
  List<String> get ekOpenings => <String>[
    ekOpen1,
    ekOpen2,
    ekOpen3,
    ekOpen4,
  ];
}

import '../core/rituals/rituals.dart';
import 'app_localizations.dart';

/// The words for rituals, weekday lamps and festivals, in the chosen language.
extension RitualWords on AppLocalizations {
  String ritualLabel(Ritual r) => switch (r) {
    Ritual.dailyGita => ritualDailyGita,
    Ritual.sandhya => ritualSandhya,
    Ritual.diya => ritualDiya,
    Ritual.ekadashi => ritualEkadashi,
    Ritual.purnima => ritualPurnima,
    Ritual.amavasya => ritualAmavasya,
    Ritual.pradosh => ritualPradosh,
    Ritual.sankashti => ritualSankashti,
    Ritual.festivals => ritualFestivals,
  };

  /// One line per ritual, for a child, reverent. Glosses each word once.
  String ritualMeaning(Ritual r) => switch (r) {
    Ritual.dailyGita => meaningDailyGita,
    Ritual.sandhya => meaningSandhya,
    Ritual.diya => meaningDiya,
    Ritual.ekadashi => meaningEkadashi,
    Ritual.purnima => meaningPurnima,
    Ritual.amavasya => meaningAmavasya,
    Ritual.pradosh => meaningPradosh,
    Ritual.sankashti => meaningSankashti,
    Ritual.festivals => meaningFestivals,
  };

  String deityLabel(Deity d) => switch (d) {
    Deity.none => deityNone,
    Deity.shiva => deityShiva,
    Deity.hanuman => deityHanuman,
    Deity.vishnu => deityVishnu,
    Deity.shani => deityShani,
  };

  /// Short card text for a deity day.
  String deityMeaning(Deity d) => switch (d) {
    Deity.none => deityMeaningNone,
    Deity.shiva => deityMeaningShiva,
    Deity.hanuman => deityMeaningHanuman,
    Deity.vishnu => deityMeaningVishnu,
    Deity.shani => deityMeaningShani,
  };

  /// Weekday 1 (Monday) to 7 (Sunday), in full.
  String weekday(int d) => switch (d) {
    1 => weekday1,
    2 => weekday2,
    3 => weekday3,
    4 => weekday4,
    5 => weekday5,
    6 => weekday6,
    _ => weekday7,
  };

  /// Weekday 1 (Monday) to 7 (Sunday), short.
  String weekdayShort(int d) => switch (d) {
    1 => weekdayShort1,
    2 => weekdayShort2,
    3 => weekdayShort3,
    4 => weekdayShort4,
    5 => weekdayShort5,
    6 => weekdayShort6,
    _ => weekdayShort7,
  };

  /// A festival by the id used in `assets/panchang/festivals.json`.
  String festival(int id) => switch (id) {
    1 => festival1,
    2 => festival2,
    3 => festival3,
    4 => festival4,
    5 => festival5,
    6 => festival6,
    7 => festival7,
    8 => festival8,
    9 => festival9,
    10 => festival10,
    11 => festival11,
    12 => festival12,
    13 => festival13,
    14 => festival14,
    15 => festival15,
    16 => festival16,
    17 => festival17,
    18 => festival18,
    19 => festival19,
    20 => festival20,
    21 => festival21,
    22 => festival22,
    23 => festival23,
    24 => festival24,
    25 => festival25,
    26 => festival26,
    27 => festival27,
    28 => festival28,
    29 => festival29,
    30 => festival30,
    _ => festivalFallback,
  };
}

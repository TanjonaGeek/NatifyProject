import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDateUtil {
  // for getting formatted time from milliSecondsSinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // for getting formatted time for sent & read
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonth(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  //get last message time (used in chat user card)
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear
        ? '${sent.day} ${_getMonth(sent)} ${sent.year}'
        : '${sent.day} ${_getMonth(sent)}';
  }

  //get formatted last active time of user in chat screen
  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    String lastSeen = "TextHorsligne";
    String lastSeenToday = "lastseentoday";
    String lastSeenYesterday = "lastseenyesterday";
    String lastSeenLongtime = "lastseenlongtime";
    String lastSeenOn = "lastseenon";
    //if time is not available then return below statement
    if (i == -1) return lastSeen;

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == time.year) {
      return '$lastSeenToday $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return '$lastSeenYesterday $formattedTime';
    }

    String month = _getMonth(time);
    return '$lastSeenLongtime ${time.day} $month $lastSeenOn $formattedTime';
  }

  // get month name from month no. or index
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

  static String timeAgoSinceDate(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);
    String ilYa = "il y a".tr;
    String ans = "ans".tr;
    String unans = "un ans".tr;
    String mois = "mois".tr;
    String unmois = "un mois".tr;
    String semaine = "semaine".tr;
    String unesemaine = "une semaine".tr;
    String jours = "jours".tr;
    String unjours = "un jours".tr;
    String Instant = "Instant".tr;
    String Lastyear = "Last year".tr;
    String LastMonth = "Last month".tr;
    String LastWeek = "Last week".tr;
    String Yesterday = "Yesterday".tr;
    String AnHourAgo = "An hour ago".tr;

    if ((difference.inDays / 365).floor() >= 2) {
      return '$ilYa ${(difference.inDays / 365).floor()} $ans';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '$ilYa $unans' : Lastyear;
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '$ilYa ${(difference.inDays / 365).floor()} $mois';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '$ilYa $unmois' : LastMonth;
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '$ilYa ${(difference.inDays / 7).floor()} $semaine';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '$ilYa $unesemaine' : LastWeek;
    } else if (difference.inDays >= 2) {
      return '$ilYa ${difference.inDays} $jours';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '$ilYa $unjours' : Yesterday;
    } else if (difference.inHours >= 2) {
      return '$ilYa ${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '$ilYa 1 h' : AnHourAgo;
    } else if (difference.inMinutes >= 2) {
      return '$ilYa ${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '$ilYa 1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '$ilYa ${difference.inSeconds} s';
    } else {
      return Instant;
    }
  }

  static String timeAgoSinceDate3(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);
    String ans = "ans".tr;
    String unans = "un ans".tr;
    String mois = "mois".tr;
    String unmois = "un mois".tr;
    String semaine = "semaine".tr;
    String unesemaine = "une semaine".tr;
    String jours = "jours".tr;
    String unjours = "un jours".tr;
    String Instant = "Instant".tr;
    String Lastyear = "Last year".tr;
    String LastMonth = "Last month".tr;
    String LastWeek = "Last week".tr;
    String Yesterday = "Yesterday".tr;
    String AnHourAgo = "An hour ago".tr;

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} $ans';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? unans : Lastyear;
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} $mois';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? unmois : LastMonth;
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} $semaine';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? unesemaine : LastWeek;
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} $jours';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? unjours : Yesterday;
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 h' : AnHourAgo;
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} s';
    } else {
      return Instant;
    }
  }

  static String timeAgoSinceDate2(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} ans';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? 'un ans' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} mois';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 mois' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} semaine';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? 'une semaine' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} jours';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 jours' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} s';
    } else {
      return 'Instant';
    }
  }
}

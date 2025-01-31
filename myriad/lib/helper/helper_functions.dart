import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

String timeSince(Timestamp timestamp) {
  final now = DateTime.now();
  final DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
  final difference = now.difference(dateTime);

  final years = difference.inDays ~/ 365;
  if (years > 0) {
    return '${years}y';
  }

  final months = difference.inDays ~/ 30;
  if (months > 0) {
    return '${months}m';
  }

  final days = difference.inDays;
  if (days > 0) {
    return '${days}d';
  }

  final hours = difference.inHours;
  if (hours > 0) {
    return '${hours}h';
  }

  final minutes = difference.inMinutes;
  if (minutes > 0) {
    return '${minutes}m';
  }

  final seconds = difference.inSeconds;
  return '${seconds}s';
}

String timeSinceInSeconds(int seconds) {
  final duration = Duration(seconds: seconds);

  final years = duration.inDays ~/ 365;
  if (years > 0) {
    return '${years}y';
  }

  final months = duration.inDays ~/ 30;
  if (months > 0) {
    return '${months}m';
  }

  final days = duration.inDays;
  if (days > 0) {
    return '${days}d';
  }

  final hours = duration.inHours;
  if (hours > 0) {
    return '${hours}h';
  }

  final minutes = duration.inMinutes;
  if (minutes > 0) {
    return '${minutes}m';
  }

  return '${seconds}s';
}

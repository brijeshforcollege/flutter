class Skill {
  final String id;
  final String title;
  final String description;
  final String teacherName;
  final String teacherImage;
  final String timeSlot;
  int skillCoins;
  final DateTime date;
  final String category;
  final int maxParticipants;
  int currentParticipants;

  Skill({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherName,
    required this.teacherImage,
    required this.timeSlot,
    required this.skillCoins,
    required this.date,
    required this.category,
    required this.maxParticipants,
    required this.currentParticipants,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String imageUrl;
  final int skillCoins;
  final List<String> skillsTeaching;
  final List<String> skillsLearning;
  final String bio;
  final String mobile;

  UserProfile({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.skillCoins,
    required this.skillsTeaching,
    required this.skillsLearning,
    required this.bio,
    required this.mobile,
  });
}

class ScheduledMeet {
  final String id;
  final String skillName;
  final String teacherName;
  final DateTime dateTime;
  final String meetLink;
  String status; // upcoming, completed, cancelled

  ScheduledMeet({
    required this.id,
    required this.skillName,
    required this.teacherName,
    required this.dateTime,
    required this.meetLink,
    required this.status,
  });
}
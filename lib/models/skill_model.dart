import 'package:cloud_firestore/cloud_firestore.dart';

class Skill {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String teacherName;
  final String teacherEmail;
  final String teacherImage;
  final String timeSlot;
  final String category;
  final int skillCoins;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime datePosted;
  final DateTime scheduledDate;
  final String meetLink;
  final String status;

  Skill({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherImage,
    required this.timeSlot,
    required this.category,
    required this.skillCoins,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.datePosted,
    required this.scheduledDate,
    required this.meetLink,
    required this.status,
  });

  factory Skill.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Skill(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? 'Anonymous',
      teacherEmail: data['teacherEmail'] ?? '',
      teacherImage: data['teacherImage'] ?? '',
      timeSlot: data['timeSlot'] ?? '',
      category: data['category'] ?? '',
      skillCoins: data['skillCoins'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      datePosted: (data['datePosted'] as Timestamp).toDate(),
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      meetLink: data['meetLink'] ?? '',
      status: data['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'teacherImage': teacherImage,
      'timeSlot': timeSlot,
      'category': category,
      'skillCoins': skillCoins,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'datePosted': Timestamp.fromDate(datePosted),
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'meetLink': meetLink,
      'status': status,
    };
  }
}
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final int skillCoins;
  final List<String> skillsTeaching;
  final List<String> skillsLearning;
  final String bio;
  final String mobile;
  final DateTime joinDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.skillCoins,
    required this.skillsTeaching,
    required this.skillsLearning,
    required this.bio,
    required this.mobile,
    required this.joinDate,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      skillCoins: data['skillCoins'] ?? 0,
      skillsTeaching: List<String>.from(data['skillsTeaching'] ?? []),
      skillsLearning: List<String>.from(data['skillsLearning'] ?? []),
      bio: data['bio'] ?? '',
      mobile: data['mobile'] ?? '',
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'skillCoins': skillCoins,
      'skillsTeaching': skillsTeaching,
      'skillsLearning': skillsLearning,
      'bio': bio,
      'mobile': mobile,
      'joinDate': Timestamp.fromDate(joinDate),
    };
  }
}

class ScheduledMeet {
  final String id;
  final String skillId;
  final String skillName;
  final String teacherId;
  final String teacherName;
  final String studentId;
  final String studentName;
  final DateTime dateTime;
  final String meetLink;
  final String status; // upcoming, completed, cancelled

  ScheduledMeet({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.teacherId,
    required this.teacherName,
    required this.studentId,
    required this.studentName,
    required this.dateTime,
    required this.meetLink,
    required this.status,
  });

  factory ScheduledMeet.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ScheduledMeet(
      id: doc.id,
      skillId: data['skillId'] ?? '',
      skillName: data['skillName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      meetLink: data['meetLink'] ?? '',
      status: data['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentId': studentId,
      'studentName': studentName,
      'dateTime': Timestamp.fromDate(dateTime),
      'meetLink': meetLink,
      'status': status,
    };
  }
}
import '../models/skill_model.dart';

List<Skill> mockSkills = [
  Skill(
    id: '1',
    title: 'Flutter Development',
    description: 'Learn to build cross-platform apps with Flutter',
    teacherName: 'Alex Johnson',
    teacherImage: 'https://randomuser.me/api/portraits/men/32.jpg',
    timeSlot: '10:00 AM - 12:00 PM',
    skillCoins: 50,
    date: DateTime.now().add(const Duration(days: 2)),
    category: 'Programming',
    maxParticipants: 10,
    currentParticipants: 4,
  ),
  Skill(
    id: '2',
    title: 'Digital Painting',
    description: 'Master digital art techniques with Procreate',
    teacherName: 'Sarah Miller',
    teacherImage: 'https://randomuser.me/api/portraits/women/44.jpg',
    timeSlot: '3:00 PM - 5:00 PM',
    skillCoins: 40,
    date: DateTime.now().add(const Duration(days: 5)),
    category: 'Art',
    maxParticipants: 8,
    currentParticipants: 6,
  ),
  // Add more skills...
];

UserProfile currentUser = UserProfile(
  name: 'Brijesh Sharma',
  email: '2022.brijesh.sharma@ves.ac.in',
  imageUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
  skillCoins: 120,
  skillsTeaching: ['Flutter', 'UI/UX Design'],
  skillsLearning: ['Digital Painting', 'Guitar'],
  bio: 'Passionate about teaching and learning new skills!',
  mobile: '+91 9876543210',
);

List<ScheduledMeet> mockMeets = [
  ScheduledMeet(
    id: '1',
    skillName: 'Flutter Development',
    teacherName: 'Alex Johnson',
    dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
    meetLink: 'https://meet.google.com/abc-xyz-123',
    status: 'upcoming',
  ),
  ScheduledMeet(
    id: '2',
    skillName: 'Digital Painting',
    teacherName: 'Sarah Miller',
    dateTime: DateTime.now().add(const Duration(days: 5, hours: 15)),
    meetLink: 'https://meet.google.com/def-uvw-456',
    status: 'upcoming',
  ),
];

// Helper functions to manage data
void addNewSkill(Skill newSkill) {
  mockSkills.insert(0, newSkill);
}

void updateCurrentUser(UserProfile updatedUser) {
  currentUser = updatedUser;
}

void addNewMeet(ScheduledMeet newMeet) {
  mockMeets.add(newMeet);
}
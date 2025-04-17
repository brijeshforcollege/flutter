import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skillxchange/screens/post_skill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _selectedCategory = 'All';

//   Future<void> _handleSkillBooking(Map<String, dynamic> skillData, String skillId) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to book a skill.')),
//       );
//       return;
//     }

//     // Check if the skill is already booked by the user
//     final bookingQuery = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('bookedSkills')
//         .where('skillId', isEqualTo: skillId)
//         .get();

//     if (bookingQuery.docs.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You have already booked this skill.')),
//       );
//       return;
//     }

//     // Check if max participants limit is reached
//     if (skillData['currentParticipants'] >= skillData['maxParticipants']) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('This skill has reached its maximum participants.')),
//       );
//       return;
//     }

//     // Format the scheduled date for display
//     final scheduledDate = (skillData['scheduledDate'] as Timestamp).toDate();
//     final formattedDate = DateFormat('MMM d, y').format(scheduledDate);

//     // Show confirmation dialog
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Booking'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Book the skill "${skillData['title']}"?'),
//             const SizedBox(height: 10),
//             Text('Scheduled: $formattedDate at ${skillData['timeSlot']}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Book'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && mounted) {
//       try {
//         // Add to user's booked skills
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('bookedSkills')
//             .add({
//           'skillId': skillId,
//           'title': skillData['title'],
//           'teacherName': skillData['teacherName'],
//           'timeSlot': skillData['timeSlot'],
//           'scheduledDate': skillData['scheduledDate'],
//           'meetLink': skillData['meetLink'],
//           'category': skillData['category'],
//           'bookedAt': Timestamp.now(),
//         });

//         // Update skill's current participants
//         await FirebaseFirestore.instance
//             .collection('skills')
//             .doc(skillId)
//             .update({
//           'currentParticipants': FieldValue.increment(1),
//         });

//         // Simulate sending email (actual implementation requires backend)
//         final emailContent = '''
// Dear ${user.displayName ?? 'User'},

// You have successfully booked "${skillData['title']}"!
// Details:
// - Date: $formattedDate
// - Time: ${skillData['timeSlot']}
// - Google Meet Link: ${skillData['meetLink']}
// - Teacher: ${skillData['teacherName']}

// Thank you for using SkillXchange!
// ''';

//         debugPrint('Simulated email sent:\n$emailContent');

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Successfully booked "${skillData['title']}"! Check your console for email details.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         debugPrint('Error booking skill: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to book skill: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

Future<void> _handleSkillBooking(Map<String, dynamic> skillData, String skillId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to book a skill.')),
    );
    return;
  }

  // Check user's current coins
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final userCoins = userDoc.data()?['skillCoins'] ?? 0;
  final skillCost = skillData['skillCoins'] ?? 0;

  if (userCoins < skillCost) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You need $skillCost coins to book this session (you have $userCoins)')),
    );
    return;
  }

  // Check if already booked
  final bookingQuery = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('bookedSkills')
      .where('skillId', isEqualTo: skillId)
      .get();

  if (bookingQuery.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have already booked this skill.')),
    );
    return;
  }

  // Check max participants
  if (skillData['currentParticipants'] >= skillData['maxParticipants']) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This skill has reached its maximum participants.')),
    );
    return;
  }

  // Format date for display
  final scheduledDate = (skillData['scheduledDate'] as Timestamp).toDate();
  final formattedDate = DateFormat('MMM d, y').format(scheduledDate);

  // Confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Book the skill "${skillData['title']}"?'),
          const SizedBox(height: 10),
          Text('Scheduled: $formattedDate at ${skillData['timeSlot']}'),
          const SizedBox(height: 10),
          Text(
            'This will cost you ${skillData['skillCoins']} skill coins',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    try {
      // Start Firestore batch to ensure atomic transaction
      final batch = FirebaseFirestore.instance.batch();

      // 1. Deduct coins from student
      final studentRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(studentRef, {
        'skillCoins': FieldValue.increment(-skillCost),
      });

      // 2. Add coins to teacher
      final teacherRef = FirebaseFirestore.instance
          .collection('users')
          .doc(skillData['teacherId']);
      batch.update(teacherRef, {
        'skillCoins': FieldValue.increment(skillCost),
      });

      // 3. Add to user's booked skills
      final bookingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookedSkills')
          .doc();
      batch.set(bookingRef, {
        'skillId': skillId,
        'title': skillData['title'],
        'teacherName': skillData['teacherName'],
        'teacherId': skillData['teacherId'],
        'timeSlot': skillData['timeSlot'],
        'scheduledDate': skillData['scheduledDate'],
        'meetLink': skillData['meetLink'],
        'category': skillData['category'],
        'bookedAt': Timestamp.now(),
        'coinsPaid': skillCost,
      });

      // 4. Update skill's participants
      final skillRef = FirebaseFirestore.instance.collection('skills').doc(skillId);
      batch.update(skillRef, {
        'currentParticipants': FieldValue.increment(1),
      });

      // Commit the batch
      await batch.commit();

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked "${skillData['title']}" for $skillCost coins!'),
          backgroundColor: Colors.green,
        ),
      );

      // Simulate email notification
      debugPrint('''
Booking Confirmation:
- Skill: ${skillData['title']}
- Teacher: ${skillData['teacherName']}
- Date: $formattedDate
- Time: ${skillData['timeSlot']}
- Coins Deducted: $skillCost
- New Balance: ${userCoins - skillCost}
''');
    } catch (e) {
      debugPrint('Error booking skill: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book skill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
  Widget _buildSkillCard(Map<String, dynamic> skillData, String skillId) {
    final scheduledDate = (skillData['scheduledDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, y').format(scheduledDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleSkillBooking(skillData, skillId),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher Info Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      skillData['teacherImage']?.isNotEmpty == true
                          ? skillData['teacherImage']
                          : 'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skillData['teacherName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        skillData['category'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Colors.amber[100],
                    label: Text(
                      '${skillData['skillCoins'] ?? 0} Coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Skill Title
              Text(
                skillData['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              
              // Skill Description
              Text(
                skillData['description'] ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              // Date and Time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    skillData['timeSlot'] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Participants Progress
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${skillData['currentParticipants'] ?? 0}/${skillData['maxParticipants'] ?? 0}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    skillData['status'] ?? 'upcoming',
                    style: TextStyle(
                      color: skillData['status'] == 'upcoming'
                          ? Colors.green
                          : skillData['status'] == 'completed'
                              ? Colors.blue
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (skillData['currentParticipants'] ?? 0) / 
                      (skillData['maxParticipants'] ?? 1),
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillXchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implement notifications
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostSkillScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('skills').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No skills available.'));
          }

          // Extract unique categories
          final skills = snapshot.data!.docs;
          final categories = [
            'All',
            ...skills.map((doc) => doc['category'] as String).toSet().toList(),
          ];

          return Column(
            children: [
              // Category Filter Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text(categories[index]),
                        selected: _selectedCategory == categories[index],
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = categories[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              
              // Skills List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() => _isLoading = false);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: skills.length,
                          itemBuilder: (context, index) {
                            final skillData = skills[index].data() as Map<String, dynamic>;
                            final skillId = skills[index].id;

                            if (_selectedCategory != 'All' &&
                                skillData['category'] != _selectedCategory) {
                              return const SizedBox.shrink();
                            }

                            return _buildSkillCard(skillData, skillId);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
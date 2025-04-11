import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skillxchange/data/mock_data.dart';
import 'package:skillxchange/models/skill_model.dart';
import 'package:skillxchange/screens/post_skill_screen.dart';
import 'package:skillxchange/widgets/skilll_card.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _selectedCategory = 'All';

  Future<void> _handleSkillEnrollment(Skill skill) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Enrollment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enroll in "${skill.title}" for ${skill.skillCoins} coins?'),
            const SizedBox(height: 10),
            Text('Selected: ${DateFormat('MMM d, y').format(selectedDate)} at ${selectedTime.format(context)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enroll'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (currentUser.skillCoins >= skill.skillCoins) {
        setState(() {
          // Update user coins
          currentUser = UserProfile(
            name: currentUser.name,
            email: currentUser.email,
            imageUrl: currentUser.imageUrl,
            skillCoins: currentUser.skillCoins - skill.skillCoins,
            skillsTeaching: currentUser.skillsTeaching,
            skillsLearning: currentUser.skillsLearning,
            bio: currentUser.bio,
            mobile: currentUser.mobile,
          );

          // Add to scheduled meets
          mockMeets.add(ScheduledMeet(
            id: 'meet_${mockMeets.length + 1}',
            skillName: skill.title,
            teacherName: skill.teacherName,
            dateTime: DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ),
            meetLink: _generateMeetLink(),
            status: 'upcoming',
          ));

          // Update skill participants
          final index = mockSkills.indexWhere((s) => s.id == skill.id);
          if (index != -1) {
            mockSkills[index] = Skill(
              id: skill.id,
              title: skill.title,
              description: skill.description,
              teacherName: skill.teacherName,
              teacherImage: skill.teacherImage,
              timeSlot: skill.timeSlot,
              skillCoins: skill.skillCoins,
              date: skill.date,
              category: skill.category,
              maxParticipants: skill.maxParticipants,
              currentParticipants: skill.currentParticipants + 1,
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully enrolled in ${skill.title}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough Skill Coins!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateMeetLink() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return 'https://meet.google.com/${List.generate(10, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...mockSkills.map((e) => e.category).toSet().toList()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillXchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              backgroundColor: Colors.amber[100],
              label: Text(
                '${currentUser.skillCoins} Coins',
                style: TextStyle(
                  color: Colors.amber[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              avatar: const Icon(Icons.monetization_on, size: 18),
            ),
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
      body: Column(
        children: [
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
                      itemCount: mockSkills.length,
                      itemBuilder: (context, index) {
                        final skill = mockSkills[index];
                        if (_selectedCategory != 'All' && skill.category != _selectedCategory) {
                          return const SizedBox.shrink();
                        }
                        return InkWell(
                          onTap: () => _handleSkillEnrollment(skill),
                          borderRadius: BorderRadius.circular(12),
                          child: SkillCard(skill: skill),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
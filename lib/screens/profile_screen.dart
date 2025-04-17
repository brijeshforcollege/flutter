import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _teachingCount = 0;
  int _learningCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _countUserActivities();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        if (data['joinDate'] == null) {
          await userDoc.reference.update({'joinDate': Timestamp.now()});
          data['joinDate'] = Timestamp.now();
        }

        setState(() {
          _user = currentUser;
          _userData = data;
          _isLoading = false;
        });
      } else {
        await _createUserProfile(currentUser);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      final newUser = {
        'id': user.uid,
        'name': user.displayName ?? user.email?.split('@').first ?? 'New User',
        'email': user.email ?? '',
        'imageUrl': user.photoURL ?? '',
        'skillCoins': 100,
        'skillsTeaching': [],
        'skillsLearning': [],
        'bio': '',
        'mobile': '',
        'gender': '',
        'address': '',
        'joinDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser);

      setState(() {
        _user = user;
        _userData = newUser;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _countUserActivities() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final teachingQuery = await FirebaseFirestore.instance
          .collection('skills')
          .where('teacherId', isEqualTo: currentUser.uid)
          .get();

      final learningQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('bookedSkills')
          .get();

      setState(() {
        _teachingCount = teachingQuery.size;
        _learningCount = learningQuery.size;
      });
    } catch (e) {
      debugPrint('Error counting activities: $e');
    }
  }

  void _navigateToEditProfile() {
    if (_userData == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData!),
      ),
    ).then((value) {
      if (value == true) {
        _fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('No user data found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildSkillsSections(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'profile-picture',
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                _userData?['imageUrl']?.isNotEmpty == true
                    ? _userData!['imageUrl']
                    : 'https://via.placeholder.com/150',
              ),
              child: _userData?['imageUrl']?.isEmpty == true
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['name'] ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _userData?['email'] ?? '',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            backgroundColor: Colors.amber[100],
            label: Text(
              '${_userData?['skillCoins'] ?? 0} Skill Coins',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData?['joinDate'] is Timestamp
                ? 'Member since ${DateFormat('MMM yyyy').format((_userData!['joinDate'] as Timestamp).toDate())}'
                : 'Join date unavailable',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Teaching', _teachingCount),
        _buildStatItem('Learning', _learningCount),
        _buildStatItem(
          'Coins',
          _userData?['skillCoins'] ?? 0,
          isCoin: true,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, {bool isCoin = false}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isCoin) ...[
              Icon(Icons.monetization_on, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _userData?['bio']?.isNotEmpty == true
                ? _userData!['bio']
                : 'No bio added yet',
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.email),
          title: Text(_userData?['email'] ?? 'No email'),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text(
            _userData?['mobile']?.isNotEmpty == true
                ? _userData!['mobile']
                : 'No mobile number',
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSections() {
    final teachingSkills = _userData?['skillsTeaching'] as List<dynamic>? ?? [];
    final learningSkills = _userData?['skillsLearning'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teaching Skills',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        teachingSkills.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: teachingSkills
                    .map((skill) => Chip(
                          label: Text(skill.toString()),
                          backgroundColor: Colors.blue[50],
                        ))
                    .toList(),
              )
            : Text(
                'No teaching skills added',
                style: TextStyle(color: Colors.grey[600]),
              ),
        const SizedBox(height: 24),
        const Text(
          'Learning Interests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        learningSkills.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: learningSkills
                    .map((skill) => Chip(
                          label: Text(skill.toString()),
                          backgroundColor: Colors.green[50],
                        ))
                    .toList(),
              )
            : Text(
                'No learning interests added',
                style: TextStyle(color: Colors.grey[600]),
              ),
      ],
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _mobileController;
  late TextEditingController _teachingSkillsController;
  late TextEditingController _learningSkillsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _mobileController = TextEditingController(text: widget.userData['mobile'] ?? '');
    
    final teachingSkills = widget.userData['skillsTeaching'] as List<dynamic>? ?? [];
    final learningSkills = widget.userData['skillsLearning'] as List<dynamic>? ?? [];
    
    _teachingSkillsController = TextEditingController(
      text: teachingSkills.join(', '),
    );
    _learningSkillsController = TextEditingController(
      text: learningSkills.join(', '),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _mobileController.dispose();
    _teachingSkillsController.dispose();
    _learningSkillsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile
      await user.updateDisplayName(_nameController.text);

      // Prepare updated profile data
      final updatedData = {
        'name': _nameController.text,
        'bio': _bioController.text,
        'mobile': _mobileController.text,
        'skillsTeaching': _teachingSkillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'skillsLearning': _learningSkillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teachingSkillsController,
                      decoration: const InputDecoration(
                        labelText: 'Teaching Skills (comma-separated)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _learningSkillsController,
                      decoration: const InputDecoration(
                        labelText: 'Learning Interests (comma-separated)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
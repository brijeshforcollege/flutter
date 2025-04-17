import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadScheduledSkills();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadScheduledSkills() async {
    setState(() => _isLoading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Clear previous events
      _events.clear();

      // Load skills the user is teaching
      final teachingQuery = await FirebaseFirestore.instance
          .collection('skills')
          .where('teacherId', isEqualTo: currentUser.uid)
          .get();

      debugPrint('Teaching skills fetched: ${teachingQuery.docs.length}');

      // Load skills the user has booked (assuming ScheduledMeet structure)
      final bookedQuery = await FirebaseFirestore.instance
          .collection('scheduledMeets')
          .where('studentId', isEqualTo: currentUser.uid)
          .get();

      debugPrint('Booked skills fetched: ${bookedQuery.docs.length}');

      Map<DateTime, List<Map<String, dynamic>>> events = {};

      // Process teaching sessions
      for (var doc in teachingQuery.docs) {
        final skill = doc.data();
        final date = (skill['scheduledDate'] as Timestamp?)?.toDate();
        if (date == null) continue;
        final day = _normalizeDate(date);

        events.putIfAbsent(day, () => []).add({
          'id': doc.id,
          'title': skill['title'] ?? 'Untitled',
          'type': 'teaching',
          'dateTime': date,
          'scheduledDate': skill['scheduledDate'],
          'timeSlot': skill['timeSlot'] ?? '',
          'category': skill['category'] ?? 'Uncategorized',
          'currentParticipants': skill['currentParticipants'] ?? 0,
          'maxParticipants': skill['maxParticipants'] ?? 1,
          'meetLink': skill['meetLink'] ?? '',
          'teacherName': skill['teacherName'] ?? 'You',
          'status': skill['status'] ?? 'upcoming',
        });
      }

      // Process booked sessions
      for (var doc in bookedQuery.docs) {
        final meet = doc.data();
        final date = (meet['dateTime'] as Timestamp?)?.toDate();
        if (date == null) continue;
        final day = _normalizeDate(date);

        events.putIfAbsent(day, () => []).add({
          'id': doc.id,
          'skillId': meet['skillId'] ?? '',
          'title': meet['skillName'] ?? 'Untitled',
          'type': 'learning',
          'dateTime': date,
          'scheduledDate': meet['dateTime'],
          'timeSlot': '', // Add if stored in ScheduledMeet
          'category': '', // Add if stored
          'currentParticipants': 1, // Adjust if needed
          'maxParticipants': 1, // Adjust if needed
          'meetLink': meet['meetLink'] ?? '',
          'teacherName': meet['teacherName'] ?? 'Unknown',
          'status': meet['status'] ?? 'upcoming',
        });
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });

      debugPrint('Events loaded: ${_events.length} days with events');
    } catch (e) {
      debugPrint('Error loading scheduled skills: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = _normalizeDate(selectedDay);
      _focusedDay = focusedDay;
    });
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    final isTeaching = session['type'] == 'teaching';
    final dateTime = session['dateTime'] as DateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                session['title'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isTeaching
                    ? 'You are teaching this session'
                    : 'With ${session['teacherName']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                Icons.calendar_today,
                DateFormat('EEE, MMM d, y').format(dateTime),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.access_time,
                session['timeSlot'].isNotEmpty
                    ? '${session['timeSlot']} (${DateFormat.jm().format(dateTime)})'
                    : DateFormat.jm().format(dateTime),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.category,
                session['category'] ?? 'No category',
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.people,
                '${session['currentParticipants']}/${session['maxParticipants']} participants',
              ),
              const SizedBox(height: 20),
              if (session['meetLink'].isNotEmpty) ...[
                _buildDetailRow(Icons.link, 'Meeting Link'),
                InkWell(
                  onTap: () {
                    // TODO: Implement URL launch
                    debugPrint('Meeting link: ${session['meetLink']}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      session['meetLink'],
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  if (!isTeaching) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancelDialog(session);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: Colors.red[400]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement join meeting
                        debugPrint('Join/Start session: ${session['title']}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        isTeaching ? 'Start Session' : 'Join Session',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this skill session booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final userId = FirebaseAuth.instance.currentUser!.uid;

                  // Remove from scheduledMeets
                  await FirebaseFirestore.instance
                      .collection('scheduledMeets')
                      .doc(session['id'])
                      .delete();

                  // Decrement participant count in skill
                  if (session['skillId'] != null && session['skillId'].isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('skills')
                        .doc(session['skillId'])
                        .update({
                      'currentParticipants': FieldValue.increment(-1),
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled')),
                  );
                  await _loadScheduledSkills();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel: $e')),
                  );
                }
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = _events[_normalizeDate(_selectedDay)] ?? [];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions scheduled',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final session = events[index];
        final isTeaching = session['type'] == 'teaching';
        final dateTime = session['dateTime'] as DateTime;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showSessionDetails(session),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isTeaching ? Colors.blue : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isTeaching ? Icons.school : Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isTeaching
                                  ? 'You are teaching'
                                  : 'With ${session['teacherName']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat.jm().format(dateTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        session['category'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${session['currentParticipants']}/${session['maxParticipants']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: session['maxParticipants'] > 0
                        ? session['currentParticipants'] / session['maxParticipants']
                        : 0,
                    backgroundColor: Colors.grey[200],
                    color: isTeaching ? Colors.blue : Colors.green,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduledSkills,
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _normalizeDate(DateTime.now());
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Map<String, dynamic>>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_normalizeDate(day), _selectedDay),
            onDaySelected: _onDaySelected,
            eventLoader: (day) => _events[_normalizeDate(day)] ?? [],
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.amber[100],
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.red[400],
                shape: BoxShape.circle,
              ),
              markerSize: 6,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.blue),
              leftChevronIcon: const Icon(Icons.chevron_left, size: 28),
              rightChevronIcon: const Icon(Icons.chevron_right, size: 28),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey[600]),
              weekendStyle: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Sessions on ${DateFormat('MMMM d, y').format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_events[_normalizeDate(_selectedDay)]?.length ?? 0}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/attendance_service.dart';
import '../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();
  final TextEditingController _subjectController = TextEditingController();
  bool _isPresent = true;
  Map<String, Map<String, dynamic>> _attendanceStats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceStats();
  }

  Future<void> _loadAttendanceStats() async {
    setState(() => _loading = true);
    Map<String, Map<String, dynamic>> stats =
    await _attendanceService.getAttendanceStats();
    setState(() {
      _attendanceStats = stats;
      _loading = false;
    });
  }

  void _showAddAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'Add Attendance',
            style: AppTheme.headingStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: AppTheme.inputDecoration(
                  'Subject',
                  Icons.subject,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${_isPresent ? "Present" : "Absent"}',
                    style: AppTheme.bodyStyle,
                  ),
                  Switch(
                    value: _isPresent,
                    activeColor: AppTheme.successColor,
                    inactiveTrackColor: AppTheme.errorColor.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _isPresent = value;
                      });
                      Navigator.of(context).pop();
                      _showAddAttendanceDialog();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ),
            ElevatedButton(
              style: AppTheme.primaryButtonStyle,
              onPressed: () async {
                if (_subjectController.text.isNotEmpty) {
                  await _attendanceService.addAttendance(
                    _subjectController.text,
                    _isPresent,
                  );
                  _subjectController.clear();
                  Navigator.of(context).pop();
                  _loadAttendanceStats();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Attendance Tracker',
          style: AppTheme.headingStyle.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      )
          : _attendanceStats.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records yet',
              style: AppTheme.subheadingStyle.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add one!',
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAttendanceStats,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _attendanceStats.length,
          itemBuilder: (context, index) {
            String subject = _attendanceStats.keys.elementAt(index);
            Map<String, dynamic> stats = _attendanceStats[subject]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: AppTheme.cardDecoration,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      subject,
                      style: AppTheme.headingStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Present: ${stats['present']} / ${stats['total']}',
                          style: AppTheme.captionStyle,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stats['percentage'] / 100,
                          backgroundColor:
                          AppTheme.errorColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stats['percentage'] >= 75
                                ? AppTheme.successColor
                                : stats['percentage'] >= 50
                                ? AppTheme.accentColor
                                : AppTheme.errorColor,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Attendance: ${stats['percentage'].toStringAsFixed(1)}%',
                          style: AppTheme.bodyStyle.copyWith(
                            color: stats['percentage'] >= 75
                                ? AppTheme.successColor
                                : stats['percentage'] >= 50
                                ? AppTheme.accentColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAttendanceDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add Attendance',
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }
}
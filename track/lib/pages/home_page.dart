import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../database/user_database.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/workout_item.dart';

// represents the home page
class HomePage extends StatefulWidget {
  static const String appBarTitle = 'Home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final UserDatabase _db = UserDatabase();
  File? _profileMedia;
  String? _name;
  String? _bio;
  VideoPlayerController? _videoController;
  Workout? _generatedWorkout;

  @override
// handles the initState functionality
  void initState() {
    super.initState();
    _loadUserProfile();
  }

// handles the _loadUserProfile functionality
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Your Name';
      _bio = prefs.getString('bio') ?? 'Your Bio';
      final mediaPath = prefs.getString('profileMedia');
      if (mediaPath != null) {
        _profileMedia = File(mediaPath);
        if (_profileMedia!.path.endsWith('.mp4')) {
          _initializeVideo(_profileMedia!.path);
        }
      }
    });
  }

// handles the _saveUserProfile functionality
  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name ?? '');
    await prefs.setString('bio', _bio ?? '');
    if (_profileMedia != null) {
      await prefs.setString('profileMedia', _profileMedia!.path);
    }
  }

// handles the _pickMedia functionality
  Future<void> _pickMedia({bool isPhoto = true}) async {
    final pickedFile = await (isPhoto
        ? _picker.pickImage(source: ImageSource.gallery)
        : _picker.pickVideo(source: ImageSource.gallery));
    if (pickedFile != null) {
      setState(() {
        _profileMedia = File(pickedFile.path);
        if (_profileMedia!.path.endsWith('.mp4')) {
          _initializeVideo(_profileMedia!.path);
        } else {
          _disposeVideo();
        }
      });
    }
  }

// handles the _initializeVideo functionality
  void _initializeVideo(String path) {
    _disposeVideo();
    _videoController = VideoPlayerController.file(File(path))
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

// handles the _disposeVideo functionality
  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

// handles the _generateWorkout functionality
  Future<void> _generateWorkout() async {
    final exercises = await _db.getExercises();
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercises available to generate a workout.')),
      );
      return;
    }

    final random = Random();
    final workoutItems = List.generate(
      random.nextInt(4) + 1,
      (_) {
      final exercise = exercises[random.nextInt(exercises.length)];
      final numberOfSets = random.nextInt(3) + 2;
      final reps = random.nextInt(8) + 8;
      final sets = List.generate(
        numberOfSets,
        (_) => Set(
        reps: reps,
        weight: random.nextDouble() * 50,
        timestamp: DateTime.now(),
        ),
      );
      return WorkoutItem(exercise: exercise, sets: sets);
      },
    );

    setState(() {
      _generatedWorkout = Workout(
        id: DateTime.now().millisecondsSinceEpoch,
        startTime: DateTime.now(),
        latitude: 0.0,
        longitude: 0.0,
        workoutItems: workoutItems,
        media: [],
      );
    });
  }

  @override
// handles the dispose functionality
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
// handles the build functionality
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                final action = await showModalBottomSheet<int>(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('Choose Photo'),
                        onTap: () => Navigator.pop(context, 1),
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Choose Video'),
                        onTap: () => Navigator.pop(context, 2),
                      ),
                    ],
                  ),
                );
                if (action == 1) {
                  await _pickMedia(isPhoto: true);
                } else if (action == 2) {
                  await _pickMedia(isPhoto: false);
                }
              },
              child: _profileMedia != null && _profileMedia!.path.endsWith('.mp4')
                  ? AspectRatio(
                      aspectRatio: _videoController?.value.aspectRatio ?? 1.0,
                      child: _videoController != null &&
                              _videoController!.value.isInitialized
                          ? VideoPlayer(_videoController!)
                          : const Center(child: CircularProgressIndicator()),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileMedia != null &&
                              _profileMedia!.path.endsWith('.jpg')
                          ? FileImage(_profileMedia!)
                          : null,
                      child: _profileMedia == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: _name),
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Bio'),
              controller: TextEditingController(text: _bio),
              maxLines: 3,
              onChanged: (value) => _bio = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              },
              child: const Text('Save Profile'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _generateWorkout,
              child: const Text('Generate Random Workout'),
            ),
            const SizedBox(height: 16),
            if (_generatedWorkout != null) ...[
              const Text(
                'Generated Workout Preview:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _generatedWorkout!.workoutItems.length,
                  itemBuilder: (context, index) {
                    final item = _generatedWorkout!.workoutItems[index];
                    return ListTile(
                      title: Text(item.exercise.name),
                      subtitle: Text(
                          'Sets: ${item.sets.length}, Reps: ${item.sets.map((set) => set.reps).join(", ")}'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

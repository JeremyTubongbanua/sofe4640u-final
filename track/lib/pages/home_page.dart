import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  static const String appBarTitle = 'Home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileMedia;
  String? _name;
  String? _bio;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

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

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name ?? '');
    await prefs.setString('bio', _bio ?? '');
    if (_profileMedia != null) {
      await prefs.setString('profileMedia', _profileMedia!.path);
    }
  }

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

  void _initializeVideo(String path) {
    _disposeVideo();
    _videoController = VideoPlayerController.file(File(path))
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
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
                      aspectRatio:
                          _videoController?.value.aspectRatio ?? 1.0,
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
          ],
        ),
      ),
    );
  }
}

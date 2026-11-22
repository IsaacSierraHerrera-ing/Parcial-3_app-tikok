import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<VideoPost> _posts = const [
    VideoPost(
      'https://content.pexels.com/aigc-bundle/videos/e2835e84-5e3e-4005-9158-ffde8cd17ce4.mp4',
      '@vibes_diarios',
      'Colores, movimiento y una historia en cada segundo.',
      12400,
    ),
    VideoPost(
      'https://content.pexels.com/aigc-bundle/videos/9c52d516-c6ec-4d08-b1e5-2c62257d907c.mp4',
      '@maria_vlogs',
      'Momentos que valen la pena guardar ✨',
      8310,
    ),
    VideoPost(
      'https://content.pexels.com/aigc-bundle/videos/9034cd21-b3b1-4a2b-8eda-8ee261da2f4d.mp4',
      '@travel_life',
      'El mundo se ve mejor desde otra perspectiva 🌍',
      23600,
    ),
    VideoPost(
      'https://content.pexels.com/aigc-bundle/videos/85e8bb76-0b3a-4409-9a84-ae20b232a4e2.mp4',
      '@creator_spot',
      'Tecnología, creatividad y nuevos caminos.',
      15900,
    ),
  ];

  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentPage = 0;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _initializePage(0);
  }

  Future<void> _initializePage(int index) async {
    if (_controllers.containsKey(index)) {
      await _controllers[index]!.play();
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_posts[index].url),
    );
    _controllers[index] = controller;
    await controller.initialize();
    await controller.setLooping(true);
    await controller.setVolume(1);
    if (mounted && index == _currentPage) await controller.play();
    if (mounted) setState(() {});
  }

  void _changePage(int index) {
    for (final entry in _controllers.entries) {
      if (entry.key == index) {
        entry.value.play();
      } else {
        entry.value.pause();
      }
    }
    _currentPage = index;
    _initializePage(index);
  }

  Future<void> _togglePlayback() async {
    final controller = _controllers[_currentPage];
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() => _loggingOut = true);

    Future<void>.sync(() => GoogleSignIn.instance.signOut())
        .catchError((Object _) {});

    Future<void>.sync(() => FacebookAuth.instance.logOut())
        .catchError((Object _) {});

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      widget.onLogout();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar la sesión. Inténtalo nuevamente.'),
          backgroundColor: Color(0xFFB82E46),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final identity = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _posts.length,
            onPageChanged: _changePage,
            itemBuilder: (context, index) {
              final post = _posts[index];
              final controller = _controllers[index];
              final initialized = controller?.value.isInitialized == true;

              return GestureDetector(
                onTap: _togglePlayback,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.black),
                    if (initialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller!.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF4D67),
                          strokeWidth: 3,
                        ),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x66000000),
                            Colors.transparent,
                            Color(0xB3000000),
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 92,
                      bottom: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33111111),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              post.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            post.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 42,
                      child: Column(
                        children: [
                          _ActionButton(
                            icon: Icons.favorite_rounded,
                            label: _formatLikes(post.likes),
                            color: const Color(0xFFFF4D67),
                          ),
                          const SizedBox(height: 18),
                          const _ActionButton(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Comentarios',
                          ),
                          const SizedBox(height: 18),
                          const _ActionButton(
                            icon: Icons.send_rounded,
                            label: 'Compartir',
                          ),
                        ],
                      ),
                    ),
                    if (initialized && !(controller?.value.isPlaying ?? false))
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0x55000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x66111111),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'PARCIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loggingOut ? null : _logout,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 210),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x99111111),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF4D67),
                                    Color(0xFF7C4DFF),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                identity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _loggingOut
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white70,
                                    size: 17,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLikes(int likes) {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(likes >= 10000 ? 0 : 1)}K';
    }
    return '$likes';
  }
}

class VideoPost {
  final String url;
  final String username;
  final String description;
  final int likes;

  const VideoPost(this.url, this.username, this.description, this.likes);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x99111111),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 12),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordSlides extends StatefulWidget {
  final int exerciseNumber;
  final List<Map<String, String>> data;

  const WordSlides({
    super.key,
    required this.exerciseNumber,
    required this.data,
  });

  @override
  State<WordSlides> createState() => _WordSlidesState();
}

class _WordSlidesState extends State<WordSlides> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  bool _isImageReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(_animationController);
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _nextSlide() {
    setState(() {
      if (_currentIndex < widget.data.length - 1) {
        if (_isImageReady) {
          _currentIndex++;
          _animationController.forward(from: 0.0);
        }
      } else {
        Navigator.of(context).maybePop();
      }
    });
  }

  void _speakWord() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(0.8);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(widget.data[_currentIndex]['word']!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exercise-${widget.exerciseNumber}',
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            widget.data[_currentIndex]['picture'] != null
                ? FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: Image.network(
                        widget.data[_currentIndex]['picture']!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            _isImageReady = true;
                            return child;
                          } else {
                            _isImageReady = false;
                            return const CircularProgressIndicator();
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          _isImageReady = false;
                          return const Text('Image not available');
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Text(
              widget.data[_currentIndex]['word']!.toUpperCase(),
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _speakWord,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image.asset('assets/images/volume.png'),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _nextSlide,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image.asset('assets/images/next.png'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


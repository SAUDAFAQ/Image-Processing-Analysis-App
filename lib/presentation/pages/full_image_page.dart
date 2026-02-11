import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-screen image viewer for tapping on result images from the detail screen.
class FullImagePage extends StatelessWidget {
  const FullImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final path = Get.arguments as String? ?? '';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: path.isEmpty
            ? const Text(
                'No image',
                style: TextStyle(color: Colors.white),
              )
            : InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}


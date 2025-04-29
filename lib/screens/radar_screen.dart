// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Weather Radar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Local Radar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.network(
                      'https://radar.weather.gov/ridge/standard/KTYX_loop.gif',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
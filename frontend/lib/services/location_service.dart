import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:math';

class LocationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Set<int> _notifiedPostIds = {};

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<void> init() async {
    // Initialize Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Calculate distance in meters
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Future<void> checkProximityAndNotify(List<dynamic> posts) async {
    try {
      Position position = await getCurrentLocation();

      for (var post in posts) {
        // Safe access to fields
        final lat = post['latitude'];
        final lng = post['longitude'];
        final postId = post['post_id'];
        final postDesc = post['item_name'] ?? 'Item';

        if (lat != null && lng != null && postId != null) {
          double distance = calculateDistance(position.latitude, position.longitude, double.parse(lat.toString()), double.parse(lng.toString()));

          // If within 100 meters
          if (distance < 100) {
             if (!_notifiedPostIds.contains(postId)) {
               _showNotification(postId, "You are near a lost item!", "Someone lost '$postDesc' near here. Check it out!");
               _notifiedPostIds.add(postId);
             }
          }
        }
      }
    } catch (e) {
      // print("Error checking proximity: $e");
    }
  }

  Future<void> _showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'proximity_channel_id', 'Proximity Notifications',
            channelDescription: 'Notifications for nearby lost items',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
            
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics);
  }
}

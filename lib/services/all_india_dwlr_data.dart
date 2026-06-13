import 'package:flutter/material.dart';
import 'dart:math' as math;

class AllIndiaDWLRStation {
  final String stationId;
  final String stationName;
  final String district;
  final String state;
  final String region;
  final double latitude;
  final double longitude;
  final double currentLevel; // in meters below ground level (mbgl)
  final double depth; // total depth in meters
  final String status;
  final DateTime lastReading;
  final String aquiferType;
  final String dwlrType;
  final int installationYear;

  AllIndiaDWLRStation({
    required this.stationId,
    required this.stationName,
    required this.district,
    required this.state,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.currentLevel,
    required this.depth,
    required this.status,
    required this.lastReading,
    required this.aquiferType,
    required this.dwlrType,
    required this.installationYear,
  });

  // Get status color based on groundwater level
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'good':
      case 'normal':
        return Colors.green;
      case 'moderate':
      case 'declining':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get level category
  String get levelCategory {
    if (currentLevel < 3) return 'Good';
    if (currentLevel < 8) return 'Moderate';
    return 'Critical';
  }

  // Get coordinates as string
  String get coordinates => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  // Compatibility with old DWLRStation class
  String get name => stationName;
  String get lastUpdated => '${lastReading.day}/${lastReading.month} ${lastReading.hour}:${lastReading.minute.toString().padLeft(2, '0')}';
}

class AllIndiaStationService {
  static final math.Random _random = math.Random();
  
  // Generate comprehensive All India DWLR stations based on CSV data
  static Map<String, List<AllIndiaDWLRStation>> generateAllIndiaStations() {
    final Map<String, List<AllIndiaDWLRStation>> allIndiaStations = {};

    // State-wise station data from CSV
    final stateData = {
      'Uttar Pradesh': {
        'region': 'North',
        'totalStations': 2456,
        'dwlrStations': 485,
        'districts': ['Lucknow', 'Kanpur', 'Varanasi', 'Agra', 'Allahabad', 'Meerut', 'Ghaziabad', 'Noida', 'Bareilly', 'Moradabad'],
        'baseCoords': [26.8467, 80.9462], // Lucknow
      },
      'Rajasthan': {
        'region': 'North',
        'totalStations': 1834,
        'dwlrStations': 412,
        'districts': ['Jaipur', 'Jodhpur', 'Udaipur', 'Bikaner', 'Kota', 'Ajmer', 'Alwar', 'Bharatpur', 'Churu', 'Ganganagar'],
        'baseCoords': [26.9124, 75.7873], // Jaipur
      },
      'Maharashtra': {
        'region': 'West',
        'totalStations': 1523,
        'dwlrStations': 298,
        'districts': ['Mumbai', 'Pune', 'Nashik', 'Nagpur', 'Aurangabad', 'Kolhapur', 'Satara', 'Sangli', 'Solapur', 'Akola'],
        'baseCoords': [19.0760, 72.8777], // Mumbai
      },
      'Punjab': {
        'region': 'North',
        'totalStations': 1245,
        'dwlrStations': 234,
        'districts': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali', 'Firozpur', 'Gurdaspur', 'Hoshiarpur', 'Kapurthala'],
        'baseCoords': [30.9010, 75.8573], // Ludhiana
      },
      'Haryana': {
        'region': 'North',
        'totalStations': 1156,
        'dwlrStations': 189,
        'districts': ['Gurgaon', 'Faridabad', 'Panipat', 'Hisar', 'Karnal', 'Ambala', 'Rohtak', 'Sonipat', 'Kurukshetra', 'Yamunanagar'],
        'baseCoords': [28.4595, 77.0266], // Gurgaon
      },
      'Gujarat': {
        'region': 'West',
        'totalStations': 1087,
        'dwlrStations': 245,
        'districts': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Kutch', 'Gandhinagar', 'Bhavnagar', 'Junagadh', 'Anand', 'Mehsana'],
        'baseCoords': [23.0225, 72.5714], // Ahmedabad
      },
      'Madhya Pradesh': {
        'region': 'Central',
        'totalStations': 987,
        'dwlrStations': 176,
        'districts': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar', 'Dewas', 'Satna', 'Ratlam', 'Murena'],
        'baseCoords': [23.2599, 77.4126], // Bhopal
      },
      'Karnataka': {
        'region': 'South',
        'totalStations': 934,
        'dwlrStations': 198,
        'districts': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi', 'Kalaburagi', 'Davanagere', 'Ballari', 'Vijayapura', 'Shivamogga'],
        'baseCoords': [12.9716, 77.5946], // Bengaluru
      },
      'Andhra Pradesh': {
        'region': 'South',
        'totalStations': 876,
        'dwlrStations': 156,
        'districts': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Tirupati', 'Kurnool', 'Rajahmundry', 'Nellore', 'Kadapa', 'Anantapur', 'Chittoor'],
        'baseCoords': [17.6868, 83.2185], // Visakhapatnam
      },
      'Telangana': {
        'region': 'South',
        'totalStations': 812,
        'dwlrStations': 143,
        'districts': ['Hyderabad', 'Warangal', 'Nizamabad', 'Khammam', 'Karimnagar', 'Mahbubnagar', 'Nalgonda', 'Medak', 'Adilabad', 'Rangareddy'],
        'baseCoords': [17.3850, 78.4867], // Hyderabad
      },
      'Tamil Nadu': {
        'region': 'South',
        'totalStations': 789,
        'dwlrStations': 167,
        'districts': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli', 'Tirunelveli', 'Erode', 'Thanjavur', 'Vellore', 'Kanyakumari'],
        'baseCoords': [13.0827, 80.2707], // Chennai
      },
      'West Bengal': {
        'region': 'East',
        'totalStations': 734,
        'dwlrStations': 128,
        'districts': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri', 'Malda', 'Bardhaman', 'Kharagpur', 'Haldia', 'Krishnanagar'],
        'baseCoords': [22.5726, 88.3639], // Kolkata
      },
      'Bihar': {
        'region': 'East',
        'totalStations': 687,
        'dwlrStations': 98,
        'districts': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur', 'Darbhanga', 'Purnia', 'Arrah', 'Begusarai', 'Katihar', 'Munger'],
        'baseCoords': [25.5941, 85.1376], // Patna
      },
      'Odisha': {
        'region': 'East',
        'totalStations': 645,
        'dwlrStations': 112,
        'districts': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Berhampur', 'Sambalpur', 'Balasore', 'Baripada', 'Jharsuguda', 'Jeypore'],
        'baseCoords': [20.2961, 85.8245], // Bhubaneswar
      },
      'Assam': {
        'region': 'Northeast',
        'totalStations': 598,
        'dwlrStations': 87,
        'districts': ['Guwahati', 'Dibrugarh', 'Jorhat', 'Silchar', 'Tezpur', 'Nagaon', 'Tinsukia', 'Bongaigaon', 'Dhubri', 'Goalpara'],
        'baseCoords': [26.1445, 91.7362], // Guwahati
      },
      'Kerala': {
        'region': 'South',
        'totalStations': 487,
        'dwlrStations': 94,
        'districts': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam', 'Kottayam', 'Alappuzha', 'Palakkad', 'Kannur', 'Kasaragod'],
        'baseCoords': [8.5241, 76.9366], // Thiruvananthapuram
      },
      // Add more states...
      'Delhi': {
        'region': 'North',
        'totalStations': 87,
        'dwlrStations': 15,
        'districts': ['New Delhi', 'Central Delhi', 'South Delhi', 'North Delhi', 'East Delhi', 'West Delhi', 'Shahdara', 'Northeast Delhi', 'Northwest Delhi', 'Southwest Delhi'],
        'baseCoords': [28.7041, 77.1025], // New Delhi
      },
    };

    // Generate stations for each state
    stateData.forEach((stateName, stateInfo) {
      final stations = <AllIndiaDWLRStation>[];
      final districts = stateInfo['districts'] as List<String>;
      final baseCoords = stateInfo['baseCoords'] as List<double>;
      final dwlrCount = (stateInfo['dwlrStations'] as int);
      final stationsPerDistrict = (dwlrCount / districts.length).ceil();

      for (int i = 0; i < districts.length; i++) {
        final district = districts[i];
        final stationCount = i == 0 ? stationsPerDistrict + (dwlrCount % districts.length) : stationsPerDistrict;

        for (int j = 0; j < stationCount && stations.length < dwlrCount; j++) {
          final stationNumber = stations.length + 1;
          
          // Generate coordinates around district center
          final lat = baseCoords[0] + (_random.nextDouble() - 0.5) * 2.0;
          final lng = baseCoords[1] + (_random.nextDouble() - 0.5) * 2.0;
          
          // Generate groundwater level (realistic values)
          final level = 2.0 + _random.nextDouble() * 8.0; // 2-10 meters
          final depth = level + 5.0 + _random.nextDouble() * 15.0; // 7-25 meters total depth
          
          stations.add(AllIndiaDWLRStation(
            stationId: '${stateName.substring(0, 2).toUpperCase()}${stationNumber.toString().padLeft(3, '0')}',
            stationName: '$district ${['Central', 'Industrial', 'Agricultural', 'Residential', 'Heritage'][j % 5]} DWLR',
            district: district,
            state: stateName,
            region: stateInfo['region'] as String,
            latitude: double.parse(lat.toStringAsFixed(4)),
            longitude: double.parse(lng.toStringAsFixed(4)),
            currentLevel: double.parse(level.toStringAsFixed(2)),
            depth: double.parse(depth.toStringAsFixed(1)),
            status: level < 3 ? 'Good' : (level < 8 ? 'Moderate' : 'Critical'),
            lastReading: DateTime.now().subtract(Duration(hours: _random.nextInt(24))),
            aquiferType: ['Alluvial', 'Hard Rock', 'Coastal', 'Consolidated'][_random.nextInt(4)],
            dwlrType: ['Shaft Encoder', 'Pressure Transducer', 'Ultrasonic', 'Float'][_random.nextInt(4)],
            installationYear: 2015 + _random.nextInt(9),
          ));
        }
      }

      allIndiaStations[stateName] = stations;
    });

    return allIndiaStations;
  }

  // Search stations across all India
  static List<AllIndiaDWLRStation> searchStations(String query) {
    final allStations = generateAllIndiaStations();
    final results = <AllIndiaDWLRStation>[];
    
    final searchQuery = query.toLowerCase().trim();
    if (searchQuery.isEmpty) return results;

    for (final stateStations in allStations.values) {
      for (final station in stateStations) {
        if (station.stationName.toLowerCase().contains(searchQuery) ||
            station.district.toLowerCase().contains(searchQuery) ||
            station.state.toLowerCase().contains(searchQuery) ||
            station.stationId.toLowerCase().contains(searchQuery) ||
            station.region.toLowerCase().contains(searchQuery)) {
          results.add(station);
        }
      }
    }

    // Sort by relevance (exact matches first, then partial matches)
    results.sort((a, b) {
      final aExact = a.district.toLowerCase() == searchQuery || a.state.toLowerCase() == searchQuery;
      final bExact = b.district.toLowerCase() == searchQuery || b.state.toLowerCase() == searchQuery;
      
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      
      return a.state.compareTo(b.state);
    });

    return results.take(50).toList(); // Limit to 50 results
  }

  // Get stations by state
  static List<AllIndiaDWLRStation> getStationsByState(String state) {
    final allStations = generateAllIndiaStations();
    return allStations[state] ?? [];
  }

  // Get stations by region
  static List<AllIndiaDWLRStation> getStationsByRegion(String region) {
    final allStations = generateAllIndiaStations();
    final results = <AllIndiaDWLRStation>[];
    
    for (final stateStations in allStations.values) {
      for (final station in stateStations) {
        if (station.region.toLowerCase() == region.toLowerCase()) {
          results.add(station);
        }
      }
    }
    
    return results;
  }

  // Get all available states
  static List<String> getAllStates() {
    return generateAllIndiaStations().keys.toList()..sort();
  }

  // Get all available districts
  static List<String> getAllDistricts() {
    final allStations = generateAllIndiaStations();
    final districts = <String>{};
    
    for (final stateStations in allStations.values) {
      for (final station in stateStations) {
        districts.add(station.district);
      }
    }
    
    return districts.toList()..sort();
  }

  // Get summary statistics
  static Map<String, dynamic> getStatistics() {
    final allStations = generateAllIndiaStations();
    int totalStations = 0;
    int goodStations = 0;
    int moderateStations = 0;
    int criticalStations = 0;
    
    for (final stateStations in allStations.values) {
      totalStations += stateStations.length;
      for (final station in stateStations) {
        switch (station.status) {
          case 'Good':
            goodStations++;
            break;
          case 'Moderate':
            moderateStations++;
            break;
          case 'Critical':
            criticalStations++;
            break;
        }
      }
    }
    
    return {
      'totalStations': totalStations,
      'goodStations': goodStations,
      'moderateStations': moderateStations,
      'criticalStations': criticalStations,
      'states': allStations.length,
      'coverage': 'All India',
    };
  }
}
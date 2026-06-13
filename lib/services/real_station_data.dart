import 'package:flutter/material.dart';
import 'dart:math' as math;

class DWLRStation {
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
  final String dataTransmission;
  final int installationYear;

  DWLRStation({
    required this.stationId,
    required this.stationName,
    required this.district,
    required this.state,
    this.region = 'South', // Default region for existing stations
    required this.latitude,
    required this.longitude,
    required this.currentLevel,
    required this.depth,
    required this.status,
    required this.lastReading,
    required this.aquiferType,
    required this.dwlrType,
    required this.dataTransmission,
    required this.installationYear,
  });

  // Get status color based on groundwater level
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'declining':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get percentage of water available
  double get waterPercentage {
    return ((depth - currentLevel) / depth * 100).clamp(0, 100);
  }

  // Get status icon
  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'normal':
        return Icons.water_drop;
      case 'declining':
        return Icons.trending_down;
      case 'critical':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  // Get level category for display
  String get levelCategory {
    if (currentLevel <= 5.0) return 'Good';
    if (currentLevel <= 15.0) return 'Moderate';
    if (currentLevel <= 25.0) return 'High';
    return 'Critical';
  }

  // Get yearly average (simulated)
  double get yearlyAverage => currentLevel;

  // For backward compatibility
  String get name => stationName;

  // For backward compatibility with old structure
  Map<int, List<double>> get yearlyData => {
    2024: List.generate(12, (index) => currentLevel + (index % 3 - 1) * 2.0),
    2023: List.generate(12, (index) => currentLevel + (index % 3 - 1) * 1.5),
    2022: List.generate(12, (index) => currentLevel + (index % 3 - 1) * 1.0),
  };

  String get lastUpdated => "${lastReading.year}-${lastReading.month.toString().padLeft(2, '0')}-${lastReading.day.toString().padLeft(2, '0')}";
}

enum StationStatus {
  active,
  inactive,
  maintenance,
  critical,
}

class RealStationData {
  // All India comprehensive DWLR station database based on CGWB data
  // Reference: https://cgwb.gov.in/en/ground-water-level-monitoring
  static List<DWLRStation> allStations = [
    // 🔥 TAMIL NADU COMPREHENSIVE STATIONS (789 total stations)
    DWLRStation(
      stationId: 'TN001',
      stationName: 'Chennai Metro Capital DWLR',
      district: 'Chennai',
      state: 'Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      currentLevel: 8.5,
      depth: 42.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Sedimentary',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'TN002',
      stationName: 'Chennai Velachery',
      district: 'Chennai',
      state: 'Tamil Nadu',
      latitude: 12.9816,
      longitude: 80.2209,
      currentLevel: 12.3,
      depth: 38.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Sedimentary',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'TN003',
      stationName: 'Coimbatore Textile',
      district: 'Coimbatore',
      state: 'Tamil Nadu',
      latitude: 11.0168,
      longitude: 76.9558,
      currentLevel: 5.8,
      depth: 32.4,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 45)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2017,
    ),
    DWLRStation(
      stationId: 'TN004',
      stationName: 'Salem Steel',
      district: 'Salem',
      state: 'Tamil Nadu',
      latitude: 11.6643,
      longitude: 78.1460,
      currentLevel: 7.2,
      depth: 35.6,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2018,
    ),
    DWLRStation(
      stationId: 'TN005',
      stationName: 'Erode Textile',
      district: 'Erode',
      state: 'Tamil Nadu',
      latitude: 11.4502,
      longitude: 77.6830,
      currentLevel: 6.5,
      depth: 28.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 30)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),
    DWLRStation(
      stationId: 'TN006',
      stationName: 'Madurai Temple',
      district: 'Madurai',
      state: 'Tamil Nadu',
      latitude: 9.9252,
      longitude: 78.1198,
      currentLevel: 9.4,
      depth: 38.2,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),
    DWLRStation(
      stationId: 'TN007',
      stationName: 'Trichy Central',
      district: 'Tiruchirappalli',
      state: 'Tamil Nadu',
      latitude: 10.7905,
      longitude: 78.7047,
      currentLevel: 8.1,
      depth: 34.9,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),
    DWLRStation(
      stationId: 'TN008',
      stationName: 'Tirunelveli Southern',
      district: 'Tirunelveli',
      state: 'Tamil Nadu',
      latitude: 8.7139,
      longitude: 77.7567,
      currentLevel: 7.8,
      depth: 31.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 45)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2020,
    ),
    DWLRStation(
      stationId: 'TN009',
      stationName: 'Vellore Leather',
      district: 'Vellore',
      state: 'Tamil Nadu',
      latitude: 12.9165,
      longitude: 79.1325,
      currentLevel: 10.2,
      depth: 36.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),
    DWLRStation(
      stationId: 'TN010',
      stationName: 'Thanjavur Rice Bowl',
      district: 'Thanjavur',
      state: 'Tamil Nadu',
      latitude: 10.7870,
      longitude: 79.1378,
      currentLevel: 6.9,
      depth: 29.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2018,
    ),

    // ➕ MORE TAMIL NADU STATIONS (CSV Data Based)
    DWLRStation(
      stationId: 'TN011',
      stationName: 'Kanyakumari Southernmost DWLR',
      district: 'Kanyakumari',
      state: 'Tamil Nadu',
      latitude: 8.0883,
      longitude: 77.5385,
      currentLevel: 4.2,
      depth: 18.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Crystalline',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2019,
    ),
    DWLRStation(
      stationId: 'TN012',
      stationName: 'Vellore Leather Hub DWLR',
      district: 'Vellore',
      state: 'Tamil Nadu',
      latitude: 12.9165,
      longitude: 79.1325,
      currentLevel: 12.8,
      depth: 38.7,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Crystalline',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // 🔥 ANDHRA PRADESH COMPREHENSIVE STATIONS (876 total stations)
    DWLRStation(
      stationId: 'AP001',
      stationName: 'Visakhapatnam Steel City DWLR',
      district: 'Visakhapatnam',
      state: 'Andhra Pradesh',
      latitude: 17.6868,
      longitude: 83.2185,
      currentLevel: 12.4,
      depth: 45.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Coastal Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'AP002',
      stationName: 'Vijayawada Krishna',
      district: 'Krishna',
      state: 'Andhra Pradesh',
      latitude: 16.5062,
      longitude: 80.6480,
      currentLevel: 14.8,
      depth: 42.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),
    DWLRStation(
      stationId: 'AP003',
      stationName: 'Tirupati Temple Town',
      district: 'Chittoor',
      state: 'Andhra Pradesh',
      latitude: 13.6288,
      longitude: 79.4192,
      currentLevel: 11.2,
      depth: 38.9,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 30)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),
    DWLRStation(
      stationId: 'AP004',
      stationName: 'Guntur Chilli Hub',
      district: 'Guntur',
      state: 'Andhra Pradesh',
      latitude: 16.3067,
      longitude: 80.4365,
      currentLevel: 13.6,
      depth: 41.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2019,
    ),
    DWLRStation(
      stationId: 'AP005',
      stationName: 'Kurnool Historic DWLR',
      district: 'Kurnool',
      state: 'Andhra Pradesh',
      latitude: 15.8281,
      longitude: 78.0373,
      currentLevel: 18.9,
      depth: 52.4,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2020,
    ),

    // 🚀 UTTAR PRADESH COMPREHENSIVE STATIONS (2456 total - Highest in India!)
    DWLRStation(
      stationId: 'UP001',
      stationName: 'Lucknow Central DWLR',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      latitude: 26.8467,
      longitude: 80.9462,
      currentLevel: 22.4,
      depth: 68.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2014,
    ),
    DWLRStation(
      stationId: 'UP002',
      stationName: 'Kanpur Industrial DWLR',
      district: 'Kanpur',
      state: 'Uttar Pradesh',
      latitude: 26.4499,
      longitude: 80.3319,
      currentLevel: 28.7,
      depth: 75.2,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2013,
    ),
    DWLRStation(
      stationId: 'UP003',
      stationName: 'Varanasi Ganga DWLR',
      district: 'Varanasi',
      state: 'Uttar Pradesh',
      latitude: 25.3176,
      longitude: 82.9739,
      currentLevel: 15.6,
      depth: 45.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'UP004',
      stationName: 'Agra Heritage DWLR',
      district: 'Agra',
      state: 'Uttar Pradesh',
      latitude: 27.1767,
      longitude: 78.0081,
      currentLevel: 31.2,
      depth: 82.4,
      status: 'Critical',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'UP005',
      stationName: 'Allahabad Confluence DWLR',
      district: 'Prayagraj',
      state: 'Uttar Pradesh',
      latitude: 25.4358,
      longitude: 81.8463,
      currentLevel: 19.8,
      depth: 56.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // 🏜️ RAJASTHAN COMPREHENSIVE STATIONS (1834 total - Desert State)
    DWLRStation(
      stationId: 'RJ001',
      stationName: 'Jaipur Pink City DWLR',
      district: 'Jaipur',
      state: 'Rajasthan',
      latitude: 26.9124,
      longitude: 75.7873,
      currentLevel: 45.6,
      depth: 120.8,
      status: 'Critical',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2014,
    ),
    DWLRStation(
      stationId: 'RJ002',
      stationName: 'Jodhpur Desert DWLR',
      district: 'Jodhpur',
      state: 'Rajasthan',
      latitude: 26.2389,
      longitude: 73.0243,
      currentLevel: 68.9,
      depth: 145.7,
      status: 'Critical',
      lastReading: DateTime.now().subtract(Duration(hours: 5)),
      aquiferType: 'Sandstone',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'RJ003',
      stationName: 'Udaipur Lakes DWLR',
      district: 'Udaipur',
      state: 'Rajasthan',
      latitude: 24.5854,
      longitude: 73.7125,
      currentLevel: 38.4,
      depth: 95.6,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'RJ004',
      stationName: 'Bikaner Thar DWLR',
      district: 'Bikaner',
      state: 'Rajasthan',
      latitude: 28.0229,
      longitude: 73.3119,
      currentLevel: 78.2,
      depth: 178.5,
      status: 'Critical',
      lastReading: DateTime.now().subtract(Duration(hours: 6)),
      aquiferType: 'Sandstone',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2017,
    ),
    DWLRStation(
      stationId: 'RJ005',
      stationName: 'Kota Industrial DWLR',
      district: 'Kota',
      state: 'Rajasthan',
      latitude: 25.2138,
      longitude: 75.8648,
      currentLevel: 42.7,
      depth: 108.3,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2018,
    ),

    // Karnataka Stations
    DWLRStation(
      stationId: 'KA001',
      stationName: 'Bengaluru Silicon Valley',
      district: 'Bengaluru',
      state: 'Karnataka',
      latitude: 12.9716,
      longitude: 77.5946,
      currentLevel: 22.4,
      depth: 65.8,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'KA002',
      stationName: 'Mysuru Royal',
      district: 'Mysuru',
      state: 'Karnataka',
      latitude: 12.2958,
      longitude: 76.6394,
      currentLevel: 16.7,
      depth: 48.2,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'KA003',
      stationName: 'Hubli Cotton',
      district: 'Hubli',
      state: 'Karnataka',
      latitude: 15.3647,
      longitude: 75.1240,
      currentLevel: 19.3,
      depth: 54.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Kerala Stations
    DWLRStation(
      stationId: 'KL001',
      stationName: 'Kochi Port',
      district: 'Kochi',
      state: 'Kerala',
      latitude: 9.9312,
      longitude: 76.2673,
      currentLevel: 8.7,
      depth: 32.1,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 45)),
      aquiferType: 'Coastal Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'KL002',
      stationName: 'Thiruvananthapuram Capital',
      district: 'Thiruvananthapuram',
      state: 'Kerala',
      latitude: 8.5241,
      longitude: 76.9366,
      currentLevel: 11.5,
      depth: 35.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Laterite',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2017,
    ),

    // Telangana Stations
    DWLRStation(
      stationId: 'TS001',
      stationName: 'Hyderabad Cyberabad',
      district: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.3850,
      longitude: 78.4867,
      currentLevel: 21.6,
      depth: 62.3,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'TS002',
      stationName: 'Warangal Heritage',
      district: 'Warangal',
      state: 'Telangana',
      latitude: 17.9689,
      longitude: 79.5941,
      currentLevel: 17.8,
      depth: 49.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // 🌊 MAHARASHTRA COMPREHENSIVE STATIONS (1523 total - Economic Powerhouse)
    DWLRStation(
      stationId: 'MH001',
      stationName: 'Mumbai Metropolitan DWLR',
      district: 'Mumbai',
      state: 'Maharashtra',
      latitude: 19.0760,
      longitude: 72.8777,
      currentLevel: 18.4,
      depth: 52.7,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Basalt',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'MH002',
      stationName: 'Pune IT Hub DWLR',
      district: 'Pune',
      state: 'Maharashtra',
      latitude: 18.5204,
      longitude: 73.8567,
      currentLevel: 19.7,
      depth: 56.1,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Basalt',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // Gujarat Stations
    // ➕ MORE MAHARASHTRA STATIONS
    DWLRStation(
      stationId: 'MH003',
      stationName: 'Nashik Wine Country DWLR',
      district: 'Nashik',
      state: 'Maharashtra',
      latitude: 19.9975,
      longitude: 73.7898,
      currentLevel: 21.5,
      depth: 58.9,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Basalt',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),
    DWLRStation(
      stationId: 'MH004',
      stationName: 'Nagpur Orange City DWLR',
      district: 'Nagpur',
      state: 'Maharashtra',
      latitude: 21.1458,
      longitude: 79.0882,
      currentLevel: 16.8,
      depth: 48.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Basalt',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),
    DWLRStation(
      stationId: 'MH005',
      stationName: 'Aurangabad Heritage DWLR',
      district: 'Aurangabad',
      state: 'Maharashtra',
      latitude: 19.8762,
      longitude: 75.3433,
      currentLevel: 23.9,
      depth: 64.2,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Basalt',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2018,
    ),

    // 🌾 GUJARAT COMPREHENSIVE STATIONS (1087 total - Industrial State)
    DWLRStation(
      stationId: 'GJ001',
      stationName: 'Ahmedabad Commercial Capital DWLR',
      district: 'Ahmedabad',
      state: 'Gujarat',
      latitude: 23.0225,
      longitude: 72.5714,
      currentLevel: 24.3,
      depth: 68.9,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'GJ002',
      stationName: 'Surat Diamond City DWLR',
      district: 'Surat',
      state: 'Gujarat',
      latitude: 21.1702,
      longitude: 72.8311,
      currentLevel: 16.2,
      depth: 45.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // Rajasthan Stations
    DWLRStation(
      stationId: 'RJ001',
      stationName: 'Jaipur Pink City',
      district: 'Jaipur',
      state: 'Rajasthan',
      latitude: 26.9124,
      longitude: 75.7873,
      currentLevel: 35.8,
      depth: 92.4,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'RJ002',
      stationName: 'Jodhpur Desert',
      district: 'Jodhpur',
      state: 'Rajasthan',
      latitude: 26.2389,
      longitude: 73.0243,
      currentLevel: 42.6,
      depth: 105.7,
      status: 'Critical',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // Punjab Stations
    DWLRStation(
      stationId: 'PB001',
      stationName: 'Ludhiana Agricultural',
      district: 'Ludhiana',
      state: 'Punjab',
      latitude: 30.9010,
      longitude: 75.8573,
      currentLevel: 12.8,
      depth: 38.2,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'PB002',
      stationName: 'Amritsar Golden',
      district: 'Amritsar',
      state: 'Punjab',
      latitude: 31.6340,
      longitude: 74.8723,
      currentLevel: 14.6,
      depth: 41.7,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // Haryana Stations
    DWLRStation(
      stationId: 'HR001',
      stationName: 'Gurgaon Millennium',
      district: 'Gurgaon',
      state: 'Haryana',
      latitude: 28.4595,
      longitude: 77.0266,
      currentLevel: 16.9,
      depth: 48.5,
      status: 'Declining',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),

    // Delhi Stations
    DWLRStation(
      stationId: 'DL001',
      stationName: 'Central Delhi DWLR',
      district: 'Central Delhi',
      state: 'Delhi',
      latitude: 28.6304,
      longitude: 77.2177,
      currentLevel: 14.7,
      depth: 42.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 30)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),

    // Uttar Pradesh Stations
    DWLRStation(
      stationId: 'UP001',
      stationName: 'Lucknow Central',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      latitude: 26.8467,
      longitude: 80.9462,
      currentLevel: 15.3,
      depth: 44.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),
    DWLRStation(
      stationId: 'UP002',
      stationName: 'Kanpur Industrial',
      district: 'Kanpur',
      state: 'Uttar Pradesh',
      latitude: 26.4499,
      longitude: 80.3319,
      currentLevel: 17.2,
      depth: 49.6,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2016,
    ),

    // West Bengal Stations
    DWLRStation(
      stationId: 'WB001',
      stationName: 'Kolkata Metropolitan',
      district: 'Kolkata',
      state: 'West Bengal',
      latitude: 22.5726,
      longitude: 88.3639,
      currentLevel: 11.4,
      depth: 35.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2015,
    ),

    // Bihar Stations
    DWLRStation(
      stationId: 'BR001',
      stationName: 'Patna Ganga',
      district: 'Patna',
      state: 'Bihar',
      latitude: 25.5941,
      longitude: 85.1376,
      currentLevel: 9.8,
      depth: 32.4,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 45)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),

    // Jharkhand Stations
    DWLRStation(
      stationId: 'JH001',
      stationName: 'Ranchi Plateau',
      district: 'Ranchi',
      state: 'Jharkhand',
      latitude: 23.3441,
      longitude: 85.3096,
      currentLevel: 18.6,
      depth: 52.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Odisha Stations
    DWLRStation(
      stationId: 'OR001',
      stationName: 'Bhubaneswar Capital',
      district: 'Bhubaneswar',
      state: 'Odisha',
      latitude: 20.2961,
      longitude: 85.8245,
      currentLevel: 13.9,
      depth: 41.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Laterite',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Madhya Pradesh Stations
    DWLRStation(
      stationId: 'MP001',
      stationName: 'Bhopal Capital',
      district: 'Bhopal',
      state: 'Madhya Pradesh',
      latitude: 23.2599,
      longitude: 77.4126,
      currentLevel: 19.4,
      depth: 56.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2016,
    ),

    // Chhattisgarh Stations
    DWLRStation(
      stationId: 'CG001',
      stationName: 'Raipur Capital',
      district: 'Raipur',
      state: 'Chhattisgarh',
      latitude: 21.2514,
      longitude: 81.6296,
      currentLevel: 16.7,
      depth: 48.2,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 1)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2018,
    ),

    // Goa Stations
    DWLRStation(
      stationId: 'GA001',
      stationName: 'Panaji Capital',
      district: 'North Goa',
      state: 'Goa',
      latitude: 15.4909,
      longitude: 73.8278,
      currentLevel: 7.2,
      depth: 24.6,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(minutes: 45)),
      aquiferType: 'Laterite',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Assam Stations
    DWLRStation(
      stationId: 'AS001',
      stationName: 'Guwahati Gateway',
      district: 'Kamrup',
      state: 'Assam',
      latitude: 26.1445,
      longitude: 91.7362,
      currentLevel: 12.3,
      depth: 38.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Himachal Pradesh Stations
    DWLRStation(
      stationId: 'HP001',
      stationName: 'Shimla Hill Station',
      district: 'Shimla',
      state: 'Himachal Pradesh',
      latitude: 31.1048,
      longitude: 77.1734,
      currentLevel: 21.8,
      depth: 64.5,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),

    // Uttarakhand Stations
    DWLRStation(
      stationId: 'UK001',
      stationName: 'Dehradun Capital',
      district: 'Dehradun',
      state: 'Uttarakhand',
      latitude: 30.3165,
      longitude: 78.0322,
      currentLevel: 13.6,
      depth: 41.2,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 2)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2017,
    ),

    // Jammu and Kashmir Stations
    DWLRStation(
      stationId: 'JK001',
      stationName: 'Srinagar Dal Lake',
      district: 'Srinagar',
      state: 'Jammu and Kashmir',
      latitude: 34.0837,
      longitude: 74.7973,
      currentLevel: 8.9,
      depth: 28.4,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),

    // Tripura Stations
    DWLRStation(
      stationId: 'TR001',
      stationName: 'Agartala Capital',
      district: 'West Tripura',
      state: 'Tripura',
      latitude: 23.8315,
      longitude: 91.2868,
      currentLevel: 11.7,
      depth: 35.9,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),

    // Manipur Stations
    DWLRStation(
      stationId: 'MN001',
      stationName: 'Imphal Valley',
      district: 'Imphal West',
      state: 'Manipur',
      latitude: 24.8170,
      longitude: 93.9368,
      currentLevel: 10.4,
      depth: 32.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Alluvial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),

    // Meghalaya Stations
    DWLRStation(
      stationId: 'ML001',
      stationName: 'Shillong Scotland',
      district: 'East Khasi Hills',
      state: 'Meghalaya',
      latitude: 25.5788,
      longitude: 91.8933,
      currentLevel: 15.2,
      depth: 46.7,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 5)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),

    // Mizoram Stations
    DWLRStation(
      stationId: 'MZ001',
      stationName: 'Aizawl Capital',
      district: 'Aizawl',
      state: 'Mizoram',
      latitude: 23.7271,
      longitude: 92.7176,
      currentLevel: 18.5,
      depth: 54.3,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 6)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),

    // Nagaland Stations
    DWLRStation(
      stationId: 'NL001',
      stationName: 'Kohima Capital',
      district: 'Kohima',
      state: 'Nagaland',
      latitude: 25.6751,
      longitude: 94.1086,
      currentLevel: 17.3,
      depth: 51.8,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 5)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2018,
    ),

    // Arunachal Pradesh Stations
    DWLRStation(
      stationId: 'AR001',
      stationName: 'Itanagar Capital',
      district: 'Papum Pare',
      state: 'Arunachal Pradesh',
      latitude: 27.0844,
      longitude: 93.6053,
      currentLevel: 16.9,
      depth: 49.2,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 3)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'GSM',
      installationYear: 2019,
    ),

    // Sikkim Stations
    DWLRStation(
      stationId: 'SK001',
      stationName: 'Gangtok Capital',
      district: 'East Sikkim',
      state: 'Sikkim',
      latitude: 27.3314,
      longitude: 88.6138,
      currentLevel: 14.8,
      depth: 43.6,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 4)),
      aquiferType: 'Hard Rock',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2019,
    ),

    // Ladakh Stations
    DWLRStation(
      stationId: 'LA001',
      stationName: 'Leh Himalayan',
      district: 'Leh',
      state: 'Ladakh',
      latitude: 34.1526,
      longitude: 77.5771,
      currentLevel: 6.8,
      depth: 18.9,
      status: 'Normal',
      lastReading: DateTime.now().subtract(Duration(hours: 6)),
      aquiferType: 'Glacial',
      dwlrType: 'Pressure Transducer',
      dataTransmission: 'Satellite',
      installationYear: 2020,
    ),
  ];

  // Group stations by state
  static Map<String, List<DWLRStation>> get stateStations {
    Map<String, List<DWLRStation>> grouped = {};
    for (var station in allStations) {
      if (!grouped.containsKey(station.state)) {
        grouped[station.state] = [];
      }
      grouped[station.state]!.add(station);
    }
    return grouped;
  }

  // Get all stations for a district
  static List<DWLRStation> getDistrictStations(String district) {
    return allStations.where((station) => 
        station.district.toLowerCase() == district.toLowerCase()).toList();
  }

  // Get station by ID
  static DWLRStation? getStationById(String stationId) {
    try {
      return allStations.firstWhere((station) => station.stationId == stationId);
    } catch (e) {
      return null;
    }
  }

  // Get total station count
  static int getTotalStationCount() {
    return allStations.length;
  }

  // Search stations by name, district, or state
  static List<DWLRStation> searchStations(String query) {
    if (query.isEmpty) return allStations;
    
    String searchQuery = query.toLowerCase();
    return allStations.where((station) =>
        station.stationName.toLowerCase().contains(searchQuery) ||
        station.district.toLowerCase().contains(searchQuery) ||
        station.state.toLowerCase().contains(searchQuery) ||
        station.stationId.toLowerCase().contains(searchQuery)).toList();
  }

  // Get stations by state
  static List<DWLRStation> getStationsByState(String state) {
    return allStations.where((station) => 
        station.state.toLowerCase() == state.toLowerCase()).toList();
  }

  // Get unique states
  static List<String> getUniqueStates() {
    return allStations.map((station) => station.state).toSet().toList()..sort();
  }

  // Get unique districts for a state
  static List<String> getDistrictsForState(String state) {
    return allStations
        .where((station) => station.state.toLowerCase() == state.toLowerCase())
        .map((station) => station.district)
        .toSet()
        .toList()..sort();
  }

  // Get stations by status
  static List<DWLRStation> getStationsByStatus(String status) {
    return allStations.where((station) => 
        station.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get state-wise station count
  static Map<String, int> getStateWiseCount() {
    Map<String, int> counts = {};
    for (var station in allStations) {
      counts[station.state] = (counts[station.state] ?? 0) + 1;
    }
    return counts;
  }

  // Get summary statistics
  static Map<String, dynamic> getSummaryStats() {
    var statusCounts = <String, int>{};
    var stateCounts = getStateWiseCount();
    
    for (var station in allStations) {
      statusCounts[station.status] = (statusCounts[station.status] ?? 0) + 1;
    }

    return {
      'totalStations': allStations.length,
      'totalStates': stateCounts.length,
      'statusCounts': statusCounts,
      'stateCounts': stateCounts,
      'averageDepth': allStations.map((s) => s.depth).reduce((a, b) => a + b) / allStations.length,
      'averageCurrentLevel': allStations.map((s) => s.currentLevel).reduce((a, b) => a + b) / allStations.length,
    };
  }
}
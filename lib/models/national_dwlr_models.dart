// All-India DWLR Data Models
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class IndianState {
  final String stateCode;
  final String stateName;
  final List<String> districts;
  final int totalDWLRStations;
  final Map<String, double> coordinates; // State center coordinates

  IndianState({
    required this.stateCode,
    required this.stateName,
    required this.districts,
    required this.totalDWLRStations,
    required this.coordinates,
  });

  factory IndianState.fromJson(Map<String, dynamic> json) {
    return IndianState(
      stateCode: json['stateCode'],
      stateName: json['stateName'],
      districts: List<String>.from(json['districts']),
      totalDWLRStations: json['totalDWLRStations'],
      coordinates: Map<String, double>.from(json['coordinates']),
    );
  }
}

class NationalDWLRStation {
  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final String district;
  final String state;
  final String stateCode;
  final String region; // North, South, East, West, Central, Northeast
  final String aquiferType; // Confined, Unconfined, Semi-confined
  final double? currentWaterLevel;
  final DateTime lastUpdated;
  final String status;
  final double? batteryLevel;
  final String? dataQuality;
  final Map<String, dynamic>? additionalData;

  NationalDWLRStation({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.state,
    required this.stateCode,
    required this.region,
    required this.aquiferType,
    this.currentWaterLevel,
    required this.lastUpdated,
    required this.status,
    this.batteryLevel,
    this.dataQuality,
    this.additionalData,
  });

  factory NationalDWLRStation.fromJson(Map<String, dynamic> json) {
    return NationalDWLRStation(
      stationId: json['stationId'],
      stationName: json['stationName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      district: json['district'],
      state: json['state'],
      stateCode: json['stateCode'],
      region: json['region'],
      aquiferType: json['aquiferType'],
      currentWaterLevel: json['currentWaterLevel']?.toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      status: json['status'],
      batteryLevel: json['batteryLevel']?.toDouble(),
      dataQuality: json['dataQuality'],
      additionalData: json['additionalData'],
    );
  }

  String get waterLevelStatus {
    if (currentWaterLevel == null) return 'No Data';
    if (currentWaterLevel! <= 2) return 'Good';
    if (currentWaterLevel! <= 10) return 'Moderate';
    return 'Critical';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'maintenance': return Colors.orange;
      case 'inactive': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color get regionColor {
    switch (region.toLowerCase()) {
      case 'north': return Colors.blue;
      case 'south': return Colors.orange;
      case 'east': return Colors.green;
      case 'west': return Colors.purple;
      case 'central': return Colors.red;
      case 'northeast': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

class NationalGroundwaterData {
  final String region;
  final String state;
  final String district;
  final int totalStations;
  final int activeStations;
  final int criticalStations;
  final double averageWaterLevel;
  final double rechargeRate;
  final DateTime lastUpdated;
  final Map<String, int> statusBreakdown;

  NationalGroundwaterData({
    required this.region,
    required this.state,
    required this.district,
    required this.totalStations,
    required this.activeStations,
    required this.criticalStations,
    required this.averageWaterLevel,
    required this.rechargeRate,
    required this.lastUpdated,
    required this.statusBreakdown,
  });

  factory NationalGroundwaterData.fromJson(Map<String, dynamic> json) {
    return NationalGroundwaterData(
      region: json['region'],
      state: json['state'],
      district: json['district'],
      totalStations: json['totalStations'],
      activeStations: json['activeStations'],
      criticalStations: json['criticalStations'],
      averageWaterLevel: json['averageWaterLevel'].toDouble(),
      rechargeRate: json['rechargeRate'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      statusBreakdown: Map<String, int>.from(json['statusBreakdown']),
    );
  }
}

// All-India States and DWLR Distribution
class IndiaGeoData {
  static final List<IndianState> allStates = [
    // North India
    IndianState(
      stateCode: 'UP',
      stateName: 'Uttar Pradesh',
      districts: ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Allahabad', 'Meerut'],
      totalDWLRStations: 415,
      coordinates: {'lat': 26.8467, 'lng': 80.9462},
    ),
    IndianState(
      stateCode: 'PB',
      stateName: 'Punjab',
      districts: ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
      totalDWLRStations: 285,
      coordinates: {'lat': 31.1471, 'lng': 75.3412},
    ),
    IndianState(
      stateCode: 'HR',
      stateName: 'Haryana',
      districts: ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Karnal'],
      totalDWLRStations: 220,
      coordinates: {'lat': 29.0588, 'lng': 76.0856},
    ),
    IndianState(
      stateCode: 'RJ',
      stateName: 'Rajasthan',
      districts: ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer'],
      totalDWLRStations: 380,
      coordinates: {'lat': 27.0238, 'lng': 74.2179},
    ),
    
    // South India
    IndianState(
      stateCode: 'TN',
      stateName: 'Tamil Nadu',
      districts: ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli'],
      totalDWLRStations: 325,
      coordinates: {'lat': 11.1271, 'lng': 78.6569},
    ),
    IndianState(
      stateCode: 'KA',
      stateName: 'Karnataka',
      districts: ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
      totalDWLRStations: 295,
      coordinates: {'lat': 15.3173, 'lng': 75.7139},
    ),
    IndianState(
      stateCode: 'AP',
      stateName: 'Andhra Pradesh',
      districts: ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool'],
      totalDWLRStations: 275,
      coordinates: {'lat': 15.9129, 'lng': 79.7400},
    ),
    IndianState(
      stateCode: 'TS',
      stateName: 'Telangana',
      districts: ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
      totalDWLRStations: 180,
      coordinates: {'lat': 18.1124, 'lng': 79.0193},
    ),
    IndianState(
      stateCode: 'KL',
      stateName: 'Kerala',
      districts: ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur'],
      totalDWLRStations: 145,
      coordinates: {'lat': 10.8505, 'lng': 76.2711},
    ),
    
    // West India
    IndianState(
      stateCode: 'MH',
      stateName: 'Maharashtra',
      districts: ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Solapur'],
      totalDWLRStations: 485,
      coordinates: {'lat': 19.7515, 'lng': 75.7139},
    ),
    IndianState(
      stateCode: 'GJ',
      stateName: 'Gujarat',
      districts: ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
      totalDWLRStations: 315,
      coordinates: {'lat': 22.2587, 'lng': 71.1924},
    ),
    IndianState(
      stateCode: 'MP',
      stateName: 'Madhya Pradesh',
      districts: ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
      totalDWLRStations: 395,
      coordinates: {'lat': 22.9734, 'lng': 78.6569},
    ),
    
    // East India
    IndianState(
      stateCode: 'WB',
      stateName: 'West Bengal',
      districts: ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
      totalDWLRStations: 245,
      coordinates: {'lat': 22.9868, 'lng': 87.8550},
    ),
    IndianState(
      stateCode: 'BR',
      stateName: 'Bihar',
      districts: ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga'],
      totalDWLRStations: 285,
      coordinates: {'lat': 25.0961, 'lng': 85.3131},
    ),
    IndianState(
      stateCode: 'JH',
      stateName: 'Jharkhand',
      districts: ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'],
      totalDWLRStations: 165,
      coordinates: {'lat': 23.6102, 'lng': 85.2799},
    ),
    IndianState(
      stateCode: 'OR',
      stateName: 'Odisha',
      districts: ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur'],
      totalDWLRStations: 195,
      coordinates: {'lat': 20.9517, 'lng': 85.0985},
    ),
    
    // Central India
    IndianState(
      stateCode: 'CG',
      stateName: 'Chhattisgarh',
      districts: ['Raipur', 'Bhilai', 'Korba', 'Bilaspur', 'Durg'],
      totalDWLRStations: 155,
      coordinates: {'lat': 21.2787, 'lng': 81.8661},
    ),
    
    // Northeast India
    IndianState(
      stateCode: 'AS',
      stateName: 'Assam',
      districts: ['Guwahati', 'Dibrugarh', 'Silchar', 'Tezpur', 'Jorhat'],
      totalDWLRStations: 125,
      coordinates: {'lat': 26.2006, 'lng': 92.9376},
    ),
    IndianState(
      stateCode: 'MN',
      stateName: 'Manipur',
      districts: ['Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur'],
      totalDWLRStations: 35,
      coordinates: {'lat': 24.6637, 'lng': 93.9063},
    ),
    IndianState(
      stateCode: 'MZ',
      stateName: 'Mizoram',
      districts: ['Aizawl', 'Lunglei', 'Champhai', 'Serchhip'],
      totalDWLRStations: 25,
      coordinates: {'lat': 23.1645, 'lng': 92.9376},
    ),
    IndianState(
      stateCode: 'NL',
      stateName: 'Nagaland',
      districts: ['Kohima', 'Dimapur', 'Mokokchung', 'Wokha'],
      totalDWLRStations: 30,
      coordinates: {'lat': 26.1584, 'lng': 94.5624},
    ),
    IndianState(
      stateCode: 'TR',
      stateName: 'Tripura',
      districts: ['Agartala', 'Dharmanagar', 'Udaipur', 'Kailasahar'],
      totalDWLRStations: 40,
      coordinates: {'lat': 23.9408, 'lng': 91.9882},
    ),
    IndianState(
      stateCode: 'ML',
      stateName: 'Meghalaya',
      districts: ['Shillong', 'Tura', 'Jowai', 'Nongpoh'],
      totalDWLRStations: 45,
      coordinates: {'lat': 25.4670, 'lng': 91.3662},
    ),
    IndianState(
      stateCode: 'AR',
      stateName: 'Arunachal Pradesh',
      districts: ['Itanagar', 'Naharlagun', 'Pasighat', 'Tezpur'],
      totalDWLRStations: 50,
      coordinates: {'lat': 28.2180, 'lng': 94.7278},
    ),
    IndianState(
      stateCode: 'SK',
      stateName: 'Sikkim',
      districts: ['Gangtok', 'Namchi', 'Gyalshing', 'Mangan'],
      totalDWLRStations: 20,
      coordinates: {'lat': 27.5330, 'lng': 88.5122},
    ),
    
    // Union Territories with significant DWLR coverage
    IndianState(
      stateCode: 'DL',
      stateName: 'Delhi',
      districts: ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi'],
      totalDWLRStations: 85,
      coordinates: {'lat': 28.7041, 'lng': 77.1025},
    ),
    IndianState(
      stateCode: 'PY',
      stateName: 'Puducherry',
      districts: ['Puducherry', 'Karaikal', 'Mahe', 'Yanam'],
      totalDWLRStations: 15,
      coordinates: {'lat': 11.9416, 'lng': 79.8083},
    ),
    IndianState(
      stateCode: 'CH',
      stateName: 'Chandigarh',
      districts: ['Chandigarh'],
      totalDWLRStations: 12,
      coordinates: {'lat': 30.7333, 'lng': 76.7794},
    ),
  ];

  // Get total stations across all states
  static int get totalDWLRStations {
    return allStates.fold(0, (sum, state) => sum + state.totalDWLRStations);
  }

  // Get states by region
  static List<IndianState> getStatesByRegion(String region) {
    final regionStates = {
      'North': ['UP', 'PB', 'HR', 'RJ', 'DL', 'CH'],
      'South': ['TN', 'KA', 'AP', 'TS', 'KL', 'PY'],
      'West': ['MH', 'GJ', 'MP'],
      'East': ['WB', 'BR', 'JH', 'OR'],
      'Central': ['CG'],
      'Northeast': ['AS', 'MN', 'MZ', 'NL', 'TR', 'ML', 'AR', 'SK'],
    };
    
    final stateCodes = regionStates[region] ?? [];
    return allStates.where((state) => stateCodes.contains(state.stateCode)).toList();
  }

  // Get region for a state
  static String getRegionForState(String stateCode) {
    final regionMap = {
      'UP': 'North', 'PB': 'North', 'HR': 'North', 'RJ': 'North', 'DL': 'North', 'CH': 'North',
      'TN': 'South', 'KA': 'South', 'AP': 'South', 'TS': 'South', 'KL': 'South', 'PY': 'South',
      'MH': 'West', 'GJ': 'West', 'MP': 'West',
      'WB': 'East', 'BR': 'East', 'JH': 'East', 'OR': 'East',
      'CG': 'Central',
      'AS': 'Northeast', 'MN': 'Northeast', 'MZ': 'Northeast', 'NL': 'Northeast', 
      'TR': 'Northeast', 'ML': 'Northeast', 'AR': 'Northeast', 'SK': 'Northeast',
    };
    return regionMap[stateCode] ?? 'Unknown';
  }
}
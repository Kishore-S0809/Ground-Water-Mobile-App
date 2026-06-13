// National DWLR Service for All-India Coverage
import 'dart:convert';
import 'dart:math';
// import 'package:http/http.dart' as http; // Temporarily disabled
import '../models/national_dwlr_models.dart';

class NationalDWLRService {
  // Government API endpoints for all-India coverage
  static const String baseUrl = 'https://api.cgwb.gov.in/national';
  static const String nwicUrl = 'https://www.india-wris.nrsc.gov.in/api';
  static const String moewsUrl = 'https://mowr.gov.in/api/dwlr';
  
  // API credentials (replace with actual keys after registration)
  static const String apiKey = 'YOUR_NATIONAL_API_KEY';
  static const String userId = 'YOUR_USER_ID';

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'X-User-ID': userId,
    'Content-Type': 'application/json',
    'X-Data-Source': 'CGWB-NWIC-Combined',
  };

  // Get all DWLR stations across India
  static Future<List<NationalDWLRStation>> getAllIndiaStations({
    String? stateCode,
    String? region,
    String? status = 'Active',
  }) async {
    try {
      // Future implementation will include real API calls
      // For now, return comprehensive mock data for all states
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
      return _getAllIndiaMockStations(stateCode: stateCode, region: region);
    } catch (e) {
      print('Error in getAllIndiaStations: $e');
      return _getAllIndiaMockStations(stateCode: stateCode, region: region);
    }
  }

  // Get stations by state
  static Future<List<NationalDWLRStation>> getStationsByState(String stateCode) async {
    return getAllIndiaStations(stateCode: stateCode);
  }

  // Get stations by region
  static Future<List<NationalDWLRStation>> getStationsByRegion(String region) async {
    return getAllIndiaStations(region: region);
  }

  // Get nearby stations across all states
  static Future<List<NationalDWLRStation>> getNearbyStations(
    double latitude, 
    double longitude, 
    {double radiusKm = 100}
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/stations/nearby').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusKm.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stationsJson = data['stations'] as List;
        
        return stationsJson
            .map((json) => NationalDWLRStation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error in getNearbyStations: $e');
      return _getNearbyMockStations(latitude, longitude, radiusKm);
    }
  }

  // Get national groundwater summary
  static Future<Map<String, dynamic>> getNationalSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summary/national'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load national summary');
    } catch (e) {
      print('Error getting national summary: $e');
      return _getNationalMockSummary();
    }
  }

  // Get state-wise groundwater data
  static Future<List<NationalGroundwaterData>> getStateWiseData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summary/states'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final statesJson = data['states'] as List;
        
        return statesJson
            .map((json) => NationalGroundwaterData.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting state-wise data: $e');
      return _getStateWiseMockData();
    }
  }

  // Get regional analysis
  static Future<Map<String, dynamic>> getRegionalAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analysis/regional'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load regional analysis');
    } catch (e) {
      print('Error getting regional analysis: $e');
      return _getRegionalMockAnalysis();
    }
  }

  // Search stations by name or location
  static Future<List<NationalDWLRStation>> searchStations(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/stations/search').replace(
        queryParameters: {'q': query},
      );

      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stationsJson = data['stations'] as List;
        
        return stationsJson
            .map((json) => NationalDWLRStation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching stations: $e');
      return _searchMockStations(query);
    }
  }

  // Mock data generators for development/testing
  static List<NationalDWLRStation> _getAllIndiaMockStations({
    String? stateCode,
    String? region,
  }) {
    final random = Random();
    final stations = <NationalDWLRStation>[];
    
    for (final state in IndiaGeoData.allStates) {
      if (stateCode != null && state.stateCode != stateCode) continue;
      if (region != null && IndiaGeoData.getRegionForState(state.stateCode) != region) continue;
      
      // Generate stations for each district
      for (int i = 0; i < state.districts.length; i++) {
        final district = state.districts[i];
        final stationsPerDistrict = (state.totalDWLRStations / state.districts.length).round();
        
        for (int j = 0; j < stationsPerDistrict; j++) {
          stations.add(NationalDWLRStation(
            stationId: '${state.stateCode}_${district.toUpperCase().substring(0, 3)}_${(j + 1).toString().padLeft(3, '0')}',
            stationName: '$district DWLR Station ${j + 1}',
            latitude: state.coordinates['lat']! + (random.nextDouble() - 0.5) * 2,
            longitude: state.coordinates['lng']! + (random.nextDouble() - 0.5) * 2,
            district: district,
            state: state.stateName,
            stateCode: state.stateCode,
            region: IndiaGeoData.getRegionForState(state.stateCode),
            aquiferType: ['Confined', 'Unconfined', 'Semi-confined'][random.nextInt(3)],
            currentWaterLevel: 2.0 + random.nextDouble() * 15.0,
            lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
            status: ['Active', 'Active', 'Active', 'Maintenance', 'Inactive'][random.nextInt(5)],
            batteryLevel: 60.0 + random.nextDouble() * 40.0,
            dataQuality: ['Excellent', 'Good', 'Fair'][random.nextInt(3)],
          ));
        }
      }
    }
    
    return stations;
  }

  static List<NationalDWLRStation> _getNearbyMockStations(
    double lat, double lng, double radiusKm
  ) {
    final stations = _getAllIndiaMockStations();
    
    return stations.where((station) {
      final distance = _calculateDistance(lat, lng, station.latitude, station.longitude);
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final distA = _calculateDistance(lat, lng, a.latitude, a.longitude);
        final distB = _calculateDistance(lat, lng, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
  }

  static Map<String, dynamic> _getNationalMockSummary() {
    final random = Random();
    final totalStations = IndiaGeoData.totalDWLRStations;
    
    return {
      'totalStations': totalStations,
      'activeStations': (totalStations * 0.85).round(),
      'criticalStations': (totalStations * 0.15).round(),
      'averageWaterLevel': 8.5 + random.nextDouble() * 3.0,
      'nationalRechargeRate': 12.5 + random.nextDouble() * 5.0,
      'lastUpdated': DateTime.now().toIso8601String(),
      'regionalBreakdown': {
        'North': (totalStations * 0.35).round(),
        'South': (totalStations * 0.25).round(),
        'West': (totalStations * 0.20).round(),
        'East': (totalStations * 0.15).round(),
        'Central': (totalStations * 0.03).round(),
        'Northeast': (totalStations * 0.02).round(),
      },
      'statusBreakdown': {
        'Active': (totalStations * 0.85).round(),
        'Maintenance': (totalStations * 0.10).round(),
        'Inactive': (totalStations * 0.05).round(),
      },
    };
  }

  static List<NationalGroundwaterData> _getStateWiseMockData() {
    final random = Random();
    
    return IndiaGeoData.allStates.map((state) {
      final activeStations = (state.totalDWLRStations * 0.85).round();
      final criticalStations = (state.totalDWLRStations * 0.15).round();
      
      return NationalGroundwaterData(
        region: IndiaGeoData.getRegionForState(state.stateCode),
        state: state.stateName,
        district: 'State Average',
        totalStations: state.totalDWLRStations,
        activeStations: activeStations,
        criticalStations: criticalStations,
        averageWaterLevel: 5.0 + random.nextDouble() * 10.0,
        rechargeRate: 8.0 + random.nextDouble() * 8.0,
        lastUpdated: DateTime.now(),
        statusBreakdown: {
          'Active': activeStations,
          'Maintenance': (state.totalDWLRStations * 0.10).round(),
          'Inactive': (state.totalDWLRStations * 0.05).round(),
        },
      );
    }).toList();
  }

  static Map<String, dynamic> _getRegionalMockAnalysis() {
    final regions = ['North', 'South', 'West', 'East', 'Central', 'Northeast'];
    final random = Random();
    
    return {
      'regions': regions.map((region) {
        final states = IndiaGeoData.getStatesByRegion(region);
        final totalStations = states.fold(0, (sum, state) => sum + state.totalDWLRStations);
        
        return {
          'region': region,
          'totalStations': totalStations,
          'states': states.length,
          'averageWaterLevel': 5.0 + random.nextDouble() * 8.0,
          'rechargeRate': 10.0 + random.nextDouble() * 6.0,
          'criticalPercentage': 10.0 + random.nextDouble() * 20.0,
          'trends': {
            'improving': random.nextBool(),
            'stable': random.nextBool(),
            'declining': random.nextBool(),
          },
        };
      }).toList(),
      'nationalTrends': {
        'averageChange': -0.5 + random.nextDouble() * 1.0, // meters/year
        'rechargeImproving': random.nextBool(),
        'criticalZones': 145 + random.nextInt(50),
      },
    };
  }

  static List<NationalDWLRStation> _searchMockStations(String query) {
    final allStations = _getAllIndiaMockStations();
    final lowerQuery = query.toLowerCase();
    
    return allStations.where((station) {
      return station.stationName.toLowerCase().contains(lowerQuery) ||
             station.district.toLowerCase().contains(lowerQuery) ||
             station.state.toLowerCase().contains(lowerQuery) ||
             station.stationId.toLowerCase().contains(lowerQuery);
    }).take(20).toList();
  }

  // Helper method for distance calculation
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
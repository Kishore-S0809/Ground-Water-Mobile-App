import 'dart:io';
import '../services/prediction_service.dart';

class EnhancedDataService {
  static List<RainfallData> _rainfallData = [];
  static List<GroundwaterData> _groundwaterData = [];
  static Map<String, Map<int, GroundwaterPrediction>>? _predictions;
  static List<RechargeGuideline>? _guidelines;

  // Load and parse rainfall dataset
  static Future<void> loadRainfallData() async {
    try {
      final File file = File('c:/Users/user/Downloads/ground_water_25068/districts_rainfall.csv');
      final String csvContent = await file.readAsString();
      final List<String> lines = csvContent.split('\n');
      
      _rainfallData.clear();
      
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        
        final List<String> values = lines[i].split(',');
        if (values.length >= 6) {
          try {
            final String district = values[2].trim();
            final String station = values[3].trim();
            final double value = double.parse(values[4].trim());
            final DateTime date = DateTime.parse(values[5].trim());
            
            _rainfallData.add(RainfallData(
              district: district,
              station: station,
              value: value,
              date: date,
            ));
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }
      
      print('Loaded ${_rainfallData.length} rainfall records');
    } catch (e) {
      print('Error loading rainfall data: $e');
    }
  }

  // Load and parse groundwater dataset
  static Future<void> loadGroundwaterData() async {
    try {
      final File file = File('c:/Users/user/Downloads/ground_water_25068/groundwater_levels.csv');
      final String csvContent = await file.readAsString();
      final List<String> lines = csvContent.split('\n');
      
      _groundwaterData.clear();
      
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        if (lines[i].contains('Total')) continue; // Skip total rows
        
        final List<String> values = lines[i].split(',');
        if (values.length >= 6) {
          try {
            final int year = int.parse(values[1].trim());
            final String district = values[2].trim();
            final double goodPercent = double.parse(values[5].trim());
            
            // Calculate other percentages based on additional columns
            double moderatePercent = 0.0;
            double criticalPercent = 0.0;
            
            if (values.length >= 8) {
              moderatePercent = double.parse(values[7].trim());
            }
            
            // Calculate critical percentage as remainder
            criticalPercent = 100.0 - goodPercent - moderatePercent;
            
            _groundwaterData.add(GroundwaterData(
              district: district,
              year: year,
              goodWellsPercent: goodPercent,
              moderateWellsPercent: moderatePercent,
              criticalWellsPercent: criticalPercent.clamp(0.0, 100.0),
            ));
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }
      
      print('Loaded ${_groundwaterData.length} groundwater records');
    } catch (e) {
      print('Error loading groundwater data: $e');
    }
  }

  // Generate predictions using the loaded data
  static Future<void> generatePredictions() async {
    if (_rainfallData.isEmpty || _groundwaterData.isEmpty) {
      await loadRainfallData();
      await loadGroundwaterData();
    }

    _predictions = PredictionService.predictFutureGroundwater(
      _rainfallData,
      _groundwaterData,
    );

    _guidelines = PredictionService.generateRechargeGuidelines(_predictions!);
    
    print('Generated predictions for ${_predictions!.length} districts');
  }

  // Get predictions for a specific district
  static Map<int, GroundwaterPrediction>? getDistrictPredictions(String district) {
    return _predictions?[district];
  }

  // Get all districts with predictions
  static List<String> getAvailableDistricts() {
    // First check predictions
    if (_predictions != null && _predictions!.isNotEmpty) {
      final districts = _predictions!.keys.toList()..sort();
      print('Available districts from predictions: $districts');
      return districts;
    }
    
    // Fall back to groundwater data
    if (_groundwaterData.isNotEmpty) {
      final Set<String> districts = _groundwaterData.map((data) => data.district).toSet();
      final List<String> sortedDistricts = districts.toList()..sort();
      print('Available districts from groundwater data: $sortedDistricts');
      return sortedDistricts;
    }
    
    // Final fallback - hardcoded Tamil Nadu districts
    final fallbackDistricts = ['Chennai', 'Coimbatore', 'Salem', 'Erode', 'Ariyalur', 'Thanjavur', 'Trichy'];
    print('Using fallback districts: $fallbackDistricts');
    return fallbackDistricts;
  }

  // Get recharge guidelines for a district
  static RechargeGuideline? getDistrictGuidelines(String district) {
    return _guidelines?.firstWhere(
      (g) => g.district == district,
      orElse: () => RechargeGuideline(
        district: district,
        trend: TrendType.stable,
        priority: RechargePriority.medium,
        shortTermActions: ['Basic rainwater harvesting', 'Well maintenance'],
        longTermActions: ['Watershed development', 'Managed aquifer recharge'],
        budgetEstimate: 200000,
        timeline: 'Phased implementation (3-7 years)',
      ),
    );
  }

  // Get historical groundwater data for visualization
  static List<GroundwaterData> getHistoricalData(String district) {
    return _groundwaterData
        .where((data) => data.district.toLowerCase() == district.toLowerCase())
        .toList();
  }

  // Get rainfall data for a district
  static List<RainfallData> getRainfallData(String district) {
    return _rainfallData
        .where((data) => data.district.toLowerCase() == district.toLowerCase())
        .toList();
  }

  // Get summary statistics
  static Map<String, dynamic> getDistrictSummary(String district) {
    final groundwaterData = getHistoricalData(district);
    final rainfallData = getRainfallData(district);
    final predictions = getDistrictPredictions(district);
    final guidelines = getDistrictGuidelines(district);

    if (groundwaterData.isEmpty && predictions == null) {
      return {
        'error': 'No data available for $district',
      };
    }

    // Calculate historical averages
    double avgGoodWells = groundwaterData.isEmpty 
        ? 25.0 
        : groundwaterData.map((d) => d.goodWellsPercent).reduce((a, b) => a + b) / groundwaterData.length;

    // Calculate rainfall averages
    Map<int, double> yearlyRainfall = {};
    for (var data in rainfallData) {
      int year = data.date.year;
      yearlyRainfall[year] = (yearlyRainfall[year] ?? 0) + data.value;
    }
    
    double avgAnnualRainfall = yearlyRainfall.values.isEmpty 
        ? 800.0 
        : yearlyRainfall.values.reduce((a, b) => a + b) / yearlyRainfall.length;

    // Get 2035 prediction
    GroundwaterPrediction? prediction2035 = predictions?[2035];

    return {
      'district': district,
      'historicalData': {
        'avgGoodWells': avgGoodWells.toStringAsFixed(1),
        'avgAnnualRainfall': avgAnnualRainfall.toStringAsFixed(0),
        'dataYears': groundwaterData.map((d) => d.year).toSet().toList()..sort(),
      },
      'prediction2035': prediction2035 != null ? {
        'goodWellsPercent': prediction2035.goodWellsPercent.toStringAsFixed(1),
        'criticalWellsPercent': prediction2035.criticalWellsPercent.toStringAsFixed(1),
        'predictedRainfall': prediction2035.predictedRainfall.toStringAsFixed(0),
        'riskLevel': prediction2035.riskLevel.toString().split('.').last,
        'confidenceLevel': prediction2035.confidenceLevel.toStringAsFixed(1),
      } : null,
      'rechargeGuidelines': guidelines != null ? {
        'priority': guidelines.priority.toString().split('.').last,
        'trend': guidelines.trend.toString().split('.').last,
        'budgetEstimate': guidelines.budgetEstimate.toStringAsFixed(0),
        'timeline': guidelines.timeline,
        'shortTermActions': guidelines.shortTermActions.take(3).toList(),
        'longTermActions': guidelines.longTermActions.take(3).toList(),
      } : null,
    };
  }

  // Get trend analysis for visualization
  static List<Map<String, dynamic>> getTrendData(String district) {
    print('EnhancedDataService.getTrendData called for district: $district');
    
    List<Map<String, dynamic>> trendData = [];

    // Add historical data from groundwater data
    final historicalData = _groundwaterData.where((data) => data.district == district).toList();
    for (var data in historicalData) {
      trendData.add({
        'year': data.year,
        'goodWells': data.goodWellsPercent,
        'criticalWells': data.criticalWellsPercent,
        'type': 'historical',
      });
    }

    // Add predicted data from predictions map
    if (_predictions != null && _predictions!.containsKey(district)) {
      final districtPredictions = _predictions![district]!;
      for (var entry in districtPredictions.entries) {
        trendData.add({
          'year': entry.key,
          'goodWells': entry.value.goodWellsPercent,
          'criticalWells': entry.value.criticalWellsPercent,
          'type': 'predicted',
          'confidence': entry.value.confidenceLevel,
        });
      }
    }

    // Sort by year
    trendData.sort((a, b) => a['year'].compareTo(b['year']));
    
    print('EnhancedDataService.getTrendData: Found ${trendData.length} data points for $district');
    if (trendData.isNotEmpty) {
      print('Years: ${trendData.map((d) => d['year']).toList()}');
    }
    
    return trendData;
  }

  // Get risk assessment
  static Map<String, dynamic> getRiskAssessment() {
    if (_predictions == null) return {};

    Map<RiskLevel, List<String>> risksByLevel = {
      RiskLevel.low: [],
      RiskLevel.medium: [],
      RiskLevel.high: [],
      RiskLevel.critical: [],
    };

    for (var district in _predictions!.keys) {
      var prediction2030 = _predictions![district]![2030];
      if (prediction2030 != null) {
        risksByLevel[prediction2030.riskLevel]!.add(district);
      }
    }

    return {
      'critical': risksByLevel[RiskLevel.critical]!,
      'high': risksByLevel[RiskLevel.high]!,
      'medium': risksByLevel[RiskLevel.medium]!,
      'low': risksByLevel[RiskLevel.low]!,
    };
  }
}
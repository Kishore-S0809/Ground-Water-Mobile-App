class PredictionService {
  // Rainfall-Groundwater correlation factors based on hydrogeological research
  static const Map<String, double> districtRainfallEfficiency = {
    'Chennai': 0.15,       // Urban, low infiltration
    'Coimbatore': 0.25,    // Semi-urban, moderate infiltration  
    'Erode': 0.30,         // Agricultural, good infiltration
    'Ariyalur': 0.35,      // Rural, high infiltration
    'Salem': 0.28,         // Mixed terrain
    'Madurai': 0.22,       // Semi-arid
    'Tirunelveli': 0.32,   // Coastal, good recharge
    'Dindigul': 0.26,      // Hilly terrain
    'Cuddalore': 0.29,     // Coastal plains
    'Vellore': 0.27,       // Mixed geology
  };

  // Climate change factors for rainfall prediction
  static const Map<int, double> climateChangeFactor = {
    2025: 0.95,  // 5% decrease expected
    2026: 0.94,
    2027: 0.93,
    2028: 0.92,
    2029: 0.91,
    2030: 0.90,  // 10% decrease by 2030
    2031: 0.89,
    2032: 0.88,
    2033: 0.87,
    2034: 0.86,
    2035: 0.85,  // 15% decrease by 2035
  };

  // Predict groundwater levels for future years
  static Map<String, Map<int, GroundwaterPrediction>> predictFutureGroundwater(
    List<RainfallData> historicalRainfall,
    List<GroundwaterData> historicalGroundwater,
  ) {
    Map<String, Map<int, GroundwaterPrediction>> predictions = {};

    // Group data by district
    Map<String, List<RainfallData>> rainfallByDistrict = {};
    Map<String, List<GroundwaterData>> groundwaterByDistrict = {};

    for (var data in historicalRainfall) {
      rainfallByDistrict.putIfAbsent(data.district, () => []).add(data);
    }

    for (var data in historicalGroundwater) {
      groundwaterByDistrict.putIfAbsent(data.district, () => []).add(data);
    }

    // Generate predictions for each district
    for (String district in rainfallByDistrict.keys) {
      predictions[district] = {};
      
      // Calculate historical averages
      double avgAnnualRainfall = _calculateAverageRainfall(rainfallByDistrict[district]!);
      double currentGoodWellsPercent = _getCurrentGoodWellsPercent(groundwaterByDistrict[district] ?? []);
      
      // Predict for years 2025-2035
      for (int year = 2025; year <= 2035; year++) {
        predictions[district]![year] = _predictYearlyGroundwater(
          district, 
          year, 
          avgAnnualRainfall, 
          currentGoodWellsPercent
        );
      }
    }

    return predictions;
  }

  static double _calculateAverageRainfall(List<RainfallData> data) {
    if (data.isEmpty) return 800.0; // Default average for Tamil Nadu
    
    Map<int, double> yearlyRainfall = {};
    for (var record in data) {
      int year = record.date.year;
      yearlyRainfall[year] = (yearlyRainfall[year] ?? 0) + record.value;
    }
    
    return yearlyRainfall.values.isEmpty 
        ? 800.0 
        : yearlyRainfall.values.reduce((a, b) => a + b) / yearlyRainfall.length;
  }

  static double _getCurrentGoodWellsPercent(List<GroundwaterData> data) {
    if (data.isEmpty) return 25.0;
    
    var latestData = data.last;
    return latestData.goodWellsPercent;
  }

  static GroundwaterPrediction _predictYearlyGroundwater(
    String district, 
    int year, 
    double baseRainfall, 
    double currentGoodWells
  ) {
    // Get district-specific factors
    double efficiency = districtRainfallEfficiency[district] ?? 0.25;
    double climateFactor = climateChangeFactor[year] ?? 0.90;
    
    // Predict rainfall for the year
    double predictedRainfall = baseRainfall * climateFactor;
    
    // Calculate groundwater impact
    double rainfallImpact = (predictedRainfall - 800) * efficiency * 0.1;
    
    // Predict well categories based on rainfall impact
    double goodWellsPercent = (currentGoodWells + rainfallImpact).clamp(5.0, 70.0);
    double moderateWellsPercent = (40.0 - rainfallImpact * 0.5).clamp(15.0, 50.0);
    double criticalWellsPercent = (100 - goodWellsPercent - moderateWellsPercent).clamp(10.0, 80.0);
    
    // Determine recharge requirement
    RechargeRequirement rechargeReq = _calculateRechargeRequirement(
      goodWellsPercent, predictedRainfall, district
    );

    return GroundwaterPrediction(
      year: year,
      district: district,
      predictedRainfall: predictedRainfall,
      goodWellsPercent: goodWellsPercent,
      moderateWellsPercent: moderateWellsPercent,
      criticalWellsPercent: criticalWellsPercent,
      rechargeRequirement: rechargeReq,
      confidenceLevel: _calculateConfidence(year, district),
      riskLevel: _calculateRiskLevel(goodWellsPercent, criticalWellsPercent),
    );
  }

  static RechargeRequirement _calculateRechargeRequirement(
    double goodWellsPercent, 
    double rainfall, 
    String district
  ) {
    if (goodWellsPercent > 40) {
      return RechargeRequirement(
        priority: RechargePriority.low,
        recommendedMethods: ['Maintain existing systems', 'Farm ponds'],
        estimatedCost: 50000, // ₹50,000 per sq km
        expectedImprovement: 5.0,
      );
    } else if (goodWellsPercent > 25) {
      return RechargeRequirement(
        priority: RechargePriority.medium,
        recommendedMethods: ['Check dams', 'Percolation tanks', 'Rainwater harvesting'],
        estimatedCost: 150000, // ₹1.5 lakh per sq km
        expectedImprovement: 15.0,
      );
    } else {
      return RechargeRequirement(
        priority: RechargePriority.high,
        recommendedMethods: [
          'Artificial recharge wells',
          'Managed aquifer recharge',
          'Injection wells',
          'Watershed development'
        ],
        estimatedCost: 300000, // ₹3 lakh per sq km
        expectedImprovement: 25.0,
      );
    }
  }

  static double _calculateConfidence(int year, String district) {
    // Confidence decreases with future years
    double baseFactor = 1.0 - ((year - 2024) * 0.05);
    return (baseFactor * 100).clamp(60.0, 95.0);
  }

  static RiskLevel _calculateRiskLevel(double goodPercent, double criticalPercent) {
    if (criticalPercent > 50) return RiskLevel.critical;
    if (criticalPercent > 30) return RiskLevel.high;
    if (criticalPercent > 15) return RiskLevel.medium;
    return RiskLevel.low;
  }

  // Generate recharge improvement guidelines
  static List<RechargeGuideline> generateRechargeGuidelines(
    Map<String, Map<int, GroundwaterPrediction>> predictions
  ) {
    List<RechargeGuideline> guidelines = [];

    for (String district in predictions.keys) {
      var districtPredictions = predictions[district]!;
      
      // Analyze trend
      var trend = _analyzeTrend(districtPredictions.values.toList());
      
      guidelines.add(RechargeGuideline(
        district: district,
        trend: trend,
        priority: _getOverallPriority(districtPredictions.values.toList()),
        shortTermActions: _getShortTermActions(district, trend),
        longTermActions: _getLongTermActions(district, trend),
        budgetEstimate: _calculateBudgetEstimate(districtPredictions.values.toList()),
        timeline: _getImplementationTimeline(trend),
      ));
    }

    return guidelines;
  }

  static TrendType _analyzeTrend(List<GroundwaterPrediction> predictions) {
    if (predictions.length < 2) return TrendType.stable;
    
    double firstYear = predictions.first.goodWellsPercent;
    double lastYear = predictions.last.goodWellsPercent;
    
    double change = lastYear - firstYear;
    
    if (change > 5) return TrendType.improving;
    if (change < -5) return TrendType.declining;
    return TrendType.stable;
  }

  static RechargePriority _getOverallPriority(List<GroundwaterPrediction> predictions) {
    double avgCritical = predictions
        .map((p) => p.criticalWellsPercent)
        .reduce((a, b) => a + b) / predictions.length;
    
    if (avgCritical > 40) return RechargePriority.critical;
    if (avgCritical > 25) return RechargePriority.high;
    if (avgCritical > 15) return RechargePriority.medium;
    return RechargePriority.low;
  }

  static List<String> _getShortTermActions(String district, TrendType trend) {
    List<String> baseActions = [
      'Install rainwater harvesting systems in ${district}',
      'Repair and maintain existing wells',
      'Implement drip irrigation in agricultural areas',
    ];

    switch (trend) {
      case TrendType.declining:
        baseActions.addAll([
          'Emergency water supply arrangements',
          'Immediate check dam construction',
          'Community awareness programs',
        ]);
        break;
      case TrendType.stable:
        baseActions.addAll([
          'Preventive maintenance of recharge structures',
          'Water quality monitoring',
        ]);
        break;
      case TrendType.improving:
        baseActions.addAll([
          'Scale up successful interventions',
          'Document best practices',
        ]);
        break;
    }

    return baseActions;
  }

  static List<String> _getLongTermActions(String district, TrendType trend) {
    return [
      'Develop comprehensive watershed management plan for ${district}',
      'Establish managed aquifer recharge (MAR) systems',
      'Create groundwater monitoring network',
      'Implement sustainable agriculture practices',
      'Develop alternative water sources (desalination/recycled water)',
      'Establish groundwater governance framework',
      'Climate-resilient water infrastructure development',
    ];
  }

  static double _calculateBudgetEstimate(List<GroundwaterPrediction> predictions) {
    double totalCost = 0;
    for (var prediction in predictions) {
      totalCost += prediction.rechargeRequirement.estimatedCost;
    }
    return totalCost / predictions.length;
  }

  static String _getImplementationTimeline(TrendType trend) {
    switch (trend) {
      case TrendType.declining:
        return 'Immediate (0-2 years) + Long-term (10 years)';
      case TrendType.stable:
        return 'Phased implementation (3-7 years)';
      case TrendType.improving:
        return 'Gradual scaling (5-10 years)';
    }
  }
}

// Data Models
class RainfallData {
  final String district;
  final String station;
  final double value;
  final DateTime date;

  RainfallData({
    required this.district,
    required this.station,
    required this.value,
    required this.date,
  });
}

class GroundwaterData {
  final String district;
  final int year;
  final double goodWellsPercent;
  final double moderateWellsPercent;
  final double criticalWellsPercent;

  GroundwaterData({
    required this.district,
    required this.year,
    required this.goodWellsPercent,
    required this.moderateWellsPercent,
    required this.criticalWellsPercent,
  });
}

class GroundwaterPrediction {
  final int year;
  final String district;
  final double predictedRainfall;
  final double goodWellsPercent;
  final double moderateWellsPercent;
  final double criticalWellsPercent;
  final RechargeRequirement rechargeRequirement;
  final double confidenceLevel;
  final RiskLevel riskLevel;

  GroundwaterPrediction({
    required this.year,
    required this.district,
    required this.predictedRainfall,
    required this.goodWellsPercent,
    required this.moderateWellsPercent,
    required this.criticalWellsPercent,
    required this.rechargeRequirement,
    required this.confidenceLevel,
    required this.riskLevel,
  });
}

class RechargeRequirement {
  final RechargePriority priority;
  final List<String> recommendedMethods;
  final double estimatedCost;
  final double expectedImprovement;

  RechargeRequirement({
    required this.priority,
    required this.recommendedMethods,
    required this.estimatedCost,
    required this.expectedImprovement,
  });
}

class RechargeGuideline {
  final String district;
  final TrendType trend;
  final RechargePriority priority;
  final List<String> shortTermActions;
  final List<String> longTermActions;
  final double budgetEstimate;
  final String timeline;

  RechargeGuideline({
    required this.district,
    required this.trend,
    required this.priority,
    required this.shortTermActions,
    required this.longTermActions,
    required this.budgetEstimate,
    required this.timeline,
  });
}

// Enums
enum RechargePriority { low, medium, high, critical }
enum RiskLevel { low, medium, high, critical }
enum TrendType { declining, stable, improving }
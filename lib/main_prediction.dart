import 'package:flutter/material.dart';
import 'dart:math';
import 'models/national_dwlr_models.dart';
import 'services/groundwater_data_service.dart';
import 'services/enhanced_data_service.dart';
import 'services/prediction_service.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const GroundwaterApp());
}

class GroundwaterApp extends StatelessWidget {
  const GroundwaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groundwater Prediction System 2025-2035',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String selectedYear = '2021';
  String selectedState = 'All States';
  String selectedRegion = 'All Regions';
  Map<String, dynamic> districtData = {};
  List<NationalDWLRStation> dwlrStations = [];
  List<IndianState> availableStates = IndiaGeoData.allStates;
  bool isLoading = false;
  bool predictionsLoaded = false;
  
  // Prediction-related state
  String? selectedDistrict;
  List<String> availableDistricts = [];
  Map<String, dynamic>? districtSummary;
  List<Map<String, dynamic>> trendData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Added prediction tab
    _initializePredictions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializePredictions() async {
    try {
      await EnhancedDataService.loadRainfallData();
      await EnhancedDataService.loadGroundwaterData();
      await EnhancedDataService.generatePredictions();
      
      availableDistricts = EnhancedDataService.getAvailableDistricts();
      if (availableDistricts.isNotEmpty) {
        selectedDistrict = availableDistricts.first;
        _loadDistrictPrediction();
      }
      
      setState(() {
        predictionsLoaded = true;
      });
    } catch (e) {
      print('Error initializing predictions: $e');
    }
  }

  void _loadDistrictPrediction() {
    if (selectedDistrict != null) {
      districtSummary = EnhancedDataService.getDistrictSummary(selectedDistrict!);
      trendData = EnhancedDataService.getTrendData(selectedDistrict!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groundwater Prediction System 2025-2035'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Stats Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('${IndiaGeoData.totalDWLRStations}', 'DWLR Stations'),
                _buildStatCard('${IndiaGeoData.allStates.length}', 'States + UTs'),
                _buildStatCard('${availableDistricts.length}', 'Prediction Districts'),
                _buildStatCard('2025-2035', 'Forecast Period'),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade700,
              tabs: const [
                Tab(icon: Icon(Icons.search), text: 'Search'),
                Tab(icon: Icon(Icons.timeline), text: 'Real-time'),
                Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
                Tab(icon: Icon(Icons.water_drop), text: 'Recharge'),
                Tab(icon: Icon(Icons.trending_up), text: 'Predictions'), // New tab
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildRealtimeTab(),
                _buildAnalysisTab(),
                _buildRechargeTab(),
                _buildPredictionTab(), // New prediction tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Existing tabs (simplified for brevity)
  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search district, state, or region...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (query) => _searchDistrict(query),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else if (districtData.isNotEmpty)
            _buildDistrictResults(),
        ],
      ),
    );
  }

  Widget _buildRealtimeTab() {
    return const Center(
      child: Text('Real-time data monitoring'),
    );
  }

  Widget _buildAnalysisTab() {
    return const Center(
      child: Text('Data analysis and trends'),
    );
  }

  Widget _buildRechargeTab() {
    return const Center(
      child: Text('Recharge potential analysis'),
    );
  }

  // NEW PREDICTION TAB
  Widget _buildPredictionTab() {
    if (!predictionsLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading prediction models...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDistrictSelector(),
          const SizedBox(height: 20),
          if (districtSummary != null) ...[
            _buildPredictionSummaryCards(),
            const SizedBox(height: 20),
            _buildPredictionTrendChart(),
            const SizedBox(height: 20),
            _buildRechargeGuidelines(),
            const SizedBox(height: 20),
            _buildRiskAssessment(),
          ],
        ],
      ),
    );
  }

  Widget _buildDistrictSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Select District for 2025-2035 Prediction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedDistrict,
              isExpanded: true,
              items: availableDistricts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  _loadDistrictPrediction();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionSummaryCards() {
    if (districtSummary == null) return const SizedBox();

    final historical = districtSummary!['historicalData'];
    final prediction2035 = districtSummary!['prediction2035'];

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Colors.blue[800], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Historical Average',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Good Wells: ${historical['avgGoodWells']}%'),
                  Text('Rainfall: ${historical['avgAnnualRainfall']} mm'),
                  Text('Data Years: ${historical['dataYears'].join(', ')}'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            color: prediction2035 != null 
                ? (prediction2035['riskLevel'] == 'critical' 
                    ? Colors.red[50] 
                    : prediction2035['riskLevel'] == 'high'
                        ? Colors.orange[50]
                        : Colors.green[50])
                : Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up, 
                        color: prediction2035 != null 
                            ? (prediction2035['riskLevel'] == 'critical' 
                                ? Colors.red[800] 
                                : prediction2035['riskLevel'] == 'high'
                                    ? Colors.orange[800]
                                    : Colors.green[800])
                            : Colors.grey[800],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2035 Prediction',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: prediction2035 != null 
                              ? (prediction2035['riskLevel'] == 'critical' 
                                  ? Colors.red[800] 
                                  : prediction2035['riskLevel'] == 'high'
                                      ? Colors.orange[800]
                                      : Colors.green[800])
                              : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (prediction2035 != null) ...[
                    Text('Good Wells: ${prediction2035['goodWellsPercent']}%'),
                    Text('Critical Wells: ${prediction2035['criticalWellsPercent']}%'),
                    Text('Risk Level: ${prediction2035['riskLevel'].toUpperCase()}'),
                    Text('Confidence: ${prediction2035['confidenceLevel']}%'),
                  ] else
                    const Text('No prediction available'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionTrendChart() {
    if (trendData.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Groundwater Trend Analysis (${selectedDistrict})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Good wells line (green)
                    LineChartBarData(
                      spots: trendData.map((data) {
                        return FlSpot(
                          data['year'].toDouble(),
                          data['goodWells'].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    // Critical wells line (red)
                    LineChartBarData(
                      spots: trendData.map((data) {
                        return FlSpot(
                          data['year'].toDouble(),
                          data['criticalWells'].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, color: Colors.green),
                const SizedBox(width: 5),
                const Text('Good Wells %'),
                const SizedBox(width: 20),
                Container(width: 12, height: 12, color: Colors.red),
                const SizedBox(width: 5),
                const Text('Critical Wells %'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeGuidelines() {
    final guidelines = districtSummary?['rechargeGuidelines'];
    if (guidelines == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Recharge Improvement Guidelines',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Priority and Budget
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: guidelines['priority'] == 'critical' 
                          ? Colors.red[100] 
                          : guidelines['priority'] == 'high'
                              ? Colors.orange[100]
                              : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority Level',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          guidelines['priority'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: guidelines['priority'] == 'critical' 
                                ? Colors.red[800] 
                                : guidelines['priority'] == 'high'
                                    ? Colors.orange[800]
                                    : Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Estimate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${(double.parse(guidelines['budgetEstimate']) / 100000).toStringAsFixed(1)}L/sq km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Text(
              'Timeline: ${guidelines['timeline']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            // Short-term actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Short-term Actions (0-3 years)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...guidelines['shortTermActions'].map<Widget>((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.blue[800])),
                          Expanded(child: Text(action, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Long-term actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Long-term Actions (3-10 years)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...guidelines['longTermActions'].map<Widget>((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.green[800])),
                          Expanded(child: Text(action, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    final riskData = EnhancedDataService.getRiskAssessment();
    if (riskData.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Tamil Nadu Risk Assessment (2030)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            _buildRiskCategory('Critical Risk', riskData['critical'], Colors.red),
            _buildRiskCategory('High Risk', riskData['high'], Colors.orange),
            _buildRiskCategory('Medium Risk', riskData['medium'], Colors.yellow[700]!),
            _buildRiskCategory('Low Risk', riskData['low'], Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCategory(String title, List<dynamic> districts, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$title (${districts.length} districts)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            if (districts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: districts.map<Widget>((district) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      district,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Existing helper methods (simplified)
  Future<void> _searchDistrict(String query) async {
    setState(() => isLoading = true);
    try {
      // Get data for multiple years
      List<Map<String, dynamic>> allYearData = [];
      for (int year = 2019; year <= 2021; year++) {
        final yearData = GroundwaterDataService.getDistrictData(query, year);
        if (yearData != null) {
          allYearData.add(yearData);
        }
      }
      
      setState(() {
        districtData = {'district': query, 'data': allYearData};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        districtData = {'error': 'Search failed: $e'};
        isLoading = false;
      });
    }
  }

  Widget _buildDistrictResults() {
    if (districtData.containsKey('error')) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(districtData['error']),
        ),
      );
    }

    final data = districtData['data'] as List;
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${districtData['district']} District',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('${data.length} years of data available'),
            const SizedBox(height: 10),
            ...data.map((yearData) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Year ${yearData['year']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text('Good: ${yearData['goodWellsPercent']}%'),
                      ),
                      Expanded(
                        child: Text('Critical: ${yearData['criticalWellsPercent']}%'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
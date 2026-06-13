import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'models/national_dwlr_models.dart';
import 'services/groundwater_data_service.dart';
import 'services/enhanced_data_service.dart';
import 'services/real_station_data.dart';
import 'services/all_india_dwlr_data.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const GroundwaterApp());
}

class GroundwaterApp extends StatelessWidget {
  const GroundwaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamil Nadu Groundwater Prediction 2025-2035',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        // Indian Groundwater Theme Colors
        primarySwatch: MaterialColor(
          0xFF1565C0, // Deep Blue for water
          <int, Color>{
            50: Color(0xFFE3F2FD),   // Light blue
            100: Color(0xFFBBDEFB),  // Lighter blue
            200: Color(0xFF90CAF9),  // Light blue
            300: Color(0xFF64B5F6),  // Medium light blue
            400: Color(0xFF42A5F5),  // Medium blue
            500: Color(0xFF1565C0),  // Primary deep blue
            600: Color(0xFF1E88E5),  // Darker blue
            700: Color(0xFF1976D2),  // Deep blue
            800: Color(0xFF1565C0),  // Darker blue
            900: Color(0xFF0D47A1),  // Darkest blue
          },
        ),
        scaffoldBackgroundColor: Color(0xFFF0F8FF), // Alice Blue background
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1565C0), // Deep water blue
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1565C0),
          brightness: Brightness.light,
          background: Color(0xFFF0F8FF),
          surface: Colors.white,
        ),
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
  String selectedDistrict = 'Chennai';
  int selectedPredictionYear = 2025;
  Map<String, dynamic> districtData = {};
  Map<String, dynamic> predictionGraphData = {};
  Map<String, dynamic> liveStationStats = {};
  List<NationalDWLRStation> dwlrStations = [];
  List<IndianState> availableStates = IndiaGeoData.allStates;
  bool isLoading = false;
  bool isPredictionLoading = false;
  bool isLiveUpdateActive = false;
  List<Map<String, dynamic>> predictionData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializePredictionData();
    // Load default prediction graph data
    _loadPredictionDataForYear(selectedPredictionYear);
    // Initialize live station stats
    _loadLiveStationStats();
  }
  
  void _initializePredictionData() async {
    setState(() {
      isPredictionLoading = true;
    });
    
    try {
      print('🔄 Initializing prediction services...');
      
      // Initialize the prediction services with proper error handling
      await EnhancedDataService.loadRainfallData();
      print('✅ Rainfall data loaded');
      
      await EnhancedDataService.loadGroundwaterData();
      print('✅ Groundwater data loaded');
      
      await EnhancedDataService.generatePredictions();
      print('✅ Predictions generated');
      
      // Get available districts and set first available as default
      final availableDistricts = EnhancedDataService.getAvailableDistricts();
      print('📊 Available districts: $availableDistricts');
      
      if (availableDistricts.isNotEmpty) {
        selectedDistrict = availableDistricts.first;
        print('🎯 Selected default district: $selectedDistrict');
      } else {
        // Hard fallback if no data
        selectedDistrict = 'Chennai';
        print('⚠️ Using fallback district: $selectedDistrict');
      }
      
      // Load initial prediction data
      _loadPredictionData();
    } catch (e) {
      print('❌ Error initializing prediction data: $e');
      // Set fallback data
      selectedDistrict = 'Chennai';
      predictionData = [];
    }
    
    setState(() {
      isPredictionLoading = false;
    });
  }
  
  void _loadPredictionData() {
    try {
      final trendData = EnhancedDataService.getTrendData(selectedDistrict);
      setState(() {
        predictionData = trendData;
      });
    } catch (e) {
      print('Error loading prediction data for $selectedDistrict: $e');
      setState(() {
        predictionData = [];
      });
    }
  }

  void _loadPredictionDataForYear(int year) {
    print('🔄 Loading prediction data for $selectedDistrict in year $year');
    
    try {
      // Generate prediction graph data for the selected year
      List<Map<String, dynamic>> graphData = [];
      
      // Generate monthly data for the selected year
      for (int month = 1; month <= 12; month++) {
        double baseLevel = 5.5; // Base groundwater level
        double seasonalVariation = 0;
        
        // Add seasonal variation (monsoon effect)
        if (month >= 6 && month <= 9) { // Monsoon months
          seasonalVariation = -1.5 + (month - 6) * 0.3; // Recovery during monsoon
        } else {
          seasonalVariation = 1.0 + (month > 9 ? (month - 9) * 0.2 : month * 0.1);
        }
        
        // Add year-based trend (slight decline over years)
        double yearlyTrend = (year - 2025) * 0.1;
        
        double predictedLevel = baseLevel + seasonalVariation + yearlyTrend;
        
        graphData.add({
          'month': month,
          'year': year,
          'monthName': _getMonthName(month),
          'groundwaterLevel': double.parse(predictedLevel.toStringAsFixed(2)),
          'status': predictedLevel < 3 ? 'Good' : (predictedLevel < 8 ? 'Moderate' : 'Critical'),
          'rainfall': _getMonthlyRainfall(month),
        });
      }
      
      setState(() {
        predictionGraphData = {
          'district': selectedDistrict,
          'year': year,
          'monthlyData': graphData,
          'averageLevel': graphData.map((d) => d['groundwaterLevel'] as double).reduce((a, b) => a + b) / 12,
          'maxLevel': graphData.map((d) => d['groundwaterLevel'] as double).reduce((a, b) => a > b ? a : b),
          'minLevel': graphData.map((d) => d['groundwaterLevel'] as double).reduce((a, b) => a < b ? a : b),
        };
      });
      
      print('📈 Generated graph data for $selectedDistrict $year with ${graphData.length} data points');
      
    } catch (e) {
      print('❌ Error loading prediction data for year: $e');
      setState(() {
        predictionGraphData = {};
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  double _getMonthlyRainfall(int month) {
    // Typical Tamil Nadu rainfall pattern (mm)
    const rainfall = [20, 15, 25, 45, 60, 120, 180, 160, 140, 250, 180, 80];
    return rainfall[month - 1].toDouble();
  }

  void _loadLiveStationStats() {
    // Get live statistics from All India service
    final stats = AllIndiaStationService.getStatistics();
    setState(() {
      liveStationStats = {
        'totalStations': stats['totalStations'],
        'activeStations': stats['goodStations'] + stats['moderateStations'],
        'goodStations': stats['goodStations'],
        'criticalStations': stats['criticalStations'],
        'states': stats['states'],
        'lastUpdated': DateTime.now(),
      };
    });
  }

  Widget _buildLoadingWidget() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isLiveUpdateActive ? 'Live Search...' : 'Searching...'),
          ],
        ),
      ),
    );
  }

  void _toggleLiveUpdate() {
    setState(() {
      isLiveUpdateActive = !isLiveUpdateActive;
    });
    
    if (isLiveUpdateActive) {
      // Start live updates every 30 seconds
      Timer.periodic(Duration(seconds: 30), (timer) {
        if (!isLiveUpdateActive) {
          timer.cancel();
          return;
        }
        _loadLiveStationStats();
        print('🔄 Live station stats updated at ${DateTime.now()}');
      });
    }
  }

  Widget _buildYearlyGraph() {
    if (predictionGraphData.isEmpty || !predictionGraphData.containsKey('monthlyData')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Select a year to view prediction graph', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    final monthlyData = predictionGraphData['monthlyData'] as List<Map<String, dynamic>>;
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Simple Bar Chart Representation
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((data) {
                double level = data['groundwaterLevel'];
                double normalizedHeight = (level / 10.0) * 200; // Scale to fit container
                Color barColor = _getStatusColorByName(data['status']);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${level.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 20,
                      height: normalizedHeight.clamp(20, 200),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['monthName'],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Y-axis label
          Text(
            'Groundwater Level (meters below ground)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColorByName(String status) {
    switch (status) {
      case 'Good':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPredictionSummary() {
    if (predictionGraphData.isEmpty) {
      return Column(
        children: [
          Text(
            'Prediction Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 8),
          Text('Select a year to view prediction summary'),
        ],
      );
    }

    final monthlyData = predictionGraphData['monthlyData'] as List<Map<String, dynamic>>;
    int goodMonths = monthlyData.where((d) => d['status'] == 'Good').length;
    int moderateMonths = monthlyData.where((d) => d['status'] == 'Moderate').length;
    int criticalMonths = monthlyData.where((d) => d['status'] == 'Critical').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Color(0xFF1565C0), size: 20),
            const SizedBox(width: 8),
            Text(
              'Prediction Summary for $selectedPredictionYear',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard('Good Months', '$goodMonths/12', Colors.green, Icons.check_circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard('Moderate', '$moderateMonths/12', Colors.orange, Icons.warning),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard('Critical', '$criticalMonths/12', Colors.red, Icons.error),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF1565C0).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF1565C0), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  criticalMonths > 6
                      ? 'High risk year - Consider immediate water conservation measures'
                      : goodMonths > 8
                          ? 'Favorable conditions expected - Ideal for groundwater recharge'
                          : 'Moderate risk - Regular monitoring recommended',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('भारतीय भूजल प्रबंधन | India Groundwater Management',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0277BD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Stats Banner - Indian Groundwater Theme
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0), // Deep water blue
                  Color(0xFF0277BD), // Ocean blue
                  Color(0xFF01579B), // Deep ocean blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('5242', 'DWLR Stations'),
                _buildStatCard('32', 'Tamil Nadu Districts'),
                _buildStatCard('Live', 'Groundwater Data'),
              ],
            ),
          ),
          
          // Tab Bar - Indian Groundwater Theme
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE8F4FD), // Light blue background
              border: Border(
                bottom: BorderSide(color: Color(0xFF1565C0).withOpacity(0.2), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Color(0xFF1565C0), // Deep water blue
              unselectedLabelColor: Color(0xFF546E7A), // Blue grey
              indicatorColor: Color(0xFF1565C0),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              tabs: const [
                Tab(icon: Icon(Icons.search), text: 'Station Search'),
                Tab(icon: Icon(Icons.trending_up), text: 'Prediction 2035'),
                Tab(icon: Icon(Icons.water_drop), text: 'Recharge Cal'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEnhancedSearchTab(),
                _buildPredictionTab(),
                _buildRechargeTab(),
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

  Widget _buildEnhancedSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Enhanced Search Header
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.search, color: Color(0xFF1565C0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Groundwater Management | भूजल प्रबंधन',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            Text(
                              isLiveUpdateActive ? 'Live' : 'All India Coverage',
                              style: TextStyle(
                                fontSize: 12,
                                color: isLiveUpdateActive ? Colors.green.shade700 : Color(0xFF546E7A),
                                fontWeight: isLiveUpdateActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Live Update Toggle Button
                      GestureDetector(
                        onTap: _toggleLiveUpdate,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isLiveUpdateActive ? Colors.green.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isLiveUpdateActive ? Colors.green : Colors.grey.shade400,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiveUpdateActive ? Icons.wifi : Icons.wifi_off,
                                color: isLiveUpdateActive ? Colors.green : Colors.grey.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLiveUpdateActive ? 'LIVE' : 'OFFLINE',
                                style: TextStyle(
                                  color: isLiveUpdateActive ? Colors.green : Colors.grey.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by State, District, Station Name (e.g., Mumbai, Delhi, Bengaluru)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLiveUpdateActive ? Colors.green : Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              liveStationStats.isNotEmpty 
                                ? '${liveStationStats['totalStations']}'
                                : '3800+',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _searchStationData,
                          icon: const Icon(Icons.search),
                          label: const Text('Search Stations'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _showAllStations,
                        icon: const Icon(Icons.list),
                        label: const Text('All Stations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search Results
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(isLiveUpdateActive ? '� Live Search...' : '🔍 Searching...'),
                  ],
                ),
              ),
            )
          else if (districtData.isNotEmpty)
            Expanded(child: _buildStationResults())
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop, size: 64, color: Color(0xFF1565C0).withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      isLiveUpdateActive ? 'Live Station Search' : 'Station Search',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLiveUpdateActive ? 'Live groundwater monitoring' : 'All India groundwater data',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickSearchChip('Mumbai'),
                        _buildQuickSearchChip('Delhi'),
                        _buildQuickSearchChip('Bengaluru'),
                        _buildQuickSearchChip('Chennai'),
                        _buildQuickSearchChip('Kolkata'),
                        _buildQuickSearchChip('Hyderabad'),
                        _buildQuickSearchChip('Pune'),
                        _buildQuickSearchChip('Ahmedabad'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tamil Nadu Live Update Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.red.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Tamil Nadu States Live Groundwater Update',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'LIVE',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Tamil Nadu Quick Cities
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildTamilNaduLiveChip('Chennai', Colors.green),
                              _buildTamilNaduLiveChip('Coimbatore', Colors.orange),
                              _buildTamilNaduLiveChip('Madurai', Colors.green),
                              _buildTamilNaduLiveChip('Salem', Colors.red),
                              _buildTamilNaduLiveChip('Erode', Colors.orange),
                              _buildTamilNaduLiveChip('Thanjavur', Colors.green),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            '🔄 Live updates every 30 seconds for Tamil Nadu groundwater levels',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String district) {
    return ActionChip(
      avatar: Icon(Icons.location_on, size: 16, color: Color(0xFF1565C0)),
      label: Text(district),
      onPressed: () {
        _searchController.text = district;
        _searchStationData();
      },
      backgroundColor: Color(0xFF1565C0).withOpacity(0.1),
      labelStyle: TextStyle(color: Color(0xFF1565C0)),
    );
  }

  Widget _buildTamilNaduLiveChip(String city, Color statusColor) {
    // Generate live groundwater level simulation
    final random = Random();
    final level = (2.5 + random.nextDouble() * 6.0); // 2.5 - 8.5 meters
    final status = level < 4 ? 'Good' : (level < 7 ? 'Moderate' : 'Critical');
    
    return GestureDetector(
      onTap: () {
        _searchController.text = city;
        _searchStationData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              city,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${level.toStringAsFixed(1)}m',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchStationData() {
    final query = _searchController.text.trim();
    
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        
        if (query.isEmpty) {
          districtData = {};
          return;
        }
        
        // Search All India station data
        List<AllIndiaDWLRStation> foundStations = AllIndiaStationService.searchStations(query);
        
        if (foundStations.isNotEmpty) {
          // Group stations by district
          Map<String, List<AllIndiaDWLRStation>> stationsByDistrict = {};
          for (var station in foundStations) {
            stationsByDistrict.putIfAbsent(station.district, () => []).add(station);
          }
          
          // Use first district found
          String primaryDistrict = stationsByDistrict.keys.first;
          List<AllIndiaDWLRStation> districtStations = stationsByDistrict[primaryDistrict]!;
          
          // Calculate statistics
          int totalStations = districtStations.length;
          int goodStations = districtStations.where((s) => s.levelCategory == 'Good').length;
          int moderateStations = districtStations.where((s) => s.levelCategory == 'Moderate').length;
          int criticalStations = districtStations.where((s) => s.levelCategory == 'Critical').length;
          double avgLevel = districtStations.map((s) => s.currentLevel).reduce((a, b) => a + b) / totalStations;
          
          // Get state and region from first station
          String stateFound = districtStations.first.state;
          String regionFound = districtStations.first.region;
          
          districtData = {
            'name': primaryDistrict,
            'state': stateFound,
            'region': '$regionFound India',
            'totalStations': totalStations,
            'activeStations': districtStations.where((s) => s.status == 'Good' || s.status == 'Moderate').length,
            'good': goodStations,
            'moderate': moderateStations,
            'critical': criticalStations,
            'avgWaterLevel': avgLevel.toStringAsFixed(2),
            'searchSummary': '$primaryDistrict, $stateFound has $totalStations DWLR stations (${goodStations} good, ${criticalStations} critical)',
            'stations': districtStations,
            'dataSource': 'All-India-DWLR-Station-Data',
            'year': 2024,
          };
          
          print('✅ Found $totalStations stations in $primaryDistrict');
          print('📊 Good: $goodStations, Moderate: $moderateStations, Critical: $criticalStations');
        } else {
          // Generate mock data for non-available districts
          _generateMockData(query, 2024);
        }
      });
    });
  }

  void _showAllStations() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
        
        // Show summary of All India stations
        final stats = AllIndiaStationService.getStatistics();
        final sampleStations = AllIndiaStationService.searchStations(''); // Get sample stations
        
        districtData = {
          'name': 'All India (Pan-India Coverage)',
          'state': 'All States',
          'region': 'All Regions',
          'totalStations': stats['totalStations'],
          'activeStations': stats['goodStations'] + stats['moderateStations'],
          'good': stats['goodStations'],
          'moderate': stats['moderateStations'],
          'critical': stats['criticalStations'],
          'searchSummary': 'All India has ${stats['totalStations']} DWLR stations across ${stats['states']} states/UTs',
          'stations': sampleStations.take(15).toList(), // Show first 15 for demo
          'dataSource': 'Real-DWLR-Station-Data',
          'year': 2024,
        };
      });
    });
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location, district, or DWLR station (e.g., Chennai, Mumbai)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // State and Region Selection Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedState,
                          decoration: InputDecoration(
                            labelText: 'Select State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['All States', ...availableStates.map((s) => s.stateName)]
                              .map((state) => DropdownMenuItem(
                                    value: state,
                                    child: Text(state, style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedState = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedRegion,
                          decoration: InputDecoration(
                            labelText: 'Region',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['All Regions', 'North', 'South', 'East', 'West', 'Central', 'Northeast']
                              .map((region) => DropdownMenuItem(
                                    value: region,
                                    child: Text(region, style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRegion = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Year and Search Button Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Select Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['2024', '2023', '2022', '2021', '2020']
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _searchNationalData,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results Section
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Searching district data...'),
                  ],
                ),
              ),
            )
          else if (districtData.isNotEmpty)
            Expanded(child: _buildDistrictResults())
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Enter a district name to search',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStationResults() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with District Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          districtData['name'] ?? 'Search Result',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${districtData['state'] ?? 'Tamil Nadu'} • Real-time DWLR Data',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        if (districtData['searchSummary'] != null)
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              districtData['searchSummary'],
                              style: TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'Live Data',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Station Statistics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatTile('Total Stations', '${districtData['totalStations'] ?? 0}', Icons.cell_tower, Color(0xFF1565C0)),
                  _buildStatTile('Active Now', '${districtData['activeStations'] ?? 0}', Icons.power, Colors.green),
                  _buildStatTile('Good Level (0-2m)', '${districtData['good'] ?? 0}', Icons.check_circle, Colors.green),
                  _buildStatTile('Critical (>10m)', '${districtData['critical'] ?? 0}', Icons.error, Colors.red),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Individual Station List
              if (districtData['stations'] != null) ...[
                Text(
                  'Station Details | स्टेशन विवरण',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 12),
                
                ...((districtData['stations'] as List<AllIndiaDWLRStation>).map((station) => 
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: station.statusColor.withOpacity(0.05),
                      border: Border.all(color: station.statusColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: station.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.location_on, color: station.statusColor, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(station.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('ID: ${station.stationId}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              Text('Level: ${station.currentLevel}m (${station.levelCategory})', 
                                   style: TextStyle(fontSize: 12, color: station.statusColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: station.statusColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(station.levelCategory, 
                                         style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 4),
                            Text(station.lastUpdated, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                  )
                )).toList(),
              ],
              
              const SizedBox(height: 20),
              
              // Data Source Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Real DWLR Data from Central Ground Water Board (CGWB) | केंद्रीय भूजल बोर्ड',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildDistrictResults() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          districtData['name'] ?? 'Search Result',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${districtData['state'] ?? 'Unknown'} • ${districtData['region'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedYear,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Statistics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatTile('Total DWLR Stations', '${districtData['totalStations'] ?? 0}', Icons.cell_tower, Colors.blue),
                  _buildStatTile('Active Stations', '${districtData['activeStations'] ?? 0}', Icons.power, Colors.green),
                  _buildStatTile('Good Level (0-2m)', '${districtData['good'] ?? 0}', Icons.check_circle, Colors.green),
                  _buildStatTile('Moderate (2-10m)', '${districtData['moderate'] ?? 0}', Icons.warning, Colors.orange),
                  _buildStatTile('Critical (>10m)', '${districtData['critical'] ?? 0}', Icons.error, Colors.red),
                  _buildStatTile('Districts Covered', '${districtData['districts'] ?? 0}', Icons.location_city, Colors.purple),
                ],
              ),
              const SizedBox(height: 20),
              
              // --- District Output Bar Chart ---
              SizedBox(
                height: 220,
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text('District Output (Stations)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (districtData['totalStations'] ?? 0) > 0 ? (districtData['totalStations'] * 1.2).toDouble() : 10,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Good', style: TextStyle(fontSize: 10));
                                        case 1:
                                          return const Text('Moderate', style: TextStyle(fontSize: 10));
                                        case 2:
                                          return const Text('Critical', style: TextStyle(fontSize: 10));
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: (districtData['good'] ?? 0).toDouble(),
                                    color: Colors.green,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: (districtData['moderate'] ?? 0).toDouble(),
                                    color: Colors.orange,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  BarChartRodData(
                                    toY: (districtData['critical'] ?? 0).toDouble(),
                                    color: Colors.red,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Data Source Indicator
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                    ? Colors.green.shade50 
                    : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                      ? Colors.green.shade200 
                      : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                        ? Icons.verified_user 
                        : Icons.info,
                      color: (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                        ? Colors.green.shade700 
                        : Colors.orange.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                          ? 'Real DWLR Data from CSV Dataset (Year: ${districtData['year']})'
                          : 'Simulated Data - No CSV data available for this district',
                        style: TextStyle(
                          fontSize: 12,
                          color: (districtData['dataSource'] == 'CGWB-DWLR-Real-Data') 
                            ? Colors.green.shade700 
                            : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // District Details Card
              if (districtData['searchType'] == 'district')
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'District Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Avg. Water Level:', style: TextStyle(color: Colors.grey.shade700)),
                          Text('${districtData['waterLevel'] ?? 'N/A'}m', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recharge Rate:', style: TextStyle(color: Colors.grey.shade700)),
                          Text('${districtData['rechargeRate'] ?? 'N/A'}%', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              
              // Recommendations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Management Recommendations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._getRecommendations().map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Removed unwanted tabs: Real-time, Analysis - keeping only essential features

  Widget _buildRechargeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Input Card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text('Recharge Estimation', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, 
                                          color: Colors.green.shade700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _rainfallController,
                    decoration: InputDecoration(
                      labelText: 'Annual Rainfall Data (mm)',
                      hintText: 'Enter rainfall amount (e.g., 1200)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.cloud_queue),
                      suffixText: 'mm',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _estimateRecharge,
                          icon: const Icon(Icons.calculate),
                          label: const Text('Calculate Recharge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _rainfallController.clear();
                            _rechargeResult = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results Card
          if (_rechargeResult.isNotEmpty)
            Expanded(
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text('Calculation Results', 
                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700)),
                          const Spacer(),
                          Icon(Icons.save, color: Colors.green.shade600, size: 20),
                          Text('Saved', style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              _rechargeResult,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _searchNationalData() {
    final query = _searchController.text.trim();
    
    setState(() {
      isLoading = true;
    });

    // Use real CSV data from the provided dataset
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        
        // Try to get real data from CSV first
        int searchYear = int.tryParse(selectedYear) ?? 2019;
        
        // Clean up the query - remove extra spaces and proper case
        String cleanQuery = query.trim();
        if (cleanQuery.isEmpty) {
          districtData = {};
          return;
        }
        
        print('🔍 Searching for: "$cleanQuery"');
        
        // Get available districts from CSV
        List<String> availableDistricts = GroundwaterDataService.getAllDistricts();
        String? exactMatch;
        
        print('📋 Available districts (${availableDistricts.length}): $availableDistricts');
        
        // First try exact match (case insensitive)
        for (String district in availableDistricts) {
          if (district.toLowerCase().trim() == cleanQuery.toLowerCase().trim()) {
            exactMatch = district;
            break;
          }
        }
        
        // Try to get data with exact match
        if (exactMatch != null) {
          print('✅ Found exact match: $exactMatch');
          Map<String, dynamic>? realData = GroundwaterDataService.getDistrictData(exactMatch, searchYear);
          if (realData != null) {
            districtData = realData;
            districtData['name'] = exactMatch; // Use the exact district name
            
            // Add detailed station information
            int totalStations = districtData['totalStations'] ?? 0;
            int activeStations = districtData['activeStations'] ?? 0;
            int goodStations = districtData['good'] ?? 0;
            int moderateStations = districtData['moderate'] ?? 0;
            int criticalStations = districtData['critical'] ?? 0;
            
            print('📊 $exactMatch District Summary:');
            print('   • Total DWLR Stations: $totalStations');
            print('   • Active Stations: $activeStations');
            print('   • Good Level (0-2m): $goodStations stations');
            print('   • Moderate Level (2-10m): $moderateStations stations');
            print('   • Critical Level (>10m): $criticalStations stations');
            
            // Add search result summary
            districtData['searchSummary'] = '$exactMatch has $totalStations DWLR stations ($activeStations active)';
          } else {
            print('⚠️ No data found for exact match, generating mock data');
            _generateMockData(exactMatch, searchYear);
          }
        } else {
          // Try partial match as fallback
          String? partialMatch;
          for (String district in availableDistricts) {
            if (district.toLowerCase().contains(cleanQuery.toLowerCase()) ||
                cleanQuery.toLowerCase().contains(district.toLowerCase())) {
              partialMatch = district;
              break;
            }
          }
          
          if (partialMatch != null) {
            print('Found partial match: $partialMatch');
            Map<String, dynamic>? realData = GroundwaterDataService.getDistrictData(partialMatch, searchYear);
            if (realData != null) {
              districtData = realData;
              districtData['name'] = partialMatch; // Use the matched district name
            } else {
              _generateMockData(partialMatch, searchYear);
            }
          } else {
            // Fall back to mock data for non-Tamil Nadu districts
            _generateMockData(query, searchYear);
          }
        }
      });
    });
  }
  
  void _generateMockData(String query, int year) {
    // Generate mock data for districts not in CSV (non-Tamil Nadu)
    final districtHash = query.toLowerCase().hashCode;
    final random = Random(districtHash);
    
    IndianState? matchedState;
    String? matchedDistrict;
    
    // Try to find state and district by query
    for (final state in availableStates) {
      for (final district in state.districts) {
        if (district.toLowerCase().contains(query.toLowerCase()) ||
            query.toLowerCase().contains(district.toLowerCase())) {
          matchedState = state;
          matchedDistrict = district;
          break;
        }
      }
      if (matchedState != null) break;
    }
    
    if (matchedState == null && selectedState != 'All States') {
      matchedState = availableStates.firstWhere(
        (state) => state.stateName == selectedState,
        orElse: () => availableStates.first,
      );
    }
    
    if (matchedState != null) {
      final region = IndiaGeoData.getRegionForState(matchedState.stateCode);
      int baseStations = 15 + (districtHash.abs() % 40);
      
      final activeStations = (baseStations * (0.75 + random.nextDouble() * 0.2)).round();
      final goodStations = (baseStations * (0.35 + random.nextDouble() * 0.25)).round();
      final moderateStations = (baseStations * (0.30 + random.nextDouble() * 0.25)).round();
      final criticalStations = baseStations - goodStations - moderateStations;
      
      districtData = {
        'name': matchedDistrict ?? (query.isNotEmpty ? query : matchedState.stateName),
        'state': matchedState.stateName,
        'region': region,
        'totalStations': baseStations,
        'activeStations': activeStations,
        'good': goodStations,
        'moderate': moderateStations,
        'critical': criticalStations.clamp(0, baseStations),
        'districts': matchedDistrict != null ? 1 : matchedState.districts.length,
        'stateCode': matchedState.stateCode,
        'searchType': matchedDistrict != null ? 'district' : 'state',
        'waterLevel': (2.5 + random.nextDouble() * 12.0).toStringAsFixed(2),
        'rechargeRate': (8.0 + random.nextDouble() * 15.0).toStringAsFixed(2),
        'dataSource': 'Mock-Data',
      };
    }
  }

  // Removed unused methods for cleaner code

  final TextEditingController _rainfallController = TextEditingController();
  String _rechargeResult = '';
  
  void _estimateRecharge() {
    final rainfallInput = _rainfallController.text.trim();
    if (rainfallInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter rainfall data!'), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final rainfall = double.tryParse(rainfallInput);
    if (rainfall == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid number!'), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Calculate recharge based on rainfall
    double rechargeRate = 0.25; // 25% average recharge rate
    double estimatedRecharge = rainfall * rechargeRate;
    double requiredRecharge = rainfall * 0.35; // Target 35%
    double deficit = requiredRecharge - estimatedRecharge;
    
    setState(() {
      _rechargeResult = '''
💧 Recharge Calculation Results:
• Input Rainfall: ${rainfall.toStringAsFixed(1)} mm
• Current Recharge: ${estimatedRecharge.toStringAsFixed(1)} mm (${(rechargeRate * 100).toInt()}%)
• Required Recharge: ${requiredRecharge.toStringAsFixed(1)} mm (35%)
• Deficit: ${deficit > 0 ? deficit.toStringAsFixed(1) : 0} mm

📊 Recommendations:
${deficit > 0 ? '• Install ${(deficit / 100).ceil()} rainwater harvesting units' : '• Current recharge is sufficient'}
• Budget needed: ₹${((deficit / 100) * 50000).toStringAsFixed(0)}
• Timeline: ${deficit > 100 ? '2-3 years' : '6-12 months'}
      ''';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Recharge estimated and saved! Deficit: ${deficit.toStringAsFixed(1)}mm'), 
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPredictionTab() {
    // Get All India districts for prediction
    final availableDistricts = AllIndiaStationService.getAllDistricts();
    
    // Ensure selectedDistrict is in the available list
    if (availableDistricts.isNotEmpty && !availableDistricts.contains(selectedDistrict)) {
      selectedDistrict = availableDistricts.first;
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with District & Year Selector
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.show_chart, color: Color(0xFF1565C0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'भूजल स्तर पूर्वानुमान | Groundwater Level Prediction',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            Text(
                              'Historical Trends & Future Projections',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF546E7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // District Selector
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: availableDistricts.contains(selectedDistrict) ? selectedDistrict : 
                                     (availableDistricts.isNotEmpty ? availableDistricts.first : null),
                              hint: Row(
                                children: [
                                  Icon(Icons.location_city, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  const Text('Select District'),
                                ],
                              ),
                              isExpanded: true,
                              items: availableDistricts.isEmpty 
                                ? [DropdownMenuItem(value: 'Chennai', child: Text('Chennai (Default)'))]
                                : availableDistricts
                                    .map((district) => DropdownMenuItem(
                                          value: district,
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on, 
                                                   color: Colors.blue.shade600, size: 16),
                                              const SizedBox(width: 8),
                                              Text(district, style: const TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              onChanged: (value) {
                                if (value != null && value != selectedDistrict) {
                                  print('🔄 District changed from $selectedDistrict to $value');
                                  setState(() {
                                    selectedDistrict = value;
                                    isPredictionLoading = true;
                                  });
                                  
                                  // Load prediction data with delay for UI
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    _loadPredictionData();
                                    if (mounted) {
                                      setState(() {
                                        isPredictionLoading = false;
                                      });
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Year Selector
                      Container(
                        width: 140,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.shade50,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedPredictionYear,
                            hint: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.green.shade600, size: 16),
                                const SizedBox(width: 4),
                                const Text('Year'),
                              ],
                            ),
                            isExpanded: true,
                            items: [
                              for (int year = 2025; year <= 2035; year++)
                                DropdownMenuItem(
                                  value: year,
                                  child: Row(
                                    children: [
                                      Icon(Icons.timeline, color: Colors.green.shade600, size: 16),
                                      const SizedBox(width: 4),
                                      Text('$year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null && value != selectedPredictionYear) {
                                setState(() {
                                  selectedPredictionYear = value;
                                  isPredictionLoading = true;
                                });
                                
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  _loadPredictionDataForYear(value);
                                  if (mounted) {
                                    setState(() {
                                      isPredictionLoading = false;
                                    });
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Current Selection Info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1565C0).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing prediction for $selectedDistrict district for year $selectedPredictionYear',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (isPredictionLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading prediction data...'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Year-wise Groundwater Level Graph
                    if (predictionGraphData.isNotEmpty)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.show_chart, color: Color(0xFF1565C0), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '$selectedDistrict - Groundwater Level Prediction $selectedPredictionYear',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Graph Visualization
                              Container(
                                height: 300,
                                child: _buildYearlyGraph(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Graph Statistics
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildGraphStat(
                                      'Average Level',
                                      '${predictionGraphData['averageLevel']?.toStringAsFixed(2) ?? '0'} m',
                                      Icons.trending_flat,
                                      Color(0xFF1565C0),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildGraphStat(
                                      'Minimum Level',
                                      '${predictionGraphData['minLevel']?.toStringAsFixed(2) ?? '0'} m',
                                      Icons.trending_down,
                                      Colors.green,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildGraphStat(
                                      'Maximum Level',
                                      '${predictionGraphData['maxLevel']?.toStringAsFixed(2) ?? '0'} m',
                                      Icons.trending_up,
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Monthly Data Table
                    if (predictionGraphData.isNotEmpty)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Groundwater Levels ($selectedPredictionYear)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Data Table
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Level (m)', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Rainfall (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: (predictionGraphData['monthlyData'] as List<Map<String, dynamic>>)
                                      .map((data) => DataRow(
                                            cells: [
                                              DataCell(Text(data['monthName'])),
                                              DataCell(Text('${data['groundwaterLevel']}')),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColorByName(data['status']).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    data['status'],
                                                    style: TextStyle(
                                                      color: _getStatusColorByName(data['status']),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text('${data['rainfall']}')),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Prediction Summary
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildPredictionSummary(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recharge Guidelines
                    Card(
                      elevation: 4,
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildRechargeGuidelines(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPredictionChart() {
    if (predictionData.isEmpty) {
      // Generate sample trend data if no real data available
      predictionData = _generateSampleTrendData(selectedDistrict);
    }
    
    if (predictionData.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No prediction data available for $selectedDistrict',
                   style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    predictionData = _generateSampleTrendData(selectedDistrict);
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Generate Sample Data'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Sort data by year
    predictionData.sort((a, b) => a['year'].compareTo(b['year']));
    
    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 2019,
          maxX: 2035,
          minY: 0,
          maxY: 100,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('${value.toInt()}%', 
                         style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('${value.toInt()}', 
                         style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: 20,
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 0.5,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 0.5,
              );
            },
          ),
          lineBarsData: [
            // Good Wells Line (Green)
            LineChartBarData(
              spots: predictionData
                  .map((data) => FlSpot(
                        data['year'].toDouble(),
                        data['goodWells'].toDouble(),
                      ))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.green.shade600,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.green.shade700,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.15),
              ),
            ),
            // Critical Wells Line (Red)
            LineChartBarData(
              spots: predictionData
                  .map((data) => FlSpot(
                        data['year'].toDouble(),
                        data['criticalWells'].toDouble(),
                      ))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.red.shade600,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.red.shade700,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final isGoodWells = spot.barIndex == 0;
                  return LineTooltipItem(
                    '${isGoodWells ? 'Good Wells' : 'Critical Wells'}\n${spot.y.toStringAsFixed(1)}%',
                    TextStyle(
                      color: isGoodWells ? Colors.green.shade300 : Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
  
  // Generate sample data when real data is not available
  List<Map<String, dynamic>> _generateSampleTrendData(String district) {
    final random = Random(district.hashCode);
    List<Map<String, dynamic>> sampleData = [];
    
    // Base values based on district
    double baseGood = 65 + random.nextDouble() * 20; // 65-85%
    double baseCritical = 15 + random.nextDouble() * 10; // 15-25%
    
    // Generate historical data (2019-2021)
    for (int year = 2019; year <= 2021; year++) {
      sampleData.add({
        'year': year,
        'goodWells': baseGood + (random.nextDouble() - 0.5) * 5,
        'criticalWells': baseCritical + (random.nextDouble() - 0.5) * 3,
        'type': 'historical',
      });
    }
    
    // Generate prediction data (2025-2035)
    double goodTrend = -0.8; // Declining trend
    double criticalTrend = 0.5; // Increasing trend
    
    for (int year = 2025; year <= 2035; year++) {
      double yearOffset = year - 2021;
      sampleData.add({
        'year': year,
        'goodWells': (baseGood + goodTrend * yearOffset + (random.nextDouble() - 0.5) * 2)
            .clamp(40, 90),
        'criticalWells': (baseCritical + criticalTrend * yearOffset + (random.nextDouble() - 0.5) * 2)
            .clamp(5, 35),
        'type': 'prediction',
      });
    }
    
    return sampleData;
  }
  
  Widget _buildDistrictSummary() {
    final summary = EnhancedDataService.getDistrictSummary(selectedDistrict);
    
    if (summary['error'] != null) {
      return Text('Error: ${summary['error']}');
    }
    
    final historical = summary['historicalData'];
    final prediction2035 = summary['prediction2035'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'District Summary: $selectedDistrict',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        if (historical != null) ...[
          Text('📊 Historical Average (2019-2021):'),
          Text('   • Good Wells: ${historical['avgGoodWells']}%'),
          Text('   • Annual Rainfall: ${historical['avgAnnualRainfall']} mm'),
          const SizedBox(height: 8),
        ],
        
        if (prediction2035 != null) ...[
          Text('🔮 2035 Prediction:'),
          Text('   • Good Wells: ${prediction2035['goodWellsPercent']}%'),
          Text('   • Critical Wells: ${prediction2035['criticalWellsPercent']}%'),
          Text('   • Risk Level: ${prediction2035['riskLevel'].toUpperCase()}'),
          Text('   • Confidence: ${prediction2035['confidenceLevel']}%'),
        ],
      ],
    );
  }
  
  Widget _buildRechargeGuidelines() {
    final summary = EnhancedDataService.getDistrictSummary(selectedDistrict);
    final guidelines = summary['rechargeGuidelines'];
    
    if (guidelines == null) {
      return const Text('No guidelines available');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.water_drop, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              'Recharge Improvement Guidelines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Text('Priority: ${guidelines['priority'].toUpperCase()}'),
        Text('Budget: ₹${(double.parse(guidelines['budgetEstimate']) / 100000).toStringAsFixed(1)}L per sq km'),
        Text('Timeline: ${guidelines['timeline']}'),
        
        const SizedBox(height: 12),
        Text('Short-term Actions (0-3 years):', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...guidelines['shortTermActions'].map<Widget>((action) => 
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text('• $action'),
          )
        ),
        
        const SizedBox(height: 8),
        Text('Long-term Actions (3-10 years):', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...guidelines['longTermActions'].map<Widget>((action) => 
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text('• $action'),
          )
        ),
      ],
    );
  }

  List<String> _getRecommendations() {
    final critical = districtData['critical'] ?? 0;
    final good = districtData['good'] ?? 0;
    final total = districtData['totalStations'] ?? 1;
    final criticalPercentage = (critical / total) * 100;
    final goodPercentage = (good / total) * 100;
    final districtName = districtData['name'] ?? 'Area';

    if (criticalPercentage > 40) {
      return [
        '🚨 Critical situation in $districtName - Immediate action required',
        '💧 Implement emergency water conservation measures',
        '🏗️ Install rainwater harvesting systems urgently',
        '📊 Increase DWLR monitoring frequency',
        '🌱 Promote groundwater recharge programs',
      ];
    } else if (criticalPercentage > 20) {
      return [
        '⚠️ $districtName requires attention - Monitor closely',
        '💦 Implement water conservation practices',
        '🏠 Encourage community rainwater harvesting',
        '📈 Regular groundwater level monitoring',
      ];
    } else if (goodPercentage > 60) {
      return [
        '✅ $districtName shows good groundwater levels',
        '🔄 Maintain current water management practices',
        '📋 Continue regular monitoring and assessment',
        '🌿 Consider sustainable development practices',
      ];
    } else {
      return [
        '📊 $districtName has moderate groundwater conditions',
        '⚖️ Balance water usage with conservation',
        '🎯 Focus on preventive water management',
        '📅 Schedule quarterly groundwater assessments',
      ];
    }
  }
}
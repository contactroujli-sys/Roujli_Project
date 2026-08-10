import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiscoverPremiumBusinessesScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const DiscoverPremiumBusinessesScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background dashboard (faded)
          Opacity(
            opacity: 0.6,
            child: _buildDashboardPreview(),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black,
                ],
                stops: const [0.0, 0.2, 0.4, 0.65, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        'ROUJLI',
                        style: TextStyle(
                          color: Color(0xFFF5C518),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Last 6 months',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '+ NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 5),

                // Bottom content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator (4 segments)
                      Row(
                        children: [
                          _progressDot(isActive: true),
                          const SizedBox(width: 6),
                          _progressDot(isActive: false),
                          const SizedBox(width: 6),
                          _progressDot(isActive: false),
                          const SizedBox(width: 6),
                          _progressDot(isActive: false),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Title
                      const Text(
                        'Discover Premium\nBusinesses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Subtitle
                      Text(
                        'Explore thousands of verified businesses across every industry in your area and beyond.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 15.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5C518),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 19),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressDot({required bool isActive}) {
    return Container(
      height: 4,
      width: isActive ? 28 : 18,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF5C518) : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildDashboardPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 70, 14, 0),
      child: Column(
        children: [
          // Metric cards
          Row(
            children: [
              Expanded(child: _metricCard('Total impressions', '17.6K', const Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Expanded(child: _metricCard('Average CTR', '1.3%', const Color(0xFF22C55E))),
              const SizedBox(width: 8),
              Expanded(child: _metricCard('Average position', '25.2', const Color(0xFFA855F7))),
            ],
          ),
          const SizedBox(height: 18),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2.8), FlSpot(1, 3.9), FlSpot(2, 3.4), FlSpot(3, 5.0),
                      FlSpot(4, 4.3), FlSpot(5, 6.1), FlSpot(6, 5.2), FlSpot(7, 7.0),
                      FlSpot(8, 6.4), FlSpot(9, 8.2), FlSpot(10, 7.1), FlSpot(11, 9.0),
                      FlSpot(12, 8.3), FlSpot(13, 10.1), FlSpot(14, 9.2), FlSpot(15, 11.0),
                    ],
                    isCurved: true,
                    color: Colors.white.withValues(alpha: 0.65),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: 0,
                maxY: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
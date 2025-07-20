import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin_scaffold.dart';
import '../../providers/app_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardShortcuts();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final isLoading = dashboardProvider.isLoading;
        final error = dashboardProvider.error;
        final analytics = dashboardProvider.analytics;
        final timeRange = dashboardProvider.selectedTimeRange;

        return AdminScaffold(
          breadcrumbs: ['Dashboard', 'Analytics'],
          selectedIndex: Provider.of<AppStateProvider>(context).selectedAdminTab,
          userRole: Provider.of<AppStateProvider>(context).userRole,
          onDestinationSelected: (index) {
            final appState = context.read<AppStateProvider>();
            appState.setSelectedAdminTab(index);
            
            // Handle different tab indices for admin vs staff
            if (appState.userRole == UserRole.admin) {
              switch (index) {
                case 0:
                  appState.setScreen(AppScreen.staffDashboard);
                  break;
                case 1:
                  appState.setScreen(AppScreen.articleManagement);
                  break;
                case 2:
                  appState.setScreen(AppScreen.userManagement);
                  break;
                case 3:
                  // Already on analytics
                  break;
              }
            } else {
              // Staff users don't have access to User Management
              switch (index) {
                case 0:
                  appState.setScreen(AppScreen.staffDashboard);
                  break;
                case 1:
                  appState.setScreen(AppScreen.articleManagement);
                  break;
                case 2:
                  // Already on analytics
                  break;
              }
            }
          },
          userName: 'Staff',
          userEmail: null,
          onLogout: () {
            final appState = Provider.of<AppStateProvider>(context, listen: false);
            appState.setRole(UserRole.reader);
            appState.setScreen(AppScreen.welcome);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isMobile = screenWidth < 600;
              final isSmallMobile = screenWidth < 400;
              
              return Padding(
                padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 24)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: isLoading
                      ? _buildSkeletonLoader(context, isSmallMobile, isMobile)
                      : error != null
                          ? _buildErrorState(error, dashboardProvider, isSmallMobile, isMobile)
                          : analytics == null
                              ? _buildEmptyState(isSmallMobile, isMobile)
                              : SingleChildScrollView(
                                  key: ValueKey(timeRange),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TimePeriodSelector(
                                        selected: timeRange,
                                        onChanged: (range) => dashboardProvider.setTimeRange(range),
                                        isSmallMobile: isSmallMobile,
                                        isMobile: isMobile,
                                      ),
                                      SizedBox(height: isSmallMobile ? 16 : 24),
                                      _KeyMetricsTable(
                                        timePeriod: timeRange,
                                        isSmallMobile: isSmallMobile,
                                        isMobile: isMobile,
                                      ),
                                      SizedBox(height: isSmallMobile ? 16 : 24),
                                      _StudentPubAnalyticsChartsGrid(
                                        timePeriod: timeRange,
                                        isSmallMobile: isSmallMobile,
                                        isMobile: isMobile,
                                      ),
                                      SizedBox(height: isSmallMobile ? 20 : 32),
                                    ],
                                  ),
                                ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}

// --- Skeleton Loader ---
Widget _buildSkeletonLoader(BuildContext context, bool isSmallMobile, bool isMobile) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: isSmallMobile ? 24 : 32, 
        width: isSmallMobile ? 160 : 220, 
        margin: EdgeInsets.only(bottom: isSmallMobile ? 16 : 24), 
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.3), 
          borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12)
        )
      ),
      if (isSmallMobile) ...[

        ...List.generate(4, (i) => Container(
          height: 80,
          margin: EdgeInsets.only(bottom: i < 3 ? 8 : 0),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3), 
            borderRadius: BorderRadius.circular(16)
          ),
        )),
      ] else ...[
        // Row layout for larger screens
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: isMobile ? 80 : 100,
              margin: EdgeInsets.only(right: i < 3 ? (isMobile ? 8 : 16) : 0),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(isMobile ? 16 : 20)
              ),
            ),
          )),
        ),
      ],
      SizedBox(height: isSmallMobile ? 16 : 32),
      Container(
        height: isSmallMobile ? 200 : (isMobile ? 220 : 260), 
        width: double.infinity, 
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.3), 
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20)
        )
      ),
      SizedBox(height: isSmallMobile ? 16 : 32),
      Container(
        height: isSmallMobile ? 36 : 48, 
        width: isSmallMobile ? 140 : 180, 
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.3), 
          borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12)
        )
      ),
    ],
  );
}

// --- Error State ---
Widget _buildErrorState(String error, DashboardProvider provider, bool isSmallMobile, bool isMobile) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded, 
          size: isSmallMobile ? 48 : (isMobile ? 56 : 64), 
          color: Colors.redAccent
        ),
        SizedBox(height: isSmallMobile ? 12 : 16),
        Text(
          'Failed to load analytics', 
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18), 
            fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: isSmallMobile ? 6 : 8),
        Text(
          error, 
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: isSmallMobile ? 11 : 14,
          )
        ),
        SizedBox(height: isSmallMobile ? 12 : 16),
        ElevatedButton.icon(
          onPressed: provider.refreshAnalytics,
          icon: Icon(Icons.refresh_rounded, size: isSmallMobile ? 16 : 20),
          label: Text(
            'Retry', 
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            )
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12)),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 16 : 20,
              vertical: isSmallMobile ? 8 : 12,
            ),
          ),
        ),
      ],
    ),
  );
}

// --- Empty State ---
Widget _buildEmptyState(bool isSmallMobile, bool isMobile) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.insights_rounded, 
          size: isSmallMobile ? 48 : (isMobile ? 56 : 64), 
          color: AppColors.textSecondary.withValues(alpha: 0.5)
        ),
        SizedBox(height: isSmallMobile ? 12 : 16),
        Text(
          'No analytics data available', 
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18), 
            fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: isSmallMobile ? 6 : 8),
        Text(
          'Data will appear here once available.', 
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: isSmallMobile ? 11 : 14,
          )
        ),
      ],
    ),
  );
}

// --- Time Range Filter ---
class TimePeriodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final bool isSmallMobile;
  final bool isMobile;
  const TimePeriodSelector({super.key, 
    required this.selected, 
    required this.onChanged,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    final periods = ['day', 'week', 'month', 'year'];
    final labels = {'day': 'Day', 'week': 'Week', 'month': 'Month', 'year': 'Year'};
    
    if (isSmallMobile) {
      // Stack vertically for small mobile
      return Column(
        children: periods.map((period) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: _PillButton(
            label: labels[period]!,
            selected: selected == period,
            onTap: () => onChanged(period),
            isSmallMobile: isSmallMobile,
            isMobile: isMobile,
          ),
        )).toList(),
      );
    }
    
    return Row(
      children: periods.map((period) => Padding(
        padding: EdgeInsets.only(right: isMobile ? 8 : 12),
        child: _PillButton(
          label: labels[period]!,
          selected: selected == period,
          onTap: () => onChanged(period),
          isSmallMobile: isSmallMobile,
          isMobile: isMobile,
        ),
      )).toList(),
    );
  }
}
class _PillButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isSmallMobile;
  final bool isMobile;
  const _PillButton({
    required this.label, 
    required this.selected, 
    required this.onTap,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile ? 12 : (isMobile ? 16 : 20), 
          vertical: isSmallMobile ? 6 : (isMobile ? 8 : 10)
        ),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: [AppColors.primary, AppColors.secondary.withValues(alpha: 0.7)]) : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(isSmallMobile ? 16 : (isMobile ? 20 : 24)),
          boxShadow: selected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 8, offset: Offset(0, 2))] : [],
        ),
        child: Text(
          label, 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
            color: selected ? AppColors.onPrimary : AppColors.textSecondary
          )
        ),
      ),
    );
  }
}

// --- Student Publication Analytics Charts Grid ---
class _StudentPubAnalyticsChartsGrid extends StatelessWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _StudentPubAnalyticsChartsGrid({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            'Analytics & Trends', 
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20), 
              color: AppColors.primary
            )
          ),
        ),
        SizedBox(height: isSmallMobile ? 8 : 12),
        if (isSmallMobile) ...[
          // Stack charts vertically for small mobile
          _ArticleViewsOverTimeChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
          SizedBox(height: 12),
          _PopularCategoriesChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
          SizedBox(height: 12),
          _TopArticlesHorizontalBarChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
          SizedBox(height: 12),
          _CommentInteractionTrendsChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
        ] else ...[
          // Grid layout for larger screens
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: isMobile ? 0 : 20,
              mainAxisSpacing: isMobile ? 16 : 20,
              childAspectRatio: isMobile ? 1.2 : 1.5,
            ),
            children: [
              _ArticleViewsOverTimeChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
              _PopularCategoriesChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
              _TopArticlesHorizontalBarChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
              _CommentInteractionTrendsChart(timePeriod: timePeriod, isSmallMobile: isSmallMobile, isMobile: isMobile),
            ],
          ),
        ],
      ],
    );
  }
}

// 1. Article Views Over Time (Line chart)
class _ArticleViewsOverTimeChart extends StatelessWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _ArticleViewsOverTimeChart({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    // Example period-specific data
    final data = timePeriod == 'day'
        ? [
            {'label': '8am', 'value': 120},
            {'label': '10am', 'value': 180},
            {'label': '12pm', 'value': 150},
            {'label': '2pm', 'value': 200},
            {'label': '4pm', 'value': 170},
            {'label': '6pm', 'value': 90},
            {'label': '8pm', 'value': 60},
          ]
        : timePeriod == 'week'
            ? [
                {'label': 'Mon', 'value': 120},
                {'label': 'Tue', 'value': 180},
                {'label': 'Wed', 'value': 150},
                {'label': 'Thu', 'value': 200},
                {'label': 'Fri', 'value': 170},
                {'label': 'Sat', 'value': 90},
                {'label': 'Sun', 'value': 60},
              ]
            : timePeriod == 'month'
                ? [
                    {'label': 'W1', 'value': 800},
                    {'label': 'W2', 'value': 1200},
                    {'label': 'W3', 'value': 950},
                    {'label': 'W4', 'value': 1100},
                  ]
                : [
                    {'label': 'Jan', 'value': 3200},
                    {'label': 'Feb', 'value': 2800},
                    {'label': 'Mar', 'value': 3500},
                    {'label': 'Apr', 'value': 3000},
                    {'label': 'May', 'value': 3700},
                    {'label': 'Jun', 'value': 3400},
                    {'label': 'Jul', 'value': 3100},
                    {'label': 'Aug', 'value': 3300},
                    {'label': 'Sep', 'value': 3600},
                    {'label': 'Oct', 'value': 3900},
                    {'label': 'Nov', 'value': 4100},
                    {'label': 'Dec', 'value': 4200},
                  ];
    return _ChartCard(
      title: 'Article Views Over Time',
      icon: Icons.show_chart_rounded,
      color: AppColors.primary,
      isSmallMobile: isSmallMobile,
      isMobile: isMobile,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.surface.withValues(alpha: 0.18), strokeWidth: 1)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
              final idx = v.toInt();
              if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
              return Text(data[idx]['label'] as String, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary));
            })),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: data.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b) * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), (data[i]['value'] as int).toDouble())],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color.fromARGB(255, 69, 99, 92).withValues(alpha: 0.18), AppColors.primary.withValues(alpha: 0.01)])),
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                return LineTooltipItem(
                  '${data[idx]['label']}',
                  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                  children: [
                    TextSpan(text: '\n${data[idx]['value']} views', style: GoogleFonts.poppins(color: AppColors.onPrimary)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Most Popular Categories (Donut chart or Horizontal Bar Chart with toggle)
class _PopularCategoriesChart extends StatefulWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _PopularCategoriesChart({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  State<_PopularCategoriesChart> createState() => _PopularCategoriesChartState();
}

class _PopularCategoriesChartState extends State<_PopularCategoriesChart> {
  bool showDonut = true;
  @override
  Widget build(BuildContext context) {
    final data = [
      {'label': 'Editorial', 'value': 38, 'color': const Color(0xFF264E36)}, 
      {'label': 'News', 'value': 22, 'color': const Color(0xFF6CA965)},     
      {'label': 'Feature', 'value': 18, 'color': const Color(0xFFFFC857)},  
      {'label': 'Sports', 'value': 12, 'color': const Color(0xFFFFE29A)},   
      {'label': 'Academics', 'value': 10, 'color': const Color(0xFFB7D7B0)},
    ];
    final total = data.fold<int>(0, (sum, e) => sum + (e['value'] as int));
    return _ChartCard(
      title: 'Most Popular Categories',
      icon: showDonut ? Icons.donut_large_rounded : Icons.bar_chart_rounded,
      color: AppColors.secondary,
      isSmallMobile: widget.isSmallMobile,
      isMobile: widget.isMobile,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Donut'),
              Switch(
                value: showDonut,
                onChanged: (v) => setState(() => showDonut = v),
                activeColor: AppColors.secondary,
              ),
              Text('Bar'),
            ],
          ),
          Expanded(
            child: showDonut
                ? Center(
                    child: SizedBox(
                      height: 220, 
                      child: PieChart(
                        PieChartData(
                          sections: [
                            for (int i = 0; i < data.length; i++)
                              PieChartSectionData(
                                color: data[i]['color'] as Color,
                                value: (data[i]['value'] as int).toDouble(),
                                title: '${((data[i]['value'] as int) / total * 100).toStringAsFixed(1)}%',
                                radius: 45,
                                titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.onPrimary, fontSize: 13),
                                badgeWidget: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                ),
                                badgePositionPercentageOffset: 1.18,
                              ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.center,
                      maxY: data.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final item = data[group.x.toInt()];
                            return BarTooltipItem(
                              '${item['label']}: ',
                              GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFFFFC857)),
                              children: [
                                TextSpan(text: '${item['value']} articles', style: GoogleFonts.poppins(color: Color(0xFFFFC857))),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                          return Text(data[idx]['label'] as String, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary));
                        }, reservedSize: 90)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)) )),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        for (int i = 0; i < data.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(toY: (data[i]['value'] as int).toDouble(), color: data[i]['color'] as Color, width: 14, borderRadius: BorderRadius.circular(6)),
                          ]),
                      ],
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.surface.withValues(alpha: 0.18), strokeWidth: 1)),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (final d in data)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: d['color'] as Color),
                    const SizedBox(width: 4),
                    Text(d['label'] as String, style: GoogleFonts.poppins(fontSize: 11)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}



// 4. Top Performing Articles (Horizontal Bar Chart)
class _TopArticlesHorizontalBarChart extends StatelessWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _TopArticlesHorizontalBarChart({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    final data = [
      {'label': 'Research Center Opens', 'views': 2847, 'color': AppColors.primary},
      {'label': 'Student Leaders Win', 'views': 2156, 'color': AppColors.secondary},
      {'label': 'Campus Life Photo Essay', 'views': 1892, 'color': AppColors.primary},
      {'label': 'Alumni Spotlight', 'views': 1560, 'color': AppColors.secondary},
      {'label': 'Online Education Future', 'views': 1420, 'color': AppColors.secondary},
    ];
    return _ChartCard(
      title: 'Top Performing Articles',
      icon: Icons.leaderboard_rounded,
      color: AppColors.primary,
      isSmallMobile: isSmallMobile,
      isMobile: isMobile,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: data.map((e) => e['views'] as int).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = data[group.x.toInt()];
                return BarTooltipItem(
                  '${item['label']}: ',
                  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFFFFC857)),
                  children: [
                    TextSpan(text: '${item['views']} views', style: GoogleFonts.poppins(color: AppColors.onPrimary)),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
              final idx = v.toInt();
              if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
              return Text(data[idx]['label'] as String, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary));
            }, reservedSize: 90)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: (data[i]['views'] as int).toDouble(), color: data[i]['color'] as Color, width: 14, borderRadius: BorderRadius.circular(6)),
              ]),
          ],
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.surface.withValues(alpha: 0.18), strokeWidth: 1)),
        ),
      ),
    );
  }
}

// 5. Comment and Interaction Trends (Area + Multi-line Chart)
class _CommentInteractionTrendsChart extends StatelessWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _CommentInteractionTrendsChart({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final comments = [12, 18, 15, 20, 17, 9, 6];
    final likes = [30, 45, 38, 50, 42, 20, 15];
    final shares = [5, 8, 7, 10, 9, 3, 2];
    
    final uniqueDays = days.toSet().toList();
    return _ChartCard(
      title: 'Comment and Interaction Trends',
      icon: Icons.multiline_chart_rounded,
      color: AppColors.secondary,
      isSmallMobile: isSmallMobile,
      isMobile: isMobile,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.surface.withValues(alpha: 0.18), strokeWidth: 1)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
              final idx = v.toInt();
              if (idx < 0 || idx >= uniqueDays.length) return const SizedBox.shrink();
              return Text(uniqueDays[idx], style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary));
            })),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (uniqueDays.length - 1).toDouble(),
          minY: 0,
          maxY: [comments, likes, shares].expand((l) => l).reduce((a, b) => a > b ? a : b) * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < uniqueDays.length; i++) FlSpot(i.toDouble(), comments[i].toDouble())],
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.secondary.withValues(alpha: 0.18), AppColors.secondary.withValues(alpha: 0.01)])),
              dotData: FlDotData(show: true),
              isStrokeCapRound: true,
              dashArray: [2, 2],
            ),
            LineChartBarData(
              spots: [for (int i = 0; i < uniqueDays.length; i++) FlSpot(i.toDouble(), likes[i].toDouble())],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: true),
              isStrokeCapRound: true,
            ),
            LineChartBarData(
              spots: [for (int i = 0; i < uniqueDays.length; i++) FlSpot(i.toDouble(), shares[i].toDouble())],
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: true),
              isStrokeCapRound: true,
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final lineIdx = spot.barIndex;
                final label = lineIdx == 0 ? 'Comments' : lineIdx == 1 ? 'Likes' : 'Shares';
                final value = lineIdx == 0 ? comments[idx] : lineIdx == 1 ? likes[idx] : shares[idx];
                return LineTooltipItem(
                  '$label\n',
                  GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFFFFC857)),
                  children: [
                    TextSpan(text: '$value', style: GoogleFonts.poppins(color: AppColors.onPrimary)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Chart Card Wrapper ---
class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool isSmallMobile;
  final bool isMobile;
  const _ChartCard({
    required this.title, 
    required this.icon, 
    required this.color, 
    required this.child,
    required this.isSmallMobile,
    required this.isMobile,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallMobile ? 8 : 12, horizontal: isSmallMobile ? 4 : 8),
      padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 20)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: isSmallMobile ? 12 : 18, offset: Offset(0, isSmallMobile ? 2 : 4)),
        ],
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                color: color, 
                size: isSmallMobile ? 18 : (isMobile ? 20 : 24)
              ),
              SizedBox(width: isSmallMobile ? 8 : 12),
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, 
                    fontSize: isSmallMobile ? 12 : (isMobile ? 14 : 18), 
                    color: color
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallMobile ? 12 : 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _KeyMetricsTable extends StatelessWidget {
  final String timePeriod;
  final bool isSmallMobile;
  final bool isMobile;
  const _KeyMetricsTable({
    required this.timePeriod,
    required this.isSmallMobile,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final metrics = [
      {
        'label': 'Total Article Views',
        'value': dashboardProvider.getTotalViewsForTimeRange().toString(),
        'subtitle': _getSubtitleForTimeRange(timePeriod),
      },
      {
        'label': 'Active Readers',
        'value': dashboardProvider.getActiveReadersForTimeRange().toString(),
        'subtitle': 'Unique users',
      },
      {
        'label': 'Articles Published',
        'value': dashboardProvider.getArticlesPublishedForTimeRange().toString(),
        'subtitle': _getSubtitleForTimeRange(timePeriod),
      },
      {
        'label': 'Most Popular Category',
        'value': dashboardProvider.getMostPopularCategoryForTimeRange(),
        'subtitle': 'Highest engagement',
      },
    ];
    
    if (isSmallMobile) {
      // Card layout for small mobile
      return Column(
        children: metrics.map((m) => Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                m['value']!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                m['subtitle']!,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        )).toList(),
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15)),
      ),
      child: DataTable(
        columns: [
          DataColumn(
            label: Text(
              'Metric',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Value',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        rows: metrics.map((m) => DataRow(cells: [
          DataCell(Text(
            m['label']!,
            style: GoogleFonts.poppins(fontSize: isMobile ? 11 : 13),
          )),
          DataCell(Text(
            m['value']!,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          )),
          DataCell(Text(
            m['subtitle']!,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 10 : 12,
              color: AppColors.textSecondary,
            ),
          )),
        ])).toList(),
      ),
    );
  }

  String _getSubtitleForTimeRange(String timeRange) {
    switch (timeRange) {
      case 'day':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return '';
    }
  }
}

 
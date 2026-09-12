import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart'; // Make sure this matches your project's color path
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/service/token/token_storage.dart';

class TransactionChart extends StatefulWidget {
  const TransactionChart({super.key});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlySummary();
    });
  }

  Future<void> _loadMonthlySummary() async {
    final token = await TokenStorage.getToken();
    if (!mounted || token == null || token.isEmpty) return;

    await context.read<TransactionProvider>().loadMonthlySummary(token);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final summaries = provider.monthlySummary;

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Matches your app's surface/card theme
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border), // Matches your app's border style
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income vs Expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Monthly transaction overview',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  _buildLegend(color: Colors.green, label: 'Income'),
                  const SizedBox(width: 12),
                  _buildLegend(color: Colors.redAccent, label: 'Expense'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Body
          Expanded(
            child: provider.isSummaryLoading && summaries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.summaryErrorMessage != null && summaries.isEmpty
                    ? Center(
                        child: Text(
                          provider.summaryErrorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : summaries.isEmpty
                        ? const Center(
                            child: Text(
                              'No monthly transaction data',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxY(summaries),
                              barGroups: summaries.asMap().entries.map((entry) {
                                final index = entry.key;
                                final summary = entry.value;

                                return BarChartGroupData(
                                  x: index,
                                  barsSpace: 4,
                                  barRods: [
                                    // Income Rod
                                    BarChartRodData(
                                      toY: summary.income,
                                      width: 10,
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    // Expense Rod
                                    BarChartRodData(
                                      toY: summary.expense,
                                      width: 10,
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final summary = summaries[groupIndex];
                                    final label = rodIndex == 0 ? 'Income' : 'Expense';
                                    final value = rodIndex == 0 ? summary.income : summary.expense;

                                    return BarTooltipItem(
                                      '$label\n\$${_formatAmount(value)}',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: _getInterval(summaries),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= summaries.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final summary = summaries[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _getMonthName(summary.month),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
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
                                        _formatAxisValue(value),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  double _getMaxY(dynamic summaries) {
    double maxValue = 0;
    for (final summary in summaries) {
      if (summary.income > maxValue) maxValue = summary.income;
      if (summary.expense > maxValue) maxValue = summary.expense;
    }
    return maxValue == 0 ? 100 : maxValue * 1.2;
  }

  double _getInterval(dynamic summaries) {
    double maxValue = 0;
    for (final summary in summaries) {
      if (summary.income > maxValue) maxValue = summary.income;
      if (summary.expense > maxValue) maxValue = summary.expense;
    }
    if (maxValue <= 1000) return 200;
    if (maxValue <= 10000) return 2000;
    if (maxValue <= 100000) return 20000;
    return maxValue / 5;
  }

  String _formatAxisValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  String _formatAmount(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }
}
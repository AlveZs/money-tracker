import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/util/constants.dart';

import 'domain/entity/month_balance.dart';

class BalanceChart extends StatefulWidget {
  final List<MonthBalance> balance;

  const BalanceChart({super.key, required this.balance});
  final Color leftBarColor = Colors.red;
  final Color rightBarColor = Colors.green;
  final Color avgColor = Colors.yellowAccent;
  final Color touchedBarColor = Colors.yellowAccent;
  @override
  State<StatefulWidget> createState() => BalanceChartState();
}

class BalanceChartState extends State<BalanceChart> {
  final double width = 10;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = widget.balance.fold(20.0, (max, bl) {
      double currGreater = bl.expenses > bl.income ? bl.expenses : bl.income;

      return currGreater > max ? currGreater : max;
    });

    return AspectRatio(
      aspectRatio: 1.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Últimos meses'),
            const SizedBox(
              height: CHART_HEIGHT,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: ((group) {
                        return Colors.grey;
                      }),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String monthName = monthsNames[group.x];
                        return BarTooltipItem(
                          '$monthName\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY).toString(),
                              style: const TextStyle(
                                color: Colors.white, //widget.touchedBarColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, titleMeta) => leftTitles(
                          value,
                          titleMeta,
                          maxY,
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: getShowingGroupsByBalance(widget.balance),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta, double maxY) {
    final formatter = NumberFormat.compact();
    formatter.maximumFractionDigits = 1;
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == (maxY ~/ 2)) {
      text = formatter.format(maxY ~/ 2);
    } else if (value == (maxY.ceil() - 1)) {
      text = formatter.format(maxY);
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      'Jn',
      'Fv',
      'Mr',
      'Ab',
      'Ma',
      'Jn',
      'Jl',
      'Ag',
      'St',
      'Ot',
      'Nv',
      'Dz',
    ];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y1,
    double y2, {
    bool isTouched = false,
  }) {
    return BarChartGroupData(
      barsSpace: 1,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: isTouched ? widget.touchedBarColor : widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: isTouched ? widget.touchedBarColor : widget.rightBarColor,
          width: width,
        ),
      ],
    );
  }

  List<BarChartGroupData> getShowingGroupsByBalance(
      List<MonthBalance> balance) {
    final List<BarChartGroupData> groupData = [];
    for (var month = 0; month < balance.length; month++) {
      groupData.add(
        makeGroupData(
          month,
          balance[month].income,
          balance[month].expenses,
          isTouched: touchedIndex == month,
        ),
      );
    }

    return groupData;
  }

  List<BarChartGroupData> showingGroups() => List.generate(12, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, 12, isTouched: touchedIndex == i);
          case 1:
            return makeGroupData(1, 16, 12, isTouched: touchedIndex == i);
          case 2:
            return makeGroupData(2, 18, 5, isTouched: touchedIndex == i);
          case 3:
            return makeGroupData(3, 20, 16, isTouched: touchedIndex == i);
          case 4:
            return makeGroupData(4, 17, 6, isTouched: touchedIndex == i);
          case 5:
            return makeGroupData(5, 19, 1.5, isTouched: touchedIndex == i);
          case 6:
            return makeGroupData(6, 10, 1.5, isTouched: touchedIndex == i);
          case 7:
            return makeGroupData(7, 5, 12, isTouched: touchedIndex == i);
          case 8:
            return makeGroupData(8, 16, 12, isTouched: touchedIndex == i);
          case 9:
            return makeGroupData(9, 18, 5, isTouched: touchedIndex == i);
          case 10:
            return makeGroupData(10, 18, 5, isTouched: touchedIndex == i);
          case 11:
            return makeGroupData(11, 18, 5, isTouched: touchedIndex == i);
          default:
            return throw Error();
        }
      });
}

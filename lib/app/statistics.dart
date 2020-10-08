import 'dart:async';
import 'dart:io';
import 'dart:math' show sqrt, max;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:videoeditbot_app/services/api/global_queue.dart';
import 'package:videoeditbot_app/services/api/types.dart';
import 'package:videoeditbot_app/services/icons/veb_icons.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

Future<VebResponse> _fetchStats() {
  return Queue.api.call('stats.json', {});
}

class Statistics extends StatefulWidget {
  Statistics(this.transitionMethod);
  final void Function(Widget w) transitionMethod;

  @override
  _StatisticsState createState() => _StatisticsState(transitionMethod);
}

class _StatisticsState extends State<Statistics> {
  _StatisticsState(this.transitionMethod);
  final void Function(Widget w) transitionMethod;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchStats(),
      builder: (context, AsyncSnapshot<VebResponse> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          var title = AppLocalizations.of(context).statisticsUnknownErrorTitle;
          var subtitle = AppLocalizations.of(context).tryAgainLater;
          if (snapshot.error is VebResponse) {
            title = AppLocalizations.of(context).statisticsServerErrorTitle;
            subtitle = AppLocalizations.of(context).statisticsServerErrorText;
          }

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlatformText(
                        title,
                        style: TextStyle(fontSize: 30),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: PlatformText(
                          subtitle,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          transitionMethod(Statistics(transitionMethod));
                        },
                        child: PlatformText(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return StatisticsPage(snapshot.data);
      },
    );
  }
}

class StatisticsPage extends StatefulWidget {
  StatisticsPage(this.data);
  final VebResponse data;

  @override
  _StatisticsPageState createState() => _StatisticsPageState(data);
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsPageState(this.data) : body = data.asJson;

  VebResponse data;
  Map<String, dynamic> body;
  List<num> cpuUsage;
  int cores;
  Timer checker;
  bool updateBusy = false;

  @override
  void initState() {
    cores = body['cpuCores'];
    cpuUsage = (body['cpuUsage'] as List).cast<num>();

    checker = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (mounted && !updateBusy) {
        updateBusy = true;

        try {
          data = await _fetchStats();
          setState(() {
            if (data.response.statusCode != HttpStatus.ok) return;

            body = data.asJson;
            if (body['cpuCores'] != cores) cores = body['cpuCores'];
            final cpuUsageLocal = (body['cpuUsage'] as List).cast<num>();

            for (var i = 0; i < cores; i++) {
              cpuUsage[i] = cpuUsageLocal[i];
            }
          });
        } catch (e) {
          //ignore
        }

        updateBusy = false;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    checker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.memory),
                    ),
                    title: PlatformText(body['cpuName']),
                    subtitle: PlatformText('${AppLocalizations.of(context).cpu}  |  ${body['cpuUsageTotal']}%'),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: max(sqrt(cores).truncate(), 2) *
                          (orientation == Orientation.portrait ? 1 : 2),
                      children: cpuUsage
                          .map((e) => CpuUsage(
                                usage: e,
                                child: CpuCoreBlock(),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
            Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Icon(VebIcons.memory)),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PlatformText('${body['memoryUsage']}  /'),
                          PlatformText(' ${body['memoryCapacity']}'),
                        ],
                      ),
                      subtitle: PlatformText(AppLocalizations.of(context).memory),
                    ),
                    TweenAnimationBuilder(
                      tween: IntTween(
                        begin: 0,
                        end: ((body['memoryUsageRaw'] /
                                body['memoryCapacityRaw'] *
                                1000) as double)
                            .truncate(),
                      ),
                      duration: Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, progress, __) {
                        return LinearProgressIndicator(
                          value: progress / 1000,
                        );
                      },
                    ),
                  ],
                )),
            Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.storage)),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PlatformText('${body['storageUsage']}  /'),
                          PlatformText(' ${body['storageCapacity']}'),
                        ],
                      ),
                      subtitle: PlatformText(AppLocalizations.of(context).storage),
                    ),
                    TweenAnimationBuilder(
                      tween: IntTween(
                        begin: 0,
                        end: ((body['storageUsageRaw'] /
                                body['storageCapacityRaw'] *
                                1000) as double)
                            .truncate(),
                      ),
                      duration: Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, progress, __) {
                        return LinearProgressIndicator(
                          value: progress / 1000,
                        );
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class CpuUsage extends InheritedWidget {
  static CpuUsage of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CpuUsage>();

  final num usage;

  CpuUsage({Key key, @required Widget child, @required this.usage})
      : assert(usage != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CpuUsage oldWidget) {
    return usage != oldWidget.usage;
  }
}

class CpuCoreBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usage = CpuUsage.of(context).usage;

    return AnimatedContainer(
      duration: Duration(seconds: 2),
      color: Theme.of(context).accentColor.withOpacity(usage / 100),
      child: Center(
        child: PlatformText(usage.toString()),
      ),
    );
  }
}

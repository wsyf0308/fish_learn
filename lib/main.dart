import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fish_learn/util/http_request.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                backgroundColor: const Color.fromARGB(255, 245, 206, 206),
                selectedIndex: selectedIndex,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings), label: Text('Settings')),
                ],
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  print(value);
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DropdownSearch<String>(
            popupProps: PopupProps.menu(
              showSelectedItems: true,
              disabledItemFn: (String s) => s.startsWith('I'),
            ),
            items: const ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Menu mode",
                hintText: "country in menu mode",
              ),
            ),
            onChanged: print,
            selectedItem: "Brazil",
          ),
          DropdownSearch<String>(
            items: const ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
            popupProps: PopupPropsMultiSelection.menu(
              showSelectedItems: false,
              disabledItemFn: (String s) => s.startsWith('I'),
            ),
            onChanged: print,
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List code = ['SZ002269', 'SH000001'];
  final List<PlutoColumn> columns = [];

  List<PlutoRow> rows = [];

  late Timer _timer;

  late final PlutoGridStateManager stateManager;

  void _getData({bool? timer}) async {
    final res = await HttpRequest().get(
      url: 'https://stock.xueqiu.com/v5/stock/realtime/quotec.json',
      params: {"symbol": code.join(',')},
    );
    List<PlutoRow> data = [];
    for (var i = 0; i < res['data'].length; i++) {
      final item = res['data'][i];
      data.add(
        PlutoRow(
          cells: {
            'symbol': PlutoCell(value: item['symbol']),
            'current': PlutoCell(value: item['current']),
            'percent': PlutoCell(value: item['percent']),
          },
        ),
      );
    }
    if (timer != null && timer) {
      stateManager.removeAllRows();
      stateManager.appendRows(data);
    } else {
      setState(() {
        rows = data;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getData(timer: true);
    });
  }

  void _cancelTimer() {
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    // 初始化操作
    columns.addAll([
      PlutoColumn(
        title: 'symbol',
        field: 'symbol',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'current',
        field: 'current',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'percent',
        field: 'percent',
        type: PlutoColumnType.text(),
      ),
    ]);
    _getData();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(rows.toString()),
          Expanded(
            child: rows.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(15),
                    child: PlutoGrid(
                      columns: columns,
                      rows: rows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                      },
                      onChanged: (PlutoGridOnChangedEvent event) {
                        print(event);
                      },
                      configuration: const PlutoGridConfiguration(),
                    ),
                  )
                : const Text('no data'),
          ),
        ],
      ),
    );
  }
}

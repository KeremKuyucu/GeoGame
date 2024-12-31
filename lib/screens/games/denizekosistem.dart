import 'package:GeoGame/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class Denizekosistem extends StatefulWidget {
  @override
  _DenizState createState() => _DenizState();
}

class _DenizState extends State<Denizekosistem> {
  double temperature = 0; // Başlangıç sıcaklığı
  double planktonDensity = 60.0; // Plankton yoğunluğu (% olarak)
  double atmosphericCO2 = 400.0; // Başlangıç CO2 seviyesi (ppm olarak)
  double nitrate = 30.0, iron = 15.0, ph = 7.5, co2 = 400.0, salinity = 35.0;

  // Parametrelerin plankton yoğunluğuna etkisi (%)
  final Map<String, double> effects = {
    'nitrate': 0.3, // %30
    'iron': 0.15, // %15
    'ph': -0.5, // %50 azalma etkisi
    'co2': -0.4, // %40 azalma etkisi
    'salinity': 0.0, // Nötr etki
  };

  void updatePlanktonDensity() {
    setState(() {
      double effectSum = 1.0;
      effectSum += effects['nitrate']! * (nitrate / 100);
      effectSum += effects['iron']! * (iron / 100);
      effectSum += effects['ph']! * (7.5 - ph).abs() / 7.5;
      effectSum += effects['co2']! * (400.0 - co2).abs() / 400.0;
      effectSum += effects['salinity']! * (35.0 - salinity).abs() / 35.0;
      planktonDensity = (60.0 * effectSum).clamp(0, 100);
      atmosphericCO2 =
          (400.0 * (1 - planktonDensity / 100 * 0.4)).clamp(0, 400);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deniz Ekosistemi'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
                initialCenter: LatLng(0.0, 0.0),
                initialZoom: 2.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    print(
                        "Tıklanan Nokta: ${point.latitude}, ${point.longitude}");
                  });
                }
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
            ],
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: darktema ? Colors.black26 : Colors.white38,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.0),
                  children: [
                    buildParameterControl('Nitrat', nitrate, (value) {
                      setState(() {
                        nitrate = value;
                        updatePlanktonDensity();
                      });
                    }),
                    buildParameterControl('Demir', iron, (value) {
                      setState(() {
                        iron = value;
                        updatePlanktonDensity();
                      });
                    }),
                    buildParameterControl('pH', ph, (value) {
                      setState(() {
                        ph = value;
                        updatePlanktonDensity();
                      });
                    }, min: 6.5, max: 8.5),
                    buildParameterControl('CO2', co2, (value) {
                      setState(() {
                        co2 = value;
                        updatePlanktonDensity();
                      });
                    }, min: 300, max: 500),
                    buildParameterControl('Tuzluluk', salinity, (value) {
                      setState(() {
                        salinity = value;
                        updatePlanktonDensity();
                      });
                    }, min: 30, max: 40),
                    SizedBox(height: 20),
                    Text(
                        'Plankton Yoğunluğu: ${planktonDensity.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                        'Atmosferik CO2 Seviyesi: ${atmosphericCO2.toStringAsFixed(1)} ppm',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildParameterControl(
      String name, double value, Function(double) onChanged,
      {double min = 0, double max = 100}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$name: ${value.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(1),
        ),
      ],
    );
  }
}

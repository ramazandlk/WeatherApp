import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'api.dart';

class Hava extends StatefulWidget {
  @override
  _HavaState createState() => new _HavaState();
}

class _HavaState extends State<Hava> {
  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Çıkış'),
            content: new Text('Uygulamadan çıkmak istediğine emin misin?'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("HAYIR"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Text("EVET"),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _cityEntered;

  static DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(now);

  Future _toNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new ChangeCity();
    }));

    setState(() {
      _cityEntered = results['sehir'];
    });
  }

  void ekranaBas() async {
    Map data = await getWeather(apiId, defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
   

    return WillPopScope(
      
      onWillPop: _onBackPressed,
      child: Scaffold(
        
        appBar: new AppBar(
            title: new Text("Hava Durumu "),
            centerTitle: true, // title ı ortala

            backgroundColor: Colors.indigoAccent,
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.search),
                  onPressed: () {
                    _toNextScreen(context);
                  })
            ]),
        body: new Stack(children: <Widget>[
           new Image.asset(
              'assets/images/gok.jpg',
           width: 500,
           height: 640,
               fit: BoxFit.fill
            ),
          new Container(
            child: RefreshIndicator(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile();
                },
              ),
              onRefresh: () async {
                setState(() {
                  Hava();
                  print("güncellendi");
                });
              },

              /* child: new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                 Hava();
                 
                  print("güncellendi");
                });
              }),*/
            ),
          ),
          new Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.all(90.0), //refresh

            child: Text(
              formattedDate,
              style: dateStyle(),
            ),
          ),
          new Container(
            child: uptadeIcon(_cityEntered),
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0, 40, 0, 60), //icon
            // derece
          ),
          new Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.all(40.0), //şehir yazdırma
            child: new Text(
              '${_cityEntered == null ? defaultCity : _cityEntered}',
              style: cityStyle(),
            ),
          ),
          new Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.fromLTRB(150, 110, 40, 0), // derece
              child: uptadeTempWidget(_cityEntered)),
          new Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.fromLTRB(250, 110, 40, 0), //min derece
              child: uptadeTempMin(_cityEntered)),
          new Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.fromLTRB(250, 125, 20, 0), // max derece
            child: uptadeTempMax(_cityEntered),
          ),
          new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(110, 300, 50, 100), // description

            child: (uptadeDescription(_cityEntered)),
          ),
        ]),
      ),
    );
  }
}

Future<Map> getWeather(String apiId, String city) async {
  String apiUrl =
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiId&units=metric&lang=tr";
  print(apiUrl);
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}

Widget uptadeTempWidget(String city) {
  print(city);
  return new FutureBuilder(
      future: getWeather(apiId, city == null ? defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return new Container(
            child: new ListView(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    content['main']['temp'].toString().substring(0, 2) + "°",
                    style: TextStyle(
                      fontSize: 60,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return new Container(
            width: 30,
            height: 30,
            color: Colors.green,
          );
        }
      });
}

Widget uptadeTempMin(String city) {
  print(city);
  return new FutureBuilder(
      future: getWeather(apiId, city == null ? defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return new Container(
            child: new ListView(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    "min: " +
                        content['main']['temp_min'].toString().substring(0, 2) +
                        "°",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return new Container(
            width: 30,
            height: 30,
            color: Colors.green,
          );
        }
      });
}

Widget uptadeTempMax(String city) {
  print(city);
  return new FutureBuilder(
      future: getWeather(apiId, city == null ? defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return new Container(
            child: new ListView(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    "max: " +
                        content['main']['temp_max'].toString().substring(0, 2) +
                        "°",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return new Container(
            width: 30,
            height: 30,
            color: Colors.green,
          );
        }
      });
}

Widget uptadeDescription(String city) {
  print(city);
  return new FutureBuilder(
      future: getWeather(apiId, city == null ? defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          return new Container(
            child: new ListView(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    "Bugün hava " +
                        content['weather'][0]['description']
                            .toString()
                            .toUpperCase() +
                        " gözüküyor.",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return new Container(
            width: 30,
            height: 30,
            color: Colors.green,
          );
        }
      });
}

Widget uptadeIcon(String city) {
  print(city);
  return new FutureBuilder(
      future: getWeather(apiId, city == null ? defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map content = snapshot.data;
          //var icon='10d';
          return new Container(
            child: new ListView(
              children: <Widget>[
                new Image.network(
                    'http://openweathermap.org/img/wn/${content['weather'][0]['icon']}@2x.png'),
              ],
            ),
          );
        } else {
          return new Container(
            width: 30,
            height: 30,
            color: Colors.green,
          );
        }
      });
}

class ChangeCity extends StatelessWidget {
  final TextEditingController _cityController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text("Şehir Seç"),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'assets/images/kar.jpg',
              height: 600,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Şehir Giriniz:',
                  ),
                  controller: _cityController,
                ),
              ),
              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      //uptadeTempWidget(_cityController.text);
                      Navigator.pop(context, {
                        'sehir': _cityController.text.toUpperCase(),
                      });
                    },
                    textColor: Colors.white,
                    color: Colors.red,
                    child: new Text('Hava Durumuna Git')),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.black87, fontSize: 45, fontStyle: FontStyle.italic);
}

TextStyle dateStyle() {
  return new TextStyle(
      color: Colors.black87, fontSize: 13, fontStyle: FontStyle.italic);
}

TextStyle menuCtyle() {
  return new TextStyle(backgroundColor: Colors.lightBlue);
}

TextStyle temptyle() {
  return new TextStyle(


  );
}

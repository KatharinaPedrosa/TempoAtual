import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Tempo Atual'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  final TextStyle estiloTemperatura = TextStyle(
      color: Colors.white, fontSize: 62.0, fontWeight: FontWeight.w600);

  final TextStyle estiloTempo = TextStyle(
      color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w600);

  String local;
  var temperatura;
  var umidade;
  var descricaoTempo;
  var velocidadeVento;

  Future getWeather() async {
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$local&Brazil&appid=e8962427977895dc7b82576019a60ef1");
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'] - 273.15;
      this.descricaoTempo = results['weather'][0]['main'];
      this.umidade = results['main']['humidity'];
      this.velocidadeVento = results['wind']['speed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.lightBlue[300],
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 30.0),
                new Form(
                  key: _key,
                  autovalidate: _validate,
                  child: formUI(),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              this.temperatura != null
                                  ? num.parse(this.temperatura.toString())
                                          .toStringAsPrecision(2) +
                                      "°"
                                  : "Carregando",
                              style: estiloTemperatura,
                            )))),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Text(
                      this.descricaoTempo != null
                          ? this.descricaoTempo.toString()
                          : "Carregando",
                      style: estiloTempo,
                    ))),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Text(
                      this.umidade != null
                          ?  "Hum   " + this.umidade.toString()  + "%"
                          : "Carregando",
                      style: estiloTempo,
                    ))),
              ]),
        )
      ])),
    );
  }

  Widget formUI() {
    return new Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(32)),
            child: new TextFormField(
              decoration: InputDecoration(
                  hintText: 'Cidade',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 30.0),
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20)),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 30.0),
              validator: _validarLocal,
              onSaved: (String val) {
                local = val;
              },
              onEditingComplete: sendForm,
            )),
      ],
    );
  }

  String _validarLocal(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o local";
    } else if (!regExp.hasMatch(value)) {
      return "O local deve ter apenas caracteres de a-z ou A-Z";
    }
    return null;
  }

  sendForm() {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      this.getWeather();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }
}

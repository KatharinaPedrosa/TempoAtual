import 'package:flutter/material.dart';
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
      color: Colors.white, fontSize: 35.0, fontWeight: FontWeight.w600);

  String cep;
  String local;
  var estado;
  var temperatura;
  var descricaoTempo;
  String iconeId;
  String icon;

  Future getWeather() async {
    http.Response responseCep =
        await http.get("https://viacep.com.br/ws/$cep/json/");
    var resultCep = jsonDecode(responseCep.body);

    setState(() {
      this.local = resultCep['localidade'];
      this.estado = resultCep['uf'];
    });

    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$local&Brazil&appid=e8962427977895dc7b82576019a60ef1&lang=pt_br");
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'] - 273.15;
      this.descricaoTempo = results['weather'][0]['description'];
      this.iconeId = results['weather'][0]['icon'];
      this.icon = "http://openweathermap.org/img/wn/$iconeId@2x.png";
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
                        child: Text(
                      this.local != null ? this.local.toString() : " ",
                      style: estiloTempo,
                    ))),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Text(
                      this.estado != null ? this.estado.toString() : " ",
                      style: estiloTempo,
                    ))),
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
                                  : " ",
                              style: estiloTemperatura,
                            )))),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Text(
                      this.descricaoTempo != null
                          ? this.descricaoTempo.toString()
                          : " ",
                      style: estiloTempo,
                    ))),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Center(
                        child: Image.network(
                      this.icon != null ? this.icon.toString() : " ",
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
                  hintText: 'Cep',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 30.0),
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20)),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 30.0),
              validator: _validarCep,
              onSaved: (String val) {
                cep = val;
              },
              onEditingComplete: sendForm,
            )),
      ],
    );
  }

  String _validarCep(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o cep";
    } else if (!regExp.hasMatch(value)) {
      return "O cep deve ter apenas caracteres de 0-9";
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

import 'package:flutter/material.dart';
import 'dart:ui';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:flutter_app/secret.dart';

class WeatherScreen extends StatefulWidget{
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> _currw;
  @override
  void initState(){
    super.initState();
    _currw=weatherinfo();
  }
  Future<Map<String,dynamic>> weatherinfo() async {
    try{
    final res=await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=Indore,ind&APPID=$API_id')
      );
      final data=jsonDecode(res.body);
      if(data['cod']!='200'){
        throw data["message"];
      }
      return data;
      }
      catch(e){
        throw e.toString();
      }
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Weather App",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: (){
                setState(() {
                         _currw=weatherinfo();         
                                });
              },
              icon: Icon(Icons.refresh),
            )
          ],
        ),
        body: FutureBuilder(
          future:_currw ,
          builder: (context,snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }
            final data=snapshot.data!;
            final currweather=data['list'][0];
            final currtemp=currweather['main']['temp'];
            final currsky=currweather['weather'][0]['main'];
            final currhum=currweather['main']["humidity"];
            final currpressure=currweather['main']["pressure"];
            double press=currpressure/1000;
            final currspeed=currweather['wind']["speed"];
            return SingleChildScrollView(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 7,),
                        //main card
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height:14),
                                Text(
                                  "$currtemp K",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  
                                ),
                                SizedBox(height:12),
                                Icon(
                                  iconval(currsky),
                                  size: 60,
                                  ),
                                SizedBox(height:12),
                                Text(
                                  "$currsky",
                                  style:TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                                SizedBox(height:14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12,),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Weather Forecast",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                        ),
                        const SizedBox(height: 8,),
                        //WeatherForecast
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                                      for(int i=0;i<5;i++)
                                        HourlyWidget(
                                        t:change(data['list'][i+1]['dt_txt'].toString()),
                                        t2: data['list'][i+1]['main']['temp'].toString(),
                                        icon: iconval(data['list'][i+1]['weather'][0]['main']),
                                        ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 15,),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Additional Information",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                        ),
                        const SizedBox(height: 15,),
                        //additional info 
                        Row(
                          mainAxisAlignment:  MainAxisAlignment.spaceAround,
                          children: [
                            Addnitem(
                              t: "Humidity",
                              icon: Icons.water_drop,
                              val: "$currhum",
                            ),
                            Addnitem(
                              t: "Wind Speed",
                              icon: Icons.air,
                              val: "$currspeed",
                            ),
                            Addnitem(
                              t: "Pressure",
                              icon: Icons.speed,
                              val: "$press",
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  ),
                ),
              );
          }
        ),
        );

    }
}
class HourlyWidget extends StatelessWidget{
  final String t;
  final IconData icon;
  final String t2;
  const HourlyWidget({
    super.key,
    required this.t,
    required this.t2,
    required this.icon,
    });
  @override
    Widget build(BuildContext context) {
    return SizedBox(
                        width: 110,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          elevation: 10,
                          child: Column(
                            children: [
                              SizedBox(height: 7,),
                              Text(
                              t,
                              style:TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              SizedBox(height: 8,),
                              Icon(
                                icon,
                                size: 30,
                                ),
                              SizedBox(height: 8,),
                              Text(
                                t2
                              ),
                              SizedBox(height: 7,),
                            ]
                          ),
                        ),
                      );
  }
}
class Addnitem extends StatelessWidget{
  final IconData icon;
  final String t;
  final String val;
  const Addnitem({
    super.key,
    required this.t,
    required this.icon,
    required this.val,
    });
  @override
  Widget build(BuildContext buildcontext){
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          ),
          SizedBox(height: 8,),
        Text(
          t,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8,),
        Text(
          val 
        )
      ],
    );
  }
}
IconData iconval(final x){
  if(x=="Clouds"){
    return Icons.cloud;
  }else if(x=="Clear"){
    return Icons.wb_sunny;
  }else if(x=="Snow"){
    return Icons.ac_unit;
  }else if(x=="Rain"){
    return Icons.beach_access;
  }
  return Icons.error;
}
String change(final x){
  DateTime dt=DateTime.parse(x).toLocal();
  return "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
}
import "dart:convert";
import "dart:ui";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:weather_app/additional_info_item.dart";
import "package:weather_app/hourly_forecast_item.dart";
import 'package:http/http.dart' as http ;
import "package:weather_app/secrets.dart";

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather = getCurrentWeather();
  Future<Map<String,dynamic>> getCurrentWeather() async{
    String cityName = 'Jaipur';
    try{
      final res = await http.get(
       Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey')
      );
      final data = jsonDecode(res.body);
      if(data['cod'] != '200'){
        throw data['message'];
      }
      return data ;
    }catch(e){
      throw e.toString();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      weather = getCurrentWeather();
  }
  @override
  Widget build(BuildContext context) {
    const title = "Weather App";
    return   Scaffold(
      appBar: AppBar(
        title: const Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        actions: [
          IconButton(
            onPressed: () { 
              setState(() {
                weather = getCurrentWeather(); 
              });
            }, icon: const Icon(Icons.refresh) 
          )
        ],
      ),
      body:  FutureBuilder(
        future: weather,
        builder :(context,snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting ){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if( snapshot.hasError ){
            return Center(child: Text("You got some error --- >  ${snapshot.error}" , style : const TextStyle(fontWeight: FontWeight.bold )));
          }
          final data = snapshot.data!;
          final currentValues = data['list'][0];
          final currentTemp = currentValues['main']['temp'];
          final currentSky = currentValues['weather'][0]['main'];
          final currentPressure = currentValues['main']['pressure'];
          final currentHumidity = currentValues['main']['humidity'];
          final currentWind = currentValues['wind']['speed'];
          return Padding(
          padding:  const EdgeInsets.all(12.0),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // main card 
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
                child:   SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                      child: Padding(
                        padding:const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "$currentTemp K",
                              style:const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32
                              ),
                            ),
                            const SizedBox( height: 20,),
                            Icon(
                              currentSky == 'Clouds'|| currentSky == 'Rain' ? Icons.cloud : Icons.sunny , 
                              size: 64,
                            ),
                            const SizedBox( height: 15,),
                            Text("$currentSky",style:const  TextStyle(fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ),
              // weather forcast cards 
              const SizedBox(
                height: 25,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox( height: 25 ,),
              // this is not good as all the things are building together and this can slow our app .
              //   SingleChildScrollView(
              //   scrollDirection:Axis.horizontal ,
              //    child:  Row(
              //     children: List.generate(20, (index) {
              //       return  HourlyForcastItem(
              //         time:data['list'][index+1]['dt'].toString(),
              //         temperature: data['list'][index+1]['main']['temp'].toString(),
              //         icon:data['list'][index+1]['weather'][0]['main'] == 'Clouds'|| data['list'][index+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny
              //       );
              //     })
              // ),
              // ),
              // List view takes whole screen , so to make it in control use SizedBox
              SizedBox(
                height: 120,
                child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      final hourlyForcast = data['list'][index+1];
                      final timeHourly = DateTime.parse(hourlyForcast['dt_txt']);
                      return  HourlyForcastItem(
                        time:DateFormat.Hm().format(timeHourly),
                        temperature: hourlyForcast['main']['temp'].toString(),
                        icon:hourlyForcast['weather'][0]['main'] == 'Clouds'|| hourlyForcast['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny
                      );
                    },
              ),
              ),
              // additional Stuff
              const SizedBox(
                height: 25,
              ),
              const  Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
              ),
              const SizedBox( height: 25 ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                AdditionalInfoItem(
                  icon :Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: currentHumidity.toString()
                ),
                AdditionalInfoItem(
                  icon :Icons.air,
                  label: 'Wind Speed',
                  value: currentWind.toString()
                ),
                AdditionalInfoItem(
                  icon :Icons.beach_access,
                  label: 'Pressure',
                  value: currentPressure.toString()
                )
              ],)
            ]
          ),
        );
        },
      ),
    );
  }
}      








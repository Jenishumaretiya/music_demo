import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

void main()
{

  runApp(MaterialApp(home: first(),));

}

class first extends StatefulWidget {
  const first({Key? key}) : super(key: key);

  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final player = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_per();

    player.onDurationChanged.listen((Duration d) {
      print(d);
    });
    player.onDurationChanged.listen((PlayerState) {

    });
  }
  get_per()
  async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      print("sdk version :-$sdkInt");
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
      if(sdkInt >=30)
      {
        var status1 = await Permission.storage.status;
        var status = await Permission.audio.status;
        if(status1.isDenied || status.isDenied){
          Map<Permission, PermissionStatus> statuses = await [
            Permission.audio,
            Permission.storage,
          ].request();
        }
      }
      else{
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("audio player"),),
      body:  FutureBuilder(future:_audioQuery.querySongs(),builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return CircularProgressIndicator();
        }
        else{
          List<SongModel> l = snapshot.data as List<SongModel>;
          print(l);
          return ListView.builder(itemCount:l.length,itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () {
                  if(player.state==PlayerState.playing)
                  {
                    player.pause();
                  }
                  else
                  {
                    player.play(DeviceFileSource(l[index].data));
                  }
                },
                title: Text("${l[index].displayName}"),
              ),
            );
          },);
        }
      },),
    );
  }
}

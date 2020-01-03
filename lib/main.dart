import 'dart:async';
import 'package:dio/dio.dart';
import 'package:image_video_capturing/GetLocation.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GetLocation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Video capturing',
      home: MyHomePage(title: 'Image and video capturing'),
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
  File _imageFile;
  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;
  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.removeListener(_onVideoControllerUpdate);
    }
    if (isVideo) {
      ImagePicker.pickVideo(source: source).then((File file) {
        if (file != null && mounted) {
          setState(() {
            _controller = VideoPlayerController.file(file)
              ..addListener(_onVideoControllerUpdate)
              ..setVolume(1.0)
              ..initialize()
              ..setLooping(true)
              ..play();
          });
        }
      });
    } else {
      try {
        _imageFile = await ImagePicker.pickImage(source: source);
        File abc;
        abc=_imageFile;
        _upload(abc);
      } catch (e) {
        _pickImageError = e;
      }
      setState(() {});
    }
  }

  void _onVideoControllerUpdate() {
    setState(() {});
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.removeListener(_onVideoControllerUpdate);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _previewVideo(VideoPlayerController controller) {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (controller == null) {
      return const Text(
        'You have not picked a video',
        textAlign: TextAlign.center,
      );
    } else if (controller.value.initialized) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatioVideo(controller),
      );
    } else {
      return const Text(
        'Error Loading Video',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not  picked anything.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          isVideo = true;
          _controller = VideoPlayerController.file(response.file)
            ..addListener(_onVideoControllerUpdate)
            ..setVolume(1.0)
            ..initialize()
            ..setLooping(true)
            ..play();
        } else {
          isVideo = false;
          _imageFile = response.file;
        }
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }
  final String UploadIP= 'http://nextbank.mollatech.com:7070/ValydateConnector/UploadOnServer';
  void _upload(File file) {
   if (file == null) return;
   String base64Image = base64Encode(file.readAsBytesSync());
   String fileName = file.path.split("/").last;
   String UserId  = "2682f99c11c2adc2ee4222fa6329f8c8fb9601db";
   http.post(UploadIP, body: {"image": base64Image+" "+ UserId + "|" + "type" + "." + "jpg"+ " \"" }).then((res) {
     print(res.statusCode);
      print(res.headers);
      print(res.body);
   }).catchError((err) {
     print(err);
   });
 }
//  Upload(File imageFile) async {    
//      stream = "2682f99c11c2adc2ee4222fa6329f8c8fb9601db";
//       var length = await imageFile.length();

//       var uri = Uri.parse('https://nextbank.mollatech.com:7443/ValydateConnector/UploadOnServer');

//      var request = new http.MultipartRequest("POST", uri);
//       var multipartFile = new http.MultipartFile('file', stream, length,
//           filename: basename(imageFile.path));
//           //contentType: new MediaType('image', 'png'));

//       request.files.add(multipartFile);
//       var response = await request.send();
//       print(response.statusCode);
//       response.stream.transform(utf8.decoder).listen((value) {
//         print(value);
//       });
//     }
// Socket socket;

// var reply;

// // TODO: MAIN

// main(List<String> arguments) async {
//   await _remoteServerConnect();
// }

// // TODO: REMOTE SERVER  CONNECT
// Future _remoteServerConnect(File _dataToBeSent) async {

//   await Socket.connect("103.39.133110", remote_port).then((Socket sock) {
//     socket = sock;
//      socket.listen(dataHandler,
//         onError: errorHandler,
//         onDone: doneHandler,
//         cancelOnError: false);
//   }).catchError((AsyncError e) {
//     print("Unable to connect: $e");
//     exit(1);
//   });

//   print(_dataToBeSent);
//   await socket.write(_dataToBeSent + "2682f99c11c2adc2ee4222fa6329f8c8fb9601db"+ "|" + type + "." + extension + "\"" + lineEnd'\n');
// }

// void dataHandler(data) async {
//   String _result = await String.fromCharCodes(data).trim();
//   print(_result);
// }

// void errorHandler(error, StackTrace trace){
//   print(error);
// }

// void doneHandler(){
//   socket.destroy();
//   exit(0);
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldstate,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Platform.isAndroid
            ? FutureBuilder<void>(
          future: retrieveLostData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Text(
                  'You have not picked anything.',
                  textAlign: TextAlign.center,
                );
              case ConnectionState.done:
                return isVideo
                    ? _previewVideo(_controller)
                    : _previewImage();
              default:
                if (snapshot.hasError) {
                  return Text(
                    'Pick image/video error: ${snapshot.error}}',
                    textAlign: TextAlign.center,
                  );
                } else {
                  return const Text(
                    'You have not picked anything.',
                    textAlign: TextAlign.center,
                  );
                }
            }
          },
        )
            : (isVideo ? _previewVideo(_controller) : _previewImage()),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              isVideo = false;
              _onImageButtonPressed(ImageSource.gallery);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'video0',
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'video1',
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
           Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.green[300],
              onPressed: () {
                Navigator.push(context, 
  new MaterialPageRoute(builder:(context)=>new GetLocation()),);
              },
              heroTag: 'location',
              tooltip: 'Geolocator',
              child: const Icon(Icons.location_on),
            ),
          ),
        ],
      ),
    );
  }
  

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
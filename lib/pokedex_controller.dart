import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:pokdex_app/pokemon_detail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'main.dart';

enum PokedexState { closed, opened, info }

class PokedexController extends ChangeNotifier {
  final TickerProvider vsync;

  PokedexState state = PokedexState.closed;
  late AnimationController flapController;
  late Animation<double> flapAnimation;
  final ScrollController scrollController = ScrollController();
  late CameraController cameraController;
  late WebSocketChannel channel;
  String? currentPokemon;
  PokemonDetail? details;

  PokedexController(this.vsync) {
    flapController =
        AnimationController(vsync: vsync, duration: const Duration(seconds: 2));
  }

  bool get isFlapOpened => state == PokedexState.opened;

  void initialize() {
    flapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(flapController);
    Future.delayed(const Duration(seconds: 1), (){
      update(PokedexState.opened);
    });
    cameraController = CameraController(cameras[1], ResolutionPreset.max, enableAudio: false);
    cameraController.setFlashMode(FlashMode.off);
    _initializeWebSocket();
    cameraController.initialize().then((_) {
      notifyListeners();
    });
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final image = await cameraController.takePicture();
        final compressedImageBytes = compressImage(image.path);
        channel.sink.add(compressedImageBytes);
      } catch (_) {}
    });
  }

  void _initializeWebSocket() {
    // 0.0.0.0 -> 10.0.2.2 (emulator)
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:8765');
    channel.stream.listen((dynamic data) {
      debugPrint(data);
      data = jsonDecode(data);
      if (data['data'] == null) {
        debugPrint('Server error occurred in recognizing face');
        return;
      } else if (data['status']) {
        debugPrint('Pokemon found!');
        currentPokemon = data['data']['name'];
      } else {
        debugPrint('No Pokemon found :(');
        currentPokemon = null;
      }
      notifyListeners();
    }, onError: (dynamic error) {
      debugPrint('Error: $error');
    }, onDone: () {
      debugPrint('WebSocket connection closed');
    });
  }

  Uint8List compressImage(String imagePath, {int quality = 85}) {
    final image =
        img.decodeImage(Uint8List.fromList(File(imagePath).readAsBytesSync()))!;
    final compressedImage =
        img.encodeJpg(image, quality: quality); // lossless compression
    return compressedImage;
  }

  Future<void> update(PokedexState newState) async {
    switch (newState) {
      case PokedexState.closed:
        flapController.reverse();
        break;
      case PokedexState.opened:
        flapController.forward();
        break;
      case PokedexState.info:
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut);
        if(currentPokemon != null) {
          final response = await get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${currentPokemon?.toLowerCase()}"));
          details = PokemonDetail.fromJson(jsonDecode(response.body));
        } else {
          details = null;
        }
        notifyListeners();
    }
  }
}

import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pokdex_app/pokedex_controller.dart';

class PokedexView extends StatefulWidget {
  const PokedexView({super.key});

  @override
  State<PokedexView> createState() => _PokedexViewState();
}

class _PokedexViewState extends State<PokedexView>
    with SingleTickerProviderStateMixin {
  late PokedexController controller;

  @override
  void initState() {
    controller = PokedexController(this);
    controller.addListener(() => setState(() {}));
    controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    controller.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              child: GestureDetector(
            onTap: () {
              controller.update(PokedexState.closed);
            },
            child: Image.asset(
              "assets/bg.png",
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.fill,
            ),
          )),
          Align(
            alignment: const Alignment(0, 0),
            child: SingleChildScrollView(
              controller: controller.scrollController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: screenHeight * 0.15,
                        left: screenWidth * 0.15,
                        child: SizedBox(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.22,
                          child: CameraPreview(controller.cameraController),
                        ),
                      ),
                      Image.asset(
                        "assets/front.png",
                        width: screenWidth * .95,
                      ),
                      Positioned(
                          bottom: screenHeight * .045,
                          left: screenWidth * 0.23,
                          child: SizedBox(
                            width: 110,
                            height: 50,
                            child: Center(
                              child: Text(
                                "${controller.currentPokemon ?? "NO POKEMON"}_",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ),
                          )),
                      Positioned(
                        bottom: screenHeight * .12,
                        left: screenWidth * .12,
                        child: GestureDetector(
                          onTap: () {
                            controller.update(PokedexState.info);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 28,
                        child: AnimatedBuilder(
                            animation: controller.flapAnimation,
                            builder: (context, _) {
                              return AnimatedOpacity(
                                opacity: controller.flapAnimation.value < 0.7
                                    ? 1
                                    : 0,
                                duration: const Duration(seconds: 1),
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(
                                        controller.flapAnimation.value * -pi),
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.update(PokedexState.opened);
                                    },
                                    child: Image.asset(
                                      "assets/info-case-back.png",
                                      width: screenWidth * .77,
                                      height: screenHeight * .54,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                      animation: controller.flapAnimation,
                      builder: (context, _) {
                        return AnimatedOpacity(
                          opacity: controller.flapAnimation.value > 0.7 ? 1 : 0,
                          duration: const Duration(seconds: 1),
                          child: Stack(
                            children: [
                              Image.asset(
                                "assets/info-case-front.png",
                                width: screenWidth * .86,
                              ),
                              Positioned(
                                bottom: screenHeight * .13,
                                left: 45,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.scrollController.animateTo(
                                        controller.scrollController.position
                                            .minScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeOut);
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              if (controller.details != null)
                                Positioned(
                                  top: screenHeight * .15,
                                  left: 45,
                                  child: SizedBox(
                                    width: screenWidth * .6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.network(
                                            controller.details!.sprite),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(controller.details!.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18)),
                                            Text(
                                              controller.details!.type,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                            ),
                                            Text(
                                              "${controller.details!.weight} KG",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

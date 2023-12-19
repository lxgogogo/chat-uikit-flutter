import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';

class ImageData {
  final String imageUrl;
  final String? messageID;

  ImageData({
    required this.imageUrl,
    this.messageID,
  });
}

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({
    Key? key,
    required this.imageDataList,
    required this.messageID,
    this.downloadFn,
    this.scanQRCode,
  }) : super(key: key);

  final List<ImageData> imageDataList;
  final String? messageID;
  final Future<void> Function(int index)? downloadFn;
  final Future<void> Function(int index,BuildContext context)? scanQRCode;

  @override
  State<StatefulWidget> createState() {
    return _ImageListScreenState();
  }
}

class _ImageListScreenState extends TIMUIKitState<ImageListScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  int _initialPage = 0;
  int _currentIndex = 0;

  late AnimationController _slideEndAnimationController;
  late Animation<double> _slideEndAnimation;
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  double _imageDetailY = 0;
  Rect? imageDRect;

  @override
  void dispose() {
    _slideEndAnimationController.dispose();
    clearGestureDetailsCache();
    super.dispose();
  }

  @override
  void initState() {
    _initialPage = widget.imageDataList
        .indexWhere((element) => element.messageID == widget.messageID);
    _currentIndex = _initialPage;
    super.initState();
    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
    });
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final Size size = MediaQuery.of(context).size;
    imageDRect = Offset.zero & size;
    Widget result = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ExtendedImageSlidePage(
            key: slidePagekey,
            slideAxis: SlideAxis.vertical,
            slideScaleHandler: (
              Offset offset, {
              ExtendedImageSlidePageState? state,
            }) {
              if (state != null && state.scale == 1.0) {
                if (state.imageGestureState!.gestureDetails!.totalScale! >
                    1.0) {
                  return 1.0;
                }
                if (offset.dy < 0 || _imageDetailY < 0) {
                  return 1.0;
                }
              }

              return null;
            },
            slideOffsetHandler: (
              Offset offset, {
              ExtendedImageSlidePageState? state,
            }) {
              if (state != null && state.scale == 1.0) {
                if (state.imageGestureState!.gestureDetails!.totalScale! >
                    1.0) {
                  return Offset.zero;
                }

                if (offset.dy < 0 || _imageDetailY < 0) {
                  return Offset.zero;
                }

                if (_imageDetailY != 0) {
                  _imageDetailY = 0;
                }
              }
              return null;
            },
            slideEndHandler: (
              Offset offset, {
              ExtendedImageSlidePageState? state,
              ScaleEndDetails? details,
            }) {
              if (_imageDetailY != 0 && state!.scale == 1) {
                if (!_slideEndAnimationController.isAnimating) {
                  final double magnitude =
                      details!.velocity.pixelsPerSecond.distance;
                  if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
                    final Offset direction =
                        details.velocity.pixelsPerSecond / magnitude * 1000;
                    _slideEndAnimation =
                        _slideEndAnimationController.drive(Tween<double>(
                      begin: _imageDetailY,
                      end: _imageDetailY + direction.dy,
                    ));
                    _slideEndAnimationController.reset();
                    _slideEndAnimationController.forward();
                  }
                }
                return false;
              }

              return null;
            },
            child: Material(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ExtendedImageGesturePageView.builder(
                    controller: ExtendedPageController(
                      initialPage: _initialPage,
                    ),
                    physics: const BouncingScrollPhysics(),
                    canScrollPage: (GestureDetails? gestureDetails) {
                      return _imageDetailY >= 0;
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final ImageData imageData = widget.imageDataList[index];

                      Widget image = ExtendedImage.network(
                        imageData.imageUrl,
                        fit: BoxFit.contain,
                        enableSlideOutPage: true,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (ExtendedImageState state) {
                          double? initialScale = 1.0;

                          if (state.extendedImageInfo != null) {
                            initialScale = initScale(
                              size: size,
                              initialScale: initialScale,
                              imageSize: Size(
                                min(
                                  size.width,
                                  state.extendedImageInfo!.image.width
                                      .toDouble(),
                                ),
                                min(
                                  size.height,
                                  state.extendedImageInfo!.image.height
                                      .toDouble(),
                                ),
                              ),
                            );
                          }
                          return GestureConfig(
                            inPageView: true,
                            initialScale: 1.0,
                            maxScale: max(initialScale ?? 1.0, 5.0),
                            animationMaxScale: max(initialScale ?? 1.0, 5.0),
                          );
                        },
                        loadStateChanged: (ExtendedImageState state) {
                          if (state.extendedImageLoadState ==
                              LoadState.completed) {
                            return ExtendedImageGesture(
                              state,
                              canScaleImage: (_) => _imageDetailY == 0,
                              imageBuilder: (Widget image) {
                                return Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      top: _imageDetailY,
                                      bottom: -_imageDetailY,
                                      child: image,
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return null;
                        },
                      );

                      image = GestureDetector(
                        onTap: () {
                          if (_imageDetailY != 0) {
                            _imageDetailY = 0;
                          } else {
                            slidePagekey.currentState!.popPage();
                            Navigator.pop(context);
                          }
                        },
                        onLongPress: () async {
                          if (widget.scanQRCode != null) {
                            setState(() {
                              isLoading = true;
                            });
                            await widget.scanQRCode!(_currentIndex,context)
                                .whenComplete(() => Future.delayed(
                                        const Duration(milliseconds: 200), () {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }));
                          }
                        },
                        child: image,
                      );

                      return image;
                    },
                    itemCount: widget.imageDataList.length,
                    onPageChanged: (int index) {
                      _currentIndex = index;
                      if (_imageDetailY != 0) {
                        _imageDetailY = 0;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
            left: 10,
            bottom: 50,
            child: IconButton(
              icon: Image.asset(
                'images/close.png',
                package: 'tencent_cloud_chat_uikit',
              ),
              iconSize: 30,
              onPressed: () {
                slidePagekey.currentState!.popPage();
                Navigator.pop(context);
              },
            )),
        if (widget.downloadFn != null)
          Positioned(
            right: 10,
            bottom: 50,
            child: Row(
              children: [
                IconButton(
                  icon: Image.asset(
                    'images/download.png',
                    package: 'tencent_cloud_chat_uikit',
                  ),
                  iconSize: 30,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await widget.downloadFn!(_currentIndex);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        if (isLoading)
          Container(
            child: LoadingAnimationWidget.staggeredDotsWave(
              size: 35,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xB22b2b2b),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
      ],
    );

    return result;
  }

  double? initScale({
    required Size imageSize,
    required Size size,
    double? initialScale,
  }) {
    final double n1 = imageSize.height / imageSize.width;
    final double n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      final Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      final Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
  }
}

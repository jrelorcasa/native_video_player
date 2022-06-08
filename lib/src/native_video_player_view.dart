import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'native_video_player_controller.dart';

/// A [StatefulWidget] that is responsible for displaying a video.
///
/// On iOS, the video is displayed using a combination
/// of AVPlayer and AVPlayerLayer.
///
/// On Android, the video is displayed using a combination
/// of MediaPlayer and VideoView.
class NativeVideoPlayerView extends StatefulWidget {
  final void Function(NativeVideoPlayerController)? onViewReady;

  const NativeVideoPlayerView({
    Key? key,
    required this.onViewReady,
  }) : super(key: key);

  @override
  _NativeVideoPlayerViewState createState() => _NativeVideoPlayerViewState();
}

class _NativeVideoPlayerViewState extends State<NativeVideoPlayerView> {
  NativeVideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// RepaintBoundary is a widget that isolates repaints
    // return RepaintBoundary(
    //   child: _buildNativeView(),
    // );

    return _buildNativeView();
  }

  Widget _buildNativeView() {
    const viewType = 'native_video_player_view';
    // final Map<String, dynamic> creationParams = <String, dynamic>{};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.rtl,
            // creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        // creationParams: creationParams,
        // creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text('$defaultTargetPlatform is not yet supported by this plugin.');
  }

  /// This method is invoked by the platform view when the native view is created.
  Future<void> onPlatformViewCreated(int id) async {
    final controller = NativeVideoPlayerController(id);
    _controller = controller;
    widget.onViewReady?.call(controller);
  }
}

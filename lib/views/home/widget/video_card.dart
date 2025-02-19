import 'package:flutter/material.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({Key? key, required this.videoLink}) : super(key: key);

  final String videoLink;

  @override
  State<VideoCard> createState() => _VideoState();
}

class _VideoState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool isPLaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        ApiIntranetConstans.baseUrl + widget.videoLink)
      ..initialize().then((_)async {
        setState(() {
          _controller.setPlaybackSpeed(0);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: _controller.value.isInitialized
              ? Column(
                  children: [
                    Center(
                        child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          backgroundColor:
                              ColorIntranetConstants.backgroundColorLight,
                          bufferedColor:
                              ColorIntranetConstants.backgroundColorDark,
                          playedColor:
                              ColorIntranetConstants.primaryColorNormal),
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  height: 200,
                  color: ColorIntranetConstants.backgroundColorNormal,
                  child: const Align(
                    alignment: Alignment(0, 0),
                    child: Center(
                      child: Text(
                        "Cargando video ...",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
          onTap: () => {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            })
          },
        ),
        _controller.value.isInitialized
            ? Row(
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: (() {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      }),
                      icon: _controller.value.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow)),
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: (() {
                        setState(() {
                          isPLaying = false;
                          _controller.pause();
                          _controller.seekTo(const Duration(seconds: 0));
                        });
                      }),
                      icon: const Icon(Icons.stop))
                ],
              )
            : Container()
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

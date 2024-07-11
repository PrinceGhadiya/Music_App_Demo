import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/model/audio_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    loadAudioFiles();
  }

  void loadAudioFiles() {
    List<Audio> audioList = [];

    for (var category in AudioData.audioList) {
      String title = category['title'];
      List<List<String>> songs = category['songs'];

      for (var song in songs) {
        String songTitle = song[0];
        String songPath = song[1];

        audioList.add(
          Audio(
            songPath,
            metas: Metas(title: songTitle, album: title),
          ),
        );
      }
    }

    assetsAudioPlayer.open(
      Playlist(audios: audioList),
      autoStart: false,
      showNotification: true,
    );
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("Audio Player"),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) {
              return [
                const PopupMenuItem(
                  child: Text("Show Audio List"),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: assetsAudioPlayer.current,
          builder: (_, asyncSnapshot) {
            Playing? playing = asyncSnapshot.data;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                ),
                if (playing != null) ...[
                  Text(
                    playing.audio.audio.metas.title ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Song Type: ${playing.audio.audio.metas.album ?? ''}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder(
                    stream: assetsAudioPlayer.currentPosition,
                    builder: (_, snapshot) {
                      final Duration? duration = snapshot.data;
                      return Column(
                        children: [
                          Slider(
                            min: 0.0,
                            max: playing.audio.duration.inSeconds.toDouble(),
                            value: duration?.inSeconds.toDouble() ?? 0.0,
                            onChanged: (value) {
                              assetsAudioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Text(
                            duration?.toString().split('.')[0] ?? '00:00:00',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        assetsAudioPlayer.previous();
                      },
                      icon:
                          const Icon(Icons.skip_previous, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        assetsAudioPlayer.playOrPause();
                      },
                      icon: StreamBuilder(
                        stream: assetsAudioPlayer.isPlaying,
                        builder: (context, asyncSnapshot) {
                          bool isPlaying = asyncSnapshot.data ?? false;
                          return Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 38,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        assetsAudioPlayer.next();
                      },
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

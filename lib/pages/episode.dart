import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:localstorage/localstorage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:milk/components/container.dart';
import 'package:milk/pages/anime.dart';
import 'package:milk/services/media_episode.dart';
import 'package:milk/tools.dart';

class EpisodeFrame extends StatefulWidget {
  const EpisodeFrame({required this.id, super.key});
  final String id;

  @override
  State<EpisodeFrame> createState() => _EpisodeFrameState();
}

class _EpisodeFrameState extends State<EpisodeFrame> {
  final LocalStorage storage = LocalStorage(Common().localStorageName);

  String actualId = "";
  String mediaId = "";

  late Future media;

  bool isContinue = false;

  final PagingController<String, ContainerAnimeEpisode>
      _pagingControllerEpisodes = PagingController(firstPageKey: "");

  late final player = Player();
  late final controller = VideoController(player);

  Future<void> openMedia() async {
    await storage.ready;
    bool isAutoPlay = storage.getItem(Common().localAutoPlayName) ??
        storage.setItem(Common().localAutoPlayName, false);
    await player.open(
        Media(httpHeaders: <String, String>{
          'Authorization': 'Bearer ${storage.getItem(Common().localTokenName)}'
        }, '${Common().baseURL}/episodes/$actualId'),
        play: isAutoPlay);
  }

  void refresh() async {
    _pagingControllerEpisodes.refresh();
    await player.stop().then((value) => openMedia());
  }

  void newEpisodeCallback(String? id) async {
    if (id == null) return;
    actualId = id;
    _pagingControllerEpisodes.refresh();
    await player.stop().then((value) => openMedia());
  }

  void addListener(String mediaId) {
    _pagingControllerEpisodes.addPageRequestListener((pageKey) {
      // TODO: PAGINATION
      fetchContainerAnimeEpisode(context, _pagingControllerEpisodes, pageKey,
          mediaId, pageKey, "", false, newEpisodeCallback, actualId);
    });
  }

  // TODO: PAGINATION (need a rework here)
  void autoNextEpisode() async {
    bool newEpisode = false;

    if (_pagingControllerEpisodes.itemList != null) {
      for (var item in _pagingControllerEpisodes.itemList!) {
        if (newEpisode) {
          actualId = item.id;
          _pagingControllerEpisodes.refresh();
          await player.stop().then((value) => openMedia());
          return;
        }
        if (item.id == actualId) newEpisode = true;
      }
    }
  }

  void showModalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.black54,
            child: AnimeInfo(id: mediaId, type: null, showBanner: false),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    actualId = widget.id;
    media = retrieveMediaEpisode(widget.id);
    media.then((value) {
      if (value.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonDecode(value.body)['errors'][0]['message'] ??
                'Unknown error')));
        Navigator.pop(context);
      }
      mediaId = jsonDecode(value.body)['data']['episode']['media']['id'];
      addListener(mediaId);
    });
    player.stream.completed.listen((event) {
      if (!isContinue) return;
      autoNextEpisode();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: FutureBuilder(
            future: media,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        overflow: TextOverflow.ellipsis));
              } else {
                openMedia();
                String coverImage = jsonDecode(snapshot.data!.body)['data']
                    ['episode']['media']['coverImage'];
                String title = jsonDecode(snapshot.data!.body)['data']
                        ['episode']['media']['title']['romaji'] ??
                    "Unknown";
                return CustomScrollView(
                  slivers: <Widget>[
                    if (!Platform.isAndroid && !Platform.isIOS)
                      const SliverAppBar(
                        title: null,
                      ),
                    SliverToBoxAdapter(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Video(controller: controller),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: CheckboxListTile(
                          value: isContinue,
                          onChanged: (value) {
                            setState(() {
                              isContinue = value!;
                            });
                          },
                          title: const Text('Auto next episode'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: showModalDialog,
                          child: Card(
                            child: ListTile(
                              leading: FadeInImage(
                                image: NetworkImage(coverImage),
                                placeholder:
                                    const AssetImage('assets/Milk.png'),
                                fit: BoxFit.cover,
                              ),
                              title:
                                  Text(title, overflow: TextOverflow.ellipsis),
                              trailing: const Icon(Icons.info_outline_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                    PagedSliverList(
                      pagingController: _pagingControllerEpisodes,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: item as ContainerAnimeEpisode);
                        },
                      ),
                    ),
                  ],
                );
              }
            }),
        onRefresh: () async {
          refresh();
        });
  }

  @override
  void dispose() {
    _pagingControllerEpisodes.dispose();
    player.dispose();
    super.dispose();
  }
}

class Episode extends StatelessWidget {
  const Episode({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EpisodeFrame(id: id),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:milk/components/container.dart';
import 'package:milk/tools.dart';

class AnimeInfo extends StatefulWidget {
  const AnimeInfo(
      {required this.id,
      required this.type,
      required this.showBanner,
      super.key});
  final TypeSpace? type;
  final String id;
  final bool showBanner;

  @override
  State<AnimeInfo> createState() => _AnimeInfoState();
}

class _AnimeInfoState extends State<AnimeInfo> {
  late Future<ContainerAnimeFrame> media;

  @override
  void initState() {
    media = getMediaById(context, widget.id, widget.type, widget.showBanner);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: media,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    overflow: TextOverflow.ellipsis));
          } else {
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: snapshot.data as ContainerAnimeFrame,
                ),
              ],
            );
          }
        });
  }
}

class AnimeFrame extends StatefulWidget {
  const AnimeFrame({required this.id, super.key});
  final String id;

  @override
  State<AnimeFrame> createState() => _AnimeFrameState();
}

class _AnimeFrameState extends State<AnimeFrame> {
  late Future<ContainerAnimeFrame> media;
  final PagingController<String, ContainerAnimeEpisode>
      _pagingControllerLastEpisodes = PagingController(firstPageKey: "");

  void refresh() {
    setState(() {
      media = getMediaById(context, widget.id, null, true);
    });
    _pagingControllerLastEpisodes.refresh();
  }

  @override
  void initState() {
    media = getMediaById(context, widget.id, null, true);
    _pagingControllerLastEpisodes.addPageRequestListener((pageKey) {
      fetchContainerAnimeEpisode(context, _pagingControllerLastEpisodes,
          pageKey, widget.id, pageKey, "", false, null, null);
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
                return CustomScrollView(
                  slivers: <Widget>[
                    if (!Platform.isAndroid && !Platform.isIOS)
                      const SliverAppBar(
                        title: null,
                        floating: true,
                        pinned: true,
                      ),
                    SliverToBoxAdapter(
                      child: snapshot.data as ContainerAnimeFrame,
                    ),
                    PagedSliverList(
                      pagingController: _pagingControllerLastEpisodes,
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
    _pagingControllerLastEpisodes.dispose();
    super.dispose();
  }
}

class Anime extends StatelessWidget {
  const Anime({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AnimeFrame(id: id));
  }
}

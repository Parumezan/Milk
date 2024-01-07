import 'package:flutter/material.dart';
import 'package:milk/components/status.dart';
import 'package:milk/pages/anime.dart';
import 'package:milk/pages/episode.dart';
import 'package:milk/tools.dart';

class ContainerAnime extends StatelessWidget {
  const ContainerAnime({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.status,
    Key? key,
  }) : super(key: key);

  final String id;
  final List<String?> title;
  final String coverImage;
  final String status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Anime(id: id)),
        );
      },
      child: Wrap(
        children: [
          Card(
            child: Column(
              children: [
                FadeInImage(
                  image: NetworkImage(coverImage),
                  placeholder: const AssetImage('assets/Milk.png'),
                  fit: BoxFit.cover,
                ),
                ListTile(
                  title: Text(title[0] ?? title[1] ?? "Unknown Name",
                      overflow: TextOverflow.ellipsis, maxLines: 2),
                  subtitle: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusWidget(status: status),
                      const SizedBox(width: 10),
                      Text(statusToString(status),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContainerAnimeEpisode extends StatelessWidget {
  const ContainerAnimeEpisode(
      {required this.callback,
      required this.selected,
      required this.id,
      required this.title,
      required this.coverImage,
      required this.episode,
      required this.status,
      required this.timeSinceLastUpdate,
      super.key});

  final CallbackNewEpisode? callback;
  final bool selected;
  final String id;
  final List<String?> title;
  final String coverImage;
  final int episode;
  final String status;
  final int timeSinceLastUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (callback != null) {
          callback!(id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Episode(id: id)),
          );
        }
      },
      child: Card(
          child: ListTile(
        leading: FadeInImage(
          image: NetworkImage(coverImage),
          placeholder: const AssetImage('assets/Milk.png'),
          fit: BoxFit.cover,
        ),
        title: Text(title[0] ?? title[1] ?? "Unknown Name",
            overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            StatusWidget(status: status),
            const SizedBox(width: 10),
            Text(
                "${statusToString(status)} - ${getTimeSinceLastUpdate(timeSinceLastUpdate)}",
                overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Text(episode.toString(), overflow: TextOverflow.ellipsis),
        tileColor: () {
          if (selected) {
            return Theme.of(context).secondaryHeaderColor;
          }
        }(),
      )),
    );
  }
}

class ContainerAnimeFrame extends StatelessWidget {
  const ContainerAnimeFrame(
      {required this.type,
      required this.showBanner,
      required this.id,
      required this.title,
      required this.format,
      required this.season,
      required this.episodes,
      required this.coverImage,
      required this.bannerImage,
      required this.description,
      required this.status,
      required this.isAdult,
      required this.startDate,
      required this.endDate,
      required this.tags,
      super.key});

  final TypeSpace? type;
  final bool showBanner;
  final String id;
  final List<String?> title;
  final String format;
  final int season;
  final int episodes;
  final String coverImage;
  final String bannerImage;
  final String description;
  final String status;
  final bool isAdult;
  final Map<String, dynamic> startDate;
  final Map<String, dynamic> endDate;
  final List<dynamic> tags;

  FadeInImage getCoverImage() {
    if (coverImage.isEmpty) {
      return const FadeInImage(
        placeholder: AssetImage('assets/Milk.png'),
        image: AssetImage('assets/Milk.png'),
        fit: BoxFit.cover,
      );
    } else {
      return FadeInImage.assetNetwork(
          placeholder: "assets/Milk.png", image: coverImage, fit: BoxFit.cover);
    }
  }

  FadeInImage getBannerImage() {
    if (bannerImage.isEmpty) {
      return const FadeInImage(
        placeholder: AssetImage("assets/banner00.gif"),
        image: AssetImage("assets/banner00.gif"),
        fit: BoxFit.cover,
      );
    } else {
      return FadeInImage.assetNetwork(
          placeholder: getRandomBannerImage(),
          image: bannerImage,
          fit: BoxFit.cover);
    }
  }

  Padding getColumnText(String title, String description, double fontSizeTitle,
      double fontSizeDescription, double padding) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSizeTitle,
              ),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 10),
            Text(
              description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 20,
              style: TextStyle(
                fontSize: fontSizeDescription,
              ),
            ),
          ],
        ));
  }

  Widget largeSpace() {
    return Stack(
      children: [
        showBanner
            ? SizedBox(
                height: 500,
                width: double.infinity,
                child: getBannerImage(),
              )
            : const SizedBox(height: 0),
        Column(children: [
          showBanner ? const SizedBox(height: 250) : const SizedBox(height: 0),
          Card(
            margin: const EdgeInsets.only(bottom: 50, left: 100, right: 100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getCoverImage(),
                Expanded(
                  child: Column(
                    children: [
                      getColumnText(
                        (title[0] ?? title[1] ?? "Unknown"),
                        description,
                        22,
                        14,
                        30,
                      ),
                      getAnimeInfo(false),
                      getTags(false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget mediumSpace() {
    return Stack(
      children: [
        showBanner
            ? SizedBox(
                height: 300,
                width: double.infinity,
                child: getBannerImage(),
              )
            : const SizedBox(height: 0),
        Column(children: [
          showBanner ? const SizedBox(height: 200) : const SizedBox(height: 0),
          Row(
            children: [
              Expanded(
                child: Card(
                  margin: const EdgeInsets.only(left: 10, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      getCoverImage(),
                      Expanded(
                        child: getColumnText(
                          (title[0] ?? title[1] ?? "Unknown"),
                          description,
                          22,
                          14,
                          30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              getAnimeInfo(true),
            ],
          ),
          getTags(false),
        ]),
      ],
    );
  }

  Widget smallSpace() {
    return Center(
        child: Column(
      children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getCoverImage(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: getColumnText((title[0] ?? title[1] ?? "Unknown"),
                    description, 22, 14, 0),
              ),
            ],
          ),
        ),
        getAnimeInfo(false),
        getTags(false),
      ],
    ));
  }

  Card getAnimeInfo(bool horizontal) {
    List<Widget> infos = [
      getColumnText("Format", format, 16, 14, 10),
      getColumnText("Season", season.toString(), 16, 14, 10),
      getColumnText("Episodes", episodes.toString(), 16, 14, 10),
      getColumnText("Status", statusToString(status), 16, 14, 10),
      getColumnText("Adult", isAdult.toString(), 16, 14, 10),
      getColumnText("Start Date", startDate['year'].toString(), 16, 14, 10),
      getColumnText("End Date", endDate['year'].toString(), 16, 14, 10),
    ];

    return Card(
      margin: const EdgeInsets.all(10),
      child: Container(
        constraints:
            horizontal ? null : const BoxConstraints(minWidth: double.infinity),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 20,
            alignment: WrapAlignment.spaceBetween,
            direction: horizontal ? Axis.vertical : Axis.horizontal,
            children: infos,
          ),
        ),
      ),
    );
  }

  Card getTags(bool horizontal) {
    List<Widget> infos = [];

    for (var tag in tags) {
      infos.add(
        Chip(
          label: Text(tag['name']),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(10),
      child: Container(
        constraints:
            horizontal ? null : const BoxConstraints(minWidth: double.infinity),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 20,
            alignment: WrapAlignment.spaceEvenly,
            direction: horizontal ? Axis.vertical : Axis.horizontal,
            children: infos,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type != null) {
      switch (type!) {
        case TypeSpace.large:
          return largeSpace();
        case TypeSpace.medium:
          return mediumSpace();
        case TypeSpace.small:
          return smallSpace();
      }
    } else {
      switch (MediaQuery.of(context).size.width) {
        case < 850:
          return smallSpace();
        case > 850 && < 1400:
          return mediumSpace();
        case > 1400:
          return largeSpace();
        default:
          break;
      }
    }
    return mediumSpace();
  }
}

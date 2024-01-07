import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:milk/components/container.dart';
import 'package:milk/pages/login.dart';
import 'package:milk/services/media.dart';
import 'package:milk/services/media_episode.dart';

typedef CallbackNewEpisode = void Function(String? id);

class Common {
  String baseURL = 'http://pantsustreaming.fr:9090';
  String localStorageName = 'localstorage';
  String localTokenName = 'token';
  String localNSFWName = 'nsfw';
  String localSwipeLockName = 'swipeLock';
  String localAutoPlayName = 'autoplay';
  int limitRequests = 20;
  int limitTags = 20;
  double aspectRatio = 0.5;
}

enum TypeSpace { small, medium, large }

String getRandomBannerImage() {
  List<String> bannerList = [
    "assets/banner00.gif",
    "assets/banner01.gif",
  ];

  final random = Random();
  return bannerList[random.nextInt(bannerList.length)];
}

String getTimeSinceLastUpdate(timeSinceLastUpdate) {
  if (timeSinceLastUpdate == null) {
    return "";
  }

  // timeSinceLastUpdate is in milliseconds (since it was updated)
  int seconds = (timeSinceLastUpdate / 1000).floor();
  int minutes = (seconds / 60).floor();
  int hours = (minutes / 60).floor();
  int days = (hours / 24).floor();
  int weeks = (days / 7).floor();
  int months = (days / 30).floor();
  int years = (days / 365).floor();

  if (years > 0) {
    return '$years year${years > 1 ? "s" : ""} ago';
  } else if (months > 0) {
    return '$months month${months > 1 ? "s" : ""} ago';
  } else if (weeks > 0) {
    return '$weeks week${weeks > 1 ? "s" : ""} ago';
  } else if (days > 0) {
    return '$days day${days > 1 ? "s" : ""} ago';
  } else if (hours > 0) {
    return '$hours hour${hours > 1 ? "s" : ""} ago';
  } else if (minutes > 0) {
    return '$minutes minute${minutes > 1 ? "s" : ""} ago';
  }

  return '$seconds second${seconds > 1 ? "s" : ""} ago';
}

Future<bool> tokenExists() async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  await storage.ready;
  return storage.getItem(Common().localTokenName) != null;
}

void checkErrorAcces(BuildContext context, http.Response response) async {
  tokenExists().then((value) => {
        if (!value)
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Login()))
      });
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    if (data['errors'] == null) return;
    if (data['errors'][0]['extensions']['code'] == 'ACCESS_DENIED') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }
  }
}

ContainerAnime getContainerAnimeFromJson(json) {
  return ContainerAnime(
    id: json['id'] ?? "",
    title: [json['title']['romaji'] ?? "", json['title']['english'] ?? ""],
    coverImage: json['coverImage'] ?? "",
    status: json['status'] ?? "",
  );
}

Future<void> fetchContainerAnime(
    BuildContext context,
    PagingController<String, ContainerAnime> pagingController,
    String pageKey,
    String search,
    String pattern,
    bool forceLastPage) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  await storage.ready;

  final bool isNSFW = await storage.getItem(Common().localNSFWName) ?? false;

  final response = await retrieveMedias(
      pageKey, Common().limitRequests, search, pattern, isNSFW);

  if (response.statusCode == 200) {
    if (context.mounted) checkErrorAcces(context, response);
    var data = jsonDecode(response.body);

    if (forceLastPage) {
      pagingController.appendLastPage(data['data']['page']['media']
          .map<ContainerAnime>((json) => getContainerAnimeFromJson(json))
          .toList());
      return;
    }

    final bool isLastPage =
        data['data']['page']['media'].length < Common().limitRequests;

    if (isLastPage) {
      pagingController.appendLastPage(data['data']['page']['media']
          .map<ContainerAnime>((json) => getContainerAnimeFromJson(json))
          .toList());
    } else {
      final String nextPageKey = data['data']['page']['media'].last['id'];
      pagingController.appendPage(
          data['data']['page']['media']
              .map<ContainerAnime>((json) => getContainerAnimeFromJson(json))
              .toList(),
          nextPageKey);
    }
  }
}

ContainerAnimeEpisode getContainerAnimeEpisodeFromJson(
    json, CallbackNewEpisode? callback, bool selected) {
  return ContainerAnimeEpisode(
    callback: callback,
    selected: selected,
    id: json['id'] ?? "",
    title: [
      json['media']['title']['romaji'] ?? "",
      json['media']['title']['english'] ?? ""
    ],
    coverImage: json['media']['coverImage'] ?? "",
    status: json['status'] ?? "",
    episode: json['episode'] ?? "",
    timeSinceLastUpdate: json['timeSinceLastUpdate'] ?? "",
  );
}

Future<void> fetchContainerAnimeEpisode(
  BuildContext context,
  PagingController<String, ContainerAnimeEpisode> pagingController,
  String pageKey,
  String? mediaId,
  String? afterId,
  String sort,
  bool forceLastPage,
  CallbackNewEpisode? callback,
  String? isSelected,
) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  await storage.ready;

  final bool isNSFW = await storage.getItem(Common().localNSFWName) ?? false;

  final response = await retrieveMediaEpisodes(
      mediaId, afterId, Common().limitRequests, sort, isNSFW);

  if (response.statusCode == 200) {
    if (context.mounted) checkErrorAcces(context, response);
    var data = jsonDecode(response.body);

    if (forceLastPage) {
      pagingController.appendLastPage(
          data['data']['page']['episode'].map<ContainerAnimeEpisode>((json) {
        bool selected = false;
        if (isSelected != null) selected = isSelected == json['id'];
        return getContainerAnimeEpisodeFromJson(json, callback, selected);
      }).toList());
      return;
    }

    final bool isLastPage =
        data['data']['page']['episode'].length < Common().limitRequests;

    if (isLastPage) {
      pagingController.appendLastPage(
          data['data']['page']['episode'].map<ContainerAnimeEpisode>((json) {
        bool selected = false;
        if (isSelected != null) selected = isSelected == json['id'];
        return getContainerAnimeEpisodeFromJson(json, callback, selected);
      }).toList());
    } else {
      final String nextPageKey = data['data']['page']['episode'].last['id'];
      pagingController.appendPage(
          data['data']['page']['episode'].map<ContainerAnimeEpisode>((json) {
            bool selected = false;
            if (isSelected != null) selected = isSelected == json['id'];
            return getContainerAnimeEpisodeFromJson(json, callback, selected);
          }).toList(),
          nextPageKey);
    }
  }
}

Future<ContainerAnimeFrame> getMediaById(context, id, type, showBanner) async {
  final response = await retrieveMedia(id);
  ContainerAnimeFrame media = const ContainerAnimeFrame(
    type: null,
    showBanner: true,
    id: "",
    title: ["", ""],
    format: "",
    season: 0,
    episodes: 0,
    coverImage: "",
    bannerImage: "",
    description: "",
    status: "",
    isAdult: false,
    startDate: {},
    endDate: {},
    tags: [],
  );

  if (response.statusCode == 200) {
    checkErrorAcces(context, response);
    var data = jsonDecode(response.body)['data']['media'];
    media = ContainerAnimeFrame(
      type: type,
      showBanner: showBanner,
      id: data['id'] ?? "",
      title: [data['title']['romaji'] ?? "", data['title']['english'] ?? ""],
      format: data['format'] ?? "Unknown",
      season: data['season'] ?? "Unknown",
      episodes: data['episodes'] ?? 0,
      coverImage: data['coverImage'] ?? "",
      bannerImage: data['bannerImage'] ?? "",
      description: data['description'] ?? "",
      status: data['status'] ?? "",
      isAdult: data['isAdult'] ?? false,
      startDate: data['startDate'] ?? "",
      endDate: data['endDate'] ?? "",
      tags: data['tags'] ?? "",
    );
    return media;
  }

  return media;
}

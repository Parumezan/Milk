import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:milk/tools.dart';

const episodeQuery = '''
query episode(\$id: String) {
	episode(id: \$id) {
		id
		episode
		status
		media {
			id
			title {
				romaji
				english
			}
      coverImage
		}
	}
}''';

const episodePageQuery = '''
query episodes(\$mediaId: String, \$afterId: String, \$limit: Int, \$sort: MediaEpisodeOrder, \$adult: Boolean) {
  page(afterId: \$afterId, limit: \$limit) {
    episode(mediaId: \$mediaId, sort: \$sort, adult: \$adult) {
      id
      media {
        id
        title {
          romaji
          english
        }
        coverImage
      }
      episode
      status
      timeSinceLastUpdate
    }
  }
}''';

Future<http.Response> retrieveMediaEpisode(id) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  String baseURL = Common().baseURL;
  await storage.ready;

  return http.post(Uri.parse('$baseURL/graphql'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${storage.getItem(Common().localTokenName)}'
      },
      body: jsonEncode(<String, dynamic>{
        'query': episodeQuery,
        'variables': {'id': id}
      }));
}

Future<http.Response> retrieveMediaEpisodes(
    mediaId, afterId, limit, sort, isNSFW) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  String baseURL = Common().baseURL;
  await storage.ready;

  afterId ??= "";
  limit ??= Common().limitRequests;

  return http.post(
    Uri.parse('$baseURL/graphql'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${storage.getItem(Common().localTokenName)}'
    },
    body: jsonEncode(<String, dynamic>{
      'query': episodePageQuery,
      'variables': {
        'mediaId': mediaId,
        'afterId': afterId,
        'limit': limit,
        'sort': sort,
        'adult': isNSFW
      }
    }),
  );
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:milk/tools.dart';

const mediaQuery = '''
query media(\$id: String) {
	media(id: \$id) {
		id
		title {
			romaji
			english
		}
		format
		season
		episodes
		coverImage
		bannerImage
		description
		status
		isAdult
		startDate {
			year
			month
			day
		}
		endDate {
			year
			month
			day
		}
		tags {
			id
			name
		}
	}
}''';

const mediaPageQuery = '''
query medias(\$afterId: String, \$limit: Int, \$search: String, \$sort: MediaOrder, \$adult: Boolean) {
	page(afterId: \$afterId, limit: \$limit) {
		media(search: \$search, sort: \$sort, adult: \$adult) {
			id
      title {
        romaji
        english
      }
      coverImage
      status
		}
	}
}''';

Future<http.Response> retrieveMedia(id) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  String baseURL = Common().baseURL;
  await storage.ready;

  return http.post(Uri.parse('$baseURL/graphql'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${storage.getItem(Common().localTokenName)}'
      },
      body: jsonEncode(<String, dynamic>{
        'query': mediaQuery,
        'variables': {'id': id}
      }));
}

Future<http.Response> retrieveMedias(
    afterId, limit, search, sort, adult) async {
  final LocalStorage storage = LocalStorage(Common().localStorageName);
  String baseURL = Common().baseURL;
  await storage.ready;

  afterId ??= "";
  limit ??= Common().limitRequests;
  search ??= "";
  sort ??= "SEARCHMATCH";

  return http.post(Uri.parse('$baseURL/graphql'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${storage.getItem(Common().localTokenName)}'
      },
      body: jsonEncode(<String, dynamic>{
        'query': mediaPageQuery,
        'variables': {
          'afterId': afterId,
          'limit': limit,
          'search': search,
          'sort': sort,
          'adult': adult
        }
      }));
}

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:localstorage/localstorage.dart';
import 'package:milk/components/container.dart';
import 'package:milk/components/drawer.dart';
import 'package:milk/pages/search.dart';
import 'package:milk/tools.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocalStorage _storage = LocalStorage(Common().localStorageName);
  bool? isSwipeLock;

  final PagingController<String, ContainerAnime> _pagingControllerTrending =
      PagingController(firstPageKey: "");

  final PagingController<String, ContainerAnimeEpisode>
      _pagingControllerLastEpisodes = PagingController(firstPageKey: "");

  final PageController _pageController = PageController(initialPage: 0);

  void refresh() {
    _pagingControllerTrending.refresh();
    _pagingControllerLastEpisodes.refresh();
  }

  void getSwipeLock() {
    _storage.ready.then((_) {
      setState(() {
        isSwipeLock = _storage.getItem(Common().localSwipeLockName) ??
            _storage.setItem(Common().localSwipeLockName, false);
      });
    });
  }

  @override
  void initState() {
    _pagingControllerTrending.addPageRequestListener((pageKey) {
      fetchContainerAnime(
          context, _pagingControllerTrending, pageKey, "", "TRENDING", true);
    });
    _pagingControllerLastEpisodes.addPageRequestListener((pageKey) {
      fetchContainerAnimeEpisode(context, _pagingControllerLastEpisodes,
          pageKey, null, pageKey, "UPDATE", true, null, null);
    });
    getSwipeLock();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics:
          isSwipeLock ?? false ? null : const NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          drawer: MilkDrawer(
              refreshCallback: refresh, swipeLockCallback: getSwipeLock),
          body: RefreshIndicator(
            child: CustomScrollView(
              slivers: <Widget>[
                MilkAppBar(pageController: _pageController),
                const SliverAppBar(
                  leading: PreferredSize(
                    preferredSize: Size.zero,
                    child: SizedBox(),
                  ),
                  title: Text('Trending'),
                  centerTitle: true,
                ),
                PagedSliverGrid(
                  pagingController: _pagingControllerTrending,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: Common().aspectRatio,
                  ),
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return item as ContainerAnime;
                    },
                  ),
                ),
                const SliverAppBar(
                  leading: PreferredSize(
                    preferredSize: Size.zero,
                    child: SizedBox(),
                  ),
                  title: Text('Last Episodes'),
                  centerTitle: true,
                ),
                PagedSliverList(
                  pagingController: _pagingControllerLastEpisodes,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return item as ContainerAnimeEpisode;
                    },
                  ),
                ),
              ],
            ),
            onRefresh: () async {
              refresh();
            },
          ),
        ),
        Search(pageController: _pageController),
      ],
    );
  }

  @override
  void dispose() {
    _pagingControllerTrending.dispose();
    _pagingControllerLastEpisodes.dispose();
    super.dispose();
  }
}

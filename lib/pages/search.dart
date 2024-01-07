import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:milk/components/container.dart';
import 'package:milk/tools.dart';

class SearchElement extends StatefulWidget {
  const SearchElement({required this.pageController, super.key});

  final PageController pageController;

  @override
  State<SearchElement> createState() => _SearchElementState();
}

class _SearchElementState extends State<SearchElement> {
  final PagingController<String, ContainerAnime> _pagingController =
      PagingController(firstPageKey: "");

  late TextEditingController _searchController;
  Timer? _debounce;

  String _search = "";

  @override
  void initState() {
    _searchController = TextEditingController();
    _debounce = Timer(const Duration(), () {});
    _pagingController.addPageRequestListener((pageKey) {
      fetchContainerAnime(
          context, _pagingController, pageKey, _search, "SEARCHMATCH", false);
    });

    _searchController.addListener(() {
      if (_debounce!.isActive) {
        _debounce!.cancel();
      }
      if (_searchController.text != _search) {
        _debounce = Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _search = _searchController.text;
            _pagingController.refresh();
          });
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(),
                ),
              ),
              floating: true,
              pinned: true,
            ),
            PagedSliverGrid(
              pagingController: _pagingController,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: Common().aspectRatio,
              ),
              builderDelegate: PagedChildBuilderDelegate(
                animateTransitions: true,
                itemBuilder: (context, item, index) {
                  return item as ContainerAnime;
                },
              ),
            ),
          ],
        ),
        onRefresh: () async {
          _pagingController.refresh();
        });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class Search extends StatelessWidget {
  const Search({required this.pageController, super.key});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            pageController.animateToPage(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          },
          child: SearchElement(pageController: pageController)),
    );
  }
}

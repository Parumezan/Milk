import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:milk/pages/login.dart';
import 'package:milk/tools.dart';

class MilkDrawer extends StatefulWidget {
  const MilkDrawer(
      {required this.swipeLockCallback,
      required this.refreshCallback,
      super.key});

  final VoidCallback refreshCallback;
  final VoidCallback swipeLockCallback;

  @override
  State<MilkDrawer> createState() => _MilkDrawerState();
}

class _MilkDrawerState extends State<MilkDrawer> {
  final LocalStorage _storage = LocalStorage(Common().localStorageName);

  bool isNSFW = false;
  bool isSwipeLock = false;
  bool isAutoPlay = false;

  @override
  void initState() {
    _storage.ready.then((_) {
      setState(() {
        isNSFW = _storage.getItem(Common().localNSFWName) ??
            _storage.setItem(Common().localNSFWName, false);
        isSwipeLock = _storage.getItem(Common().localSwipeLockName) ??
            _storage.setItem(Common().localSwipeLockName, false);
        isAutoPlay = _storage.getItem(Common().localAutoPlayName) ??
            _storage.setItem(Common().localAutoPlayName, false);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Milk.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: null,
          ),
          ListTile(
            title: Row(
              children: [
                const Text('NSFW'),
                const Spacer(),
                Switch(
                  value: isNSFW,
                  onChanged: null,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                isNSFW = !isNSFW;
                _storage.setItem(Common().localNSFWName, isNSFW);
              });
              widget.refreshCallback();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Swipe Lock'),
                const Spacer(),
                Switch(
                  value: isSwipeLock,
                  onChanged: null,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                isSwipeLock = !isSwipeLock;
                _storage.setItem(Common().localSwipeLockName, isSwipeLock);
              });
              widget.swipeLockCallback();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Auto Play'),
                const Spacer(),
                Switch(
                  value: isAutoPlay,
                  onChanged: null,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                isAutoPlay = !isAutoPlay;
                _storage.setItem(Common().localAutoPlayName, isAutoPlay);
              });
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              _storage.deleteItem(Common().localTokenName);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MilkAppBar extends StatefulWidget {
  const MilkAppBar({required this.pageController, super.key});

  final PageController pageController;

  @override
  State<MilkAppBar> createState() => _MilkAppBarState();
}

class _MilkAppBarState extends State<MilkAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      title: const Text('Milk'),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Image(
              image: AssetImage('assets/Milk.png'),
              fit: BoxFit.contain,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        ButtonBar(
          children: [
            TextButton(
              onPressed: () {
                widget.pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
              child: const Row(
                children: [
                  Text('Search'),
                  SizedBox(width: 10),
                  Icon(Icons.search),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

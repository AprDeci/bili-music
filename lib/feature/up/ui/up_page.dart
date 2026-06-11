import 'package:bilimusic/feature/up/domain/up_page_state.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:bilimusic/feature/up/ui/components/up_collection_list.dart';
import 'package:bilimusic/feature/up/ui/components/up_profile_header.dart';
import 'package:bilimusic/feature/up/ui/components/up_video_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpPage extends ConsumerStatefulWidget {
  const UpPage({super.key, required this.mid});

  final int mid;

  @override
  ConsumerState<UpPage> createState() => _UpPageState();
}

class _UpPageState extends ConsumerState<UpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    ref
        .read(upPageControllerProvider(widget.mid).notifier)
        .selectTab(
          _tabController.index == 0 ? UpPageTab.videos : UpPageTab.collections,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Brightness statusBarIconBrightness =
        colorScheme.surface.computeLuminance() > 0.5
        ? Brightness.dark
        : Brightness.light;
    final AsyncValue<UpPageState> state = ref.watch(
      upPageControllerProvider(widget.mid),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surface,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarIconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          bottom: false,
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: TextButton(
                onPressed: () =>
                    ref.invalidate(upPageControllerProvider(widget.mid)),
                child: Text(error.toString()),
              ),
            ),
            data: (UpPageState data) {
              final int nextIndex = data.selectedTab == UpPageTab.videos
                  ? 0
                  : 1;
              if (_tabController.index != nextIndex) {
                _tabController.index = nextIndex;
              }
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          pinned: false,
                          floating: true,
                          snap: true,
                          stretch: true,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            centerTitle: true,
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: UpProfileHeader(
                            profile: data.profile,
                            error: data.profileError,
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedTabBarDelegate(
                            child: ColoredBox(
                              color: colorScheme.surface,
                              child: TabBar(
                                controller: _tabController,
                                tabs: const <Widget>[
                                  Tab(text: '投稿'),
                                  Tab(text: '合集'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    UpVideoList(
                      mid: widget.mid,
                      items: data.videos,
                      isLoadingMore: data.isLoadingVideosMore,
                      hasMore: data.hasMoreVideos,
                      error: data.videoError,
                      loadMoreError: data.videoLoadMoreError,
                    ),
                    UpCollectionList(
                      mid: widget.mid,
                      ownerName: data.profile?.name ?? '',
                      items: data.collections,
                      isLoadingMore: data.isLoadingCollectionsMore,
                      hasMore: data.hasMoreCollections,
                      error: data.collectionError,
                      loadMoreError: data.collectionLoadMoreError,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

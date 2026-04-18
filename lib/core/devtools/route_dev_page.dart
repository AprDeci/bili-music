import 'package:bilimusic/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteDevPage extends ConsumerWidget {
  const RouteDevPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final GoRouterDelegate delegate = router.routerDelegate;

    return ListenableBuilder(
      listenable: delegate,
      builder: (BuildContext context, Widget? child) {
        final RouteDebugSnapshot snapshot = RouteDebugSnapshot.fromRouter(
          router,
        );

        return ListView(
          children: <Widget>[
            _SectionTitle(title: '当前路由'),
            _FieldTile(label: 'uri', value: snapshot.uri.toString()),
            _FieldTile(
              label: 'matchedLocation',
              value: snapshot.matchedLocation,
            ),
            _FieldTile(label: 'fullPath', value: snapshot.fullPath),
            _FieldTile(label: 'leafPath', value: snapshot.leafPath),
            _FieldTile(label: 'leafName', value: snapshot.leafName),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Path Parameters'),
            if (snapshot.pathParameters.isEmpty)
              const _EmptyState(message: '当前没有 path 参数。')
            else
              ...snapshot.pathParameters.entries.map(
                (MapEntry<String, String> entry) =>
                    _FieldTile(label: entry.key, value: entry.value),
              ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Query Parameters'),
            if (snapshot.queryParameters.isEmpty)
              const _EmptyState(message: '当前没有 query 参数。')
            else
              ...snapshot.queryParameters.entries.map(
                (MapEntry<String, String> entry) =>
                    _FieldTile(label: entry.key, value: entry.value),
              ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Extra'),
            _FieldTile(label: 'extraType', value: snapshot.extraType),
            _FieldTile(
              label: 'extraPreview',
              value: snapshot.extraPreview,
              multiline: true,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Match Stack'),
            if (snapshot.matchStack.isEmpty)
              const _EmptyState(message: '当前没有可用的 route match。')
            else
              ...snapshot.matchStack.asMap().entries.map(
                (MapEntry<int, String> entry) => _FieldTile(
                  label: 'match[${entry.key}]',
                  value: entry.value,
                  multiline: true,
                ),
              ),
          ],
        );
      },
    );
  }
}

class RouteDebugSnapshot {
  const RouteDebugSnapshot({
    required this.uri,
    required this.matchedLocation,
    required this.fullPath,
    required this.leafPath,
    required this.leafName,
    required this.pathParameters,
    required this.queryParameters,
    required this.extraType,
    required this.extraPreview,
    required this.matchStack,
  });

  final Uri uri;
  final String matchedLocation;
  final String fullPath;
  final String leafPath;
  final String leafName;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final String extraType;
  final String extraPreview;
  final List<String> matchStack;

  factory RouteDebugSnapshot.fromRouter(GoRouter router) {
    final RouteMatchList configuration =
        router.routerDelegate.currentConfiguration;
    final GoRouterState topState = router.state;
    final RouteMatch? leafMatch = configuration.lastOrNull;
    final GoRoute? leafRoute = leafMatch?.route;

    return RouteDebugSnapshot(
      uri: configuration.uri,
      matchedLocation: topState.matchedLocation,
      fullPath: topState.fullPath ?? '',
      leafPath: leafRoute?.path ?? topState.path ?? '',
      leafName: topState.name ?? '',
      pathParameters: configuration.pathParameters,
      queryParameters: configuration.uri.queryParameters,
      extraType: configuration.extra?.runtimeType.toString() ?? 'null',
      extraPreview: configuration.extra?.toString() ?? 'null',
      matchStack: _buildMatchStack(configuration),
    );
  }

  String toSummary() {
    return <String>[
      'uri=${uri.toString()}',
      'matchedLocation=$matchedLocation',
      'fullPath=${fullPath.ifEmpty('-')}',
      'leafPath=${leafPath.ifEmpty('-')}',
      'leafName=${leafName.ifEmpty('-')}',
      'pathParameters=$pathParameters',
      'queryParameters=$queryParameters',
      'extraType=$extraType',
      'extraPreview=$extraPreview',
      'matchStack=$matchStack',
    ].join('\n');
  }

  static List<String> _buildMatchStack(RouteMatchList configuration) {
    return configuration.matches
        .map((RouteMatchBase match) => _describeMatch(match))
        .toList(growable: false);
  }

  static String _describeMatch(RouteMatchBase match) {
    if (match is RouteMatch) {
      return <String>[
        'type=RouteMatch',
        'matchedLocation=${match.matchedLocation}',
        'routePath=${match.route.path}',
        'routeName=${match.route.name ?? '-'}',
        'pageKey=${match.pageKey.value}',
      ].join('\n');
    }

    return match.toString();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value.ifEmpty('-'),
            minLines: 1,
            maxLines: multiline ? null : 3,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.35,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) {
    return isEmpty ? fallback : this;
  }
}

import 'package:bilimusic/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteDevPage extends ConsumerWidget {
  const RouteDevPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final RouteInformationProvider routeInformationProvider =
        router.routeInformationProvider;
    return ValueListenableBuilder<RouteInformation>(
      valueListenable: routeInformationProvider,
      builder:
          (
            BuildContext context,
            RouteInformation routeInformation,
            Widget? child,
          ) {
            final Uri uri = routeInformation.uri;
            final Object? state = routeInformation.state;
            final Map<String, String> queryParameters = uri.queryParameters;
            final List<String> segments = uri.pathSegments;

            return ListView(
              children: <Widget>[
                _SectionTitle(title: '当前路由'),
                _FieldTile(label: 'location', value: uri.toString()),
                _FieldTile(label: 'path', value: uri.path.ifEmpty('/')),
                _FieldTile(label: 'fragment', value: uri.fragment),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Query Parameters'),
                if (queryParameters.isEmpty)
                  const _EmptyState(message: '当前没有 query 参数。')
                else
                  ...queryParameters.entries.map(
                    (MapEntry<String, String> entry) =>
                        _FieldTile(label: entry.key, value: entry.value),
                  ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Path Segments'),
                if (segments.isEmpty)
                  const _EmptyState(message: '当前路径没有 segment。')
                else
                  ...segments.asMap().entries.map(
                    (MapEntry<int, String> entry) => _FieldTile(
                      label: 'segment[${entry.key}]',
                      value: entry.value,
                    ),
                  ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Route State'),
                _FieldTile(
                  label: 'stateType',
                  value: state?.runtimeType.toString() ?? 'null',
                ),
                _FieldTile(
                  label: 'statePreview',
                  value: state?.toString() ?? 'null',
                  multiline: true,
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'URI Breakdown'),
                _FieldTile(label: 'scheme', value: uri.scheme),
                _FieldTile(label: 'host', value: uri.host),
                _FieldTile(
                  label: 'port',
                  value: uri.hasPort ? '${uri.port}' : '',
                ),
              ],
            );
          },
    );
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

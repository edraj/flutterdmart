/// A dmart resource type.
///
/// [wire] is the name dmart sends and expects (`plugin_wrapper`,
/// `data_asset`), which for some types differs from the Dart name. Read one
/// with [ResourceType.fromWire], which never throws: a type this package
/// doesn't know yet reads as [unknown], so a response that holds one still
/// parses.
enum ResourceType {
  user('user'),
  group('group'),
  folder('folder'),
  schema('schema'),
  content('content'),
  acl('acl'),
  comment('comment'),
  media('media'),
  locator('locator'),
  relationship('relationship'),
  alteration('alteration'),
  history('history'),
  space('space'),
  permission('permission'),
  role('role'),
  ticket('ticket'),
  json('json'),
  post('post'),
  pluginWrapper('plugin_wrapper'),
  notification('notification'),
  reaction('reaction'),
  csv('csv'),
  jsonl('jsonl'),
  parquet('parquet'),
  sqlite('sqlite'),
  dataAsset('data_asset'),
  lock('lock'),
  log('log'),
  reply('reply'),
  share('share'),
  integration('integration'),

  /// A type dmart sent that this package doesn't know yet.
  unknown('unknown');

  const ResourceType(this.wire);

  /// The name dmart uses for this type.
  final String wire;

  /// The type dmart names [value], or [unknown].
  static ResourceType fromWire(Object? value) =>
      ResourceType.values.firstWhere((t) => t.wire == value, orElse: () => ResourceType.unknown);
}

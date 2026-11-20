import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

// dmart's resource types, actions and content types are read with
// .values.byName, which throws on a name the package doesn't know, so one
// unfamiliar record failed a whole response (a reply, a lock, a data asset,
// an integration), and one unfamiliar action (assign, lock, unlock) failed a
// whole profile. Types also went out under their Dart names, so
// pluginWrapper reached dmart as "pluginWrapper", not "plugin_wrapper".
void main() {
  // Every type csdmart 1.8.0 has (Dmart.Models/Enums/ResourceType.cs).
  const serverTypes = [
    'acl', 'alteration', 'comment', 'content', 'csv', 'data_asset', 'folder', 'group', 'history',
    'integration', 'json', 'jsonl', 'locator', 'lock', 'log', 'media', 'notification', 'parquet',
    'permission', 'plugin_wrapper', 'post', 'reaction', 'relationship', 'reply', 'role', 'schema',
    'share', 'space', 'sqlite', 'ticket', 'user',
  ];

  group('ResourceType', () {
    test('knows every type dmart has, under dmart\'s name', () {
      for (final wire in serverTypes) {
        final type = ResourceType.fromWire(wire);
        expect(type, isNot(ResourceType.unknown), reason: wire);
        expect(type.wire, wire);
      }
      expect(ResourceType.fromWire('plugin_wrapper'), ResourceType.pluginWrapper);
      expect(ResourceType.fromWire('data_asset'), ResourceType.dataAsset);
    });

    test('a type it does not know reads as unknown instead of throwing', () {
      expect(ResourceType.fromWire('a_type_from_the_future'), ResourceType.unknown);
      expect(ResourceType.fromWire(null), ResourceType.unknown);
    });

    test('a record of a new or unknown type parses, and writes dmart\'s name back', () {
      for (final wire in ['integration', 'reply', 'a_type_from_the_future']) {
        final record = ResponseRecord.fromJson({
          'resource_type': wire,
          'uuid': 'u',
          'shortname': 's',
          'subpath': '/',
          'attributes': {'is_active': true},
        });
        expect(record.resourceType, ResourceType.fromWire(wire));
      }
      final wrapper = ResponseRecord.fromJson({
        'resource_type': 'plugin_wrapper',
        'uuid': 'u',
        'shortname': 's',
        'subpath': '/',
        'attributes': {'is_active': true},
      });
      expect(wrapper.toJson()['resource_type'], 'plugin_wrapper');
    });
  });

  group('Permission', () {
    test('reads assign, lock and unlock, and skips an action it does not know', () {
      final permission = Permission.fromJson({
        'allowed_actions': ['view', 'assign', 'lock', 'unlock', 'an_action_from_the_future'],
        'conditions': ['own_group'],
        'allowed_fields_values': <String, dynamic>{},
      });
      expect(permission.allowedActions,
          [ActionType.view, ActionType.assign, ActionType.lock, ActionType.unlock]);
      expect(permission.conditions, ['own_group']);
    });
  });

  group('ContentType', () {
    test('reads dmart\'s comment, reaction and opaque, and an unknown one as binary', () {
      expect(ContentType.get('comment'), ContentType.comment);
      expect(ContentType.get('reaction'), ContentType.reaction);
      expect(ContentType.get('opaque'), ContentType.opaque);
      expect(ContentType.get('image_jpeg'), ContentType.imageJpeg);
      expect(ContentType.get('a_kind_from_the_future'), ContentType.binary);
    });
  });
}

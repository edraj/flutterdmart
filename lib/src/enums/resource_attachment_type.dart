enum ResourceAttachmentType {
  json,
  comment,
  media,
  relationship,
  alteration;

  static ResourceAttachmentType byName(String name) => ResourceAttachmentType.values.byName(name);
}

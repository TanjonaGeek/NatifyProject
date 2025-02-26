enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  gif('gif'),
  music('music'),
  document('document'),
  appel('appel');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
      case 'music':
        return MessageEnum.music;
      case 'document':
        return MessageEnum.document;
      case 'appel':
        return MessageEnum.appel;
      default:
        return MessageEnum.text;
    }
  }
}

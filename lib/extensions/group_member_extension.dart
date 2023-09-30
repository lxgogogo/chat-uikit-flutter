import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';

extension GroupMemberPrivateAvatar on V2TimGroupMemberFullInfo? {
  String? get privateAvatar {
    final privateAvatar = this?.customInfo?['private_avatar'] ?? '';
    final avatarPrefix = this?.customInfo?['avatar_prefix'] ?? '';
    if (avatarPrefix.isNotEmpty && privateAvatar.isNotEmpty) {
      return avatarPrefix + privateAvatar;
    }
    return this?.faceUrl;
  }
}

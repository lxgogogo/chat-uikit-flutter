// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/message/message_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/extended_wrap/extended_wrap.dart';

class TIMUIKitMessageReactionItem extends TIMUIKitStatelessWidget {
  /// the unicode of the emoji
  final int sticker;

  /// the list contains the name who choose the current emoji
  final List nameList;

  /// current message
  final V2TimMessage message;

  /// show the details of message reaction
  final Function(int sticker) onShowDetail;

  /// the member in current chat
  final List<V2TimGroupMemberFullInfo?> memberList;

  TIMUIKitMessageReactionItem({
    Key? key,
    required this.message,
    required this.sticker,
    required this.memberList,
    required this.onShowDetail,
    required this.nameList,
  }) : super(key: key);

  final selfInfoModel = serviceLocator<TUISelfInfoViewModel>();

  Future<void> clickOnCurrentSticker() async {
    for (int i = 0; i < 5; i++) {
      final res = await modifySticker();
      if (res.code == 0) {
        break;
      }
    }
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifySticker() async {
    return await Future.delayed(
      const Duration(milliseconds: 50),
      () async {
        return await MessageReactionUtils.clickOnSticker(message, sticker);
      },
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final isIncludeMe = nameList.contains(
      selfInfoModel.loginInfo?.userID,
    );

    return Container(
      height: 28.w,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
      ),
      decoration: BoxDecoration(
        color: isIncludeMe ? const Color(0xffEAF4CD) : const Color(0xffFAFAFA),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color:
              isIncludeMe ? const Color(0xffB2F417) : const Color(0xffE8E8E8),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: clickOnCurrentSticker,
        onLongPress: () {
          onShowDetail(sticker);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: (!PlatformUtils().isIOS) ? 4.w : 2.w,
                  top: (!PlatformUtils().isIOS) ? 4.w : 0),
              child: Text(
                String.fromCharCode(sticker),
                style: TextStyle(
                  fontSize: (!PlatformUtils().isIOS) ? 12.w : 16.w,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              nameList.length.toString(),
              style: TextStyle(
                fontSize: 12.w,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

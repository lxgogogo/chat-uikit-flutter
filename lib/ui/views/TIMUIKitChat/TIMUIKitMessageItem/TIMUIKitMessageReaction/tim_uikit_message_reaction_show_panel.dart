import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_detail.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_item.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_show_item.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';

class TIMUIKitMessageReactionShowPanel extends StatefulWidget {
  /// current message
  final V2TimMessage message;

  final MessageRewardListBuilder? rewardListBuilder;

  const TIMUIKitMessageReactionShowPanel({
    Key? key,
    required this.message,
    this.rewardListBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TIMUIKitMessageReactionShowPanelState();
}

class _TIMUIKitMessageReactionShowPanelState
    extends TIMUIKitState<TIMUIKitMessageReactionShowPanel> {
  final TUISelfInfoViewModel selfInfoModel =
  serviceLocator<TUISelfInfoViewModel>();

  bool isShowJumpState = false;
  bool isShining = false;

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUIChatSeparateViewModel model =
    Provider.of<TUIChatSeparateViewModel>(context);

    CloudCustomData messageCloudCustomData =
    MessageReactionUtils.getCloudCustomData(widget.message);

    ///打赏的
    Map<String, dynamic> messageReward = {};
    if (messageCloudCustomData.messageReward != null &&
        messageCloudCustomData.messageReward!.isNotEmpty) {
      messageReward = messageCloudCustomData.messageReward!;
    }

    ///点赞的
    Map<String, dynamic> messageReaction = {};
    if (messageCloudCustomData.messageReaction != null &&
        messageCloudCustomData.messageReaction!.isNotEmpty) {
      messageReaction = messageCloudCustomData.messageReaction!;
    }

    final List<int> messageReactionStickerList = [];

    messageReaction.forEach((key, value) {
      messageReactionStickerList.add(int.parse(key));
    });

    final filteredMessageReactionStickerList =
    messageReactionStickerList.where((sticker) {
      if (messageReaction[sticker.toString()] == null ||
          messageReaction[sticker.toString()] is! List ||
          messageReaction[sticker.toString()].length == 0) {
        return false;
      }
      return true;
    }).toList();

    final ConvType convType = model.conversationType ?? ConvType.c2c;
    List<V2TimGroupMemberFullInfo?> memberList = [];
    if (convType == ConvType.group) {
      memberList = model.groupMemberList ?? [];
    } else {
      final V2TimGroupMemberFullInfo selfInfo = V2TimGroupMemberFullInfo(
        userID: selfInfoModel.loginInfo?.userID ?? "",
        nickName: selfInfoModel.loginInfo?.nickName,
        faceUrl: selfInfoModel.loginInfo?.faceUrl,
      );

      final V2TimGroupMemberFullInfo targetInfo = V2TimGroupMemberFullInfo(
        userID: model.conversationID,
      );
      memberList = [selfInfo, model.currentChatUserInfo ?? targetInfo];
    }

    return messageReward.isNotEmpty ||
        filteredMessageReactionStickerList.isNotEmpty
        ? Container(
      margin: EdgeInsets.only(top: 4.w),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: (!PlatformUtils().isIOS) ? 12.w : 8.w,
        children: [
          if (widget.rewardListBuilder != null)
            ...widget.rewardListBuilder!(
              widget.message,
              messageCloudCustomData.messageReward,
            ),
          if (filteredMessageReactionStickerList.isNotEmpty)
            ...filteredMessageReactionStickerList.map((sticker) {
              return TIMUIKitMessageReactionItem(
                  memberList: memberList,
                  message: widget.message,
                  nameList: messageReaction[sticker.toString()],
                  sticker: sticker,
                  onShowDetail: (int sticker) {
                    showMore(
                        context,
                        memberList,
                        messageReaction,
                        sticker,
                        filteredMessageReactionStickerList,
                        model);
                  });
            }).toList(),
        ],
      ),
    )
        : const SizedBox();
  }

  void showMore(
      BuildContext context,
      List<V2TimGroupMemberFullInfo?>? memberList,
      Map<String, dynamic> messageReaction,
      int currentSticker,
      List<int> stickerList,
      TUIChatSeparateViewModel model) async {
    _showCustomModalBottomSheet(context, memberList, messageReaction,
        currentSticker, stickerList, model);
  }

  Future<Future<int?>> _showCustomModalBottomSheet(
      context,
      List<V2TimGroupMemberFullInfo?>? memberList,
      Map<String, dynamic> messageReaction,
      int currentSticker,
      List<int> stickerList,
      TUIChatSeparateViewModel model,
      ) async {
    return showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.66,
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  Center(
                    child: Text(
                      TIM_t("回应详情"),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
                child: TIMUIKitMessageReactionDetail(
                  onTapAvatar: model.onTapAvatar,
                  stickerList: stickerList,
                  currentStickerIndex: stickerList
                      .indexWhere((element) => element == currentSticker),
                  memberList: memberList,
                  messageReaction: messageReaction,
                )),
          ]),
        );
      },
    );
  }
}

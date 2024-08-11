// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_clipboard/image_clipboard.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/common_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/message.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_select_emoji.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/action_sheet.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/forward_message_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class TIMUIKitOtherAvatarTooltip extends StatefulWidget {
  /// tool tips panel configuration, long press message will show tool tips panel
  final ToolTipsConfig? toolTipsConfig;

  /// current message
  final V2TimMessage message;

  /// allow notifi user when send reply message
  final bool allowAtUserWhenReply;

  /// the callback for long press event, except myself avatar
  final Function(String? userId, String? nickName)?
      onLongPressForOthersHeadPortrait;

  final Function(String? userId, String? nickName)? onViewMessages;
  final Function(String? userId, String? nickName)? onSearchMessages;
  final Function(String? userId, String? nickName)? onSendMessages;

  final bool isUseMessageReaction;

  /// direction
  final SelectEmojiPanelPosition selectEmojiPanelPosition;

  /// on add sticker reaction to a message
  final ValueChanged<int> onSelectSticker;

  /// on close tooltip area
  final VoidCallback onCloseTooltip;

  final TUIChatSeparateViewModel model;

  final bool isShowMoreSticker;

  final V2TimGroupMemberFullInfo? groupMemberInfo;

  final bool iSUseDefaultHoverBar;

  const TIMUIKitOtherAvatarTooltip({
    Key? key,
    this.toolTipsConfig,
    this.isUseMessageReaction = true,
    required this.model,
    required this.message,
    required this.allowAtUserWhenReply,
    this.onLongPressForOthersHeadPortrait,
    required this.selectEmojiPanelPosition,
    required this.onCloseTooltip,
    required this.onSelectSticker,
    this.isShowMoreSticker = false,
    this.groupMemberInfo,
    required this.iSUseDefaultHoverBar,
    this.onViewMessages,
    this.onSearchMessages,
    this.onSendMessages,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitOtherAvatarTooltipState();
}

class TIMUIKitOtherAvatarTooltipState
    extends TIMUIKitState<TIMUIKitOtherAvatarTooltip> {
  final TUIChatGlobalModel globalModal = serviceLocator<TUIChatGlobalModel>();
  final TUISelfInfoViewModel selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();

  @override
  void initState() {
    super.initState();
  }

  Widget ItemInkWell({
    Widget? child,
    GestureTapCallback? onTap,
  }) {
    return SizedBox(
      width: 44,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(bottom: 6, top: 6),
          child: child,
        ),
      ),
    );
  }

  _buildLongPressTipItem(
      TUITheme theme, TUIChatSeparateViewModel model, V2TimMessage message) {
    final isGroup = TencentUtils.checkString(widget.message.groupID) != null;
    final List<MessageToolTipItem> defaultTipsList = [
      MessageToolTipItem(
          label: TIM_t("查看信息"),
          id: "viewMessages",
          iconImageAsset: "images/view_messages.png",
          onClick: () => _onTap("viewMessages", model)),
      MessageToolTipItem(
          label: TIM_t("搜索消息"),
          id: "searchMessages",
          iconImageAsset: "images/search_messages.png",
          onClick: () => _onTap("searchMessages", model)),
      MessageToolTipItem(
          label: TIM_t("发信息"),
          id: "sendMessages",
          iconImageAsset: "images/send_messages.png",
          onClick: () => _onTap("sendMessages", model)),
      if (isGroup)
        MessageToolTipItem(
            label: TIM_t("@Ta"),
            id: "atMessages",
            iconImageAsset: "images/at_messages.png",
            onClick: () => _onTap("atMessages", model)),
    ];
    final defaultTipsIds = defaultTipsList.map((e) => e.id);
    List<dynamic> widgetList = [];
    widgetList = defaultTipsList
        .map(
          (item) => ItemInkWell(
            onTap: () {
              item.onClick();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Image.asset(
                    item.iconImageAsset,
                    package: defaultTipsIds.contains(item.id)
                        ? 'tencent_cloud_chat_uikit'
                        : null,
                    width: 16,
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
    if (widgetList.isEmpty) {
      widget.onCloseTooltip();
    }

    return widgetList;
  }

  _onTap(String operation, TUIChatSeparateViewModel model) async {
    final messageItem = widget.message;
    final msgID = messageItem.msgID as String;
    switch (operation) {
      case "viewMessages":
        if (widget.onViewMessages != null) {
          widget.onViewMessages!(
              widget.message.sender, widget.message.nickName);
        }
        break;
      case "searchMessages":
        if (widget.onSearchMessages != null) {
          widget.onSearchMessages!(
              widget.message.sender, widget.message.nickName);
        }
        break;
      case "sendMessages":
        final isGroup =
            TencentUtils.checkString(widget.message.groupID) != null;
        if (isGroup && widget.onSendMessages != null) {
          widget.onSendMessages!(
              widget.message.sender, widget.message.nickName);
        }
        break;
      case "atMessages":
        final isSelf = widget.message.isSelf ?? true;
        final isGroup =
            TencentUtils.checkString(widget.message.groupID) != null;
        final isAtWhenReply = !isSelf &&
            isGroup &&
            widget.onLongPressForOthersHeadPortrait != null;
        widget.onLongPressForOthersHeadPortrait!(
            !isAtWhenReply ? null : widget.message.sender,
            !isAtWhenReply ? null : widget.message.nickName);
        break;
      default:
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("暂未实现"),
            infoCode: 6660409));
    }
    widget.onCloseTooltip();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.model),
      ],
      builder: (BuildContext context, Widget? w) {
        final TUIChatSeparateViewModel model =
            Provider.of<TUIChatSeparateViewModel>(context);
        final message = widget.message;
        return Container(
            width: MediaQuery.sizeOf(context).width * 0.3,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildLongPressTipItem(theme, model, message),
            ));
      },
    );
  }
}

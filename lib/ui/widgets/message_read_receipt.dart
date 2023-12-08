import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/message.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/time_ago.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_face_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_file_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_image_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_image_elem_orgin.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_sound_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_chat_video_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/tim_uikit_merger_message_elem.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/avatar.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class MessageReadReceipt extends StatefulWidget {
  final V2TimMessage messageItem;
  final int unreadCount;
  final int readCount;
  final void Function(String userID, TapDownDetails tapDetails)? onTapAvatar;
  final TUIChatSeparateViewModel model;

  /////////// 版本迁移 ///////////
  final Function(String qrCode)? onIdentifyQrCode;
  final void Function(
    V2TimMessage message,
    dynamic heroTag,
    V2TimVideoElem videoElement,
  ) onVideoTap;
  /////////// 版本迁移 ///////////

  const MessageReadReceipt({
    Key? key,
    required this.messageItem,
    required this.unreadCount,
    required this.readCount,
    this.onTapAvatar,
    required this.model,
    /////////// 版本迁移 ///////////
    this.onIdentifyQrCode,
    required this.onVideoTap,
    /////////// 版本迁移 ///////////
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageReadReceiptState();
}

class _MessageReadReceiptState extends TIMUIKitState<MessageReadReceipt> {
  bool readMemberIsFinished = false;
  bool unreadMemberIsFinished = false;
  int readMemberListNextSeq = 0;
  int unreadMemberListNextSeq = 0;
  List<V2TimGroupMemberInfo> readMemberList = [];
  List<V2TimGroupMemberInfo> unreadMemberList = [];
  int currentIndex = 0;

  _getUnreadMemberList() async {
    final unReadMemberRes = await widget.model.getGroupMessageReadMemberList(
        widget.messageItem.msgID!,
        GetGroupMessageReadMemberListFilter
            .V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD,
        unreadMemberListNextSeq);
    if (unReadMemberRes.code == 0) {
      final res = unReadMemberRes.data;
      if (res != null) {
        unreadMemberList = [...unreadMemberList, ...res.memberInfoList];
        unreadMemberIsFinished = res.isFinished;
        unreadMemberListNextSeq = res.nextSeq;
      }
    }
    setState(() {});
  }

  _getReadMemberList() async {
    final readMemberRes = await widget.model.getGroupMessageReadMemberList(
      widget.messageItem.msgID!,
      GetGroupMessageReadMemberListFilter
          .V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ,
      readMemberListNextSeq,
    );
    if (readMemberRes.code == 0) {
      final res = readMemberRes.data;
      if (res != null) {
        readMemberList = [...readMemberList, ...res.memberInfoList];
        readMemberIsFinished = res.isFinished;
        readMemberListNextSeq = res.nextSeq;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getReadMemberList();
    _getUnreadMemberList();
  }

  Widget _getMsgItem(V2TimMessage message) {
    final type = message.elemType;
    final isFromSelf = message.isSelf ?? true;

    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        ////////////////// 自定义视频消息兼容 begin //////////////////
        if (message.customElem?.extension ==
            '${MessageElemType.V2TIM_ELEM_TYPE_VIDEO}') {
          return TIMUIKitVideoElem(
            message,
            chatModel: widget.model,
            isShowMessageReaction: false,
            isFrom: "merger",
            /////////// 版本迁移 ///////////
            onVideoTap: widget.onVideoTap,
            /////////// 版本迁移 ///////////
          );
        }
        ////////////////// 自定义视频消息兼容 end //////////////////
        return Text(TIM_t("[自定义]"));
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIMUIKitSoundElem(
            isShowMessageReaction: false,
            chatModel: widget.model,
            message: message,
            soundElem: message.soundElem!,
            msgID: message.msgID ?? "",
            isFromSelf: isFromSelf,
            localCustomInt: message.localCustomInt);
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return Text(
          message.textElem!.text!,
          softWrap: true,
          style: const TextStyle(fontSize: 16),
        );
      // return Text(message.textElem!.text!);
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return TIMUIKitFaceElem(
            isShowMessageReaction: false,
            model: widget.model,
            isShowJump: false,
            path: message.faceElem?.data ?? "",
            message: message);
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(
          chatModel: widget.model,
          isShowMessageReaction: false,
          message: message,
          messageID: message.msgID,
          fileElem: message.fileElem,
          isSelf: isFromSelf,
          isShowJump: false,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElemOrigin(
          chatModel: widget.model,
          isShowMessageReaction: false,
          message: message,
          isFrom: "merger",
          key: Key("${message.seq}_${message.timestamp}"),
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(
          message,
          chatModel: widget.model,
          isShowMessageReaction: false,
          isFrom: "merger",
          /////////// 版本迁移 ///////////
          onVideoTap: widget.onVideoTap,
          /////////// 版本迁移 ///////////
        );
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return Text(TIM_t("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
          isShowMessageReaction: false,
          model: widget.model,
          isShowJump: false,
          message: message,
          mergerElem: message.mergerElem!,
          isSelf: isFromSelf,
          messageID: message.msgID!,
          /////////// 版本迁移 ///////////
          onIdentifyQrCode: widget.onIdentifyQrCode,
          onVideoTap: widget.onVideoTap,
          /////////// 版本迁移 ///////////
        );
      default:
        return Text(TIM_t("未知消息"));
    }
  }

  _getShowName(V2TimGroupMemberInfo item) {
    final friendRemark = item.friendRemark ?? "";
    final nickName = item.nickName ?? "";
    final userID = item.userID;
    final showName = nickName != "" ? nickName : userID;
    return friendRemark != "" ? friendRemark : showName;
  }

  Widget _memberItemBuilder(V2TimGroupMemberInfo item, TUITheme theme) {
    final faceUrl = item.faceUrl ?? '';
    final showName = _getShowName(item);
    final isDesktopScreen =
        TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;

    return InkWell(
      onTapDown: (details) {
        if (widget.onTapAvatar != null) {
          widget.onTapAvatar!(item.userID!, details);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 16),
        child: Row(
          children: [
            Container(
              height: isDesktopScreen ? 30 : 40,
              width: isDesktopScreen ? 30 : 40,
              margin:
                  EdgeInsets.only(right: 12, bottom: isDesktopScreen ? 6 : 0),
              child: Avatar(faceUrl: faceUrl, showName: showName),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                  top: 10, bottom: isDesktopScreen ? 14 : 19, right: 28),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.weakDividerColor ??
                              CommonColor.weakDividerColor))),
              child: Text(
                showName,
                style: TextStyle(
                    color: Colors.black, fontSize: isDesktopScreen ? 14 : 18),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final option1 = widget.readCount;
    final option2 = widget.unreadCount;
    final isDesktopScreen =
        TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;

    Widget pageBody() {
      return Container(
        color: isDesktopScreen ? null : Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(MessageUtils.getDisplayName(widget.messageItem)),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        TimeAgo().getTimeForMessage(
                            widget.messageItem.timestamp ?? 0),
                        softWrap: true,
                        style:
                            TextStyle(fontSize: 12, color: theme.weakTextColor),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  _getMsgItem(widget.messageItem)
                ],
              ),
            ),
            Container(
              height: 8,
              color: theme.weakBackgroundColor,
            ),
            Row(
              // direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      currentIndex = 0;
                      setState(() {});
                    },
                    child: Container(
                      height: isDesktopScreen ? 40 : 50.0,
                      alignment: Alignment.bottomCenter,
                      padding:
                          EdgeInsets.only(bottom: isDesktopScreen ? 8 : 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  width: 2,
                                  color: currentIndex == 0
                                      ? theme.primaryColor!
                                      : Colors.white))),
                      child: Text(
                        TIM_t_para("{{option1}}人已读", "$option1人已读")(
                            option1: option1),
                        style: TextStyle(
                          color: currentIndex != 0
                              ? theme.weakTextColor
                              : Colors.black,
                          fontSize: isDesktopScreen ? 14 : 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      currentIndex = 1;
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: isDesktopScreen ? 40 : 50.0,
                      padding:
                          EdgeInsets.only(bottom: isDesktopScreen ? 8 : 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  width: 2,
                                  color: currentIndex == 1
                                      ? theme.primaryColor!
                                      : Colors.white))),
                      child: Text(
                        TIM_t_para("{{option2}}人未读", "$option2人未读")(
                            option2: option2),
                        style: TextStyle(
                          color: currentIndex != 1
                              ? theme.weakTextColor
                              : Colors.black,
                          fontSize: isDesktopScreen ? 14 : 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.weakDividerColor ??
                              CommonColor.weakDividerColor))),
            ),
            Expanded(
                child: IndexedStack(
              index: currentIndex,
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: readMemberList.length,
                    itemBuilder: (context, index) {
                      if (!readMemberIsFinished &&
                          index == readMemberList.length - 5) {
                        _getReadMemberList();
                      }
                      return _memberItemBuilder(readMemberList[index], theme);
                    }),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: unreadMemberList.length,
                    itemBuilder: (context, index) {
                      if (!unreadMemberIsFinished &&
                          index == unreadMemberList.length - 5) {
                        _getUnreadMemberList();
                      }
                      return _memberItemBuilder(unreadMemberList[index], theme);
                    }),
              ],
            )),
          ],
        ),
      );
    }

    return TUIKitScreenUtils.getDeviceWidget(
        context: context,
        desktopWidget: pageBody(),
        defaultWidget: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                  title: Text(
                    TIM_t("消息详情"),
                    style:
                        TextStyle(color: theme.appbarTextColor, fontSize: 17),
                  ),
                  shadowColor: theme.weakDividerColor,
                  backgroundColor: theme.appbarBgColor ?? theme.primaryColor,
                  iconTheme: IconThemeData(
                    color: theme.appbarTextColor,
                  )),
              body: pageBody()),
        ));
  }
}

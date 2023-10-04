import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitTextField/special_text/DefaultSpecialTextSpanBuilder.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/link_preview/link_preview_entry.dart';
import 'package:tencent_super_tooltip/tencent_super_tooltip.dart';

class TIMUIKitTextTranslationElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isFromSelf;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;
  final TUIChatSeparateViewModel chatModel;
  final bool? isShowMessageReaction;
  final bool isUseDefaultEmoji;
  final List<CustomEmojiFaceData> customEmojiStickerList;

  const TIMUIKitTextTranslationElem(
      {Key? key,
      required this.message,
      required this.isFromSelf,
      required this.isShowJump,
      required this.clearJump,
      this.fontStyle,
      this.borderRadius,
      this.isShowMessageReaction,
      this.backgroundColor,
      this.textPadding,
      required this.chatModel,
      this.isUseDefaultEmoji = false,
      this.customEmojiStickerList = const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextTranslationElemState();
}

class _TIMUIKitTextTranslationElemState
    extends TIMUIKitState<TIMUIKitTextTranslationElem> {
  bool isShowJumpState = false;
  bool isShining = false;

  final GlobalKey _key = GlobalKey();
  TapDownDetails? _tapDetails;

  SuperTooltip? tooltip;

  _onOpenToolTip(
    c,
    V2TimMessage message,
    TUIChatSeparateViewModel model,
    TUITheme theme,
    TapDownDetails? details,
  ) {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }
    tooltip = null;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLongMessage = context.size!.height + 350 > screenHeight;
    final tapDetails = isLongMessage ? (details ?? _tapDetails) : details;
    final isSelf = message.isSelf ?? true;

    final targetWidth =
        min(MediaQuery.of(context).size.width * 0.84, 350).toDouble();
    final double dx = !isSelf
        ? min(tapDetails?.globalPosition.dx ?? targetWidth,
            screenWidth - targetWidth)
        : max(tapDetails?.globalPosition.dx ?? targetWidth, targetWidth)
            .toDouble();
    final double dy = min(
            tapDetails?.globalPosition.dy ?? MediaQuery.of(context).size.height,
            MediaQuery.of(context).size.height - 320)
        .toDouble();
    final finalTapDetail = tapDetails != null
        ? TapDownDetails(
            globalPosition: Offset(dx, dy),
          )
        : null;

    initTools(
      context: c,
      model: model,
      details: finalTapDetail,
      theme: theme,
    );
    tooltip!.show(c, targetCenter: finalTapDetail?.globalPosition);
  }

  initTools({
    BuildContext? context,
    bool isLongMessage = false,
    required TUIChatSeparateViewModel model,
    TUITheme? theme,
    TapDownDetails? details,
  }) {
    final isUseMessageReaction = widget.message.elemType == 2
        ? false
        : model.chatConfig.isUseMessageReaction;
    final isSelf = widget.message.isSelf ?? true;
    double arrowTipDistance = 30;
    double arrowBaseWidth = 10;
    double arrowLength = 10;
    bool hasArrow = true;
    TooltipDirection popupDirection = TooltipDirection.up;
    double? left;
    double? right;
    if (context != null) {
      RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (details != null && box != null) {
        double screenWidth = MediaQuery.of(context).size.width;
        final mousePosition = details.globalPosition;
        hasArrow = false;
        arrowTipDistance = 0;
        arrowBaseWidth = 0;
        arrowLength = 0;
        popupDirection = TooltipDirection.down;
        if (isSelf) {
          right = screenWidth - mousePosition.dx;
        } else {
          left = mousePosition.dx;
        }
      } else {
        if (box != null) {
          double screenWidth = MediaQuery.of(context).size.width;
          double viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
          Offset offset = box.localToGlobal(Offset.zero);
          double boxWidth = box.size.width;
          if (isSelf) {
            right = screenWidth -
                offset.dx -
                ((isUseMessageReaction) ? boxWidth : (boxWidth / 1.3));
          } else {
            left = offset.dx;
          }
          if (offset.dy < 300 && !isLongMessage && viewInsetsBottom == 0) {
            popupDirection = TooltipDirection.down;
          } else if (viewInsetsBottom != 0 && offset.dy < 220) {
            popupDirection = TooltipDirection.down;
          }
        }
        arrowTipDistance = (context.size!.height / 2).roundToDouble() +
            (isLongMessage ? -120 : 10);
      }
    }

    tooltip = SuperTooltip(
      popupDirection: popupDirection,
      minimumOutSidePadding: 0,
      arrowTipDistance: arrowTipDistance,
      arrowBaseWidth: arrowBaseWidth,
      arrowLength: arrowLength,
      right: right,
      left: left,
      hasArrow: hasArrow,
      borderColor: theme?.white ?? Colors.white,
      backgroundColor: theme?.white ?? Colors.white,
      shadowColor: Colors.black26,
      hasShadow: false,
      borderWidth: 1.0,
      showCloseButton: ShowCloseButton.none,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      content: TIMUIKitTranslateTooltip(
        model: model,
        message: widget.message,
        onCloseTooltip: () => tooltip?.close(),
      ),
    );
  }

  closeTooltip() {
    tooltip?.close();
  }

  _showJumpColor() {
    if ((widget.chatModel.jumpMsgID != widget.message.msgID) &&
        (widget.message.msgID?.isNotEmpty ?? true)) {
      return;
    }
    isShining = true;
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        isShining = false;
        timer.cancel();
      }
      shineAmount--;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump();
    });
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final isDesktopScreen =
        TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;
    final borderRadius = widget.isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    if ((widget.chatModel.jumpMsgID == widget.message.msgID)) {}
    if (widget.isShowJump) {
      if (!isShining) {
        Future.delayed(Duration.zero, () {
          _showJumpColor();
        });
      } else {
        if ((widget.chatModel.jumpMsgID == widget.message.msgID) &&
            (widget.message.msgID?.isNotEmpty ?? false)) {
          widget.clearJump();
        }
      }
    }

    final defaultStyle = widget.isFromSelf
        ? (theme.chatMessageItemFromSelfBgColor ??
            theme.lightPrimaryMaterialColor.shade50)
        : (theme.chatMessageItemFromOthersBgColor);

    final backgroundColor = isShowJumpState
        ? const Color.fromRGBO(245, 166, 35, 1)
        : (defaultStyle ?? widget.backgroundColor);

    final LocalCustomDataModel localCustomData = LocalCustomDataModel.fromMap(
        json.decode(
            TencentUtils.checkString(widget.message.localCustomData) ?? "{}"));
    final String? translateText = localCustomData.translatedText;

    final textWithLink = LinkPreviewEntry.getHyperlinksText(translateText ?? "",
        widget.chatModel.chatConfig.isSupportMarkdownForTextMessage,
        onLinkTap: widget.chatModel.chatConfig.onTapLink,
        isUseQQPackage: (widget.chatModel.chatConfig.stickerPanelConfig
                    ?.useTencentCloudChatStickerPackage ??
                true) ||
            widget.isUseDefaultEmoji,
        isUseTencentCloudChatPackage: widget.chatModel.chatConfig
                .stickerPanelConfig?.useTencentCloudChatStickerPackage ??
            true,
        customEmojiStickerList: widget.customEmojiStickerList,
        isEnableTextSelection:
            widget.chatModel.chatConfig.isEnableTextSelection ?? false);

    return TencentUtils.checkString(translateText) != null
        ? GestureDetector(
            onLongPress: () {
              _onOpenToolTip(
                context,
                widget.message,
                widget.chatModel,
                theme,
                null,
              );
            },
            onTapDown: (details) {
              _tapDetails = details;
            },
            child: Container(
              key: _key,
              margin: const EdgeInsets.only(top: 6),
              padding: widget.textPadding ??
                  EdgeInsets.all(isDesktopScreen ? 12 : 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: widget.borderRadius ?? borderRadius,
              ),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If the [elemType] is text message, it will not be null here.
                  // You can render the widget from extension directly, with a [TextStyle] optionally.
                  widget.chatModel.chatConfig.urlPreviewType !=
                          UrlPreviewType.none
                      ? textWithLink!(
                          style: widget.fontStyle ??
                              TextStyle(
                                  fontSize: isDesktopScreen ? 14 : 16,
                                  textBaseline: TextBaseline.ideographic,
                                  height:
                                      widget.chatModel.chatConfig.textHeight))
                      : ExtendedText(translateText!,
                          softWrap: true,
                          style: widget.fontStyle ??
                              TextStyle(
                                  fontSize: isDesktopScreen ? 14 : 16,
                                  height:
                                      widget.chatModel.chatConfig.textHeight),
                          specialTextSpanBuilder: DefaultSpecialTextSpanBuilder(
                            isUseQQPackage: (widget
                                        .chatModel
                                        .chatConfig
                                        .stickerPanelConfig
                                        ?.useTencentCloudChatStickerPackage ??
                                    true) ||
                                widget.isUseDefaultEmoji,
                            isUseTencentCloudChatPackage: widget
                                    .chatModel
                                    .chatConfig
                                    .stickerPanelConfig
                                    ?.useTencentCloudChatStickerPackage ??
                                true,
                            customEmojiStickerList:
                                widget.customEmojiStickerList,
                            showAtBackground: true,
                          )),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0x72282c34),
                        size: 12,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      InkWell(
                        onTap: () {
                          widget.chatModel.hideTranslateText(widget.message);
                        },
                        child: Text(
                          TIM_t("翻译完成"),
                          style: const TextStyle(
                              color: Color(0x72282c34), fontSize: 10),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : const SizedBox(width: 0, height: 0);
  }
}

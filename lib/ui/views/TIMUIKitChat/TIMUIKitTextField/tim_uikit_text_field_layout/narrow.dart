import 'dart:async';
import 'dart:math';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_setting_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/message.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/optimize_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/permission.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitTextField/special_text/DefaultSpecialTextSpanBuilder.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_send_sound_message.dart';
import 'package:tencent_keyboard_visibility/tencent_keyboard_visibility.dart';

GlobalKey<_TIMUIKitTextFieldLayoutNarrowState> narrowTextFieldKey = GlobalKey();

class TIMUIKitTextFieldLayoutNarrow extends StatefulWidget {
  /// sticker panel customization
  final CustomStickerPanel? customStickerPanel;

  final VoidCallback onEmojiSubmitted;
  final Function(int, String) onCustomEmojiFaceSubmitted;
  final Function(String, bool) handleSendEditStatus;
  final VoidCallback backSpaceText;
  final ValueChanged<String> addStickerToText;

  final ValueChanged<String> handleAtText;

  /// Whether to use the default emoji
  final bool isUseDefaultEmoji;

  final TUIChatSeparateViewModel model;

  /// background color
  final Color? backgroundColor;

  /// control input field behavior
  final TIMUIKitInputTextFieldController? controller;

  /// config for more panel
  final MorePanelConfig? morePanelConfig;

  final String languageType;

  final TextEditingController textEditingController;

  /// conversation id
  final String conversationID;

  /// conversation type
  final ConvType conversationType;

  final FocusNode focusNode;

  /// show more panel
  final bool showMorePanel;

  /// hint text for textField widget
  final String? hintText;

  final int? currentCursor;

  final ValueChanged<int?> setCurrentCursor;

  final VoidCallback onCursorChange;

  /// show send audio icon
  final bool showSendAudio;

  final VoidCallback handleSoftKeyBoardDelete;

  /// on text changed
  final void Function(String)? onChanged;

  final V2TimMessage? repliedMessage;

  /// show send emoji icon
  final bool showSendEmoji;

  final String? forbiddenText;

  final VoidCallback onSubmitted;

  final VoidCallback goDownBottom;

  final List<CustomEmojiFaceData> customEmojiStickerList;

  final List<CustomStickerPackage> stickerPackageList;

  const TIMUIKitTextFieldLayoutNarrow(
      {Key? key,
      this.customStickerPanel,
      required this.onEmojiSubmitted,
      required this.onCustomEmojiFaceSubmitted,
      required this.backSpaceText,
      required this.addStickerToText,
      required this.isUseDefaultEmoji,
      required this.languageType,
      required this.textEditingController,
      this.morePanelConfig,
      required this.conversationID,
      required this.conversationType,
      required this.focusNode,
      this.currentCursor,
      required this.setCurrentCursor,
      required this.onCursorChange,
      required this.model,
      this.backgroundColor,
      this.onChanged,
      required this.handleSendEditStatus,
      required this.handleAtText,
      required this.handleSoftKeyBoardDelete,
      this.repliedMessage,
      this.forbiddenText,
      required this.onSubmitted,
      required this.goDownBottom,
      required this.showSendAudio,
      required this.showSendEmoji,
      required this.showMorePanel,
      this.hintText,
      required this.customEmojiStickerList,
      this.controller,
      required this.stickerPackageList})
      : super(key: key);

  @override
  State<TIMUIKitTextFieldLayoutNarrow> createState() =>
      _TIMUIKitTextFieldLayoutNarrowState();
}

class _TIMUIKitTextFieldLayoutNarrowState
    extends TIMUIKitState<TIMUIKitTextFieldLayoutNarrow> {
  final TUISettingModel settingModel = serviceLocator<TUISettingModel>();

  bool showMore = false;
  bool showMoreButton = true;
  bool showSendSoundText = false;
  bool showEmojiPanel = false;
  bool showKeyboard = false;
  Function? setKeyboardHeight;
  double? bottomPadding;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller?.addListener(
        () {
          final actionType = widget.controller?.actionType;
          if (actionType == ActionType.hideAllPanel) {
            hideAllPanel();
          }
        },
      );
    }
  }

  void setSendButton() {
    final value = widget.textEditingController.text;
    if (isWebDevice() || isAndroidDevice()) {
      if (value.isEmpty && showMoreButton != true) {
        setState(() {
          showMoreButton = true;
        });
      } else if (value.isNotEmpty && showMoreButton == true) {
        setState(() {
          showMoreButton = false;
        });
      }
    }
  }

  hideAllPanel() {
    widget.focusNode.unfocus();
    widget.currentCursor == null;
    if (showKeyboard != false || showMore != false || showEmojiPanel != false) {
      setState(() {
        showKeyboard = false;
        showMore = false;
        showEmojiPanel = false;
      });
    }
  }

  Widget _getBottomContainer(TUITheme theme) {
    if (showEmojiPanel) {
      return widget.customStickerPanel != null
          ? widget.customStickerPanel!(
              sendTextMessage: () {
                widget.onEmojiSubmitted();
                setSendButton();
              },
              sendFaceMessage: widget.onCustomEmojiFaceSubmitted,
              deleteText: () {
                widget.backSpaceText();
                setSendButton();
              },
              addText: (int unicode) {
                final newText = String.fromCharCode(unicode);
                widget.addStickerToText(newText);
                setSendButton();
                // handleSetDraftText();
              },
              addCustomEmojiText: ((String singleEmojiName) {
                String? emojiName = singleEmojiName.split('.png')[0];
                if (widget.isUseDefaultEmoji &&
                    widget.languageType == 'zh' &&
                    TUIKitStickerConstData.emojiMapList[emojiName] != null &&
                    TUIKitStickerConstData.emojiMapList[emojiName] != '') {
                  emojiName = TUIKitStickerConstData.emojiMapList[emojiName];
                }
                final newText = '[$emojiName]';
                widget.addStickerToText(newText);
                setSendButton();
              }),
              defaultCustomEmojiStickerList: widget.isUseDefaultEmoji
                  ? TUIKitStickerConstData.emojiList
                  : [])
          : StickerPanel(
              isWideScreen: false,
              sendTextMsg: () {
                widget.onEmojiSubmitted();
                setSendButton();
              },
              sendFaceMsg: widget.onCustomEmojiFaceSubmitted,
              deleteText: () {
                widget.backSpaceText();
                setSendButton();
              },
              addText: (int unicode) {
                final newText = String.fromCharCode(unicode);
                widget.addStickerToText(newText);
                setSendButton();
                // handleSetDraftText();
              },
              addCustomEmojiText: ((String singleEmojiName) {
                String? emojiName = singleEmojiName.split('.png')[0];
                if (widget.isUseDefaultEmoji &&
                    widget.languageType == 'zh' &&
                    TUIKitStickerConstData.emojiMapList[emojiName] != null &&
                    TUIKitStickerConstData.emojiMapList[emojiName] != '') {
                  emojiName = TUIKitStickerConstData.emojiMapList[emojiName];
                }
                final newText = '[$emojiName]';
                widget.addStickerToText(newText);
                setSendButton();
              }),
              customStickerPackageList: widget.stickerPackageList,
              lightPrimaryColor: theme.lightPrimaryColor);
    }

    if (showMore) {
      return MorePanel(
          morePanelConfig: widget.morePanelConfig,
          conversationID: widget.conversationID,
          conversationType: widget.conversationType);
    }

    return const SizedBox(height: 0);
  }

  double _getBottomHeight() {
    if (showKeyboard) {
      final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      double originHeight = settingModel.keyboardHeight;
      if (currentKeyboardHeight != 0) {
        if (currentKeyboardHeight >= originHeight) {
          originHeight = currentKeyboardHeight;
        }
        if (setKeyboardHeight != null) {
          setKeyboardHeight!(currentKeyboardHeight);
        }
      }
      final height = originHeight != 0 ? originHeight : currentKeyboardHeight;
      return height;
    } else if (showMore || showEmojiPanel) {
      return 248.0 + (bottomPadding ?? 0.0);
    } else if (widget.textEditingController.text.length >= 46 &&
        showKeyboard == false) {
      return 25 + (bottomPadding ?? 0.0);
    } else {
      return bottomPadding ?? 0;
    }
  }

  _openMore() {
    if (!showMore) {
      widget.focusNode.unfocus();
      widget.setCurrentCursor(null);
    }
    setState(() {
      showKeyboard = false;
      showEmojiPanel = false;
      showSendSoundText = false;
      showMore = !showMore;
    });
  }

  _openEmojiPanel() {
    widget.onCursorChange();
    showKeyboard = showEmojiPanel;
    if (showEmojiPanel) {
      widget.focusNode.requestFocus();
    } else {
      widget.focusNode.unfocus();
    }

    setState(() {
      showMore = false;
      showSendSoundText = false;
      showEmojiPanel = !showEmojiPanel;
    });
  }

  _debounce(
    Function(String text) fun, [
    Duration delay = const Duration(milliseconds: 30),
  ]) {
    Timer? timer;
    return (String text) {
      if (timer != null) {
        timer?.cancel();
      }

      timer = Timer(delay, () {
        fun(text);
      });
    };
  }

  String getAbstractMessage(V2TimMessage message) {
    final String? customAbstractMessage =
        widget.model.abstractMessageBuilder != null
            ? widget.model.abstractMessageBuilder!(message)
            : null;
    return customAbstractMessage ??
        MessageUtils.getAbstractMessageAsync(
            message, widget.model.groupMemberList ?? []);
  }

  _buildRepliedMessage(V2TimMessage? repliedMessage) {
    final haveRepliedMessage = repliedMessage != null;
    if (haveRepliedMessage) {
      final String text =
          "${MessageUtils.getDisplayName(repliedMessage)}:${getAbstractMessage(repliedMessage)}";
      return Container(
        color: widget.backgroundColor ?? hexToColor("f5f5f6"),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hexToColor("8f959e"), fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            InkWell(
              onTap: () {
                widget.model.repliedMessage = null;
              },
              child: Icon(Icons.clear, color: hexToColor("8f959e"), size: 18),
            )
          ],
        ),
      );
    }
    return Container();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;

    setKeyboardHeight ??= OptimizeUtils.debounce((height) {
      settingModel.keyboardHeight = height;
    }, const Duration(seconds: 1));

    final debounceFunc = _debounce((value) {
      if (isWebDevice() || isAndroidDevice()) {
        if (value.isEmpty && showMoreButton != true) {
          setState(() {
            showMoreButton = true;
          });
        } else if (value.isNotEmpty && showMoreButton == true) {
          setState(() {
            showMoreButton = false;
          });
        }
      }
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
      widget.handleAtText(value);
      widget.handleSendEditStatus(value, true);
      final isEmpty = value.isEmpty;
      if (isEmpty) {
        widget.handleSoftKeyBoardDelete();
      }
    }, const Duration(milliseconds: 80));

    final MediaQueryData data = MediaQuery.of(context);
    EdgeInsets padding = data.padding;
    if (bottomPadding == null || padding.bottom > bottomPadding!) {
      bottomPadding = padding.bottom;
    }

    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          _buildRepliedMessage(widget.repliedMessage),
          Container(
            // color: widget.backgroundColor ?? hexToColor("f5f5f6"),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(
                    children: [
                      if (widget.forbiddenText != null)
                        Expanded(
                            child: Container(
                          height: 35,
                          color: theme.weakBackgroundColor,
                          alignment: Alignment.center,
                          child: Text(
                            TIM_t(widget.forbiddenText!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.weakTextColor,
                            ),
                          ),
                        )),
                      if (PlatformUtils().isMobile &&
                          widget.showSendAudio &&
                          widget.forbiddenText == null)
                        InkWell(
                          onTap: () async {
                            showKeyboard = showSendSoundText;
                            if (showSendSoundText) {
                              widget.focusNode.requestFocus();
                            }
                            if (await Permissions.checkPermission(
                              context,
                              Permission.microphone.value,
                              theme,
                            )) {
                              setState(() {
                                showEmojiPanel = false;
                                showMore = false;
                                showSendSoundText = !showSendSoundText;
                              });
                            }
                          },
                          // child: Container(
                          //   width: 48,
                          //   height: 48,
                          //   decoration: ShapeDecoration(
                          //       color: Colors.white,
                          //       shape: const CircleBorder(),
                          //       shadows: [
                          //         BoxShadow(
                          //           color: Colors.black.withOpacity(0.08),
                          //           blurRadius: 5,
                          //           spreadRadius: 1,
                          //           offset: const Offset(0, 3),
                          //         )
                          //       ]),
                          //   alignment: Alignment.center,
                          child: Image.asset(
                            showSendSoundText
                                ? 'images/hello/send_keyboard.png'
                                : 'images/hello/send_voice1.png',
                            package: 'tencent_cloud_chat_uikit',
                            // color: const Color.fromRGBO(68, 68, 68, 1),
                            height: 24,
                            width: 24,
                          ),
                          // ),
                        ),
                      if (widget.forbiddenText == null)
                        const SizedBox(
                          width: 6,
                        ),
                      if (widget.forbiddenText == null)
                        Expanded(
                          // child: Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 0, vertical: 0),
                          //   decoration: BoxDecoration(
                          //     color: hexToColor("F1F0F3"),
                          //     borderRadius: BorderRadius.circular(24),
                          //   ),
                          child: Row(
                            children: [
                              Expanded(
                                child: showSendSoundText
                                    ? SendSoundMessage(
                                        onDownBottom: widget.goDownBottom,
                                        conversationID: widget.conversationID,
                                        conversationType:
                                            widget.conversationType)
                                    : KeyboardVisibility(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            // color: hexToColor("F10000"),
                                            color: Colors.transparent,
                                            border: Border.all(
                                                color: hexToColor("D0D1DB"),
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: ExtendedTextField(
                                              maxLines: 4,
                                              minLines: 1,
                                              focusNode: widget.focusNode,
                                              onChanged: debounceFunc,
                                              onTap: () {
                                                showKeyboard = true;
                                                widget.goDownBottom();
                                                setState(() {
                                                  showEmojiPanel = false;
                                                  showMore = false;
                                                });
                                              },
                                              keyboardType:
                                                  TextInputType.multiline,
                                              textInputAction:
                                                  PlatformUtils().isAndroid
                                                      ? TextInputAction.newline
                                                      : TextInputAction.send,
                                              onEditingComplete: () {
                                                widget.onSubmitted();
                                                if (showKeyboard) {
                                                  widget.focusNode
                                                      .requestFocus();
                                                }
                                                setState(() {
                                                  if (widget
                                                      .textEditingController
                                                      .text
                                                      .isEmpty) {
                                                    showMoreButton = true;
                                                  }
                                                });
                                              },
                                              textAlignVertical:
                                                  TextAlignVertical.top,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  // contentPadding:
                                                  //     EdgeInsets.symmetric(
                                                  //         vertical: 12,
                                                  //         horizontal: 0),
                                                  hintStyle: const TextStyle(
                                                    // fontSize: 10,
                                                    color: Color(0xffAEA4A3),
                                                  ),
                                                  // fillColor: Colors.white,
                                                  // filled: true,
                                                  isDense: true,
                                                  hintText:
                                                      widget.hintText ?? ''),
                                              controller:
                                                  widget.textEditingController,
                                              specialTextSpanBuilder:
                                                  PlatformUtils().isWeb
                                                      ? null
                                                      : DefaultSpecialTextSpanBuilder(
                                                          isUseQQPackage: (widget
                                                                      .model
                                                                      .chatConfig
                                                                      .stickerPanelConfig
                                                                      ?.useTencentCloudChatStickerPackage ??
                                                                  true) ||
                                                              widget
                                                                  .isUseDefaultEmoji,
                                                          isUseTencentCloudChatPackage: widget
                                                                  .model
                                                                  .chatConfig
                                                                  .stickerPanelConfig
                                                                  ?.useTencentCloudChatStickerPackage ??
                                                              true,
                                                          customEmojiStickerList:
                                                              widget
                                                                  .customEmojiStickerList,
                                                          showAtBackground:
                                                              true,
                                                        )),
                                        ),
                                        onChanged: (bool visibility) {
                                          if (showKeyboard != visibility) {
                                            setState(() {
                                              showKeyboard = visibility;
                                            });
                                          }
                                        }),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (widget.showSendEmoji)
                                InkWell(
                                  onTap: () {
                                    onTIMCallback(TIMCallback(
                                        type: TIMCallbackType.INFO,
                                        infoRecommendText: TIM_t("未开放功能"),
                                        infoCode: 6660408));
                                  },
                                  child: PlatformUtils().isWeb
                                      ? Icon(
                                          showEmojiPanel
                                              ? Icons.keyboard_alt_outlined
                                              : Icons.mood_outlined,
                                          color: hexToColor("5c6168"),
                                          size: 32)
                                      : Image.asset(
                                          'images/hello/send_ai1.png',
                                          package: 'tencent_cloud_chat_uikit',
                                          color: const Color(0xff4D4054),
                                          height: 24,
                                          width: 24,
                                        ),
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (widget.showSendEmoji)
                                InkWell(
                                  onTap: () {
                                    _openEmojiPanel();
                                    widget.goDownBottom();
                                  },
                                  child: PlatformUtils().isWeb
                                      ? Icon(
                                          showEmojiPanel
                                              ? Icons.keyboard_alt_outlined
                                              : Icons.mood_outlined,
                                          color: hexToColor("5c6168"),
                                          size: 32)
                                      : Image.asset(
                                          showEmojiPanel
                                              ? 'images/hello/send_keyboard.png'
                                              : 'images/hello/send_face1.png',
                                          package: 'tencent_cloud_chat_uikit',
                                          // color: const Color.fromRGBO(68, 68, 68, 1),
                                          height: 24,
                                          width: 24,
                                        ),
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              if (widget.showMorePanel && showMoreButton)
                                InkWell(
                                  onTap: () {
                                    // model.sendCustomMessage(data: "a", convID: model.currentSelectedConv, convType: model.currentSelectedConvType == 1 ? ConvType.c2c : ConvType.group);
                                    _openMore();
                                    widget.goDownBottom();
                                  },
                                  child: PlatformUtils().isWeb
                                      ? Icon(Icons.add_circle_outline_outlined,
                                          color: hexToColor("5c6168"), size: 32)
                                      : Image.asset(
                                          'images/hello/send_add1.png',
                                          package: 'tencent_cloud_chat_uikit',
                                          // color: const Color.fromRGBO(68, 68, 68, 1),
                                          height: 24,
                                          width: 24,
                                        ),
                                ),
                            ],
                            // ),
                          ),
                        ),
                      if ((isAndroidDevice() || isWebDevice()) &&
                          !showMoreButton)
                        Container(
                          height: 32.0,
                          padding: const EdgeInsets.only(left: 6),
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onSubmitted();
                              if (showKeyboard) {
                                widget.focusNode.requestFocus();
                              }
                              if (widget.textEditingController.text.isEmpty) {
                                setState(() {
                                  showMoreButton = true;
                                });
                              }
                            },
                            child: Text(TIM_t("发送")),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff6E5B7D), // 背景色设置为红色
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // 圆角半径设置为6
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(
                      milliseconds: (showKeyboard && PlatformUtils().isAndroid)
                          ? 200
                          : 340),
                  curve: Curves.fastOutSlowIn,
                  height: max(_getBottomHeight(), 0.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_getBottomContainer(theme)],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

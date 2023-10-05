import 'dart:ui';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitChat/TIMUIKitTextField/special_text/DefaultSpecialTextSpanBuilder.dart';
import 'package:tencent_keyboard_visibility/tencent_keyboard_visibility.dart';

class FullScreenTextField extends StatefulWidget {
  const FullScreenTextField({
    Key? key,
    required this.onChanged,
    required this.onTap,
    required this.onSubmitted,
    required this.hintText,
    required this.textEditingController,
    required this.isUseDefaultEmoji,
    required this.customEmojiStickerList,
     this.chatModel,
  }) : super(key: key);

  final Function(String text) onChanged;
  final Function() onTap;
  final Function() onSubmitted;
  final String hintText;
  final TextEditingController textEditingController;
  final bool isUseDefaultEmoji;
  final List<CustomEmojiFaceData> customEmojiStickerList;
  final TUIChatSeparateViewModel? chatModel;

  @override
  State<FullScreenTextField> createState() => _FullScreenTextFieldState();
}

class _FullScreenTextFieldState extends State<FullScreenTextField> {
  bool showKeyboard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 24,
                  height: 24,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xff1b1b1b),
                  ),
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Color(0xFFE8E8E8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: KeyboardVisibility(
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Color(0xFFB8B8B8),
                    ),
                    child: ExtendedTextField(
                      autofocus: true,
                      maxLines: showKeyboard ? 16 : null,
                      minLines: 1,
                      selectionHeightStyle: BoxHeightStyle.max,
                      onChanged: widget.onChanged,
                      onTap: widget.onTap,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onEditingComplete: widget.onSubmitted,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          // fontSize: 10,
                          color: Color(0xffAEA4A3),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        isDense: true,
                        hintText: widget.hintText ?? '',
                      ),
                      controller: widget.textEditingController,
                      specialTextSpanBuilder: DefaultSpecialTextSpanBuilder(
                        isUseQQPackage: (widget
                            .chatModel
                            ?.chatConfig
                            .stickerPanelConfig
                            ?.useTencentCloudChatStickerPackage ??
                            true) ||
                            widget.isUseDefaultEmoji,
                        isUseTencentCloudChatPackage: widget
                            .chatModel
                            ?.chatConfig
                            .stickerPanelConfig
                            ?.useTencentCloudChatStickerPackage ??
                            true,
                        customEmojiStickerList: widget.customEmojiStickerList,
                        showAtBackground: true,
                      ),
                    ),
                  ),
                  onChanged: (bool visibility) {
                    if (showKeyboard != visibility) {
                      setState(() {
                        showKeyboard = visibility;
                      });
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

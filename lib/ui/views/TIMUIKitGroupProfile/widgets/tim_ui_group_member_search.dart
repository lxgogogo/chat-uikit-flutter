import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/optimize_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_input.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupMemberSearchTextField extends TIMUIKitStatelessWidget {
  final Function(String text) onTextChange;
  GroupMemberSearchTextField({Key? key, required this.onTextChange})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final isDesktopScreen =
        TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;
    final FocusNode focusNode = FocusNode();

    var debounceFunc = OptimizeUtils.debounce(
        (text) => onTextChange(text), const Duration(milliseconds: 300));

    return Container(
      color: Colors.white,
      child: Column(children: [
        if (!isDesktopScreen)
          Container(
            decoration: BoxDecoration(
              // borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              // border: Border.all(color: theme.weakBackgroundColor!, width: 12),
              /////////// 版本迁移 ///////////
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 30,
                ),
              ],
              /////////// 版本迁移 ///////////
            ),
            /////////// 版本迁移 ///////////
            margin: const EdgeInsets.only(left: 15, top: 20, right: 15),
            padding: const EdgeInsets.only(right: 12),
            /////////// 版本迁移 ///////////
            child: TextField(
              /////////// 版本迁移 ///////////
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F1F1F),
              ),
              /////////// 版本迁移 ///////////
              onChanged: debounceFunc,
              decoration: InputDecoration(
                hintText: TIM_t("搜索"),
                /////////// 版本迁移 ///////////
                filled: false,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF808080),
                ),
                /////////// 版本迁移 ///////////
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        /////////// 版本迁移 ///////////
        if (isDesktopScreen) ...[
          TIMUIKitSearchInput(
            prefixIcon: Icon(
              Icons.search,
              size: 16,
              color: hexToColor("979797"),
            ),
            onChange: (text) {
              focusNode.requestFocus();
              debounceFunc(text);
            },
            focusNode: focusNode,
          ),
          Divider(
            thickness: 1,
            indent: 74,
            endIndent: 0,
            color: theme.weakBackgroundColor,
            height: 0,
          ),
        ],
        /////////// 版本迁移 ///////////
      ]),
    );
  }
}

// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/screen_utils.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class TIMUIKitTranslateTooltip extends StatefulWidget {
  final V2TimMessage message;

  final VoidCallback onCloseTooltip;

  final TUIChatSeparateViewModel model;

  const TIMUIKitTranslateTooltip({
    Key? key,
    required this.model,
    required this.message,
    required this.onCloseTooltip,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitTranslateTooltipState();
}

class TIMUIKitTranslateTooltipState
    extends TIMUIKitState<TIMUIKitTranslateTooltip> {
  Widget ItemInkWell({Widget? child, GestureTapCallback? onTap}) {
    return SizedBox(
      width: 40,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(bottom: 6, top: 6),
          child: child,
        ),
      ),
    );
  }

  _buildLongPressTipItem(TUITheme theme, TUIChatSeparateViewModel model) {
    final defaultTipsList = [
      {
        "label": TIM_t("复制"),
        "id": "copyMessage",
        "icon": "images/copy_message.png"
      },
      {
        "label": TIM_t("取消"),
        "id": "hideMessage",
        "icon": "images/hide_message.png"
      },
    ];
    return defaultTipsList
        .map(
          (item) => Material(
            color: Colors.white,
            child: ItemInkWell(
              onTap: () {
                _onTap(item["id"]!, model);
              },
              child: Column(
                children: [
                  Image.asset(
                    item["icon"]!,
                    package: 'tencent_cloud_chat_uikit',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    item["label"]!,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: theme.darkTextColor,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  _onTap(String operation, TUIChatSeparateViewModel model) async {
    switch (operation) {
      case "copyMessage":
        try {
          final LocalCustomDataModel localCustomData =
              LocalCustomDataModel.fromMap(json.decode(
                  TencentUtils.checkString(widget.message.localCustomData) ??
                      "{}"));
          final String? translateText = localCustomData.translatedText;

          await Clipboard.setData(ClipboardData(text: translateText ?? ""));
          onTIMCallback(TIMCallback(
              type: TIMCallbackType.INFO,
              infoRecommendText: TIM_t("已复制"),
              infoCode: 6660408));
        } catch (e) {
          print(e);
        }
        break;
      case "hideMessage":
        if (widget.message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
          widget.model.hideTranslateText(widget.message);
        }
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
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: min(MediaQuery.of(context).size.width * 0.7, 350),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    direction: Axis.horizontal,
                    alignment:
                    TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop
                            ? WrapAlignment.spaceAround
                            : WrapAlignment.start,
                    spacing: 4,
                    runSpacing: 16,
                    children: [
                      ..._buildLongPressTipItem(theme, model),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}

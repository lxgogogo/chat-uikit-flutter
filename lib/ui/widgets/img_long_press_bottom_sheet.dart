import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';

class ImgLongPressBottomSheet extends StatefulWidget {
  final VoidCallback scanQRCode;

  const ImgLongPressBottomSheet({
    super.key,
    required this.scanQRCode,
  });

  @override
  _ImgLongPressBottomSheetState createState() =>
      _ImgLongPressBottomSheetState();
}

class _ImgLongPressBottomSheetState extends State<ImgLongPressBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              widget.scanQRCode.call();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.w),
              child: Text(
                // TIM_t("识别图中二维码"),
                'Scan QR code',
                style: TextStyle(
                  fontSize: 16.w,
                  color: const Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

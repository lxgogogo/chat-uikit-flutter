import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/link_preview/common/utils.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/link_preview/models/link_preview_content.dart';

class LinkPreviewWidget extends TIMStatelessWidget {
  final LocalCustomDataModel linkPreview;

  const LinkPreviewWidget({Key? key, required this.linkPreview})
      : super(key: key);

  @override
  Widget timBuild(BuildContext context) {
    if (linkPreview.isLinkPreviewEmpty()) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        if (linkPreview.url != null) {
          LinkUtils.launchURL(context, linkPreview.url!);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (linkPreview.title != null && linkPreview.title!.isNotEmpty)
              Text(
                linkPreview.title!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.0,
                    color: LinkUtils.hexToColor("015fff"),
                    fontWeight: FontWeight.w400),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (linkPreview.image != null && linkPreview.image!.isNotEmpty)
                  Image.network(
                    linkPreview.image!,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                if (linkPreview.description != null &&
                    linkPreview.description!.isNotEmpty)
                  Expanded(
                      child: Text(
                    linkPreview.description!,
                    style: const TextStyle(
                        fontSize: 12.0, color: Color(0xFF999999)),
                        maxLines: 5,overflow: TextOverflow.ellipsis,
                  )),
                if ((linkPreview.description == null ||
                        linkPreview.description!.isEmpty) &&
                    linkPreview.title != null &&
                    linkPreview.title!.isNotEmpty)
                  Expanded(
                      child: Text(
                    linkPreview.title!,
                    style: const TextStyle(
                        fontSize: 12.0, color: Color(0xFF999999)),
                  )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/group/group_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/group_member_list.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class BlockGroupMemberPage extends StatefulWidget {
  final TUIGroupProfileModel model;
  final Function(V2TimGroupMemberFullInfo memberInfo)? onTapMemberItem;

  const BlockGroupMemberPage({
    Key? key,
    required this.model,
    this.onTapMemberItem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BlockGroupMemberPageState();
}

class _BlockGroupMemberPageState extends TIMUIKitState<BlockGroupMemberPage> {
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  List<V2TimGroupMemberFullInfo?>? searchMemberList;

  @override
  initState() {
    searchMemberList = widget.model.groupMemberList;
    super.initState();
  }

  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMember(
      V2TimGroupMemberSearchParam searchParam) async {
    final res =
        await _groupServices.searchGroupMembers(searchParam: searchParam);

    if (res.code == 0) {}
    return res;
  }

  handleSearchGroupMembers(String searchText, context) async {
    final res = await searchGroupMember(V2TimGroupMemberSearchParam(
      keywordList: [searchText],
      groupIDList: [widget.model.groupID],
    ));

    if (res.code == 0) {
      List<V2TimGroupMemberFullInfo?> list = [];
      final searchResult = res.data!.groupMemberSearchResultItems!;
      searchResult.forEach((key, value) {
        if (value is List) {
          for (V2TimGroupMemberFullInfo item in value) {
            list.add(item);
          }
        }
      });
      searchMemberList = list;
    }

    setState(() {
      searchMemberList = isSearchTextExist(searchText)
          ? searchMemberList
          : widget.model.groupMemberList;
    });
  }

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
  }

  handleRole(groupMemberList) {
    return groupMemberList
            ?.where((value) =>
                value?.role ==
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER)
            .toList() ??
        [];
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            TIM_t("拉黑群成员"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          backgroundColor: const Color(0xff1f1f1f),
          iconTheme: const IconThemeData(
            color: Colors.white,
          )),
      body: GroupProfileMemberList(
          memberList: handleRole(searchMemberList ?? []),
          canSlideDelete: false,
          onTapMemberItem: (memberInfo, tapDownDetails) {
            widget.onTapMemberItem?.call(memberInfo);
          },
          touchBottomCallBack: () {},
          customTopArea: GroupMemberSearchTextField(
            onTextChange: (text) => handleSearchGroupMembers(text, context),
          )),
    );
  }
}

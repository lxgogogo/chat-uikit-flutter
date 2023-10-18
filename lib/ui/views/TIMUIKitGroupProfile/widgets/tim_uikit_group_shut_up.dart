import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable_for_tencent_im/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/group/group_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_member_search.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/avatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/widgets/group_member_list.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupProfileGroupShutUp extends TIMUIKitStatelessWidget {
  GroupProfileGroupShutUp({Key? key}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    final model = Provider.of<TUIGroupProfileModel>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupProfileGroupShutUpPage(
                      model: model,
                    )));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(
                    color: theme.weakDividerColor ??
                        CommonColor.weakDividerColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TIM_t("禁言"),
              style: TextStyle(fontSize: 16, color: theme.darkTextColor),
            ),
            Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
          ],
        ),
      ),
    );
  }
}

/// 禁言设置页面
class GroupProfileGroupShutUpPage extends StatefulWidget {
  final TUIGroupProfileModel model;

  const GroupProfileGroupShutUpPage({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupProfileGroupShutUpPageState();
}

class _GroupProfileGroupShutUpPageState
    extends TIMUIKitState<GroupProfileGroupShutUpPage> {
  int? serverTime;

  @override
  void initState() {
    super.initState();
    getServerTime();
  }

  void getServerTime() async {
    final res = await TencentImSDKPlugin.v2TIMManager.getServerTime();
    setState(() {
      serverTime = res.data;
    });
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: widget.model),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final memberList =
              Provider.of<TUIGroupProfileModel>(context).groupMemberList;
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          final isAllMuted = widget.model.groupInfo?.isAllMuted ?? false;
          List<V2TimGroupMemberFullInfo?> temp = memberList.where((element) => (serverTime != null ? (element?.muteUntil ?? 0) > serverTime! : false)).map((e) {
            return e;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                TIM_t("禁言"),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 12, left: 16, bottom: 12, right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.weakDividerColor ??
                                  CommonColor.weakDividerColor))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TIM_t("全员禁言"),
                        style:
                            TextStyle(fontSize: 16, color: theme.darkTextColor),
                      ),
                      CupertinoSwitch(
                        value: isAllMuted,
                        onChanged: (value) async {
                          widget.model.setMuteAll(value);
                        },
                        activeColor: const Color(0xFFB2F417),
                      )
                    ],
                  ),
                ),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                //   color: theme.weakBackgroundColor,
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //     TIM_t("全员禁言开启后，只允许群主和管理员发言。"),
                //     style: TextStyle(fontSize: 12, color: theme.weakTextColor),
                //   ),
                // ),
                if (!isAllMuted)
                  InkWell(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: theme.weakDividerColor ??
                                          CommonColor.weakDividerColor))),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(TIM_t("添加需要禁言的群成员"))
                            ],
                          ),
                        )),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupShutUpMemberPage(
                                    groupID: widget.model.groupID,
                                    memberList: memberList.where((element) {
                                      final isMute = (serverTime != null
                                          ? (element?.muteUntil ?? 0) >
                                              serverTime!
                                          : false);
                                      final isMember = element!.role ==
                                          GroupMemberRoleType
                                              .V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                                      return !isMute && isMember;
                                    }).toList(),
                                    onTapMemberItem: (member) async {
                                      final userID = member.userID;
                                      if (userID.isNotEmpty) {
                                        widget.model.muteGroupMember(
                                            userID, true, serverTime);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  )));
                    },
                  ),
                if (!isAllMuted && temp.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: temp.length,
                      itemBuilder: (BuildContext context, int index) {
                        var e = temp[index];
                        return _buildListItem(
                            context,
                            e!,
                            callback: (){
                              widget.model.muteGroupMember(e.userID, false, serverTime);
                            }
                        );
                      },
                    ),
                  )
              ],
            ),
          );
        });
  }
}

_getShowName(V2TimGroupMemberFullInfo? item) {
  final friendRemark = item?.friendRemark ?? "";
  final nameCard = item?.nameCard ?? "";
  final nickName = item?.nickName ?? "";
  final userID = item?.userID ?? "";
  return friendRemark.isNotEmpty
      ? friendRemark
      : nameCard.isNotEmpty
          ? nameCard
          : nickName.isNotEmpty
              ? nickName
              : userID;
}

Widget _buildListItem(BuildContext context, V2TimGroupMemberFullInfo memberInfo,{Function? callback}) {
  final theme = Provider.of<TUIThemeViewModel>(context).theme;
  return Container(
      color: Colors.white,
    child: Column(children: [
      ListTile(
        tileColor: Colors.black,
        leading: SizedBox(
          width: 36,
          height: 36,
          child: Avatar(
            faceUrl: memberInfo.faceUrl ?? "",
            showName: _getShowName(memberInfo),
            type: 2,
          ),
        ),
        title: Row(
          children: [
            Text(_getShowName(memberInfo),
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        trailing: GestureDetector(
          onTap: (){
            callback!();
          },
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(10.w)
            ),
            padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 5.w),
            child: Text(TIM_t("删除"),style: const TextStyle(color: Color(0xFFB2F417)),),
          ),
        ),
        onTap: () {},
      ),
      Divider(
          thickness: 1,
          indent: 74,
          endIndent: 0,
          color: theme.weakDividerColor,
          height: 0)
    ]),
  );
}

/// 添加管理员
class GroupShutUpMemberPage extends StatefulWidget {
  final String groupID;
  final List<V2TimGroupMemberFullInfo?> memberList;
  final Function(V2TimGroupMemberFullInfo memberInfo)? onTapMemberItem;

  const GroupShutUpMemberPage({
    Key? key,
    required this.groupID,
    required this.memberList,
    this.onTapMemberItem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupShutUpMemberPageState();
}

class _GroupShutUpMemberPageState extends TIMUIKitState<GroupShutUpMemberPage> {
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  List<V2TimGroupMemberFullInfo?>? groupMemberList;
  List<V2TimGroupMemberFullInfo?>? searchMemberList;

  @override
  void initState() {
    groupMemberList = widget.memberList;
    searchMemberList = groupMemberList;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      groupIDList: [widget.groupID],
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
      searchMemberList =
          isSearchTextExist(searchText) ? searchMemberList : groupMemberList;
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
          TIM_t("设置禁言"),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: GroupProfileMemberList(
        memberList: handleRole(searchMemberList ?? []),
        canSlideDelete: false,
        touchBottomCallBack: () {
          // Get all by once, unnecessary to load more
        },
        customTopArea: GroupMemberSearchTextField(
          onTextChange: (text) => handleSearchGroupMembers(text, context),
        ),
        onTapMemberItem: (_, __) => widget.onTapMemberItem?.call(_),
      ),
    );
  }
}

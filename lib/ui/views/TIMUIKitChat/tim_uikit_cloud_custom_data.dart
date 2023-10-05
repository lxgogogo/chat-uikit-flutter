import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';

/////////// 版本迁移 ///////////
class MessageRewardData {
  MessageRewardData({
    this.recordList = const [],
  });

  final List<RewardRecord> recordList;

  factory MessageRewardData.fromJson(Map messageReply) => MessageRewardData(
        recordList: (messageReply["recordList"] as List<dynamic>? ?? [])
            .map((e) => RewardRecord.fromJson(e as Map<String, dynamic>? ?? {}))
            .toList(),
      );
}

class RewardRecord {
  RewardRecord({
    this.userID = '',
    this.count = 0,
  });

  final String userID;
  int count;

  factory RewardRecord.fromJson(Map messageReply) => RewardRecord(
        userID: messageReply["userID"] as String? ?? '',
        count: messageReply["count"] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'count': count,
      };
}
/////////// 版本迁移 ///////////

class MessageRepliedData {
  late String messageAbstract;
  late String messageSender;
  late String messageID;

  MessageRepliedData.fromJson(Map messageReply) {
    messageAbstract = messageReply["messageAbstract"];
    messageSender = messageReply["messageSender"] ?? "";
    messageID = messageReply["messageID"];
  }
}

class RepliedMessageAbstract {
  final int? elemType;
  final String? msgID;
  final int? timestamp;
  final String? seq;
  final String? summary;

  RepliedMessageAbstract(
      {this.elemType, this.msgID, this.timestamp, this.seq, this.summary});

  // fromJson constructor
  RepliedMessageAbstract.fromJson(Map<String, dynamic> json)
      : elemType = json['elemType'],
        msgID = json['msgID'],
        timestamp = json['timestamp'],
        seq = json['seq'],
        summary = json['summary'];

  // toJson function
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'elemType': elemType,
      'msgID': msgID,
      'timestamp': timestamp,
      'seq': seq,
    };
  }

  // isNotEmpty method
  bool get isNotEmpty =>
      TencentUtils.checkString(msgID) != null &&
      TencentUtils.checkString(timestamp.toString()) != null &&
      TencentUtils.checkString(seq) != null;
}

class CloudCustomData {
  Map<String, dynamic>? messageReply;
  Map<String, dynamic>? messageReaction = {};
  Map<String, dynamic>? messageReward = {};

  CloudCustomData.fromJson(Map jsonMap) {
    messageReply = jsonMap["messageReply"];
    messageReaction = jsonMap["messageReaction"] ?? {};
    messageReward = jsonMap["messageReward"] ?? {};
  }

  Map<String, Map?> toMap() {
    final Map<String, Map?> data = {};
    if (messageReply != null) {
      data['messageReply'] = messageReply;
    }
    data['messageReaction'] = messageReaction ?? {};
    data['messageReward'] = messageReward ?? {};
    return data;
  }

  CloudCustomData();
}

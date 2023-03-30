import 'package:json_annotation/json_annotation.dart';
import 'package:kspot_002/models/upload_model.dart';
import 'package:kspot_002/models/user_model.dart';
import 'etc_model.dart';
import '../utils/utils.dart';

part 'chat_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class ChatModel {
  String  id;
  int     status;   // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  int     action;   // 액션 (0:normal, 1:room in, 2:room exit 3:room s exit)
  String  desc;
  String  roomId;
  String  senderId;
  String  senderName;
  String  senderPic;
  DateTime updateTime;     // 수정 시간
  DateTime createTime;     // 생성 시간

  List<String>? openList;
  List<String>? thumbList;
  List<UploadFileModel>? fileData;

  @JsonKey(ignore: true)
  DateTime? cacheTime;    // for local cache refresh time..

  ChatModel({
    required this.id,
    required this.status,
    required this.action,
    required this.desc,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderPic,
    required this.updateTime,
    required this.createTime,

    this.openList,
    this.thumbList,
    this.fileData,
  });
  factory ChatModel.fromJson(JSON json) => _$ChatModelFromJson(json);
  JSON toJson() => _$ChatModelToJson(this);
}

class ChatRoomModelEx extends ChatRoomModel {
  ChatRoomModelEx.create(String userId, int type) : super(
    id: '',
    status: 1,
    type: type,
    title: '',
    password: '',
    pic: '',
    lastMessage: '',
    userId: userId,
    updateTime: DateTime(0),
    createTime: DateTime(0),
    memberList: [],
    memberData: [],
  );
}


@JsonSerializable(
  explicitToJson: true,
)
class ChatRoomModel {
  String  id;
  int     status;
  int     type;     // 0: public  1: private
  String  title;
  String  password;
  String  pic;
  String  lastMessage;
  String  userId;
  DateTime updateTime;     // 수신 시간
  DateTime createTime;     // 수신 시간
  List<String> memberList;      // 채팅 맴버 ID 목록 (for Search)
  List<MemberData> memberData;  // 채팅 맴버 목록

  String? groupId;        // 이벤트 그룹 Id
  String? country;
  String? countryState;
  List<NoticeModel>? noticeData;  // 채팅 맴버 목록
  List<BanData>? banData;          // 밴 맴버 목록

  @JsonKey(ignore: true)
  DateTime? cacheTime;    // for local cache refresh time..

  ChatRoomModel({
    required this.id,
    required this.status,
    required this.type,
    required this.title,
    required this.password,
    required this.pic,
    required this.lastMessage,
    required this.userId,
    required this.updateTime,
    required this.createTime,
    required this.memberList,
    required this.memberData,

    this.groupId,
    this.country,
    this.countryState,
    this.noticeData,
    this.banData,
  });
  factory ChatRoomModel.fromJson(JSON json) => _$ChatRoomModelFromJson(json);
  JSON toJson() => _$ChatRoomModelToJson(this);

  //------------------------------------------------------------------------------------------------------
  //  ManagerData
  //

  get getMemberDataMap {
    JSON result = {};
    for (var item in memberData) {
      result[item.id] = item.toJson();
    }
    return result;
  }

  get noticeDataMap {
    JSON result = {};
    if (noticeData != null) {
      for (var item in noticeData!) {
        result[item.id] = item.toJson();
      }
    }
    return result;
  }

  get noticeSortedList {
    if (noticeData == null) return [];
    for (var item in noticeData!) {
      LOG('--> noticeSortedList index [${item.id}] : ${item.index}');
    }
    noticeData!.sort((a, b) => a.index > b.index ? 1 : -1);
    return noticeData!;
  }

  checkBanUser(String userId) {
    if (banData == null) return false;
    for (var item in banData!) {
      if (item.id == userId) return true;
    }
    return false;
  }

  removeMemberData(String key) {
    for (var item in memberData) {
      if (item.id.toLowerCase() == key.toLowerCase()) {
        memberData.remove(item);
        return true;
      }
    }
    return false;
  }

  setMemberDataMap(JSON map) {
    memberData.clear();
    memberList.clear();
    if (map.isNotEmpty) {
      for (var item in map.entries) {
        memberData.add(MemberData.fromJson(item.value));
        memberList.add(item.value['id']);
      }
    }
    return memberData;
  }

  addMemberData(JSON member) {
    final addItem = MemberData.fromJson(member);
    for (var item in memberData) {
      if (item.id == addItem.id) {
        memberData.remove(item);
        memberList.remove(item.id);
        break;
      }
    }
    memberData.add(addItem);
    memberList.add(addItem.id);
    return memberData;
  }
}

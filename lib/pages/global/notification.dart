import 'package:bunny/pages/global/open_chat.dart';
import 'package:bunny/utils/extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/models/device.dart';
import 'package:sharebox/models/message.dart';
import 'package:sharebox/models/transfer.dart';
import 'package:sharebox/providers/courier/courier.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/screen.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/modal_widget.dart';
import 'package:sharebox/widgets/widget.dart';

class CustomNotification extends StatefulWidget {
  const CustomNotification({
    super.key,
  });
  _SlideInNotificationState createState() => _SlideInNotificationState();
}

class _SlideInNotificationState extends State<CustomNotification>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<Offset>> _animations = {};

  final ValueNotifier<Map<String, bool>> _isExpanded = ValueNotifier({});
  final int maxMessage = 3;

  final Map<String, Device> _devices = {
    "0": Device(
        device: BaseDevice()
          ..physicsId = "0"
          ..name = "",
        ip: "",
        port: 0,
        pk: ""),
  };
  final Map<String, List<MessageModel>> _messages = {};

  List<int> getMessageIds(String deviceId) {
    if (!_messages.containsKey(deviceId)) {
      return [];
    }
    return _messages[deviceId]!.map((m) => m.id).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _isExpanded.dispose();
    super.dispose();
  }

  Animation<Offset> createAnimation(MessageModel message) {
    if (!_controllers.containsKey(message.id)) {
      _controllers[message.id] = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      );
      _animations[message.id] = Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
          parent: _controllers[message.id]!, curve: Curves.easeInOut));

      showNotification(message.id);
    }
    return _animations[message.id]!;
  }

  void showNotification(int id) {
    _controllers[id]?.forward();
  }

  Future<void> hideNotification(Device device, int id,
      [bool batch = false]) async {
    await _controllers[id]?.reverse();
    _controllers[id]?.dispose();
    _controllers.remove(id);
    if (!batch) {
      final bloc = context.read<CourierBloc>();
      bloc.add(NotificationDeleteEvent(device, [id]));
    }
  }

  Future<void> clearByDevice(Device device) async {
    final ids = getMessageIds(device.physicsId);
    final bloc = context.read<CourierBloc>();
    for (var id in ids) {
      await hideNotification(device, id, true);
    }
    bloc.add(NotificationDeleteEvent(device, ids));
    _messages.remove(device.physicsId);
    _isExpanded.value.remove(device.physicsId);
  }

  void openChatBox(Device device) {
    final bloc = context.read<CourierBloc>();
    final clientCubit = bloc.getClientCubit(device);
    if (clientCubit != null) {
      openChatbox(context, clientCubit, [device]);
    }
    clearByDevice(device);
  }

  Widget buildPanel(Device device, List<MessageModel> messages) {
    final len = messages.length;
    final len4height = len > maxMessage ? 1 : len;
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, value, child) {
        final isExpanded = value[device.physicsId] ?? len == 1 ? true : false;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (len == 1 || value[device.physicsId] == true) return;
            _isExpanded.value[device.physicsId] = !isExpanded;
            final newValue = Map<String, bool>.from(value);
            newValue[device.physicsId] = !isExpanded;
            _isExpanded.value = newValue;
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 350,
            height: isExpanded ? len4height * 80 : 80 + len4height * 8,
            margin: EdgeInsets.only(right: 2),
            child: len > maxMessage
                ? SlideTransition(
                    position: createAnimation(messages.first), //.._animation,
                    child: HoveringWidget(
                        onTap: () {
                          openChatBox(device);
                        },
                        colorHover: Colors.transparent,
                        alignment: Alignment.topLeft,
                        top: 0,
                        left: 0,
                        hover: ClearButton(
                          onTap: () {
                            clearByDevice(device);
                          },
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, left: 5),
                          child: NotificationCard.number(
                            device: device,
                            number: len,
                            isLatest: true,
                            time: messages.last.time,
                          ),
                        )),
                  )
                : Stack(
                    children: [
                      for (int i = len - 1; i >= 0; i--)
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          top: isExpanded ? i * 80 : i * 8,
                          left: 0,
                          right: 0,
                          child: SlideTransition(
                            position:
                                createAnimation(messages[i]), //.._animation,
                            child: HoveringWidget(
                              onTap: isExpanded
                                  ? () {
                                      openChatBox(device);
                                    }
                                  : null,
                              colorHover: Colors.transparent,
                              alignment: Alignment.topLeft,
                              top: 0,
                              left: 0,
                              hover: (isExpanded || i == 0)
                                  ? ClearButton(
                                      modality: !isExpanded,
                                      onTap: () {
                                        if (!isExpanded) {
                                          clearByDevice(device);
                                        } else {
                                          hideNotification(
                                              device,
                                              _messages[device.physicsId]![i]
                                                  .id);
                                        }
                                      },
                                    )
                                  : null,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: 5, left: 5).copyWith(
                                  right: isExpanded ? 0 : i * 8,
                                ),
                                child: NotificationCard(
                                  device: device,
                                  message: messages[i],
                                  isLatest: i == 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourierBloc, CourierState>(
      builder: (context, state) {
        var deviceId = "0";
        if (state is CourierMessageDeleted) {
          if (state.device != null) {
            deviceId = state.device!.physicsId;
            _messages[deviceId]?.removeWhere((e) => state.ids.contains(e.id));
            if (_messages[deviceId] != null && _messages[deviceId]!.isEmpty) {
              _messages.remove(deviceId);
            }
          }
        } else if (state is CourierMessageAppended) {
          if (state.device != null) {
            deviceId = state.device!.physicsId;
            if (!_devices.containsKey(deviceId)) {
              _devices[deviceId] = state.device!;
            }
          }
          if (!_messages.containsKey(deviceId)) {
            _messages[deviceId] = state.messages
                .whereType<MessageModel>()
                // .where((message) => (message is MessageModel))
                .toList();
          } else {
            _messages[deviceId]!
                .insertAll(0, state.messages.whereType<MessageModel>());
          }
        }
        List<Widget> widgets = [];
        if (_messages.isEmpty) {
          return SizedBox.shrink();
        }
        _messages.forEach(
          (key, value) {
            if (_devices[key] != null) {
              widgets.add(buildPanel(_devices[key]!, value));
            }
          },
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                    ScreenHelper.getScreenSizeWithBuild(context).height - 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        );
      },
      buildWhen: (previous, current) {
        return current is CourierMessageAppended ||
            current is CourierMessageDeleted;
      },
      listener: (context, state) {
        logger.d(">>>>>>>>. ${state}");
        if (state is CourierReceivedItem) {
          if (state.transferState.status == TransferStatus.reject) {
            MyModal.toast(
              "ask".tr(gender: "rejected"),
            );
          }
        }
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final bool isLatest;
  final MessageModel? message;
  final Device device;
  final int? number;
  final int? time;
  const NotificationCard({
    super.key,
    this.isLatest = false,
    this.message,
    required this.device,
    this.number,
    this.time,
  });

  const NotificationCard.number({
    super.key,
    required this.number,
    required this.isLatest,
    required this.device,
    required this.time,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), // 圆角
        boxShadow: [
          BoxShadow(
              color:
                  Color.fromRGBO(0, 0, 0, .2), //.withValues(alpha:0.2), // 阴影颜色
              blurRadius: 2, // 模糊半径
              spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          device.type.icon,
          const SizedBox(width: 12), // 间距
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    Text(
                      Utils.format(time != null ? time! : message!.time,
                          format: "HH:mm"),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                Text(
                  number != null ? "有$number条信息." : message!.message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                // SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClearButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool modality;

  const ClearButton({
    super.key,
    required this.onTap,
    this.modality = true,
  });

  @override
  _ClearButtonState createState() => _ClearButtonState();
}

class _ClearButtonState extends State<ClearButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: _isHovered && widget.modality
              ? const EdgeInsets.symmetric(vertical: 3, horizontal: 8)
              : const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(
                      0, 0, 0, .2), //.withValues(alpha:0.2), // 阴影颜色
                  blurRadius: 2, // 模糊半径
                  spreadRadius: 2),
            ],
          ),
          child: _isHovered && widget.modality
              ? Text(
                  "全部清除",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                )
              : Img.image(
                  "delete.png",
                  size: Size(14, 14),
                  color: Colors.black54,
                ),
        ),
      ),
    );
  }
}

// import 'package:bunny/constants/colors.dart';
// import 'package:bunny/models/record.dart';
// import 'package:bunny/pages/recording/form.dart';
// import 'package:bunny/providers/cubit/record_cubit.dart';
// import 'package:bunny/providers/cubit/record_state.dart';
// import 'package:sharebox/utils/log.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../widgets/button.dart';
// import '../../widgets/dot.dart';

// class RecordingPage extends StatelessWidget {
//   const RecordingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     logger.d("build records.....");
//     return Row(
//       children: <Widget>[
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     CustomButton(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                       borderRadius: 5,
//                       color: Color.fromRGBO(49, 108, 244, 10),
//                       onTap: () {
//                         showDialog(
//                           // barrierDismissible: false,
//                           barrierColor: Colors.transparent,
//                           context: context,
//                           builder: (BuildContext dialogContext) {
//                             RecordCubit recordingCubit =
//                                 BlocProvider.of<RecordCubit>(context);
//                             return Dialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(10), // 设置圆角为0
//                               ),
//                               shadowColor: Colors.grey,
//                               backgroundColor: Skin.white,
//                               child: Container(
//                                   width: 640,
//                                   padding: EdgeInsets.all(40),
//                                   child: RecordingDialog(
//                                     rc: recordingCubit,
//                                   )),
//                             );
//                           },
//                         );
//                       },
//                       icon: Icon(
//                         Icons.add_circle_outline,
//                         color: Colors.white,
//                         size: 22.0,
//                         // semanticLabel: 'Text to announce in accessibility modes',
//                       ),
//                       child: Text(
//                         "添加主播",
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     CustomButton(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                       borderRadius: 5,
//                       onTap: () {
//                         RecordCubit recordingCubit =
//                             BlocProvider.of<RecordCubit>(context);
//                         recordingCubit.loadRecord();
//                       },
//                       icon: Icon(
//                         Icons.play_circle_outline,
//                         color: Colors.black54,
//                         size: 22.0,
//                         // semanticLabel: 'Text to announce in accessibility modes',
//                       ),
//                       child: Text(
//                         "开始录制",
//                         style: TextStyle(color: Colors.black54, fontSize: 12),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     CustomButton(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                       borderRadius: 5,
//                       icon: Icon(
//                         Icons.stop_circle_outlined,
//                         color: Colors.black54,
//                         size: 22.0,
//                         // semanticLabel: 'Text to announce in accessibility modes',
//                       ),
//                       child: Text(
//                         "停止录制",
//                         style: TextStyle(color: Colors.black54, fontSize: 12),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     CustomButton(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                       borderRadius: 5,
//                       color: Color.fromRGBO(203, 68, 74, 10),
//                       icon: Icon(
//                         Icons.remove_circle_outline,
//                         color: Colors.white,
//                         size: 22.0,
//                         // semanticLabel: 'Text to announce in accessibility modes',
//                       ),
//                       child: Text(
//                         "删除选中",
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           // color: const Color.fromRGBO(28, 39, 99, 8),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             // BoxShadow(
//                             //   color: Colors.grey.withValues(alpha:0.2),
//                             //   spreadRadius: 1,
//                             //   blurRadius: 3,
//                             // ),
//                           ],
//                         ),
//                         child: BlocBuilder<RecordCubit, RecordState?>(
//                           buildWhen: (previous, current) {
//                             return current is RecordLoaded;
//                           },
//                           builder: (context, state) {
//                             logger.d(">>>>>>>>> $state");
//                             List<Recording> records = [];
//                             if (state is RecordLoaded) {
//                               records = state.records ?? [];
//                             }
//                             return DataTableDemo(data: records);
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DataTableDemo extends StatelessWidget {
//   List<Recording> data = [];

//   DataTableDemo({super.key, required this.data});

//   List<bool> selected = List<bool>.generate(3, (int index) => false);

//   Widget buildButtons({bool? played, bool? favorited}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CustomButton(
//           color: Colors.transparent,
//           onTap: () => {},
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           icon: Icon(
//             color: Colors.black54,
//             size: 22.0,
//             Icons.edit_note_outlined,
//           ),
//           hoverText: "修改资料",
//         ),
//         CustomButton(
//           // borderColor: Colors.amber,
//           color: Colors.transparent,
//           onTap: () => {logger.d("button....")},
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           icon: Icon(
//             color: Colors.black54,
//             size: 22.0,
//             (played != null && played)
//                 ? Icons.stop_circle_outlined
//                 : Icons.play_circle_outline,
//           ),
//           hoverText: "开始录制",
//         ),
//         CustomButton(
//           color: Colors.transparent,
//           onTap: () => {},
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           icon: Icon(
//             color: Colors.black54,
//             size: 22.0,
//             Icons.cancel_outlined,
//           ),
//         ),
//         CustomButton(
//           color: Colors.transparent,
//           onTap: () => {},
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           icon: Icon(
//             color: Colors.black54,
//             size: 22.0,
//             (favorited != null && favorited)
//                 ? Icons.favorite_sharp
//                 : Icons.favorite_outline,
//           ),
//         ),
//         CustomButton(
//           color: Colors.transparent,
//           onTap: () => {},
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           icon: Icon(
//             color: Colors.black54,
//             size: 22.0,
//             Icons.folder_open_outlined,
//           ),
//           hoverText: "打开目录",
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: DataTable(
//           border: TableBorder.all(color: Colors.grey.shade400),
//           showBottomBorder: true,
//           columnSpacing: 30.0,
//           headingRowColor: WidgetStateProperty.resolveWith(
//             (states) => Color.fromRGBO(224, 224, 224, 8),
//           ),
//           headingRowHeight: 40,
//           dataRowMinHeight: 35,
//           dataRowMaxHeight: 35,
//           headingTextStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.black54, // 表头字体颜色
//           ),
//           // dataRowColor: MaterialStateProperty.resolveWith(
//           //     (states) => Color(0xFF1C1C1C)), // 每一行的背景颜色
//           dataTextStyle: TextStyle(
//             color: Colors.black54, // 单元格字体颜色
//             fontSize: 12,
//           ),
//           onSelectAll: (value) {},
//           checkboxHorizontalMargin: 0,
//           // showBottomBorder: true,
//           columns: const <DataColumn>[
//             DataColumn(
//               label: Text(
//                 '序号',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '平台',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '主播昵称',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '开播状态',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '录制状态',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '格式',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//             DataColumn(
//               label: Text(
//                 '操作',
//                 // style: TextStyle(fontStyle: FontStyle.italic),
//               ),
//               headingRowAlignment: MainAxisAlignment.center,
//             ),
//           ],
//           rows: List.generate(data.length, (i) {
//             Recording recording = data[i];
//             return DataRow(
//               selected: selected[0],
//               onSelectChanged: (bool? value) {
//                 // setState(() {
//                 //   selected[index] = value!;
//                 // });
//               },
//               cells: <DataCell>[
//                 DataCell(Center(child: Text(recording.id))),
//                 DataCell(Center(child: Text(recording.platform))),
//                 DataCell(Center(
//                   child: Text(
//                     "${recording.author?.name}/${recording.title}",
//                     textAlign: TextAlign.center,
//                   ),
//                 )),
//                 DataCell(
//                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Text(
//                     '10-17 10:30',
//                     // Utils.timestampToDate(recording.created),
//                     style: TextStyle(color: Skin.blue),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   recording.streamingStatus == 0
//                       ? Text(
//                           "未开播",
//                           style: TextStyle(color: Skin.blue),
//                         )
//                       : Text(
//                           "直播中",
//                           style: TextStyle(color: Skin.red),
//                         )
//                   // RecordingBreathingLight(),
//                 ])),
//                 DataCell(Center(
//                     child:
//                         //  recording.recordStatus == 1
//                         //     ? RecordingBreathingLight()
//                         //     :
//                         Dot(
//                   color: Skin.secondary,
//                 ))),
//                 DataCell(Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Text(recording.format),
//                     Text("/"),
//                     // Text(Quality.byValue(recording.quality).label)
//                   ],
//                 )),
//                 DataCell(buildButtons()),
//               ],
//             );
//           })

//           // <DataRow>[
//           //   DataRow(
//           //     selected: selected[0],
//           //     onSelectChanged: (bool? value) {
//           //       // setState(() {
//           //       //   selected[index] = value!;
//           //       // });
//           //     },
//           //     cells: <DataCell>[
//           //       DataCell(Text('1')),
//           //       DataCell(Text('John')),
//           //       DataCell(Row(children: [
//           //         Text('10-17 10:30'),
//           //         // RecordingBreathingLight(),
//           //       ])),
//           //       DataCell(Center(child: RecordingBreathingLight())),
//           //       DataCell(buildButtons()),
//           //     ],
//           //   ),
//           //   DataRow(
//           //     selected: selected[1],
//           //     onSelectChanged: (bool? value) {
//           //       // setState(() {
//           //       //   selected[index] = value!;
//           //       // });
//           //     },
//           //     cells: <DataCell>[
//           //       DataCell(Text('2')),
//           //       DataCell(Text('John')),
//           //       DataCell(Row(children: [
//           //         Text('10-17 10:30'),
//           //         // RecordingBreathingLight(),
//           //       ])),
//           //       DataCell(Center(child: RecordingBreathingLight())),
//           //       DataCell(buildButtons(played: true)),
//           //     ],
//           //   ),
//           //   DataRow(
//           //     selected: selected[2],
//           //     onSelectChanged: (bool? value) {
//           //       // setState(() {
//           //       //   selected[index] = value!;
//           //       // });
//           //     },
//           //     cells: <DataCell>[
//           //       DataCell(Text('3')),
//           //       DataCell(Text('John')),
//           //       DataCell(Row(children: [
//           //         Text('10-17 10:30'),
//           //         // RecordingBreathingLight(),
//           //       ])),
//           //       DataCell(Center(child: RecordingBreathingLight())),
//           //       DataCell(buildButtons(favorited: true)),
//           //     ],
//           //   ),
//           // ],
//           ),
//     );
//   }
// }

// import 'package:bunny/models/common.dart';
// import 'package:bunny/models/record.dart';
// import 'package:bunny/providers/cubit/record_cubit.dart';
// import 'package:bunny/widgets/button.dart';
// import 'package:bunny/widgets/textfield.dart';
// // import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';

// import '../../constants/colors.dart';

// class RecordingDialog extends StatefulWidget {
//   final RecordCubit rc;

//   const RecordingDialog({super.key, required this.rc});

//   @override
//   _RecordingDialogState createState() => _RecordingDialogState();
// }

// class _RecordingDialogState extends State<RecordingDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _remarkController = TextEditingController();
//   final _addrController = TextEditingController();

//   RecordForm rf = RecordForm(addr: "", remark: "");

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       rf.addr = _addrController.text.trim();
//       rf.remark = _remarkController.text.trim();
//       widget.rc.addRecord(rf);
//     }
//   }

//   List<Format> formats = [
//     Format(parameter: "mp4", name: "MP4", categroy: Categroy.video),
//     Format(parameter: "flv", name: "FLV", categroy: Categroy.video),
//     Format(parameter: "mkv", name: "MKV", categroy: Categroy.video),
//     Format(parameter: "mp3", name: "MP3", categroy: Categroy.audio),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FieldTitle(
//               text: "录播备注",
//               must: true,
//             ),
//             SizedBox(height: 5.0),
//             CustomFormTextField(
//               controller: _remarkController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return "该项为必填项"; // 表示不验证错误
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 5.0),
//             FieldTitle(
//               text: "直播地址",
//               must: true,
//             ),
//             SizedBox(height: 5.0),
//             CustomFormTextField(
//               controller: _addrController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return "该项为必填项"; // 表示不验证错误
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 5.0),
//             FieldTitle(
//               text: "视频格式",
//               must: true,
//             ),
//             SizedBox(height: 5.0),
//             MyDropdownButton<Format>(
//               onChange: (Format item) {
//                 rf.format = item.parameter;
//               },
//               validator: (value) {
//                 if (value == null) {
//                   return '选择格式';
//                 }
//                 return null;
//               },
//               hint: "选择格式",
//               items: formats,
//               dropdownMenuRender: (Format item) {
//                 return Row(
//                   children: [
//                     Icon(
//                       item.categroy == Categroy.video
//                           ? Icons.movie_outlined
//                           : Icons.music_note,
//                       size: 14,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       item.name,
//                       style: const TextStyle(
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             SizedBox(height: 5.0),
//             FieldTitle(
//               text: "清晰度",
//               must: true,
//             ),
//             SizedBox(height: 5.0),
//             // MyDropdownButton<Quality>(
//             //   onChange: (Quality item) {
//             //     rf.quality = item.value;
//             //   },
//             //   hint: "选择清晰度",
//             //   items: Quality.values,
//             //   dropdownMenuRender: (Quality item) {
//             //     return Row(children: [
//             //       Icon(
//             //         item.icon,
//             //         size: 20,
//             //         weight: 1,
//             //       ),
//             //       SizedBox(
//             //         width: 10,
//             //       ),
//             //       Text(
//             //         item.label,
//             //         style: const TextStyle(
//             //           fontSize: 12,
//             //         ),
//             //       )
//             //     ]);
//             //   },
//             // ),
//             SizedBox(height: 16.0),
//             Divider(
//               height: 1,
//             ),
//             SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomButton(
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Please enter a value')),
//                     );
//                     if (Navigator.canPop(context)) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   borderRadius: 5,
//                   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                   child: Text(
//                     "取消",
//                     style: TextStyle(color: Skin.dark, fontSize: 12),
//                   ),
//                 ),
//                 SizedBox(width: 10.0),
//                 CustomButton(
//                   onTap: () {
//                     _submitForm();
//                   },
//                   borderRadius: 5,
//                   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                   color: Skin.primary,
//                   child: Text(
//                     "确定",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyDropdownButton<T> extends StatefulWidget {
//   final List<T> items;
//   final Function dropdownMenuRender;
//   final String? hint;
//   final Function? onChange;
//   final Function? validator;

//   const MyDropdownButton({
//     super.key,
//     required this.items,
//     required this.dropdownMenuRender,
//     this.hint,
//     this.onChange,
//     this.validator,
//   });

//   @override
//   _MyDropdownButtonState<T> createState() => _MyDropdownButtonState<T>();
// }

// class _MyDropdownButtonState<T> extends State<MyDropdownButton<T>> {
//   T? _value;

//   @override
//   void initState() {
//     _value = widget.items.first;
//     widget.onChange?.call(_value);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicWidth(
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<T>(
//           // validator: (value) {
//           //   return widget.validator?.call(value);
//           // },
//           isExpanded: true,
//           hint: widget.hint != null && widget.hint != ""
//               ? Text(
//                   widget.hint!,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Theme.of(context).hintColor,
//                   ),
//                 )
//               : null,
//           buttonStyleData: ButtonStyleData(
//             height: 30,
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               color: Color.fromRGBO(244, 244, 244, 10),
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//           menuItemStyleData: MenuItemStyleData(
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             customHeights: List<double>.filled(widget.items.length, 35),
//           ),
//           dropdownStyleData: DropdownStyleData(
//             decoration: BoxDecoration(color: Colors.white),
//           ),
//           items: widget.items
//               .map((item) => DropdownMenuItem(
//                   value: item, child: widget.dropdownMenuRender(item)))
//               .toList(),
//           value: _value,
//           onChanged: (value) {
//             setState(() {
//               _value = value;
//             });
//             widget.onChange?.call(value);
//           },
//         ),
//       ),
//     );
//   }
// }

// class FieldTitle extends StatelessWidget {
//   String text;
//   bool? must;

//   FieldTitle({super.key, required this.text, this.must});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           text,
//           style: TextStyle(
//             color: Skin.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         if (must != null && must!)
//           Text(
//             '*',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Skin.red,
//               fontFamily: 'PingFang SC',
//             ),
//           ),
//       ],
//     );
//   }
// }

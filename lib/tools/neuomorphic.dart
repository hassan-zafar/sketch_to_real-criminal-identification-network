// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:glassmorphism_ui/glassmorphism_ui.dart';

// import '../constants.dart';

// class EditedNeuomprphicContainer extends StatelessWidget {
//   EditedNeuomprphicContainer(
//       {this.icon, this.text, this.isImage = false, this.isLanding = false});
//   final String icon;
//   final String text;
//   final isImage;
//   final bool isLanding;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: NeuomorphicContainer(
//         color: containerColor,
//         borderRadius: BorderRadius.circular(20),
//         style: NeuomorphicStyle.Convex,
//         intensity: 0.6,
//         width: isImage && !isLanding ? 120 : 100,
//         //blur: 8,
//         // shadowStrength: 10,
//         height: isImage && !isLanding ? 120 : 100,
//         // opacity: 0.2,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 isImage
//                     ? Image.asset(
//                         icon,
//                         height: 40,
//                       )
//                     : SvgPicture.asset(
//                         icon,
//                         height: 35,
//                       ),
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: Text(
//                     text,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

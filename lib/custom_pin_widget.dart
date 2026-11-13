// import 'package:flutter/material.dart';

// class CustomPinWidget extends StatelessWidget {
//   final String pinImage;
//   final List<String> profileImages;
//   final double size;
//   final IconData? sideIcon;

//   const CustomPinWidget({
//     super.key,
//     required this.pinImage,
//     required this.profileImages,
//     this.size = 100.0,
//     this.sideIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           height: 120,
//           width: 120,
//           child: Center(
//             child: Container(
//               height: 90,
//               width: 90,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(pinImage),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         buildProfileImage(profileImages),
//         CircleAvatar(
//           radius: 28,
//           backgroundColor: Colors.transparent,
//           foregroundColor: Colors.transparent,
//         ),
//         if (sideIcon != null)
//           Positioned(
//             bottom: 20,
//             right: 10,
//             child: Container(
//               height: 30,
//               width: 30,
//               // padding: EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                     spreadRadius: 1,
//                   )
//                 ],
//               ),
//               child: Icon(
//                 sideIcon,
//                 size: 18,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   buildProfileImage(List<String> profileImages) {
//     return profileImages.length < 2
//         ? Positioned(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 10.0),
//               child: CircleAvatar(
//                 radius: 35,
//                 backgroundImage: NetworkImage(profileImages.first),
//                 backgroundColor: Colors.yellow,
//               ),
//             ),
//           )
//         : profileImages.length < 3
//             ? Positioned(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 10.0),
//                   child: CircleAvatar(
//                     radius: 35,
//                     // backgroundColor: Colors.yellow,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           height: 60,
//                           width: 30,
//                           child: Image.network(
//                             profileImages[0],
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Container(
//                           height: 60,
//                           width: 30,
//                           child: Image.network(
//                             profileImages[1],
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : SizedBox();
//   }
// }

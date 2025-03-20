// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smartcare/providers/auth_provider.dart';
// import 'package:smartcare/models/user.dart';

// class ProfileTab extends StatefulWidget {
//   const ProfileTab({super.key});

//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }

// class _ProfileTabState extends State<ProfileTab> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _addressController;
//   late TextEditingController _phoneController;
//   String _selectedLanguage = 'English';

//   final List<String> _languages = [
//     'English',
//     'Spanish',
//     'French',
//     'German',
//     'Chinese',
//     'Japanese',
//     'Arabic',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

//     _nameController = TextEditingController(text: user?.name ?? '');
//     _addressController = TextEditingController(text: user?.address ?? '');
//     _phoneController = TextEditingController(text: user?.phone ?? '');
//     _selectedLanguage = user?.language ?? 'English';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.updateProfile(
//       name: _nameController.text.trim(),
//       address: _addressController.text.trim(),
//       phone: _phoneController.text.trim(),
//       language: _selectedLanguage,
//     );

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profile updated successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     if (user == null) {
//       return const Center(
//         child: Text('User not found'),
//       );
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Profile',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildProfileHeader(user),
//           const SizedBox(height: 24),
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Personal Information',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Full Name',
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your name';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _addressController,
//                       decoration: const InputDecoration(
//                         labelText: 'Address',
//                         prefixIcon: Icon(Icons.home),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number',
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: _selectedLanguage,
//                       decoration: const InputDecoration(
//                         labelText: 'Preferred Language',
//                         prefixIcon: Icon(Icons.language),
//                       ),
//                       items: _languages.map((language) {
//                         return DropdownMenuItem(
//                           value: language,
//                           child: Text(language),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() {
//                             _selectedLanguage = value;
//                           });
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed:
//                             authProvider.isLoading ? null : _updateProfile,
//                         child: authProvider.isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Update Profile'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildEmergencyContactsSection(user, authProvider),
//           if (user.connectedDevice != null) ...[
//             const SizedBox(height: 24),
//             _buildConnectedDeviceSection(user),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader(User user) {
//     return Center(
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.grey[200],
//             backgroundImage: user.profileImage != null
//                 ? NetworkImage(user.profileImage!)
//                 : null,
//             child: user.profileImage == null
//                 ? const Icon(
//                     Icons.person,
//                     size: 50,
//                     color: Colors.grey,
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             user.name,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             user.email,
//             style: const TextStyle(
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmergencyContactsSection(User user, AuthProvider authProvider) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Emergency Contacts',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline),
//                   onPressed: () {
//                     _showAddContactDialog(authProvider);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (user.emergencyContacts.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Text(
//                     'No emergency contacts added',
//                     style: TextStyle(
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               )
//             else
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: user.emergencyContacts.length,
//                 separatorBuilder: (_, __) => const Divider(),
//                 itemBuilder: (context, index) {
//                   final contact = user.emergencyContacts[index];
//                   return ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     leading: const CircleAvatar(
//                       backgroundColor: Colors.teal,
//                       child: Icon(
//                         Icons.person,
//                         color: Colors.white,
//                       ),
//                     ),
//                     title: Text(contact.name),
//                     subtitle: Text(contact.phone),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete_outline),
//                       onPressed: () {
//                         _showDeleteContactDialog(authProvider, contact);
//                       },
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildConnectedDeviceSection(User user) {
//     final deadline = user.deviceDeadline;
//     final daysLeft = deadline?.difference(DateTime.now()).inDays;

//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Connected Device',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.teal.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.watch,
//                     color: Colors.teal,
//                     size: 32,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.connectedDevice!,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       if (daysLeft != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           'Return in $daysLeft days',
//                           style: TextStyle(
//                             color: daysLeft < 7 ? Colors.red : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddContactDialog(AuthProvider authProvider) {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Emergency Contact'),
//         content: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   prefixIcon: Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a phone number';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 Navigator.pop(context);
//                 await authProvider.addEmergencyContact(
//                   nameController.text.trim(),
//                   phoneController.text.trim(),
//                 );
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteContactDialog(
//       AuthProvider authProvider, EmergencyContact contact) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Contact'),
//         content: Text('Are you sure you want to delete ${contact.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await authProvider.removeEmergencyContact(contact.id);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

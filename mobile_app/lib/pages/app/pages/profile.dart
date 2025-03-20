import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
// import 'package:health_care/components/list/design1/list_item1.dart';
// import 'package:health_care/constants/consts.dart';
// import 'package:health_care/controllers/profileController.dart';
// import 'package:health_care/controllers/textController.dart';
import 'package:health_care/models/user.dart';
// import 'package:health_care/pages/app/additional/add_contact_popup.dart';
// import 'package:health_care/pages/app/additional/edit_profile_popup.dart';
// import 'package:health_care/pages/app/additional/show_contact_popup.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:iconly/iconly.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Account user = Account.instance;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String _selectedLanguage = '';
  String pic = "";
  String msg = "";
  bool state = false;
  bool _isLoading = false;

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Arabic',
  ];

  @override
  void initState() {
    super.initState();
    Account().initialize();
    user = Account.instance;
    _nameController = TextEditingController(text: user.name);
    _addressController = TextEditingController(text: user.address);
    _phoneController = TextEditingController(text: user.mobile);
    _selectedLanguage = user.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    await Account().initialize();
    user = Account.instance;
    _nameController = TextEditingController(text: user.name);
    _addressController = TextEditingController(text: user.address);
    _phoneController = TextEditingController(text: user.mobile);
    _selectedLanguage = user.language;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshPage() async {
    await _initializeData();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> res = await FirestoreDbService().updateProfile(
      user.uid,
      _phoneController.text,
      _selectedLanguage,
      _addressController.text,
      pic,
    );

    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Profile updated successfully'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // }
    if (res['success']) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: Colors.green,
          ),
        );
      });
      _refreshPage();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchProfileData();
  //   fetchEmergency();
  // }

  // Future<void> fetchProfileData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Map<String, dynamic> res =
  //       await FirestoreDbService().fetchAccount(widget.user!.uid);
  //   if (res['success']) {
  //     setState(() {
  //       _userProfile.name = res['data']['name'];
  //       _userProfile.email = res['data']['email'];
  //       _userProfile.address = res['data']['address'];
  //       _userProfile.color = res['data']['color'];
  //       _userProfile.device = res['data']['deviceId'];
  //       _userProfile.isDone = res['data']['isDone'];
  //       _userProfile.language = res['data']['language'];
  //       _userProfile.mobile = res['data']['mobile'];
  //       _userProfile.pic = res['data']['pic'];
  //       _userProfile.birthday = res['data']['birthday'] ?? "";
  //       _userProfile.doctorId = res['data']['docId'];
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['error']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  // Future<void> onSubmit() async {
  //   Map<String, dynamic> res = await FirestoreDbService().updateProfile(
  //       widget.user!.uid,
  //       profileController.mobile.text,
  //       profileController.language.text,
  //       profileController.address.text,
  //       profileController.pic.text);
  //   if (res['success']) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['message']),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['error']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  // }

  // Future<void> onSubmitContact() async {
  //   Map<String, dynamic> res = await FirestoreDbService().addContact(
  //       widget.user!.uid,
  //       profileController.name.text,
  //       profileController.mobile.text);
  //   if (res['success']) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['message']),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['error']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  // }

  // Future<void> fetchEmergency() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Map<String, dynamic> res =
  //       await FirestoreDbService().fetchEmergency(widget.user!.uid);
  //   if (res['success']) {
  //     setState(() {
  //       final people = res['data'] as List<Map<String, dynamic>>;
  //       for (var person in people) {
  //         _people.add(
  //             ContactProfile(name: person['name'], mobile: person['mobile']));
  //       }
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['error']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // if (user == null) {
    //   return const Center(
    //     child: Text('User not found'),
    //   );
    // }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // TextFormField(
                    //   controller: _nameController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Full Name',
                    //     prefixIcon: Icon(Icons.person),
                    //   ),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter your name';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    // DropdownButtonFormField<String>(
                    //   value: _selectedLanguage,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Preferred Language',
                    //     prefixIcon: Icon(Icons.language),
                    //   ),
                    //   items: _languages.map((language) {
                    //     return DropdownMenuItem(
                    //       value: language,
                    //       child: Text(language),
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     if (value != null) {
                    //       setState(() {
                    //         _selectedLanguage = value;
                    //       });
                    //     }
                    //   },
                    // ),
                    DropdownButtonFormField<String>(
                      value: _languages.contains(_selectedLanguage)
                          ? _selectedLanguage
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Preferred Language',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: _languages.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Update Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildEmergencyContactsSection(),
          if (user.deviceId != 'Device') ...[
            const SizedBox(height: 24),
            _buildConnectedDeviceSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  user.profileImage = pickedFile.path;
                });
                await FirestoreDbService().updateProfile(
                  user.uid,
                  user.mobile,
                  user.language,
                  user.address,
                  user.profileImage,
                );
                // Upload logic to store image in Firebase or backend can be added here.
              }
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.profileImage.isNotEmpty
                      ? FileImage(File(user.profileImage)) as ImageProvider
                      : null,
                  child: user.profileImage.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    _showAddContactDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.emergency.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No emergency contacts added',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.emergency.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final contact = user.emergency[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(contact['name']!),
                    subtitle: Text(contact['mobile']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _showDeleteContactDialog(contact);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceSection() {
    print(user.deviceDeadline);
    final deadline = DateTime.parse(user.deviceDeadline);
    final daysLeft = deadline.difference(DateTime.now()).inDays;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connected Device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.watch,
                    color: Colors.teal,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.deviceId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ...[
                        const SizedBox(height: 4),
                        Text(
                          'Return in $daysLeft days',
                          style: TextStyle(
                            color: daysLeft < 7 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await FirestoreDbService().addContact(
                  user.uid,
                  nameController.text.trim(),
                  phoneController.text.trim(),
                );
                _refreshPage();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteContactDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact['name']!}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirestoreDbService()
                  .removeEmergencyContact(user.uid, contact['id']!);
              _refreshPage();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   AppSizes().initSizes(context);
  //   if (_isLoading) {
  //     return Center(
  //         child: CircularProgressIndicator(
  //       backgroundColor: StyleSheet().uiBackground,
  //       color: StyleSheet().btnBackground,
  //     ));
  //   }
  //   return SingleChildScrollView(
  //     child: Container(
  //       color: StyleSheet().uiBackground,
  //       width: double.infinity,
  //       padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //       child: Column(
  //         spacing: AppSizes().getBlockSizeVertical(1),
  //         children: [
  //           Container(
  //             clipBehavior: Clip.hardEdge,
  //             width: AppSizes().getBlockSizeHorizontal(50),
  //             height: AppSizes().getBlockSizeHorizontal(50),
  //             decoration: BoxDecoration(
  //                 color: StyleSheet().btnBackground,
  //                 borderRadius: BorderRadius.circular(60)),
  //             child: _userProfile.pic.isNotEmpty
  //                 ? Image.memory(
  //                     base64Decode(_userProfile.pic),
  //                     fit: BoxFit
  //                         .cover, // Ensures the image fills the CircleAvatar nicely
  //                   )
  //                 : const Icon(
  //                     Icons.person,
  //                     size: 40, // Optional: Adjust size as needed
  //                     color: Colors.white, // Optional: Adjust icon color
  //                   ),
  //           ),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.name,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.email,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.mobile,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.birthday,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.address,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.language,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //                 color: StyleSheet().profileBase,
  //               ),
  //               width: double.infinity,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   _userProfile.device,
  //                   style: TextStyle(
  //                     fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                     color: StyleSheet().profiletext,
  //                   ),
  //                 ),
  //               )),
  //           CustomTextButton(
  //             label: "Edit Profile",
  //             onPressed: () {
  //               profileController.mobile.text = _userProfile.mobile;
  //               profileController.address.text = _userProfile.address;
  //               profileController.language.text = _userProfile.language;
  //               profileController.pic.text = _userProfile.pic;
  //               showDialog(
  //                   context: context,
  //                   builder: (context) => EditProfilePopup(
  //                       mobileController: profileController.mobile,
  //                       addressController: profileController.address,
  //                       languageController: profileController.language,
  //                       picController: profileController.pic,
  //                       onSubmit: () {
  //                         onSubmit();
  //                         profileController.clear();
  //                         Navigator.pop(context);
  //                         fetchProfileData();
  //                       }));
  //             },
  //             icon: IconlyLight.edit,
  //             backgroundColor: StyleSheet().btnBackground,
  //             textColor: StyleSheet().btnText,
  //           ),
  //           Container(
  //               width: double.infinity,
  //               color: StyleSheet().uiBackground,
  //               child: Padding(
  //                 padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //                 child: Text(
  //                   "Emergency Contacts",
  //                   style: TextStyle(
  //                       fontSize: AppSizes().getBlockSizeHorizontal(4),
  //                       color: StyleSheet().profiletext,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               )),
  //           CustomTextButton(
  //               label: "Add",
  //               icon: IconlyLight.add_user,
  //               backgroundColor: StyleSheet().btnBackground,
  //               textColor: StyleSheet().btnText,
  //               onPressed: () {
  //                 showDialog(
  //                     context: context,
  //                     builder: (context) => AddContactPopup(
  //                         mobileController: profileController.mobile,
  //                         nameController: profileController.name,
  //                         onSubmit: () {
  //                           onSubmitContact();
  //                           profileController.clear();
  //                           Navigator.pop(context);
  //                           fetchEmergency();
  //                         }));
  //               }),
  //           Column(
  //               children: _people.map((person) {
  //             return ListItem1(
  //                 title: person.name,
  //                 icon: IconlyLight.profile,
  //                 onPressed: () {
  //                   showDialog(
  //                       context: context,
  //                       builder: (context) =>
  //                           ShowContactPopup(profile: person));
  //                 });
  //           }).toList())
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

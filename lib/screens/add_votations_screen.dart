import 'dart:typed_data';
import 'dart:io';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';

import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:dressing_room/responsive/web_screen_layout.dart';
import 'feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:provider/provider.dart';

class AddVotationsScreen extends StatefulWidget {
  const AddVotationsScreen({Key? key}) : super(key: key);

  @override
  _AddVotationsScreenState createState() => _AddVotationsScreenState();
}

class _AddVotationsScreenState extends State<AddVotationsScreen> {
  List<Uint8List>? _files;
  List<TextEditingController> _descriptionControllers = [];
  bool isLoading = false;
  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectImage(context);
    });
  }


  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.nearlyWhite,
          title: Align(
            alignment: Alignment.center,
            child: const Text(
              'UPLOAD',
              style: AppTheme.subheadline,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.camera),
                label: const Text(
                  'Camera',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _files ??= [];
                    _files!.add(file);
                    _descriptionControllers.add(TextEditingController());
                  });
                },
              ),
              SizedBox(width: 10,),
              ElevatedButton.icon(
                icon: Icon(Icons.photo_library),
                label: const Text(
                  'Gallery',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(primary: AppTheme.vinho),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _files ??= [];
                    _files!.add(file);
                    _descriptionControllers.add(TextEditingController());
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void uploadVotations(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> votationOptions = [];
    for (int i = 0; i < _files!.length; i++) {
      Uint8List file = _files![i];
      String description = _descriptionControllers[i].text;

      votationOptions.add({
        "description": description,
        "photo": file,
      });
    }

    try {
      String res = await FireStoreMethods().uploadVotation(
        votationOptions,
        _files!,
        uid,
        username,
        profImage,
      );

      if (res == "success") {
        showSnackBar(
          context,
          'Votations uploaded!',
        );
        clearImages();
         
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

 void clearImages() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
        (route) => false,
      );
}

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _descriptionControllers.forEach((controller) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _files == null
        ? Container()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.nearlyWhite,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.nearlyBlack,
                onPressed: clearImages,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => uploadVotations(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Upload",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading ? const LinearProgressIndicator() : const SizedBox(height: 0.0),
                const Divider(),
                Flexible(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _files!.length,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.memory(
                                _files![pageIndex],
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                            ),
                          );
                        },
                      ),
                      if (_currentPageIndex > 0)
                        Positioned(
                          top: MediaQuery.of(context).size.height / 2 - 15.0,
                          left: 16.0,
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(_currentPageIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.vinho,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_currentPageIndex < _files!.length - 1)
                        Positioned(
                          top: MediaQuery.of(context).size.height / 2 - 15.0,
                          right: 16.0,
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(_currentPageIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.vinho,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectImage(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Add More',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 20)
                    ],
                  ),
                ),
                SizedBox(
                  height: 100.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
  itemCount: _descriptionControllers.length,
  itemBuilder: (context, index) {
    final bool isCurrentPage = index == _currentPageIndex;
    return Visibility(
      visible: isCurrentPage,
      child: TextField(
        controller: _descriptionControllers[index],
        style: AppTheme.title,
        decoration: const InputDecoration(
          hintText: "Write a description...",
          hintStyle: AppTheme.title,
          border: InputBorder.none,
        ),)
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

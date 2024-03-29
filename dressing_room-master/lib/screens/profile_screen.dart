import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/screens/basket_screen.dart';
import 'package:dressing_room/screens/favorites_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/resources/auth_methods.dart';
import 'package:dressing_room/resources/firestore_methods.dart';
import 'package:dressing_room/screens/login_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/utils/utils.dart';
import 'package:gap/gap.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'edit_profile_screen.dart';
import 'seepost.dart';
import 'package:dressing_room/widgets/follow_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  int tabviews = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final double drawerWidth = 300.0;
  bool isDrawerOpen = false;
  String selectedOption = "public";

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      var votationSnap = await FirebaseFirestore.instance
          .collection('votations')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length + votationSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      tabviews = userSnap.data()!['tabviews'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void openDrawer() {
    setState(() {
      isDrawerOpen = true;
    });
  }

  void closeDrawer() {
    setState(() {
      isDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showAll =
        FirebaseAuth.instance.currentUser!.uid == widget.uid ? true : false;
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : GestureDetector(
            onTap: closeDrawer,
            child: Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Profile",
                      style: AppTheme.barapp.copyWith(
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black, // Cor da sombra
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    actions: [
                      if (FirebaseAuth.instance.currentUser!.uid == widget.uid)
                        IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(
                                  color: AppTheme.nearlyBlack, blurRadius: 3.0)
                            ],
                            CupertinoIcons.list_bullet,
                            color: AppTheme.nearlyBlack,
                          ),
                          onPressed: openDrawer,
                        ),
                    ],
                    iconTheme: IconThemeData(color: AppTheme.vinho),
                  ),
                  body: ListView(children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                              radius: 45,
                            ),
                            onTap: () {
                              print(widget.uid);
                            },
                          ),
                          Gap(16.h),
                          Text(
                            userData['username'],
                            style: AppTheme.title,
                          ),
                          Gap(16.h),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "publications"),
                              buildStatColumn(followers, "followers"),
                              buildStatColumn(following, "following"),
                            ],
                          ),
                          Gap(16.h),
                          if (FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid)
                            Container()
                          else if (isFollowing)
                            FollowButton(
                              text: 'Unfollow',
                              backgroundColor: AppTheme.vinho,
                              textColor: AppTheme.nearlyWhite,
                              borderColor: Colors.grey,
                              function: () async {
                                await FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );

                                setState(() {
                                  isFollowing = false;
                                  followers--;
                                });
                              },
                            )
                          else
                            FollowButton(
                              text: 'Follow',
                              backgroundColor: AppTheme.vinho,
                              textColor: AppTheme.nearlyWhite,
                              borderColor: Colors.grey,
                              function: () async {
                                await FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );

                                setState(() {
                                  isFollowing = true;
                                  followers++;
                                });
                              },
                            ),
                          DefaultTabController(
                              length: userData['tabviews'].length + 2,
                              initialIndex: 0,
                              child: Column(children: [
                                Container(
                                    color: Colors.transparent,
                                    child: RawScrollbar(
                                      mainAxisMargin: 5,
                                      trackVisibility: false,
                                      thumbVisibility: true,
                                      interactive: false,
                                      scrollbarOrientation:
                                          ScrollbarOrientation.top,
                                      child: TabBar(
                                        tabAlignment: TabAlignment.center,
                                        dividerColor: Colors.transparent,
                                        isScrollable: true,
                                        indicatorColor: Colors.transparent,
                                        labelColor: AppTheme.vinho,
                                        labelStyle: AppTheme.caption.copyWith(
                                          shadows: [
                                            Shadow(
                                              blurRadius: .5,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        unselectedLabelColor:
                                            AppTheme.nearlyWhite,
                                        tabs: [
                                          Tab(text: 'Public'),
                                          if (FirebaseAuth
                                                  .instance.currentUser!.uid ==
                                              widget.uid)
                                            Tab(text: 'Private'),
                                          if (showAll)
                                            for (Map<String, dynamic> tabText
                                                in userData['tabviews'])
                                              Tab(text: tabText.keys.first),
                                        ],
                                      ),
                                    )),
                                Gap(20.h),
                                SizedBox(
                                    height: 450.h,
                                    child: TabBarView(children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              children: [
                                                Text(
                                                  FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid ==
                                                          widget.uid
                                                      ? "My Looks"
                                                      : "Looks",
                                                  style: AppTheme.subheadline,
                                                ),
                                              ],
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection('posts')
                                                .where('uid',
                                                    isEqualTo: widget.uid)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }

                                              return SizedBox(
                                                height: 150,
                                                child: ListView.builder(
                                                  itemCount: (snapshot.data!
                                                          as QuerySnapshot)
                                                      .docs
                                                      .length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    DocumentSnapshot snap =
                                                        (snapshot.data!
                                                                as QuerySnapshot)
                                                            .docs[index];

                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SeePost(
                                                                    postId: snap[
                                                                        'postId']),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Container(
                                                            width: 150,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            child: Image(
                                                              image: NetworkImage(
                                                                  snap['photoUrls']
                                                                      [0]),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              children: [
                                                Text(
                                                  FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid ==
                                                          widget.uid
                                                      ? "My Votations"
                                                      : "Votations",
                                                  style: AppTheme.subheadline,
                                                ),
                                              ],
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection('votations')
                                                .where('uid',
                                                    isEqualTo: widget.uid)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }

                                              return SizedBox(
                                                height: 150,
                                                child: ListView.builder(
                                                  itemCount: (snapshot.data!
                                                          as QuerySnapshot)
                                                      .docs
                                                      .length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    DocumentSnapshot snap =
                                                        (snapshot.data!
                                                                as QuerySnapshot)
                                                            .docs[index];

                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SeePost(
                                                                    postId: snap[
                                                                        'votationId']),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Container(
                                                            width: 150,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            child: Image(
                                                              image: NetworkImage(
                                                                  snap['options']
                                                                          [0][
                                                                      'photoUrl']),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      if (FirebaseAuth
                                              .instance.currentUser!.uid ==
                                          widget.uid)
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Anonymous Posts",
                                                    style: AppTheme.subheadline,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection('anonymous_posts')
                                                  .where('uid',
                                                      isEqualTo: widget.uid)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                return SizedBox(
                                                  height: 150,
                                                  child: ListView.builder(
                                                    itemCount: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs
                                                        .length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      DocumentSnapshot snap =
                                                          (snapshot.data!
                                                                  as QuerySnapshot)
                                                              .docs[index];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SeePost(
                                                                      postId: snap[
                                                                          'postId']),
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Container(
                                                              width: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              child: Container(
                                                                width: 150,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child: Image(
                                                                  image: NetworkImage(
                                                                      snap['photoUrls']
                                                                          [0]),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Favorites",
                                                    style: AppTheme.subheadline,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection('favorites')
                                                  .doc(widget
                                                      .uid) // Use the user's ID as the document ID
                                                  .collection('userFavorites')
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }

                                                List<QueryDocumentSnapshot>
                                                    favorites = (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs;

                                                return SizedBox(
                                                  height: 150,
                                                  child: ListView.builder(
                                                    itemCount: favorites.length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      dynamic snap =
                                                          favorites[index];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SeePost(
                                                                      postId: snap[
                                                                          'postId']),
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Container(
                                                              width: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              child: Image(
                                                                image: NetworkImage(
                                                                    snap['photoUrls']
                                                                        [0]),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      for (Map<String, dynamic> tabText
                                          in userData['tabviews'])
                                        for (var value in tabText.values)
                                          if (value is List)
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height: 450.h,
                                                  child: GridView.builder(
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      mainAxisSpacing: 8.h,
                                                      crossAxisSpacing: 8.h,
                                                      childAspectRatio: 1.0,
                                                    ),
                                                    itemCount: value.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return FutureBuilder(
                                                        future:
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'posts')
                                                                .doc(value[
                                                                    index])
                                                                .get(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          }

                                                          return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: InkWell(
                                                                child: Image
                                                                    .network(
                                                                  snapshot.data![
                                                                      'photoUrls'][0],
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                SeePost(postId: value[index])),
                                                                  );
                                                                },
                                                              ));
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                    ]))
                              ]))
                        ],
                      ),
                    ),
                  ]),
                  backgroundColor: AppTheme.cinza,
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  top: 0,
                  right: isDrawerOpen ? 0 : -drawerWidth,
                  bottom: 0,
                  width: drawerWidth,
                  child: Container(
                    color: Color.fromARGB(255, 80, 55, 67),
                    child: Column(
                      children: [
                        Gap(70.h),
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            userData['photoUrl'],
                          ),
                          radius: 40.h,
                        ),
                        Gap(16.h),
                        ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "Edit Profile",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.shopify_sharp,
                            color: AppTheme.nearlyWhite,
                          ),
                          title: Text(
                            "My Purchases",
                            style: AppTheme.subheadlinewhite,
                          ),
                          onTap: () {},
                        ),
                        Divider(),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: ListView(children: [
                                  Text(
                                    "Collections",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.favorite,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Favorites",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FavoritesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      CupertinoIcons.bag_fill,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Shopping Bag",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BasketScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  Text(
                                    "My stores",
                                    style: AppTheme.subtitlewhite,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.add,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Create a store",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {},
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                    title: Text(
                                      "Logout",
                                      style: AppTheme.subheadlinewhite,
                                    ),
                                    onTap: () {
                                      AuthMethods().signOut().then((value) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()),
                                            (Route<dynamic> route) => false);
                                      });
                                    },
                                  )
                                ]))),
                        Text(
                          "Version: beta of beta",
                          style: AppTheme.subtitlewhite,
                        ),
                        Gap(10)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTheme.title,
        ),
        Text(
          label,
          style: AppTheme.subtitle,
        ),
      ],
    );
  }
}

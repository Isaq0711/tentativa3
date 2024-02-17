import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:dressing_room/screens/product_card.dart';
import 'package:flutter/material.dart';
import 'package:dressing_room/screens/outfit_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'package:dressing_room/2d_cards/new_votation_card.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:dressing_room/2d_cards/new_post_card.dart';

double altura = 650.h;
double largura = (altura * 9) / 16;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _anonymousPostsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _votationsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream;
  bool isLoading = false;
  bool isShop = false;
  late ScrollController scrollController;

  late String fotoUrl = '';

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    scrollController.addListener(() {
      final bool isScrollingUp =
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse;

      if (isScrollingUp) {
        context.read<BottonNavController>().setBottomVisible(false);
      } else {
        context.read<BottonNavController>().setBottomVisible(true);
      }
    });

    _anonymousPostsStream =
        FirebaseFirestore.instance.collection('anonymous_posts').snapshots();
    _postsStream = FirebaseFirestore.instance.collection('posts').snapshots();
    _votationsStream =
        FirebaseFirestore.instance.collection('votations').snapshots();
    _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.h,
        elevation: 0.0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            "DressRoom",
            style: AppTheme.headlinevinho.copyWith(
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black, // Cor da sombra
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.vinho, blurRadius: 2.0)
                      ],
                      CupertinoIcons.search,
                      color: AppTheme.vinho,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      shadows: <Shadow>[
                        Shadow(color: AppTheme.vinho, blurRadius: 3.0)
                      ],
                      CupertinoIcons.info_circle,
                      color: AppTheme.vinho,
                    ),
                    onPressed: () {},
                  ),
                  isShop
                      ? IconButton(
                          icon: Icon(
                            shadows: <Shadow>[
                              Shadow(
                                  color: AppTheme.nearlyBlack, blurRadius: 5.0)
                            ],
                            CupertinoIcons.shopping_cart,
                            color: AppTheme.vinho,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OutfitScreen(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      )),
                            );
                          },
                        )
                      : Container()
                ],
              ))
        ],
      ), // Adicionei 'const' ao Text
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _anonymousPostsStream,
        builder: (context, anonymousPostsSnapshot) {
          if (anonymousPostsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot<Map<String, dynamic>>> anonymousPosts =
              anonymousPostsSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _postsStream,
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot<Map<String, dynamic>>> posts =
                  postsSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _votationsStream,
                builder: (context, votationsSnapshot) {
                  if (votationsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot<Map<String, dynamic>>> votations =
                      votationsSnapshot.data!.docs;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _productsStream,
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      List<DocumentSnapshot<Map<String, dynamic>>> products =
                          productsSnapshot.data!.docs;

                      List<DocumentSnapshot<Map<String, dynamic>>>
                          allDocuments = [];

                      if (isShop) {
                        allDocuments = [
                          ...products,
                        ];
                      } else {
                        allDocuments = [
                          ...anonymousPosts,
                          ...posts,
                          ...votations,
                        ];
                      }

                      allDocuments.sort((a, b) => (b.data()!['datePublished']
                              as Timestamp)
                          .compareTo(a.data()!['datePublished'] as Timestamp));

                      return TwoDimensionalGridView(
                        diagonalDragBehavior: DiagonalDragBehavior.free,
                        delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: 4,
                          maxYIndex: 4,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            final int index =
                                vicinity.yIndex * 5 + vicinity.xIndex;
                            if (index < allDocuments.length) {
                              final documentData = allDocuments[index].data();

                              if (documentData!.containsKey('options')) {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: NewVotationCard(
                                    snap: documentData,
                                  ),
                                );
                              } else if (documentData.containsKey('category')) {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: ProductCard(
                                    snap: documentData,
                                  ),
                                );
                              } else {
                                return Container(
                                  height: altura,
                                  width: largura,
                                  child: NewPostCard(
                                    snap: documentData,
                                  ),
                                );
                              }
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    Key? key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(key: key, delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      key: key,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    Key? key,
    required ViewportOffset verticalOffset,
    required AxisDirection verticalAxisDirection,
    required ViewportOffset horizontalOffset,
    required AxisDirection horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required Axis mainAxis,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          key: key,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          cacheExtent: cacheExtent,
          clipBehavior: clipBehavior,
        );

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      key: key,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    Key? key,
    required ViewportOffset horizontalOffset,
    required AxisDirection horizontalAxisDirection,
    required ViewportOffset verticalOffset,
    required AxisDirection verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required Axis mainAxis,
    required TwoDimensionalChildManager childManager,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          childManager: childManager,
          cacheExtent: cacheExtent,
          clipBehavior: clipBehavior,
        );

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = math.max((horizontalPixels / largura).floor(), 0);
    final int leadingRow = math.max((verticalPixels / altura).floor(), 0);
    final int trailingColumn = math.min(
      ((horizontalPixels + viewportWidth) / largura).ceil(),
      maxColumnIndex,
    );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / altura).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset = (leadingColumn * largura) - horizontalOffset.pixels;
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow * altura) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox? child = buildOrObtainChildFor(vicinity);
        if (child != null) {
          child.layout(constraints.loosen(), parentUsesSize: true);
          // Subclasses only need to set the normalized layout offset. The super
          // class adjusts for reversed axes.
          parentDataOf(child).layoutOffset =
              Offset(xLayoutOffset, yLayoutOffset);
          yLayoutOffset += altura;
        }
      }
      xLayoutOffset += largura;
    }

    final double verticalExtent = altura * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      math.max(verticalExtent - viewportDimension.height, 0.0),
    );
    final double horizontalExtent = largura * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      math.max(horizontalExtent - viewportDimension.width, 0.0),
    );
  }
}

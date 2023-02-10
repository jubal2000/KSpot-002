import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:kspot_002/widget/user_card_widget.dart';
import 'package:kspot_002/widget/user_item_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import 'dart:developer';

import 'edit/edit_text_input_widget.dart';
import 'like_widget.dart';

enum GoodsItemCardType {
  normal,
  square,
  squareSmall,
  cart,
  placeGroup,
  place,
}

enum GoodsItemCardSellType {
  none,
  talent,
  goods,
  portfolio,
  place,
  event,
}

class EventSquareItem extends GoodsItemCard {
  EventSquareItem(
      JSON itemData, {
        Key? key,
        GoodsItemCardType showType = GoodsItemCardType.square,
        GoodsItemCardSellType sellType = GoodsItemCardSellType.event,
        TextStyle titleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black, height: 1.1),
        TextStyle descStyle = const TextStyle(fontSize: 12, color: Colors.black87, height: 1.1),
        TextStyle extraStyle = const TextStyle(fontSize: 12, color: Colors.amber),
        TextStyle priceStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
        TextStyle priceOrgStyle = const TextStyle(fontSize: 9, color: Colors.grey),
        TextStyle ribbonStyle = const TextStyle(fontSize: 8, color: Colors.white),
        Color ribbonColor = Colors.red,
        Alignment descAlign = Alignment.centerLeft,
        EdgeInsets padding = const EdgeInsets.fromLTRB(0, 5, 0, 5),
        Color backgroundColor = Colors.transparent,
        JSON? couponInfo,
        int titleMaxLine = 1,
        int descMaxLine = 1,
        double imageHeight = 60,
        bool isSelected = false,
        bool isSelectable = false,
        bool isEditable = false,
        showOutline = false,
        isShowExtra = true,
        outlineWidth = 3.0,
        outlineColor = Colors.white,
        faceOutlineColor = Colors.black,
        cartId = '' ,
        onChanged,
        onSelected,
        onShowDetail,
      }) : super(
    itemData,
    key: key,
    showType: showType,
    sellType: sellType,
    titleStyle: titleStyle,
    descStyle: descStyle,
    extraStyle: extraStyle,
    priceStyle: priceStyle,
    priceOrgStyle: priceOrgStyle,
    ribbonStyle: ribbonStyle,
    ribbonColor: ribbonColor,
    descAlign: descAlign,
    padding: padding,
    backgroundColor: backgroundColor,
    titleMaxLine: titleMaxLine,
    descMaxLine: descMaxLine,
    imageHeight: imageHeight,
    couponInfo: couponInfo,
    isSelected: isSelected,
    isSelectable: isSelectable,
    isEditable: isEditable,
    onChanged: onChanged,
    onSelected: onSelected,
    onShowDetail: onShowDetail,
    cartId: cartId,
    showOutline: showOutline,
    outlineWidth: outlineWidth,
    outlineColor: outlineColor,
    faceOutlineColor: faceOutlineColor,
    isShowExtra: isShowExtra,
  );
}

class ContentItem extends GoodsItemCard {
  ContentItem(
      JSON itemData, {
        Key? key,
        GoodsItemCardType showType = GoodsItemCardType.normal,
        GoodsItemCardSellType sellType = GoodsItemCardSellType.none,
        TextStyle titleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black),
        TextStyle descStyle = const TextStyle(fontSize: 12, color: Colors.black87),
        TextStyle extraStyle = const TextStyle(fontSize: 12, color: Colors.black),
        TextStyle priceStyle = const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple),
        TextStyle priceOrgStyle = const TextStyle(fontSize: 9, color: Colors.grey),
        TextStyle ribbonStyle = const TextStyle(fontSize: 8, color: Colors.white),
        Color ribbonColor = Colors.red,
        Alignment descAlign = Alignment.centerLeft,
        EdgeInsets padding = const EdgeInsets.fromLTRB(0, 5, 0, 5),
        Color backgroundColor = Colors.transparent,
        JSON? couponInfo,
        int descMaxLine = 1,
        double imageHeight = 60,
        bool isSelected = false,
        bool isSelectable = false,
        bool isEditable = false,
        isShowSelectIcon = true,
        showOutline = false,
        isShowExtra = true,
        outlineWidth = 3.0,
        outlineColor = Colors.white,
        cartId = '' ,
        onChanged,
        onSelected,
        onShowDetail,
      }) : super(
    itemData,
    key: key,
    showType: showType,
    sellType: sellType,
    titleStyle: titleStyle,
    descStyle: descStyle,
    extraStyle: extraStyle,
    priceStyle: priceStyle,
    priceOrgStyle: priceOrgStyle,
    ribbonStyle: ribbonStyle,
    ribbonColor: ribbonColor,
    descAlign: descAlign,
    padding: padding,
    backgroundColor: backgroundColor,
    descMaxLine: descMaxLine,
    imageHeight: imageHeight,
    couponInfo: couponInfo,
    isSelected: isSelected,
    isSelectable: isSelectable,
    isEditable: isEditable,
    isShowSelectIcon: isShowSelectIcon,
    onChanged: onChanged,
    onSelected: onSelected,
    onShowDetail: onShowDetail,
    cartId: cartId,
    showOutline: showOutline,
    outlineWidth: outlineWidth,
    outlineColor: outlineColor,
    isShowExtra: isShowExtra,
  );
}

class GoodsItemCartCard extends GoodsItemCard {
  GoodsItemCartCard(
    JSON goodsData, {
    Key? key,
    GoodsItemCardType showType = GoodsItemCardType.cart,
    GoodsItemCardSellType sellType = GoodsItemCardSellType.talent,
    TextStyle titleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black),
    TextStyle descStyle = const TextStyle(fontSize: 12, color: Colors.black87),
    TextStyle extraStyle = const TextStyle(fontSize: 12, color: Colors.black),
    TextStyle priceStyle = const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple),
    TextStyle priceOrgStyle = const TextStyle(fontSize: 9, color: Colors.grey),
    TextStyle ribbonStyle = const TextStyle(fontSize: 8, color: Colors.white),
    Color ribbonColor = Colors.red,
    Alignment descAlign = Alignment.centerLeft,
    EdgeInsets padding = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    Color backgroundColor = Colors.white,
    JSON? couponInfo,
    int descMaxLine = 2,
    double imageHeight = 80,
    int cartCount = 1,
    bool isSelected = true,
    bool isSelectable = true,
    bool isEditable = false,
    onChanged,
    onSelected,
    onShowDetail,
    cartId,
  }) : super(
          goodsData,
          key: key,
          showType: showType,
          sellType: sellType,
          titleStyle: titleStyle,
          descStyle: descStyle,
          extraStyle: extraStyle,
          priceStyle: priceStyle,
          priceOrgStyle: priceOrgStyle,
          ribbonStyle: ribbonStyle,
          ribbonColor: ribbonColor,
          descAlign: descAlign,
          padding: padding,
          backgroundColor: backgroundColor,
          descMaxLine: descMaxLine,
          imageHeight: imageHeight,
          couponInfo: couponInfo,
          cartCount: cartCount,
          isSelected: isSelected,
          isSelectable: isSelectable,
          isEditable: isEditable,
          onChanged: onChanged,
          onSelected: onSelected,
          onShowDetail: onShowDetail,
          cartId: cartId,
        );
}

class GoodsItemSquareCard extends GoodsItemCard {
  GoodsItemSquareCard(
    JSON goodsData, {
    Key? key,
    GoodsItemCardType showType = GoodsItemCardType.square,
    GoodsItemCardSellType sellType = GoodsItemCardSellType.talent,
    TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
    TextStyle descStyle = const TextStyle(fontSize: 10, color: Colors.black),
    TextStyle extraStyle = const TextStyle(fontSize: 11, color: Colors.purple),
    TextStyle priceStyle = const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
    TextStyle priceOrgStyle = const TextStyle(fontSize: 8, color: Colors.grey),
    TextStyle ribbonStyle = const TextStyle(fontSize: 7, color: Colors.white),
    Color ribbonColor = Colors.red,
    Alignment descAlign = Alignment.centerLeft,
    EdgeInsets padding = const EdgeInsets.fromLTRB(10, 10, 10, 10),
    Color backgroundColor = Colors.white,
    int descMaxLine = 2,
    double imageHeight = 90,
    bool isSelected = false,
    bool isSelectable = false,
    bool isEditable = false,
    onChanged,
    onSelected,
    onShowDetail,
  }) : super(
          goodsData,
          key: key,
          showType: showType,
          sellType: sellType,
          titleStyle: titleStyle,
          descStyle: descStyle,
          extraStyle: extraStyle,
          priceStyle: priceStyle,
          priceOrgStyle: priceOrgStyle,
          ribbonStyle: ribbonStyle,
          ribbonColor: ribbonColor,
          descAlign: descAlign,
          padding: padding,
          backgroundColor: backgroundColor,
          descMaxLine: descMaxLine,
          imageHeight: imageHeight,
          isSelected: isSelected,
          isSelectable: isSelectable,
          isEditable: isEditable,
          onChanged: onChanged,
          onSelected: onSelected,
          onShowDetail: onShowDetail,
        );
}

class GoodsItemSquareSmallCard extends GoodsItemCard {
  GoodsItemSquareSmallCard(
    JSON goodsData, {
    Key? key,
    GoodsItemCardType showType = GoodsItemCardType.square,
    GoodsItemCardSellType sellType = GoodsItemCardSellType.talent,
    TextStyle titleStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
    TextStyle descStyle = const TextStyle(fontSize: 9, color: Colors.black),
    TextStyle extraStyle = const TextStyle(fontSize: 9, color: Colors.purple),
    TextStyle priceStyle = const TextStyle(fontSize: 9, color: Colors.black),
    TextStyle priceOrgStyle = const TextStyle(fontSize: 8, color: Colors.grey),
    TextStyle ribbonStyle = const TextStyle(fontSize: 8, color: Colors.white),
    Color ribbonColor = Colors.red,
    Alignment descAlign = Alignment.centerLeft,
    EdgeInsets padding = const EdgeInsets.fromLTRB(10, 10, 10, 10),
    Color backgroundColor = Colors.white,
    int descMaxLine = 1,
    double imageHeight = 90.0,
    bool isSelected = false,
    bool isSelectable = false,
    bool isEditable = false,
    onChanged,
    onSelected,
    onShowDetail,
  }) : super(
          goodsData,
          key: key,
          showType: showType,
          sellType: sellType,
          titleStyle: titleStyle,
          descStyle: descStyle,
          extraStyle: extraStyle,
          priceStyle: priceStyle,
          priceOrgStyle: priceOrgStyle,
          ribbonStyle: ribbonStyle,
          ribbonColor: ribbonColor,
          descAlign: descAlign,
          padding: padding,
          backgroundColor: backgroundColor,
          descMaxLine: descMaxLine,
          imageHeight: imageHeight,
          isSelected: isSelected,
          isSelectable: isSelectable,
          isEditable: isEditable,
          onChanged: onChanged,
          onSelected: onSelected,
          onShowDetail: onShowDetail,
        );
}

class GoodsItemCard extends StatefulWidget {
  GoodsItemCard(
    this.goodsData, {
    Key? key,
    this.showType = GoodsItemCardType.normal,
    this.sellType = GoodsItemCardSellType.talent,
    this.titleStyle = const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
    this.descStyle = const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.black),
    this.extraStyle = const TextStyle(fontSize: 11, color: Colors.purple),
    this.priceStyle = const TextStyle(fontSize: 11, color: Colors.black),
    this.priceOrgStyle = const TextStyle(fontSize: 11, color: Colors.grey),
    this.ribbonStyle = const TextStyle(fontSize: 8, color: Colors.white),
    this.ribbonColor = Colors.red,
    this.descAlign = Alignment.centerLeft,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.transparent,
    this.titleMaxLine = 1,
    this.descMaxLine = 2,
    this.imageHeight = 80.0,
    this.faceSize = 46.0,
    this.cartCount = 1,
    this.couponInfo,
    this.isSelected = false,
    this.isSelectable = false,
    this.isEditable = false,
    this.onChanged,
    this.onSelected,
    this.onShowDetail,
    this.onShowDetailJSON,
    this.cartId = '',
    this.showOutline = false,
    this.outlineWidth = 2.0,
    this.outlineColor = Colors.white,
    this.faceOutlineColor = Colors.black,
    this.isShowExtra = true,
    this.isShowLink = false,
    this.isShowSelectIcon = false,
  }) : super(key: key);

  void Function(String, int)? onChanged;
  void Function(String, bool)? onSelected;
  void Function(String, int)? onShowDetail; // 0: detail, 1: delete, 2: buy now...
  void Function(JSON, int)? onShowDetailJSON; // 0: detail, 1: delete, 2: buy now...

  // card show type..
  GoodsItemCardType showType;
  GoodsItemCardSellType sellType;

  JSON goodsData;
  JSON? couponInfo;

  String cartId;
  TextStyle titleStyle;
  TextStyle descStyle;
  TextStyle ribbonStyle;
  TextStyle extraStyle;
  TextStyle priceStyle;
  TextStyle priceOrgStyle;
  Color ribbonColor;
  Alignment descAlign;
  EdgeInsets padding;
  Color backgroundColor;
  int titleMaxLine;
  int descMaxLine;

  bool   showOutline;
  double outlineWidth;
  Color  outlineColor;
  Color  faceOutlineColor;

  bool isSelected;
  bool isSelectable;
  bool isEditable;
  bool isShowExtra;
  bool isShowLink;
  bool isShowSelectIcon;

  double imageHeight;
  double faceSize;

  int cartCount; // 구매갯수..

  @override
  State<StatefulWidget> createState() => GoodsItemCardState();
}

class GoodsItemCardState extends State<GoodsItemCard> {
  final api = Get.find<ApiService>();
  Future<JSON>? _goodsDataInit;

  double _sumPrice = 0.0; // price * cartCount
  double _totalPrice = 0.0; // price * cartCount + transPee
  double _curPrice = 0.0;
  double _curTransPee = 0.0;
  double _saleRatio = 0.0;
  double _salePrice = 0.0;
  double _sumOrgPrice = 0.0;
  var _orgId = '';
  bool isDisabled = false;

  int _buyMin = 1;
  int _buyMax = 99999;
  var _isDataReady = false;
  var _isSale = false;
  var roundCorner = 8.0;

  JSON _goodsItem = {};

  refresh() {
    // log("--> item refresh [${_goodsItem['id']}]");
    // _goodsItem['desc'] = '$_orgId : ${_goodsItem['categoryGroup']} / ${_goodsItem['category']}'; // for test..
    _buyMin = INT(_goodsItem['buyMin'], defaultValue: 1);
    _buyMax = INT(_goodsItem['buyMax'], defaultValue: 9999);
    _sumOrgPrice = 0;

    if (_goodsItem['_price'] != null) {
      _sumPrice     = DBL(_goodsItem['_price']);
      _sumOrgPrice  = DBL(_goodsItem['_priceOrg']);
      _curTransPee  = DBL(_goodsItem['_transPee']);
      _isSale       = BOL(_goodsItem['_isSale']);
    } else {
      _sumPrice     = DBL(_goodsItem['price' ]);
      _salePrice    = DBL(_goodsItem['salePrice']);
      _saleRatio    = DBL(_goodsItem['saleRatio']);
      _curTransPee  = DBL(_goodsItem['transPee']);
      _curPrice     = _sumPrice - _salePrice - ((_sumPrice - _salePrice) * _saleRatio / 100.0);
    }

    if (widget.cartCount < _buyMin) widget.cartCount = _buyMin;
    // _sumPrice = 0.0;
    _totalPrice = 0.0;
    if (INT(_goodsItem['status']) > 0 && widget.isSelected) {
      // if (widget.couponInfo != null) {
      //   var saleP = DBL(widget.couponInfo!['salePrice']);
      //   var saleR = DBL(widget.couponInfo!['saleRatio']);
      //   _sumOrgPrice = _sumPrice;
      //   _sumPrice = _sumPrice - saleP - ((_sumPrice - saleP) * saleR / 100.0);
      //   log("--> item coupon [${widget.couponInfo!['id']}] : $saleP / $saleR / $_sumOrgPrice -> $_sumPrice");
      // }
      _totalPrice = _sumPrice + _curTransPee;
    }
    _isDataReady = true;
    // AppData.mainCartPrice['totalPrice'] = DBL(AppData.mainCartPrice['totalPrice']) + _totalPrice;
    log("--> item refresh [${_goodsItem['id']}] result : ${widget.isSelected} / $_sumPrice / ${_goodsItem['_price']} - ${widget.cartCount}");
  }

  @override
  void initState() {
    super.initState();
    // log("--> GoodsItemCardState init : ${_goodsItem['id']} / ${_goodsItem['targetId']} / ${_goodsItem['title']}");
    // if (_goodsItem['title'] != null) {
    //   refresh();
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (INT(widget.goodsData['status']) < 1) {
      _goodsItem = widget.goodsData;
      _isDataReady = true;
      isDisabled = true;
      widget.isSelected = false;
    } else if (widget.goodsData['targetId'] != null) {
      // log("--> target info [${widget.goodsData['id']}] : ${widget.goodsData['targetId']} -> ${widget.goodsData['title']}");
      _goodsItem = {};
      _isDataReady = false;
      _orgId = widget.goodsData['targetId'];
      // _goodsDataInit = getGoodsDataFromId(widget.goodsData['targetId']);
    } else {
      _goodsItem = widget.goodsData;
      _orgId = _goodsItem['id'];
      refresh();
    }
    switch (widget.showType) {
      case GoodsItemCardType.square:
      case GoodsItemCardType.squareSmall:
        return LayoutBuilder(
          builder: (context, layout) {
           return Container(
            child: VisibilityDetector(
              onVisibilityChanged: (VisibilityInfo info) {
                // log("--> onVisibilityChanged [${widget.goodsData['id']}] : ${info.visibleFraction} / $_isDataReady - ${widget.goodsData['targetId']} / ${widget.goodsData['title']}");
                if (info.visibleFraction > 0 && !_isDataReady && widget.goodsData['targetId'] != null) {
                  setState(() {
                    // _goodsDataInit = api.getGoodsDataFromId(widget.goodsData['targetId']);
                  });
                }
              },
              key: GlobalKey(),
              child: FutureBuilder(
                future: _goodsDataInit,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData || _isDataReady) {
                    if (!_isDataReady) {
                      _goodsItem = snapshot.data;
                      refresh();
                    }
                    return GestureDetector(
                      onTap: () {
                        if (widget.onShowDetail != null) widget.onShowDetail!(_goodsItem['id'], 0);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                          children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                              height: layout.maxHeight - widget.faceSize * 0.5,
                              color: widget.backgroundColor,
                              child: Column(
                              children: [
                            if (JSON_NOT_EMPTY(_goodsItem['pic'])) ...[
                              Stack(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: widget.imageHeight,
                                      minWidth: double.infinity,
                                    ),
                                    child: showImageWidget(_goodsItem['pic'], BoxFit.cover),
                                  ),
                                  if (widget.isShowLink)
                                  TopRightAlign(
                                    child: LikeWidget(context, 'event', _goodsItem,
                                        iconSize: 22, padding: EdgeInsets.all(5)),
                                  )
                                ]
                              ),
                              SizedBox(height: 5),
                            ],
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DESC(_goodsItem['title']), style: widget.titleStyle, maxLines: widget.titleMaxLine, textAlign: TextAlign.center),
                                    if (widget.descMaxLine > 0 && STR(_goodsItem['desc']).isNotEmpty)...[
                                      Text(DESC(_goodsItem['desc']),
                                        style: widget.descStyle,
                                        maxLines: widget.descMaxLine,
                                        textAlign: TextAlign.center
                                      ),
                                    ],
                                    if (STR(_goodsItem['timeRange']).isNotEmpty)...[
                                      Text(DESC(_goodsItem['timeRange']),
                                          style: widget.extraStyle,
                                          maxLines: 1,
                                          textAlign: TextAlign.center
                                      ),
                                    ]
                                  ],
                                )
                              )
                            ),
                                SizedBox(height: widget.faceSize * 0.5),
                                ]
                              )
                            ),
                            )
                          ],
                        ),
                        if (widget.showType != GoodsItemCardType.placeGroup)...[
                          Positioned(
                            bottom: 0,
                            child: UserIdCardOneWidget(_goodsItem['userId'],
                              size: widget.faceSize,
                              faceCircleSize: 3.0,
                              borderColor: widget.faceOutlineColor,
                              backColor: Color(0xFF333333)),
                          ),
                        ],
                        if (widget.isSelectable)
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Checkbox(
                              value: widget.isSelected,
                              onChanged: (value) {
                                if (!isDisabled) {
                                  setState(() {
                                    widget.isSelected = value!;
                                    widget.cartCount = widget.isSelected ? 1 : 0;
                                  });
                                }
                              }),
                          ),
                        ]
                      )
                    );
                  } else {
                    return showLoadingCircleSquare(20);
                  }
                }
              )
            )
          );
          }
        );
      case GoodsItemCardType.cart:
        return GestureDetector(
          onTap: () {
            setState(() {
              // log("--> select item : ${widget.cartId} / ${_goodsItem['title']}");
              if (widget.onShowDetail != null) widget.onShowDetail!(widget.cartId, 0);
            });
          },
          child: Container(
              padding: widget.padding,
              // color: Colors.yellow,
              child: VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {
                  // log("--> onVisibilityChanged [${widget.goodsData['id']}] : ${info.visibleFraction} / $_isDataReady - ${widget.goodsData['targetId']} / ${widget.goodsData['title']}");
                  if (info.visibleFraction > 0 && !_isDataReady && widget.goodsData['targetId'] != null) {
                    setState(() {
                      // _goodsDataInit = api.getGoodsDataFromId(widget.goodsData['targetId']);
                    });
                  }
                },
                key: GlobalKey(),
                child: FutureBuilder(
                  future: _goodsDataInit,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData || _isDataReady) {
                    if (!_isDataReady) {
                      _goodsItem = snapshot.data;
                      refresh();
                    }
                    return Column(children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                              // activeColor: Colors.purple,
                              value: widget.isSelected,
                              onChanged: (value) {
                                if (!isDisabled) {
                                  setState(() {
                                    widget.isSelected = value!;
                                    widget.cartCount = widget.isSelected ? _buyMin : 0;
                                    refresh();
                                    if (widget.onSelected != null) widget.onSelected!(widget.cartId, widget.isSelected);
                                    log("--> check item : ${widget.cartCount} / ${widget.isSelected}");
                                  });
                                }
                              }),
                          if (_goodsItem['pic'] != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: SizedBox(
                                width: widget.imageHeight - 20,
                                height: widget.imageHeight - 20,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: showImageFit(_goodsItem['pic']),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Container(
                              height: widget.imageHeight,
                              // color: Colors.yellow,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(STR(_goodsItem['title']), style: widget.titleStyle, maxLines: 1),
                                    if (STR(_goodsItem['optionStr']).isNotEmpty)...[
                                    SizedBox(height: 5),
                                  ],
                                  Text(DESC(_goodsItem['optionStr']), style: widget.descStyle, maxLines: widget.descMaxLine),
                                  SizedBox(height: 5),
                                  if (_goodsItem['status'] > 0)...[
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (_isSale)...[
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(2.5)),
                                                color: Colors.blueAccent,
                                              ),
                                              child: Text('SALE',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  )
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                          Text("상품금액 ", style: widget.extraStyle),
                                          Text("${PRICE_STR(_sumPrice)}원", style: widget.extraStyle),
                                          if (_sumOrgPrice > _sumPrice)...[
                                            SizedBox(width: 5),
                                            Text("${PRICE_STR(_sumOrgPrice)}원", style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough
                                            )),
                                          ],
                                          SizedBox(width: 10),
                                          Text("배송비 ", style: widget.extraStyle),
                                          Text(_curTransPee > 0 ? "${PRICE_STR(_curTransPee)}원" : "무료", style: widget.extraStyle),
                                        ]
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Expanded(
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text("결제금액 ", style: widget.titleStyle),
                                              Text("${PRICE_STR(_totalPrice)}원", style: widget.priceStyle),
                                            ]
                                        )
                                      ),
                                    ],
                                    if (_goodsItem['status'] < 1)...[
                                      Text("해당 상품을 찾을 수 없습니다. ", style: widget.extraStyle),
                                      SizedBox(height: 10)
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]
                    );
                  } else {
                      return showLoadingImageSquare(widget.imageHeight);
                  }
                }
              ),
            )
          )
        );
      case GoodsItemCardType.place:
        return Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: widget.outlineColor, width: widget.outlineWidth, style: widget.showOutline ? BorderStyle.solid : BorderStyle.none),
              borderRadius: BorderRadius.circular(roundCorner),
            ),
            child: VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {
                  // log("--> onVisibilityChanged [${widget.goodsData['id']}] : ${info.visibleFraction} / $_isDataReady - ${widget.goodsData['targetId']} / ${widget.goodsData['title']}");
                  if (info.visibleFraction > 0 && !_isDataReady && widget.goodsData['targetId'] != null) {
                    setState(() {
                      // _goodsDataInit = api.getGoodsDataFromId(widget.goodsData['targetId']);
                    });
                  }
                },
                key: GlobalKey(),
                child: FutureBuilder(
                    future: _goodsDataInit,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // log("--> snapshot.hasData [${widget.goodsData['id']}] : ${snapshot.hasData} / $_isDataReady");
                      if (snapshot.hasData || _isDataReady) {
                        if (!_isDataReady) {
                          // log("--> set _goodsItem [${widget.goodsData['id']}]");
                          _goodsItem = snapshot.data;
                          refresh();
                        }
                        return GestureDetector(
                            onTap: () {
                              if (widget.onShowDetailJSON != null) widget.onShowDetailJSON!(_goodsItem, 0);
                              if (widget.onShowDetail != null) widget.onShowDetail!(_goodsItem['id'], 0);
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Row(
                              children: [
                                if (widget.isSelectable)
                                  Checkbox(
                                      value: widget.isSelected,
                                      onChanged: (value) {
                                        if (!isDisabled) {
                                          setState(() {
                                            widget.isSelected = value!;
                                            widget.cartCount = widget.isSelected ? _buyMin : 0;
                                            if (widget.onSelected != null) {
                                              widget.onSelected!(_goodsItem['id'], widget.isSelected);
                                            }
                                          });
                                        }
                                      }),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(roundCorner),
                                  child: SizedBox(
                                    width: widget.imageHeight,
                                    height: widget.imageHeight,
                                    child: Stack(
                                        children: [
                                          SizedBox(
                                            width: widget.imageHeight,
                                            height: widget.imageHeight,
                                            child: showImageFit(_goodsItem['pic']),
                                          ),
                                          if (_goodsItem['status'] == 2)...[
                                            ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 5),
                                          ]
                                        ]
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(STR(_goodsItem['title']), style: widget.titleStyle, maxLines: 1),
                                          ),
                                        ]),
                                        if (_goodsItem['desc'] != null) ...[
                                          SizedBox(height: 3),
                                          Text(DESC(_goodsItem['desc']), style: widget.descStyle, maxLines: widget.descMaxLine),
                                        ],
                                        // if (widget.showType != GoodsItemCardType.placeGroup)...[
                                        if (widget.isShowExtra)...[
                                          SizedBox(height: 3),
                                          priceTextStyle(),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.isEditable)
                                  editMenuWidget,
                                if (widget.isShowSelectIcon)
                                  Icon(Icons.arrow_forward_ios_sharp, size: 20, color: Theme.of(context).hintColor),
                              ],
                            )
                        );
                      } else {
                        return showLoadingImageSquare(widget.imageHeight);
                      }
                    }
                )
            )
        );      default:
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: widget.outlineColor, width: widget.outlineWidth, style: widget.showOutline ? BorderStyle.solid : BorderStyle.none),
            borderRadius: BorderRadius.circular(roundCorner),
          ),
          child: VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
                // log("--> onVisibilityChanged [${widget.goodsData['id']}] : ${info.visibleFraction} / $_isDataReady - ${widget.goodsData['targetId']} / ${widget.goodsData['title']}");
                if (info.visibleFraction > 0 && !_isDataReady && widget.goodsData['targetId'] != null) {
                  setState(() {
                    // _goodsDataInit = api.getGoodsDataFromId(widget.goodsData['targetId']);
                  });
                }
              },
              key: GlobalKey(),
              child: FutureBuilder(
              future: _goodsDataInit,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // log("--> snapshot.hasData [${widget.goodsData['id']}] : ${snapshot.hasData} / $_isDataReady");
                if (snapshot.hasData || _isDataReady) {
                  if (!_isDataReady) {
                    // log("--> set _goodsItem [${widget.goodsData['id']}]");
                    _goodsItem = snapshot.data;
                    refresh();
                  }
                  return GestureDetector(
                    onTap: () {
                      if (widget.onShowDetailJSON != null) widget.onShowDetailJSON!(_goodsItem, 0);
                      if (widget.onShowDetail != null) widget.onShowDetail!(_goodsItem['id'], 0);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      children: [
                        if (widget.isSelectable)
                          Checkbox(
                              value: widget.isSelected,
                              onChanged: (value) {
                                if (!isDisabled) {
                                  setState(() {
                                    widget.isSelected = value!;
                                    widget.cartCount = widget.isSelected ? _buyMin : 0;
                                    if (widget.onSelected != null) {
                                      widget.onSelected!(_goodsItem['id'], widget.isSelected);
                                    }
                                  });
                                }
                              }),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(roundCorner),
                          child: SizedBox(
                            width: widget.imageHeight,
                            height: widget.imageHeight,
                            child: Stack(
                                children: [
                                  SizedBox(
                                    width: widget.imageHeight,
                                    height: widget.imageHeight,
                                    child: showImageFit(_goodsItem['pic']),
                                  ),
                                  if (_goodsItem['status'] == 2)...[
                                    ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 5),
                                  ]
                                ]
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(STR(_goodsItem['title']), style: widget.titleStyle, maxLines: 1),
                                ),
                              ]),
                              if (_goodsItem['desc'] != null) ...[
                                SizedBox(height: 3),
                                Text(DESC(_goodsItem['desc']), style: widget.descStyle, maxLines: widget.descMaxLine),
                              ],
                              // if (widget.showType != GoodsItemCardType.placeGroup)...[
                              if (widget.isShowExtra)...[
                                SizedBox(height: 3),
                                priceTextStyle(),
                              ]
                            ],
                          ),
                          ),
                        ),
                        if (widget.isEditable)
                          editMenuWidget,
                      ],
                    )
                );
              } else {
                  return showLoadingImageSquare(widget.imageHeight);
              }
            }
          )
        )
      );
    }
  }

  priceTextStyle() {
    LOG("--> priceTextStyle : ${widget.showType}");
    var _iconColor = Theme.of(context).colorScheme.tertiary.withOpacity(0.5);
    switch (widget.showType) {
      case GoodsItemCardType.square:
        {
          switch (widget.sellType) {
            case GoodsItemCardSellType.talent:
              {
                return Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text("거리 ", style: widget.descStyle),
                        // Text("${PRICE_STR(DBL(_goodsItem['distance']))}km", style: widget.extraStyle),
                        // SizedBox(width: 10),
                        Text("최근 거래 ", style: widget.descStyle),
                        Text("${PRICE_STR(INT(_goodsItem['trades']))}회", style: widget.extraStyle),
                      ]),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.sms, size: 15, color: _iconColor),
                      SizedBox(width: 5),
                      Text("${PRICE_STR(INT(_goodsItem['comments']))}", style: widget.descStyle),
                      SizedBox(width: 10),
                      Icon(Icons.favorite, size: 15, color: _iconColor),
                      SizedBox(width: 5),
                      Text("${PRICE_STR(INT(_goodsItem['likes']))}", style: widget.descStyle),
                    ],
                  ),
                ]);
              }
            case GoodsItemCardSellType.portfolio:
              {
                return SizedBox(width: 1, height: 1);
              }
            case GoodsItemCardSellType.event:
              {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.sms, size: 12, color: _iconColor),
                      SizedBox(width: 5),
                      Text("${PRICE_STR(INT(_goodsItem['comments']))}", style: widget.descStyle),
                      SizedBox(width: 10),
                      Icon(Icons.favorite, size: 12, color: _iconColor),
                      SizedBox(width: 5),
                      Text("${PRICE_STR(INT(_goodsItem['likes']))}", style: widget.descStyle),
                    ]
                );
              }
            default:
              {
                return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: SizedBox(),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.sms, size: 10, color: _iconColor),
                        Text("${PRICE_STR(INT(_goodsItem['comments']))}", style: widget.descStyle),
                        SizedBox(width: 5),
                        Icon(Icons.favorite, size: 10, color: _iconColor),
                        Text("${PRICE_STR(INT(_goodsItem['likes']))}", style: widget.descStyle),
                      ]),
                ]);
              }
          }
        }
      default:
        {
          switch (widget.sellType) {
            case GoodsItemCardSellType.talent:
              {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("거리", style: widget.descStyle),
                    SizedBox(width: 5),
                    Text("${PRICE_STR(DBL(_goodsItem['distance']))}km", style: widget.extraStyle),
                    SizedBox(width: 10),
                    Text("거래 횟수", style: widget.descStyle),
                    SizedBox(width: 5),
                    Text("${PRICE_STR(INT(_goodsItem['trades']))}회", style: widget.extraStyle),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 3),
                          Icon(Icons.sms, size: 15, color: _iconColor),
                          SizedBox(width: 5),
                          Text("${PRICE_STR(INT(_goodsItem['comments']))}", style: widget.descStyle),
                          SizedBox(width: 10),
                          Icon(Icons.favorite, size: 15, color: _iconColor),
                          SizedBox(width: 5),
                          Text("${PRICE_STR(INT(_goodsItem['likes']))}", style: widget.descStyle),
                        ]),
                  ],
                );
              }
            case GoodsItemCardSellType.portfolio:
              {
                return SizedBox(width: 1, height: 1);
              }
            case GoodsItemCardSellType.event:
              {
                return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(_goodsItem['timeRange'], style: widget.extraStyle),
                  SizedBox(width: 5),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.sms, size: 15, color: _iconColor),
                        SizedBox(width: 5),
                        Text("${PRICE_STR(DBL(_goodsItem['comments']))}", style: widget.descStyle),
                        SizedBox(width: 10),
                        Icon(Icons.favorite, size: 15, color: _iconColor),
                        SizedBox(width: 5),
                        Text("${PRICE_STR(DBL(_goodsItem['likes']))}", style: widget.descStyle),
                      ]),
                ]);
              }
            default:
              {
                return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text("${PRICE_STR(_curPrice)}원", style: widget.priceStyle),
                  SizedBox(width: 5),
                  Visibility(
                    visible: _sumPrice > 0 && _sumPrice != _curPrice,
                    child: Text("${PRICE_STR(_sumPrice)}원",
                        style: TextStyle(
                            fontSize: widget.priceOrgStyle.fontSize,
                            color: widget.priceOrgStyle.color,
                            decoration: TextDecoration.lineThrough)),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.sms, size: 15, color: _iconColor),
                        SizedBox(width: 5),
                        Text("${PRICE_STR(DBL(_goodsItem['comments']))}", style: widget.descStyle),
                        SizedBox(width: 10),
                        Icon(Icons.favorite, size: 15, color: _iconColor),
                        SizedBox(width: 5),
                        Text("${PRICE_STR(DBL(_goodsItem['likes']))}", style: widget.descStyle),
                      ]),
                ]);
              }
          }
        }
    }
  }

  Widget get editMenuWidget {
    return  DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Container(
              width: 30,
              height: double.infinity,
              alignment: Alignment.centerRight,
              child: Icon(Icons.more_vert_outlined, size: 22, color: Colors.black),
            ),
            // customItemsHeights: const [3],
            itemHeight: 45,
            dropdownWidth: 160,
            buttonHeight: 30,
            buttonWidth: 30,
            itemPadding: const EdgeInsets.only(left: 16, right: 16),
            offset: Offset(0, 50),
            items: [
              // if (_goodsItem['status'] == 1)
              //   ...GoodsMenuItems.myItems1.map((item) => DropdownMenuItem<DropdownItem>(
              //       value: item,
              //       child: GoodsMenuItems.buildItem(item),
              //     ),
              //   ),
              // if (_goodsItem['status'] == 2)
              //   ...GoodsMenuItems.myItems2.map((item) => DropdownMenuItem<DropdownItem>(
              //     value: item,
              //     child: GoodsMenuItems.buildItem(item),
              //   ),
              //   ),
            ],
            onChanged: (value) {
              var selected = value as DropdownItem;
              log("--> selected.index : ${selected.type}");
              switch (selected.type) {
                case DropdownItemType.enable:
                case DropdownItemType.disable:
                  // showAlertYesNoDialog(context, '상품보이기', '해당 상품을 ${_goodsItem['status'] == 1 ? '비활성화' : '활성화'} 하시겠습니까?', '비활성화 상태에서는 다른 유저는 볼 수 없습니다', '아니오', '예').then((value) {
                  //   if (value == 1) {
                  //     api.setGoodsStatus(_goodsItem['id'], _goodsItem['status'] == 1 ? 2 : 1).then((value) {
                  //       setState(() {
                  //         _goodsItem['status'] = _goodsItem['status'] == 1 ? 2 : 1;
                  //       });
                  //     });
                  //   }
                  // });
                  break;
                case DropdownItemType.edit:
                  // var topBarState = AppData.mainTopWidgetKey.currentState as MainAppBarState;
                  // topBarState.showGoodsEditScreen(_goodsItem, () {
                  //   setState(() {});
                  // });
                  break;
                case DropdownItemType.delete:
                  // showAlertYesNoDialog(context, '삭제', '해당 상품을 삭제 하시겠습니까?', '', '아니오', '예').then((value) {
                  //   if (value == 1) {
                  //     setState(() {
                  //       api.setGoodsStatus(_goodsItem['id'], 0).then((value) {
                  //         log('--> widget.onChanged : ${widget.onChanged != null ? 'ready' : 'null'}');
                  //         if (widget.onChanged != null) widget.onChanged!(_goodsItem['id'], 0);
                  //       });
                  //     });
                  //   }
                  // });
              }
            },
          ),
      );
  }
}

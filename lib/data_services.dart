import 'package:flutter/cupertino.dart';
import 'package:miplate/model/coupon_model.dart';
import 'package:miplate/model/holiday_model.dart';
import 'package:miplate/model/toggle_model.dart';
import 'package:miplate/model/voucher_model.dart';
import 'package:provider/provider.dart';
import 'package:miplate/model/order_details_model.dart';

class DataServices with ChangeNotifier {
  List<OrderDetailsModel> _currentOrders = [];

  List<OrderDetailsModel> get currentOrders => _currentOrders;

  void setCurrentOrders(List<OrderDetailsModel> orders) {
    _currentOrders = orders;
    _filteredOrders = orders;
    print(orders);
    notifyListeners();
  }

  List<OrderDetailsModel> _filteredOrders = [];
  List<OrderDetailsModel> get filteredOrders => _filteredOrders;
  void setFilteredOrders(int paymentType) {
    if (paymentType == 1) {
      //Cash On Delivery
      _filteredOrders =
          _currentOrders.where((element) => element.paymentType == 1).toList();
      notifyListeners();
    } else if (paymentType == 2) {
      // Card Payment
      _filteredOrders =
          _currentOrders.where((element) => element.paymentType == 2).toList();
      notifyListeners();
    } else {
      //All
      _filteredOrders = _currentOrders;
      notifyListeners();
    }
  }

  void modifyDeliveryTime({int index, String time}) {
    //_currentOrders[index].modifiedDeliveryTime = time;
    _filteredOrders[index].modifiedDeliveryTime = time;
    notifyListeners();
  }

  void increaseCount(int index) {
    //_currentOrders[index].noOfTimesClicked++;
    _filteredOrders[index].noOfTimesClicked++;
    //print(_currentOrders[index].noOfTimesClicked);
    notifyListeners();
  }

  void decreaseCount(int index) {
    // print(_currentOrders[index].noOfTimesClicked);
    // if (_currentOrders[index].noOfTimesClicked > 0) {
    //   _currentOrders[index].noOfTimesClicked--;
    // }
    // print(_currentOrders[index].noOfTimesClicked);
    print(_filteredOrders[index].noOfTimesClicked);
    if (_filteredOrders[index].noOfTimesClicked > 0) {
      _filteredOrders[index].noOfTimesClicked--;
    }
    print(_filteredOrders[index].noOfTimesClicked);
    notifyListeners();
  }

  void removeOrderFromCurrentOrder(int index) {
    //_currentOrders.removeAt(index);
    _filteredOrders.removeAt(index);
    notifyListeners();
  }

  List<OrderDetailsModel> _historyOrders = [];
  List<OrderDetailsModel> get historyOrders => _historyOrders;
  void setHistoryOrders(List<OrderDetailsModel> orders) {
    _historyOrders = orders;
    _historyFilteredOrders = orders;
    print(_historyOrders);
    notifyListeners();
  }

  List<OrderDetailsModel> _historyFilteredOrders = [];
  List<OrderDetailsModel> get historyFilteredOrders => _historyFilteredOrders;
  void setHistoryOrdersFilter({int type, int option}) {
    if (type == 1) {
      // Filter by payment Option
      _historyFilteredOrders =
          _historyOrders.where((element) => element.paymentType == 1).toList();
      if (option == 1) {
        // Cash on Delivery
      } else if (option == 2) {
        // Card Payment
        _historyFilteredOrders = _historyOrders
            .where((element) => element.paymentType == 2)
            .toList();
      } else {
        // All
        _historyFilteredOrders = _historyOrders;
      }
    } else {
      // Filter by order type
      if (option == 2) {
        // Collection
        _historyFilteredOrders =
            _historyOrders.where((element) => element.orderType == 2).toList();
      } else if (option == 3) {
        // Delivery
        _historyFilteredOrders =
            _historyOrders.where((element) => element.orderType == 3).toList();
      } else {
        // All
        _historyFilteredOrders = _historyOrders;
      }
    }
    notifyListeners();
  }

  ToggleModel _restaurantToggle =
      ToggleModel(name: 'Restaurant', status: 1, id: 1);
  ToggleModel get restaurantToggle => _restaurantToggle;
  void setRestaurantToggle(ToggleModel model) {
    _restaurantToggle = model;
    notifyListeners();
  }

  void updateRestaurantToggleStatus(int flag) {
    _restaurantToggle.status = flag;
    notifyListeners();
  }

  ToggleModel _deliveryToggle = ToggleModel(name: 'Delivery', status: 1, id: 3);
  ToggleModel get deliveryToggle => _deliveryToggle;
  void setDeliveryToggle(ToggleModel model) {
    _deliveryToggle = model;
    notifyListeners();
  }

  void updateDeliveryToggleStatus(int flag) {
    _deliveryToggle.status = flag;
    notifyListeners();
  }

  ToggleModel _collectionToggle =
      ToggleModel(name: 'Collection', status: 1, id: 2);
  ToggleModel get collectionToggle => _collectionToggle;
  void setCollectionToggle(ToggleModel model) {
    _collectionToggle = model;
    notifyListeners();
  }

  void updateCollectionToggleStatus(int flag) {
    _collectionToggle.status = flag;
    notifyListeners();
  }

  ToggleModel _curbSideToggle = ToggleModel(name: 'Curbside', status: 1, id: 4);
  ToggleModel get curbSideToggle => _curbSideToggle;
  void setCurbSideToggle(ToggleModel model) {
    _curbSideToggle = model;
    notifyListeners();
  }

  void updateCurbSideToggleStatus(int flag) {
    _curbSideToggle.status = flag;
    notifyListeners();
  }

  List<Coupon> _allCoupons = [];
  List<Coupon> get allCoupons => _allCoupons;
  void setAllCoupons(List<Coupon> newValue) {
    _allCoupons = newValue;
    notifyListeners();
  }

  List<Voucher> _allVouchers = [];
  List<Voucher> get allVouchers => _allVouchers;
  void setAllVouchers(List<Voucher> newValue) {
    _allVouchers = newValue;
    notifyListeners();
  }

  List<Holiday> _allHolidays = [];
  List<Holiday> get allHolidays => _allHolidays;
  void setAllHolidays(List<Holiday> newValue) {
    _allHolidays = newValue;
    notifyListeners();
  }
}

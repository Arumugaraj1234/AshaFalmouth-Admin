import 'package:flutter/material.dart';
import 'package:image/image.dart';

class Constants {
  //static String BASE_URL = "https://gurkha-api.azurewebsites.net/api/Admin";
  static String BASE_URL =
      "https://ashafalmouth-api.azurewebsites.net:443//api/Admin";

  //MARK:- HEADER CONSTANTS

}

const kHeader = {"Content-Type": "application/json"};
//const kBaseUrl = "http://64.15.141.244:80/Gurkha/WebApi/api/Admin/";
//const kBaseUrl = "https://gurkha-api.azurewebsites.net/api/Admin/";
const kBaseUrl = 'https://ashafalmouth-api.azurewebsites.net:443//api/Admin/';
const kUrlToSaveTimings = kBaseUrl + 'SaveTiming';
const kUrlToGetToggleStatus = kBaseUrl + 'GetToggle';
const kUrlToUpdateToggleStatus = kBaseUrl + 'UpdateToggle';
const kUrlToCompleteOrder = kBaseUrl + 'CompleteOrder';
const kUrlToGetAllCurrentOrders = kBaseUrl + 'GetAllOrders';
const kUrlToGetAllCoupons = kBaseUrl + 'GetCoupons';
const kUrlToAddOrEditCoupon = kBaseUrl + 'SaveCoupon';
const kUrlToGetAllVouchers = kBaseUrl + 'GetVouchers';
const kUrlToAddOrEditVoucher = kBaseUrl + 'SaveVouchers';
const kUrlToGetHolidays = kBaseUrl + 'GetHoliday';
const kUrlToAddOrEditHoliday = kBaseUrl + 'SaveHoliday';

//MARK: SHARED PREFERENCES KEYS CONSTANT
const kPrinterKey = 'printerKey';

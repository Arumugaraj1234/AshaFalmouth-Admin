class Coupon {
  int id;
  String code;
  int percentage;
  int status;
  int couponFor;

  Coupon({this.id, this.code, this.percentage, this.status, this.couponFor});

  String statusDescription() {
    String returnValue = 'Active';
    if (status == 1) {
      returnValue = 'Active';
    } else {
      returnValue = 'In-Active';
    }

    return returnValue;
  }

  String forMedium() {
    String returnValue = '';
    switch (couponFor) {
      case 1:
        returnValue = 'All';
        break;
      case 2:
        returnValue = 'Website';
        break;
      case 3:
        returnValue = 'IOS / Android';
        break;
      default:
        returnValue = 'IOS / Android';
    }

    return returnValue;
  }
}

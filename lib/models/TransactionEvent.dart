class Transactionevent {  
  final int isMoneyReceived;
  final int id;
  final String details;
  final double amt;
  final String time;
  final bool isBill;


  const Transactionevent(this.isMoneyReceived, this.id, this.details, this.amt, this.time, this.isBill);

  @override
  String toString() => details;
}

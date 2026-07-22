enum RequestStatus { pending, fulfilled, rejected }

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.fulfilled:
        return 'Fulfilled';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }
}

class CustomerRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String requestText;
  final DateTime timestamp;
  final RequestStatus status;
  final String? response;

  CustomerRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.requestText,
    DateTime? timestamp,
    this.status = RequestStatus.pending,
    this.response,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'requestText': requestText,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'response': response,
      };

  factory CustomerRequest.fromJson(Map<String, dynamic> json) =>
      CustomerRequest(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        requestText: json['requestText'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: RequestStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => RequestStatus.pending,
        ),
        response: json['response'] as String?,
      );

  CustomerRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? requestText,
    DateTime? timestamp,
    RequestStatus? status,
    String? response,
  }) =>
      CustomerRequest(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        requestText: requestText ?? this.requestText,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        response: response ?? this.response,
      );
}

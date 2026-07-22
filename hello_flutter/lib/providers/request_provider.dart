import 'package:flutter/material.dart';
import '../models/customer_request.dart';
import '../services/storage_service.dart';

class RequestProvider extends ChangeNotifier {
  final StorageService _storage;

  List<CustomerRequest> _requests = [];
  bool _isLoading = false;

  RequestProvider(this._storage);

  List<CustomerRequest> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;

  List<CustomerRequest> requestsForCustomer(String customerId) =>
      _requests.where((r) => r.customerId == customerId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<CustomerRequest> get pendingRequests =>
      _requests.where((r) => r.status == RequestStatus.pending).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();
    _requests = await _storage.getRequests();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRequest(CustomerRequest request) async {
    await _storage.addRequest(request);
    _requests.add(request);
    notifyListeners();
  }

  Future<void> updateRequest(CustomerRequest updated) async {
    await _storage.updateRequest(updated);
    final idx = _requests.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _requests[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> fulfillRequest(String id, {String? response}) async {
    final req = _requests.firstWhere((r) => r.id == id);
    final updated = req.copyWith(
      status: RequestStatus.fulfilled,
      response: response,
    );
    await updateRequest(updated);
  }

  Future<void> rejectRequest(String id, {String? response}) async {
    final req = _requests.firstWhere((r) => r.id == id);
    final updated = req.copyWith(
      status: RequestStatus.rejected,
      response: response,
    );
    await updateRequest(updated);
  }
}

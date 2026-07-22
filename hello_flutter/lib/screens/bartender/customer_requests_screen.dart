import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/customer_request.dart';
import '../../providers/request_provider.dart';

class CustomerRequestsScreen extends StatefulWidget {
  const CustomerRequestsScreen({super.key});

  @override
  State<CustomerRequestsScreen> createState() =>
      _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends State<CustomerRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().loadRequests();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showResponseDialog(
      BuildContext context, CustomerRequest request, bool fulfill) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          fulfill ? 'Fulfill Request' : 'Reject Request',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${request.requestText}"',
              style: const TextStyle(
                  color: Colors.white54, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    fulfill ? 'Add a note for the customer...' : 'Reason for rejection...',
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<RequestProvider>();
              if (fulfill) {
                provider.fulfillRequest(request.id,
                    response: ctrl.text.trim().isEmpty
                        ? 'Your request has been fulfilled!'
                        : ctrl.text.trim());
              } else {
                provider.rejectRequest(request.id,
                    response: ctrl.text.trim().isEmpty
                        ? 'Sorry, we cannot fulfill this request.'
                        : ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  fulfill ? const Color(0xFF2E7D32) : Colors.red,
            ),
            child: Text(
              fulfill ? 'Fulfill' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFFFB300),
          labelColor: const Color(0xFFFFB300),
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'All'),
          ],
        ),
        Expanded(
          child: Consumer<RequestProvider>(
            builder: (context, provider, _) {
              final pending = provider.pendingRequests;
              final all = List<CustomerRequest>.from(provider.requests)
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _RequestList(
                    requests: pending,
                    onFulfill: (r) =>
                        _showResponseDialog(context, r, true),
                    onReject: (r) =>
                        _showResponseDialog(context, r, false),
                    emptyMessage: '✅ No pending requests',
                    showActions: true,
                  ),
                  _RequestList(
                    requests: all,
                    onFulfill: (r) =>
                        _showResponseDialog(context, r, true),
                    onReject: (r) =>
                        _showResponseDialog(context, r, false),
                    emptyMessage: '📭 No requests yet',
                    showActions: false,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<CustomerRequest> requests;
  final void Function(CustomerRequest) onFulfill;
  final void Function(CustomerRequest) onReject;
  final String emptyMessage;
  final bool showActions;

  const _RequestList({
    required this.requests,
    required this.onFulfill,
    required this.onReject,
    required this.emptyMessage,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (requests.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5), fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: requests.length,
      itemBuilder: (context, i) => _RequestTile(
        request: requests[i],
        onFulfill: () => onFulfill(requests[i]),
        onReject: () => onReject(requests[i]),
        showActions: showActions && requests[i].status == RequestStatus.pending,
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final CustomerRequest request;
  final VoidCallback onFulfill;
  final VoidCallback onReject;
  final bool showActions;

  const _RequestTile({
    required this.request,
    required this.onFulfill,
    required this.onReject,
    required this.showActions,
  });

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.pending:
        return const Color(0xFFF57C00);
      case RequestStatus.fulfilled:
        return const Color(0xFF388E3C);
      case RequestStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = DateFormat('MMM d, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(color: _statusColor.withValues(alpha: 0.35))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.person, color: cs.primary, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.customerName,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(fmt.format(request.timestamp),
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.38),
                            fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(request.status.displayName,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Text(request.requestText,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.75), fontSize: 13)),
          ),
          if (request.response != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.reply,
                    color: cs.onSurface.withValues(alpha: 0.38), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(request.response!,
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontSize: 12)),
                ),
              ],
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFulfill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Fulfill'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

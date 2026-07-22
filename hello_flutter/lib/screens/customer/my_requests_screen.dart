import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _requestCtrl = TextEditingController();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().loadRequests();
    });
  }

  @override
  void dispose() {
    _requestCtrl.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    final text = _requestCtrl.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser!;
    final request = CustomerRequest(
      id: _uuid.v4(),
      customerId: user.id,
      customerName: user.name,
      requestText: text,
    );

    await context.read<RequestProvider>().addRequest(request);
    _requestCtrl.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request submitted! The bartender will review it.'),
          backgroundColor: Color(0xFF7B1FA2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Column(
      children: [
        // Request input
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6)),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✉️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Request a Drink',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _requestCtrl,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the drink you want or request a custom creation...',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),

        // Requests list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Requests',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: Consumer<RequestProvider>(
            builder: (context, provider, _) {
              final myRequests = provider.requestsForCustomer(user.id);

              if (myRequests.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📭', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('No requests yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: myRequests.length,
                itemBuilder: (context, i) =>
                    _RequestCard(request: myRequests[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CustomerRequest request;

  const _RequestCard({required this.request});

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

  IconData get _statusIcon {
    switch (request.status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.fulfilled:
        return Icons.check_circle;
      case RequestStatus.rejected:
        return Icons.cancel;
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
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.requestText,
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(request.status.displayName,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(fmt.format(request.timestamp),
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
          if (request.response != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🍹', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(request.response!,
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

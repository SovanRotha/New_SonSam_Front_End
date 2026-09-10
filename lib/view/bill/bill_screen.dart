import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/bill/bill_provider.dart';
import 'package:sansom/view/bill/edit_bill.dart';
import 'package:sansom/widget/bill/create_bill.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BillProvider>().getBills();
    });
  }

  Future<void> createBill() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateBill(),
    );

    if (!mounted || data == null) return;

    final billProvider = context.read<BillProvider>();
    final created = await billProvider.createBill(data);

    if (!mounted) return;

    if (created) {
      await billProvider.getBills();
    } else if (billProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(billProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: createBill),
        ],
      ),
      body: billProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : billProvider.errorMessage != null
          ? Center(child: Text(billProvider.errorMessage!))
          : billProvider.bills.isEmpty
          ? const Center(child: Text('No bills found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: billProvider.bills.length,
              itemBuilder: (context, index) {
                final bill = billProvider.bills[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        BillDetail(
                          label: 'Amount',
                          value: '\$${bill.amount.toStringAsFixed(2)}',
                        ),
                        BillDetail(
                          label: 'Account',
                          value:
                              bill.account?.name ??
                              'Account #${bill.accountId}',
                        ),
                        BillDetail(
                          label: 'Category',
                          value:
                              bill.category?.name ??
                              (bill.categoryId == null
                                  ? 'None'
                                  : 'Category #${bill.categoryId}'),
                        ),
                        BillDetail(label: 'Due date', value: bill.dueDate),
                        BillDetail(label: 'Status', value: bill.status),
                        if (bill.notes != null && bill.notes!.isNotEmpty)
                          BillDetail(label: 'Notes', value: bill.notes!),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // EDIT
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => EditBill(
                                    billId: bill.id,
                                    name: bill.name,
                                    amount: bill.amount,
                                    accountId: bill.accountId,
                                    categoryId: bill.categoryId,
                                    dueDate: bill.dueDate,
                                    status: bill.status,
                                    notes: bill.notes,
                                  ),
                                );

                                if (!mounted) return;

                                if (updated == true) {
                                  await context.read<BillProvider>().getBills();
                                }
                              },
                            ),

                            // DELETE
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Bill'),
                                      content: Text(
                                        'Are you sure you want to delete "${bill.name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm != true || !mounted) return;

                                final provider = context.read<BillProvider>();

                                final success = await provider.deleteBill(
                                  bill.id,
                                );

                                if (!mounted) return;

                                if (success) {
                                  await provider.getBills();

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Bill deleted successfully',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.errorMessage ??
                                            'Failed to delete bill',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BillDetail extends StatelessWidget {
  const BillDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $value'),
    );
  }
}

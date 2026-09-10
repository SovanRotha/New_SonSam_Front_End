
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/subscription/subscription_provider.dart';
import 'package:sansom/view/bill/edit_subscription.dart';
import 'package:sansom/widget/bill/create_subscription.dart';


class SubscribtionScreen extends StatefulWidget {
  const SubscribtionScreen({super.key});

  @override
  State<SubscribtionScreen> createState() =>
      _SubscribtionScreenState();
}

class _SubscribtionScreenState extends State<SubscribtionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<SubscriptionProvider>()
          .getSubscriptions();
    });
  }

  Future<void> createSubscription() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateSubscription(),
    );

    if (!mounted || data == null) return;

    final subscriptionProvider =
        context.read<SubscriptionProvider>();

    final created =
        await subscriptionProvider.createSubscription(data);

    if (!mounted) return;

    if (created) {
      await subscriptionProvider.getSubscriptions();
    } else if (subscriptionProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            subscriptionProvider.errorMessage!,
          ),
        ),
      );
    }
  }

  Future<void> deleteSubscription(int id) async {
    final provider =
        context.read<SubscriptionProvider>();

    final success =
        await provider.deleteSubscription(id);

    if (!mounted) return;

    if (success) {
      await provider.getSubscriptions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription deleted successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to delete subscription',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider =
        context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: createSubscription,
          ),
        ],
      ),

      body: subscriptionProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : subscriptionProvider.errorMessage != null
          ? Center(
              child: Text(
                subscriptionProvider.errorMessage!,
              ),
            )
          : subscriptionProvider.subscriptions.isEmpty
          ? const Center(
              child: Text('No subscriptions found'),
            )
          : ListView.builder(
              itemCount:
                  subscriptionProvider.subscriptions.length,

              itemBuilder: (context, index) {
                final subscription =
                    subscriptionProvider.subscriptions[index];

                return ListTile(
                  title: Text(
                    subscription.name,
                  ),

                  subtitle: Text(
                    '\$${subscription.amount.toStringAsFixed(2)}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),

                        onPressed: () async {
                          final updated =
                              await showDialog<bool>(
                            context: context,
                            builder: (_) {
                              return EditSubscription(
                                subscriptionId:
                                    subscription.id,
                                accountId: subscription.accountId,
                                categoryId: subscription.categoryId,
                                name: subscription.name,
                                amount:
                                    subscription.amount,
                                billingCycle:
                                  subscription.billingCycle,
                                nextPaymentDate:
                                  subscription.nextPaymentDate,
                                startDate: subscription.startDate,
                                endDate: subscription.endDate,
                                status: subscription.status ?? 'active',
                              );
                            },
                          );

                          if (!mounted) return;

                          if (updated == true) {
                            await context
                                .read<SubscriptionProvider>()
                                .getSubscriptions();
                          }
                        },
                      ),

                      // DELETE
                      IconButton(
                        icon: const Icon(Icons.delete),

                        onPressed: () async {
                          final confirm =
                              await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Delete Subscription',
                                ),

                                content: Text(
                                  'Are you sure you want to delete '
                                  '"${subscription.name}"?',
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child:
                                        const Text('Cancel'),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                    child:
                                        const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm != true ||
                              !mounted) {
                            return;
                          }

                          await deleteSubscription(
                            subscription.id,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}


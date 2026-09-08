import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/subscription/subscription_provider.dart';
import 'package:sansom/widget/bill/create_subscription.dart';

class SubscribtionScreen extends StatefulWidget {
  const SubscribtionScreen({super.key});

  @override
  State<SubscribtionScreen> createState() => _SubscribtionScreenState();
}

class _SubscribtionScreenState extends State<SubscribtionScreen> {

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // You can add any initialization logic here if needed
      final subscribtionProvider = context.read<SubscriptionProvider>();
      context.read<SubscriptionProvider>().getSubscriptions();
    });
  }

  Future<void> createSubscription() async {
    // Show a dialog to create a new subscription
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateSubscription(),
    );

    if (!mounted || data == null) return;

    final subscriptionProvider = context.read<SubscriptionProvider>();
    final created = await subscriptionProvider.createSubscription(data);

    if (!mounted) return;

    if (created) {
      await subscriptionProvider.getSubscriptions();
    } else if (subscriptionProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(subscriptionProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscribtion = context.watch<SubscriptionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribtion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: createSubscription,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: subscribtion.subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscribtion.subscriptions[index];
          return ListTile(
            title: Text(subscription.name ?? 'No Description'),
            subtitle: Text('\$${subscription.amount.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle button press for each subscription
                final subscriptionProvider = context.read<SubscriptionProvider>(); 
                            context.read<SubscriptionProvider>().deleteSubscription(subscription.id).then((_) {
                              // Refresh the list of subscriptions after deletion
                              subscriptionProvider.getSubscriptions();
                            });
              },
              child:  Icon(Icons.delete)),
            
          );
        },
      ),
    );
  }
}
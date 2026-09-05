import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/budget/budget_provider.dart';

class CreateBudget extends StatefulWidget {
  const CreateBudget({super.key});

  @override
  State<CreateBudget> createState() => _CreateBudgetState();
}

class _CreateBudgetState extends State<CreateBudget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  DateTime? dateTime;
  

  bool rollover = false;

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        dateTime = picked;
      });
    }
  }

  // Future<void> selectToDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: toDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       toDate = picked;
  //     });
  //   }
  // }

  Future<void> createBudget() async {
    if (nameController.text.isEmpty ||
        totalController.text.isEmpty ||
        dateTime == null ||
        totalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    final budgetData = {
      'name': nameController.text,
      'month':
          '${dateTime!.year}-${dateTime!.month.toString().padLeft(2, '0')}-01',
      'total_limit': double.parse(totalController.text),
      'rollover_enabled': rollover,
    };

    final success = await context
        .read<BudgetProvider>()
        .createBudget(budgetData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget created successfully'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<BudgetProvider>().errorMessage ??
                'Failed to create budget',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Budget Name
            const Text(
              'Budget Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter budget name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // From Date
            const Text(
              'From',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => selectFromDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateTime == null
                      ? 'Select date'
                      : '${dateTime!.day}/${dateTime!.month}/${dateTime!.year}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // To Date
            // const Text(
            //   'To',
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),

            // const SizedBox(height: 8),

            // GestureDetector(
            //   onTap: () => selectToDate(context),
            //   child: Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       border: Border.all(),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Text(
            //       toDate == null
            //           ? 'Select end date'
            //           : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
            //     ),
            //   ),
            // ),

            const SizedBox(height: 20),

            // Total Limit
            const Text(
              'Total Limit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter total budget limit',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Rollover
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Rollover'),
              value: rollover,
              onChanged: (value) {
                setState(() {
                  rollover = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createBudget,
                child: const Text('Create Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
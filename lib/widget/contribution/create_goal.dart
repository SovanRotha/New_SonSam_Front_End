
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({super.key});

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  final TextEditingController goalNameController =
      TextEditingController();

  final TextEditingController goalDescriptionController =
      TextEditingController();

  final TextEditingController goalTargetAmountController =
      TextEditingController();

  DateTime? selectedTargetDate;

  bool isCreating = false;

  @override
  void dispose() {
    goalNameController.dispose();
    goalDescriptionController.dispose();
    goalTargetAmountController.dispose();
    super.dispose();
  }

  // =========================
  // SELECT TARGET DATE
  // =========================
  Future<void> selectTargetDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedTargetDate = pickedDate;
      });
    }
  }

  // =========================
  // CREATE GOAL
  // =========================
  Future<void> createGoal() async {
    final name = goalNameController.text.trim();
    final description =
        goalDescriptionController.text.trim();
    final targetAmount =
        goalTargetAmountController.text.trim();

    // Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal name'),
        ),
      );
      return;
    }

    // Validate target amount
    if (targetAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter target amount'),
        ),
      );
      return;
    }

    // Validate date
    if (selectedTargetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select target date'),
        ),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    // Format date as YYYY-MM-DD
    final targetDate =
        '${selectedTargetDate!.year.toString().padLeft(4, '0')}-'
        '${selectedTargetDate!.month.toString().padLeft(2, '0')}-'
        '${selectedTargetDate!.day.toString().padLeft(2, '0')}';

    final goalData = {
      'name': name,
      'description':
          description.isEmpty ? null : description,
      'target_amount': double.parse(targetAmount),
      'target_date': targetDate,

      // Default status
      'status': 'active',
    };

    final goalProvider =
        context.read<GoalProvider>();

    final success =
        await goalProvider.createGoal(goalData);

    if (!mounted) return;

    setState(() {
      isCreating = false;
    });

    if (success) {
      // Immediately get the newest goals
      await goalProvider.getGoals();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goalProvider.errorMessage ??
                'Failed to create goal',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // GOAL NAME
              // =========================
              TextField(
                controller: goalNameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // DESCRIPTION
              // =========================
              TextField(
                controller: goalDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // TARGET AMOUNT
              // =========================
              TextField(
                controller:
                    goalTargetAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // TARGET DATE
              // =========================
              InkWell(
                onTap: selectTargetDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Date',
                    border: OutlineInputBorder(),
                    suffixIcon:
                        Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedTargetDate == null
                        ? 'Select target date'
                        : '${selectedTargetDate!.year}-'
                          '${selectedTargetDate!.month.toString().padLeft(2, '0')}-'
                          '${selectedTargetDate!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // STATUS
              // =========================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status: Active',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // CREATE BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isCreating ? null : createGoal,
                  child: isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


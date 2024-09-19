import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/utils.dart';
import '../../bloc/parent_bloc/usage_app/usage_app_bloc.dart';

class ChildAppUsageScreen extends StatefulWidget {
  const ChildAppUsageScreen({super.key});

  @override
  State<ChildAppUsageScreen> createState() => _ChildAppUsageScreenState();
}

class _ChildAppUsageScreenState extends State<ChildAppUsageScreen> {
  late UsageAppBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = context.read<UsageAppBloc>();
    bloc.add(FetchUsageAppEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời gian sử dụng ứng dụng của trẻ'),
      ),
      body: BlocBuilder<UsageAppBloc, UsageAppState>(
        builder: (context, state) {
          if (state.model.isNotEmpty) {
            return ListView.builder(
              itemCount: state.model.length,
              itemBuilder: (context, index) {
                final app = state.model[index];
                return ListTile(
                  leading: Image.memory(
                    base64Decode(app.icon),
                    width: 30,
                    height: 30,
                  ),
                  title: Text(app.name),
                  subtitle: Text(Utils().formatUsageTime(app.usageTime)),
                );
              },
            );
          } else if (state.error.isNotEmpty) {
            return Center(
              child: Text(
                state.error,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/parent_bloc/web_blocked/web_blocked_bloc.dart';

class WebBlockedScreen extends StatefulWidget {
  const WebBlockedScreen({super.key});

  @override
  State<WebBlockedScreen> createState() => _WebBlockedScreenState();
}

class _WebBlockedScreenState extends State<WebBlockedScreen> {
  late WebBlockedBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<WebBlockedBloc>();
    bloc.add(FetchWebBlockedEvent());
  }

  void _showAddWebsiteDialog() {
    final TextEditingController websiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm mục bị chặn'),
          content: TextField(
            controller: websiteController,
            decoration: const InputDecoration(hintText: 'Nhập URL trang web'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Thêm'),
              onPressed: () {
                final String website = websiteController.text.trim();
                if (website.isNotEmpty) {
                  bloc.add(SendWebBlockedEvent(website));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách các trang web bị chặn'),
      ),
      body: BlocBuilder<WebBlockedBloc, WebBlockedState>(
        buildWhen: (previous, current) =>
            previous.listWebBlocked != current.listWebBlocked ||
            previous.error != current.error,
        builder: (context, state) {
          if (state.listWebBlocked.isNotEmpty) {
            return ListView.builder(
              itemCount: state.listWebBlocked.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.listWebBlocked[index]),
                );
              },
            );
          } else if (state.error.isNotEmpty) {
            return Center(child: Text(state.error));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWebsiteDialog,
        tooltip: 'Thêm trang web',
        child: const Icon(Icons.add),
      ),
    );
  }
}

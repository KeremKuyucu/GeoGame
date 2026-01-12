import 'package:flutter/material.dart';

import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/drawer_widget.dart';
import 'package:geogame/widgets/profile_view_widget.dart';
import 'package:geogame/widgets/profiles_widgets.dart';

import 'profiles_controller.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final ProfilesController _controller = ProfilesController();

  @override
  @override
  void initState() {
    super.initState();
    _controller.fetchUserProfile().then((_) {
      if (!mounted) return;
      setState(() {});
      if (_controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_controller.isAuthenticated && !_controller.isLoading) {
      return ProfilesGuestView(controller: _controller);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localization.t('profile.title').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.teal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.fetchUserProfile().then((_) {
              if (mounted) setState(() {});
            }),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileViewWidget(
              name: _controller.userName,
              avatarUrl: _controller.userAvatar,
              totalScore: _controller.totalScore,
              stats: _controller.statsData,
            ),
    );
  }
}

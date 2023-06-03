import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubit/playlist_cubit.dart';
import '../../model/playlist.dart';
import '../app_drawer.dart';
import '../player.dart';
import '../roster_list.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width >= 840;

    const bodyContents = [
      Player(),
      Expanded(child: RosterList()),
    ];
    return Scaffold(
      appBar: !isLarge ? AppBar(title: _buildTitle()) : null,
      endDrawer: !isLarge ? const AppDrawer() : null,
      body: isLarge
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AppBar(title: _buildTitle(isLarge: isLarge)),
                      ...bodyContents,
                    ],
                  ),
                ),
                AppDrawer(isLargeScreen: isLarge)
              ],
            )
          : const Column(children: bodyContents),
    );
  }

  BlocBuilder<PlaylistCubit, PlaylistState> _buildTitle(
      {bool isLarge = false}) {
    Playlist? currentPlaylist;

    return BlocBuilder<PlaylistCubit, PlaylistState>(builder: (context, rs) {
      if (rs is PlaylistStateLoading) {
        currentPlaylist = rs.selectedRoster;
      }
      if (rs is PlaylistStateSuccess) {
        currentPlaylist = rs.selectedRoster;
      }
      return InkWell(
        onTap: !isLarge ? () => Scaffold.of(context).openEndDrawer() : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title +
                (currentPlaylist != null ? ' - ${currentPlaylist!.name}' : '')),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      );
    });
  }
}

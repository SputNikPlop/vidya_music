import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/cubit/playlist_cubit.dart';
import '../controller/cubit/theme_cubit.dart';
import '../controller/services/package_info_singleton.dart';
import '../model/playlist.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.isLargeScreen = false});

  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    Playlist? currentPlaylist;
    List<Playlist>? availablePlaylists;

    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, rs) {
        if (rs is PlaylistStateLoading) {
          currentPlaylist = rs.selectedPlaylist;
          availablePlaylists = rs.availablePlaylists;
        }
        if (rs is PlaylistStateSuccess) {
          currentPlaylist = rs.selectedPlaylist;
          availablePlaylists = rs.availablePlaylists;
        }
        if (rs is PlaylistStateError) {
          availablePlaylists = rs.availablePlaylists;
        }
        return Drawer(
          shape: isLargeScreen ? const LinearBorder() : null,
          child: Column(
            children: <Widget>[
              _buildDrawerHeader(context),
              Expanded(
                child: SafeArea(
                  left: true,
                  right: true,
                  top: false,
                  bottom: false,
                  child: ListView(
                    padding: Provider.of<bool>(context)
                        ? EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom)
                        : null,
                    children: [
                      if (availablePlaylists != null)
                        ...availablePlaylists!
                            .map((p) => _buildPlaylistTile(
                                context, p, p == currentPlaylist))
                            .toList(),
                      _buildDivider(context),
                      _buildThemeTiles(),
                      _buildDivider(context),
                      _buildAboutTile(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  DrawerHeader _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/icon/app_icon.png'
                    : 'assets/icon/app_icon_monochrome.png',
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
            ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Vidya Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ));
  }

  Divider _buildDivider(BuildContext context) {
    return Divider(
      height: 1.0,
      thickness: 0.0,
      color: Theme.of(context).dividerColor,
      indent: 16,
      endIndent: 16,
    );
  }

  ListTile _buildPlaylistTile(
      BuildContext context, Playlist playlist, bool isSelected) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(playlist.name),
      subtitle: Text(playlist.description),
      onTap: () async {
        Scaffold.of(context).closeEndDrawer();
        await BlocProvider.of<PlaylistCubit>(context, listen: false)
            .setPlaylist(playlist);
      },
      selected: isSelected,
    );
  }

  BlocBuilder<ThemeCubit, ThemeState> _buildThemeTiles() {
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, themeState) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System Theme'),
            onTap: () {
              BlocProvider.of<ThemeCubit>(context)
                  .setThemeMode(ThemeMode.system);
            },
            selected: themeState.themeMode == ThemeMode.system,
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light Theme'),
            onTap: () {
              BlocProvider.of<ThemeCubit>(context)
                  .setThemeMode(ThemeMode.light);
            },
            selected: themeState.themeMode == ThemeMode.light,
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Theme'),
            onTap: () {
              BlocProvider.of<ThemeCubit>(context).setThemeMode(ThemeMode.dark);
            },
            selected: themeState.themeMode == ThemeMode.dark,
          ),
        ],
      );
    });
  }

  ListTile _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.help_outline),
      title: const Text('About'),
      onTap: () async {
        final packageInfo = await PackageInfoSingleton.instance;

        // ignore: use_build_context_synchronously
        if (!context.mounted) return;

        showAboutDialog(
            context: context,
            applicationName: packageInfo.appName,
            applicationVersion: packageInfo.version,
            applicationLegalese:
                "Licensed under AGPLv3+, developed by MateusRodCosta",
            children: [
              const SizedBox(height: 8),
              const Text(
                  'A player for the Vidya Intarweb Playlist (aka VIP Aersia)'),
              const SizedBox(height: 8),
              GestureDetector(
                child: Text('Vidya Intarweb Playlist by Cats777',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                onTap: () {
                  launchUrl(Uri.parse('https://www.vipvgm.net/'),
                      mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 8),
              const Text('All Tracks © & ℗ Their Respective Owners'),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Source code is available at ',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextSpan(
                      text: 'https://github.com/MateusRodCosta/vidya_music',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                              Uri.parse(
                                  'https://github.com/MateusRodCosta/vidya_music'),
                              mode: LaunchMode.externalApplication);
                        },
                    ),
                  ],
                ),
              ),
            ]);
      },
    );
  }
}

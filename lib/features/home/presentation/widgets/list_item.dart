import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:external_video_player_launcher/external_video_player_launcher.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:mime/mime.dart';
import 'package:samftp/core/routes/app_routes.gr.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';
import 'package:share_plus/share_plus.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.model, required this.base});

  final ClickableModel model;
  final String base;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(.6),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.white.withOpacity(.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: Colors.white,
        titleAlignment: ListTileTitleAlignment.center,
        leading: Icon(model.isFile ? Icons.file_copy : Icons.folder),
        title: Text(
          (model.title.endsWith('/')
                  ? model.title.substring(0, model.title.length - 1)
                  : model.title)
              .split('/')
              .last,
        ),
        trailing: !(Platform.isAndroid || Platform.isIOS)
            ? model.isFile
                ? PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'play',
                          onTap: () {
                            print(base);
                            print(model);
                            if (!model.isFile) {
                              context.router.push(
                                ContentRoute(
                                  title: Uri.decodeFull(
                                      model.route.split('/').last),
                                  base: base,
                                  url: base + model.route,
                                ),
                              );
                            } else {
                              // play video
                              final url = base + model.route;
                              print(url);
                              // context.router.push(
                              //   VideoPlayerRoute(
                              //     url: url,
                              //     title: Uri.decodeFull(model.route.split('/').last),
                              //   ),
                              // );
                              if (isImage(url)) {
                                final imageProvider = Image.network(url).image;
                                showImageViewer(
                                  context,
                                  imageProvider,
                                  backgroundColor: Colors.black,
                                  immersive: true,
                                  useSafeArea: true,
                                );
                              } else {
                                // if(Platform.isAndroid) {
                                //   ExternalVideoPlayerLauncher.launchVlcPlayer(url, MIME.video, {
                                //   "title": (model.title.endsWith('/')
                                //           ? model.title.substring(0, model.title.length - 1)
                                //           : model.title)
                                //       .split('/')
                                //       .last,
                                // });
                                context.router.push(
                                  VideoPlayerRoute(
                                    url: url,
                                    title: HtmlCharacterEntities.decode(
                                        model.route.split('/').last),
                                  ),
                                );
                                // } else if(Platform.isMacOS) {
                                //   Process.run('/opt/homebrew/bin/mpv', [url], runInShell: true);
                                // }
                              }
                            }
                          },
                          child: const Text('Play Locally'),
                        ),
                        PopupMenuItem(
                          value: 'mpv',
                          child: const Text('Play with mpv'),
                          onTap: () {
                            if (model.isFile) {
                              final url = base + model.route;
                              if (Platform.isMacOS) {
                                Process.run(
                                  '/opt/homebrew/bin/mpv',
                                  [url],
                                  runInShell: true,
                                ).then((value) {
                                  if (value.exitCode != 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please install mpv player on your device'),
                                      ),
                                    );
                                  }
                                });
                              } else {
                                Share.share(url);
                              }
                            }
                          },
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_horiz_rounded),
                  )
                : null
            : null,
        onLongPress: () {
          if (model.isFile) {
            final url = base + model.route;
            if (Platform.isAndroid) {
              ExternalVideoPlayerLauncher.launchOtherPlayer(url, MIME.video, {
                "title": (model.title.endsWith('/')
                        ? model.title.substring(0, model.title.length - 1)
                        : model.title)
                    .split('/')
                    .last,
              });
            } else if (Platform.isMacOS) {
              Process.run('/opt/homebrew/bin/mpv', [url], runInShell: true);
            } else {
              Share.share(url);
            }
          }
        },
        onTap: () async {
          print(base);
          print(model);
          if (!model.isFile) {
            context.router.push(
              ContentRoute(
                title: Uri.decodeFull(model.route.split('/').last),
                base: base,
                url: base + model.route,
              ),
            );
          } else {
            // play video
            final url = base + model.route;
            print(url);
            // context.router.push(
            //   VideoPlayerRoute(
            //     url: url,
            //     title: Uri.decodeFull(model.route.split('/').last),
            //   ),
            // );
            if (isImage(url)) {
              final imageProvider = Image.network(url).image;
              showImageViewer(
                context,
                imageProvider,
                backgroundColor: Colors.black,
                immersive: true,
                useSafeArea: true,
              );
            } else {
              // if(Platform.isAndroid) {
              //   ExternalVideoPlayerLauncher.launchVlcPlayer(url, MIME.video, {
              //   "title": (model.title.endsWith('/')
              //           ? model.title.substring(0, model.title.length - 1)
              //           : model.title)
              //       .split('/')
              //       .last,
              // });
              context.router.push(
                VideoPlayerRoute(
                  url: url,
                  title:
                      HtmlCharacterEntities.decode(model.route.split('/').last),
                ),
              );
              // } else if(Platform.isMacOS) {
              //   Process.run('/opt/homebrew/bin/mpv', [url], runInShell: true);
              // }
            }
          }
        },
      ),
    );
  }

  bool isImage(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType?.startsWith('image/') ?? false;
  }
}

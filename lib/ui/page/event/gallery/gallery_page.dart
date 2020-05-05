import 'dart:io';

import 'package:eventmanagement/bloc/event/gallery/gallery_bloc.dart';
import 'package:eventmanagement/bloc/event/gallery/gallery_state.dart';
import 'package:eventmanagement/bloc/user/user_bloc.dart';
import 'package:eventmanagement/intl/app_localizations.dart';
import 'package:eventmanagement/main.dart';
import 'package:eventmanagement/model/event/gallery/gallery_data.dart';
import 'package:eventmanagement/ui/page/event/gallery/video_thumbnail.dart';
import 'package:eventmanagement/ui/platform/widget/platform_scroll_bar.dart';
import 'package:eventmanagement/utils/vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as Path;

class GalleryPage extends StatefulWidget {
  @override
  createState() => _GalleryState();
}

class _GalleryState extends State<GalleryPage> {
  Future _futureSystemPath;
  GalleryBloc _galleryBloc;
  final _bannerViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _galleryBloc = BlocProvider.of<GalleryBloc>(context);
    _galleryBloc
        .authTokenSave(BlocProvider.of<UserBloc>(context).state.authToken);
    _futureSystemPath = getSystemDirPath();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScrollbar(
      child: Stack(
        children: <Widget>[
          BlocBuilder<GalleryBloc, GalleryState>(
            bloc: _galleryBloc,
            condition: (prevState, newState) {
              return (prevState.galleryList.length == 0 &&
                      newState.galleryList.length > 0) ||
                  (prevState.galleryList.length > 0 &&
                      newState.galleryList.length == 0);
            },
            builder: (_, state) {
              if (state.galleryList.isEmpty)
                return Container(
                  margin: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildBannerImage(),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: DecoratedBox(
                            decoration: BoxDecoration(color: bgColorSecondary),
                            child: Center(
                                child: _buildUploadMediaInfoText(
                                    AppLocalizations.of(context)
                                        .labelUploadEventGallery,
                                    false))),
                      ),
                    ],
                  ),
                );
              else {
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        _buildBannerImage(),
                        const SizedBox(height: 16.0),
                        _buildGalleryMedia(),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: _buildUploadGalleryRow()),
        ],
      ),
    );
  }

  Widget _buildBannerImage() => FutureBuilder(
      key: _bannerViewKey,
      future: _futureSystemPath,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return SizedBox.shrink();
        else
          return GestureDetector(
            onTap: () => showImagePickerBottomSheet(true, false),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColorSecondary,
                  ),
                  child: BlocBuilder(
                      bloc: _galleryBloc,
                      condition: (prevState, newState) {
                        return prevState.banner != newState.banner;
                      },
                      builder: (context, state) {
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            if (isValid(state.banner))
                              Image(
                                width: double.infinity,
                                fit: BoxFit.cover,
                                image: state.banner.startsWith('http')
                                    ? NetworkToFileImage(
                                        url: state.banner,
                                        file: File(Path.join(
                                            snapshot.data,
                                            'Pictures',
                                            state.banner.substring(
                                                state.banner.lastIndexOf('/') +
                                                    1))),
                                        debug: true,
                                      )
                                    : FileImage(
                                        File(state.banner),
                                      ),
                              ),
                            _buildUploadMediaInfoText(
                              isValid(state.banner)
                                  ? AppLocalizations.of(context)
                                      .labelUpdateBanner
                                  : AppLocalizations.of(context)
                                      .labelUploadBanner,
                              true,
                            ),
                          ],
                        );
                      })),
            ),
          );
      });

  Widget _buildUploadMediaInfoText(String infoText, bool withIcon) => RichText(
        text: TextSpan(
          children: [
            if (withIcon)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.cloud_upload),
              ),
            if (withIcon)
              WidgetSpan(
                child: const SizedBox(width: 8.0),
              ),
            TextSpan(
              text: infoText,
              style: Theme.of(context).textTheme.subtitle,
            ),
          ],
        ),
      );

  Widget _buildGalleryMedia() {
    return FutureBuilder(
        future: _futureSystemPath,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return SizedBox.shrink();
          else
            return BlocBuilder<GalleryBloc, GalleryState>(
                bloc: _galleryBloc,
                condition: (prevState, newState) {
                  return prevState.galleryList != newState.galleryList;
                },
                builder: (context, state) {
                  return GridView.builder(
                      padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.galleryList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                      ),
                      itemBuilder: (context, position) {
                        GalleryData galleryData = state.galleryList[position];
                        return Padding(
                          key: ValueKey(galleryData.id),
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: <Widget>[
                              if (galleryData.type == 'image' &&
                                  (isValid(galleryData.localFilePath) ||
                                      isValid(galleryData.link)))
                                Image(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  image: isValid(galleryData.localFilePath)
                                      ? FileImage(
                                          File(galleryData.localFilePath))
                                      : NetworkToFileImage(
                                          url: galleryData.link,
                                          file: File(Path.join(
                                              snapshot.data,
                                              'Pictures',
                                              galleryData.link.substring(
                                                  galleryData.link
                                                          .lastIndexOf('/') +
                                                      1))),
                                          debug: true,
                                        ),
                                ),
                              if (galleryData.type == 'video' &&
                                  (isValid(galleryData.localFilePath) ||
                                      isValid(galleryData.link)))
                                VideoThumbnail(
                                    isValid(galleryData.localFilePath)
                                        ? galleryData.localFilePath
                                        : galleryData.link),
                              _buildRemoveMediaButton(galleryData),
                            ],
                          ),
                        );
                      });
                });
        });
  }

  Widget _buildRemoveMediaButton(GalleryData galleryData) => InkWell(
        onTap: () async {
          _galleryBloc.removeGalleryItem(galleryData);
          if (isValid(galleryData.localFilePath)) {
            final fileToDelete = File(galleryData.localFilePath);

            if (galleryData.ownedByApp) {
              bool exist = await fileToDelete.exists();
              if (exist) fileToDelete.delete();
            }
            if (galleryData.type == 'video') {
              final thumbToDelete = File(
                Path.join(
                  await getSystemDirPath(),
                  'Pictures',
                  '${galleryData.localFilePath.substring(galleryData.localFilePath.lastIndexOf('/') + 1, galleryData.localFilePath.lastIndexOf('.'))}.jpg',
                ),
              );
              bool exist = await thumbToDelete.exists();
              if (exist) thumbToDelete.delete();
            }
          } else {
            final fileToDelete = File(Path.join(
                await getSystemDirPath(),
                'Pictures',
                galleryData.link
                    .substring(galleryData.link.lastIndexOf('/') + 1)));

            bool exist = await fileToDelete.exists();
            if (exist) fileToDelete.delete();
          }
        },
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
              color: bgColorSecondary.withAlpha(150),
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(36.0))),
          child: Icon(Icons.delete_forever),
        ),
      );

  Widget _buildUploadGalleryRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildUploadGalleryImageButton(false),
          const SizedBox(width: 16.0),
          _buildUploadGalleryVideoButton(true),
        ],
      ),
    );
  }

  Widget _buildUploadGalleryImageButton(bool video) {
    return RaisedButton.icon(
        onPressed: () {
          showImagePickerBottomSheet(false, video);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 0.0,
        color: bgColorButton.withAlpha(100),
        icon: Icon(
          Icons.image,
          color: colorIcon,
        ),
        label: Text(
          AppLocalizations.of(context).labelUploadImage,
          style: Theme.of(context).textTheme.button,
        ));
  }

  Widget _buildUploadGalleryVideoButton(bool video) {
    return RaisedButton.icon(
        onPressed: () {
          showImagePickerBottomSheet(false, video);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 0.0,
        color: bgColorButton.withAlpha(100),
        icon: Icon(
          Icons.video_library,
          color: colorIcon,
        ),
        label: Text(
          AppLocalizations.of(context).labelUploadVideo,
          style: Theme.of(context).textTheme.button,
        ));
  }

  void showImagePickerBottomSheet(bool banner, bool video) {
    if (isPlatformAndroid)
      showModalBottomSheet(
          context: context,
          builder: (ctx) => _buildImagePickerView(banner, video));
    else
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: _buildImagePickerView(banner, video),
          );
        },
      );
  }

  Widget _buildImagePickerView(bool banner, bool video) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _openCamera(banner, video);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.camera,
                  size: 32.0,
                ),
                Text(AppLocalizations.of(context).labelCamera),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _openGallery(banner, video);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.filter,
                  size: 32.0,
                ),
                Text(AppLocalizations.of(context).labelGallery),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCamera(bool banner, bool video) async {
    var image;

    if (video)
      image = await ImagePicker.pickVideo(source: ImageSource.camera);
    else
      image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 80);

    print('Camera Image/Video Path--->${image?.path}');
    if (image != null) {
      if (banner) {
        await _deleteExistingBanner();
        _galleryBloc.addBanner(image.path);
      } else
        _galleryBloc.addGalleryItem(
          GalleryData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            localFilePath: image.path,
            type: video ? 'video' : 'image',
            uploadRequired: true,
            ownedByApp: true,
          ),
        );
    }
  }

  Future<void> _openGallery(bool banner, bool video) async {
    var image;
    if (video)
      image = await ImagePicker.pickVideo(source: ImageSource.gallery);
    else
      image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);

    print('Gallery Image/Video Path--->${image?.path}');
    if (image != null) {
      if (banner) {
        await _deleteExistingBanner();
        _galleryBloc.addBanner(image.path);
      } else
        _galleryBloc.addGalleryItem(
          GalleryData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            localFilePath: image.path,
            type: video ? 'video' : 'image',
            uploadRequired: true,
            ownedByApp: !video,
          ),
        );
    }
  }

  Future<void> _deleteExistingBanner() async {
    if (isValid(_galleryBloc.state.banner)) {
      File fileToDelete;

      print('_galleryBloc.state.banner ${_galleryBloc.state.banner}');
      if (_galleryBloc.state.banner.startsWith('http')) {
        fileToDelete = File(Path.join(
            await getSystemDirPath(),
            'Pictures',
            _galleryBloc.state.banner
                .substring(_galleryBloc.state.banner.lastIndexOf('/') + 1)));
      } else {
        fileToDelete = File(_galleryBloc.state.banner);
      }

      bool exist = await fileToDelete.exists();

      print('fileToDelete.path ${fileToDelete.path} $exist');
      if (exist) fileToDelete.delete();
    }
  }
}

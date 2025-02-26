import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<void> requestStoragePermission() async {
    // var status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }
  }

  String getFileExtension(String url) {
    return url
        .split('.')
        .last
        .split('?')
        .first; // Extrait l'extension du fichier
  }

  Future<void> downloadAndSaveFile(String url, BuildContext context) async {
    // await requestStoragePermission();

    // try {
    //   showCustomSnackBar("sauvegarde_en_cours");
    //   // Déduire l'extension de fichier
    //   String fileExtension = getFileExtension(url);
    //   bool isVideo = fileExtension == 'mp4' || fileExtension == 'mov';

    //   // Téléchargement du fichier dans la mémoire
    //   var response = await _dio.get(
    //     url,
    //     options: Options(responseType: ResponseType.bytes),
    //   );

    //   Uint8List bytes = Uint8List.fromList(response.data);

    //   var result;
    //   if (isVideo) {
    //     // Enregistrement des vidéos en utilisant un fichier temporaire local
    //     final tempDir = await getTemporaryDirectory();
    //     final tempPath = '${tempDir.path}/temp_video.$fileExtension';
    //     File tempFile = await File(tempPath).writeAsBytes(bytes);

    //     result = await ImageGallerySaver.saveFile(tempFile.path);
    //     tempFile
    //         .delete(); // Nettoyage du fichier temporaire après l'enregistrement
    //   } else {
    //     // Enregistrement des images directement depuis la mémoire
    //     result = await ImageGallerySaver.saveImage(bytes);
    //   }

    //   if (result['isSuccess'] == true) {
    //     showCustomSnackBar("sauvegarde_terminee");
    //   } else {
    //     showCustomSnackBar("erreur_sauvegarde");
    //   }
    // } catch (e) {
    //   showCustomSnackBar(
    //       "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    // }
  }
}

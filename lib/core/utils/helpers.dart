import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class GifCache {
  static final Map<String, List<String>> _cache = {};

  static List<String>? get(String query) => _cache[query];
  static void set(String query, List<String> gifs) => _cache[query] = gifs;
}

abstract class Helpers {
  static final random = Random();

  static String randomPictureUrl() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }

  static DateTime randomDate() {
    final random = Random();
    final currentDate = DateTime.now();
    return currentDate.subtract(Duration(seconds: random.nextInt(200000)));
  }

  static String countryCodeToEmoji(String countryCode) {
    final int firstLetter =
        countryCode.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter =
        countryCode.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  static Future<List<String>> fetchGifs(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.giphy.com/v1/gifs/search?api_key=pwXu0t7iuNVm8VO5bgND2NzwCpVH9S0F&q=$query&limit=25&offset=0&rating=G&lang=en'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<String> gifs = (data['data'] as List).map<String>((gif) {
          return gif['images']['downsized_medium']['url'] as String;
        }).toList();

        // Cache les résultats
        GifCache.set(query, gifs);

        return gifs;
      } else {
        throw Exception('Failed to load GIFs');
      }
    } catch (e) {
      print('Error fetching GIFs: $e');
      throw Exception('Error fetching GIFs');
    }
  }

  static Map<String, List<String>> stopWordsByLanguage = {
    'fr': [
      'le',
      'la',
      'de',
      'et',
      'du',
      'un',
      'une',
      'des',
      'pour',
      'dans',
      'avec'
    ],
    'en': ['the', 'and', 'for', 'a', 'to', 'in', 'with', 'is', 'at', 'of'],
    'de': [
      'der',
      'die',
      'das',
      'und',
      'für',
      'ein',
      'eine',
      'mit',
      'in',
      'von'
    ],
    'es': ['el', 'la', 'y', 'de', 'un', 'una', 'para', 'con', 'en', 'por'],
    'it': ['il', 'la', 'un', 'una', 'di', 'e', 'per', 'con', 'in', 'da'],
    'pt': ['o', 'a', 'e', 'de', 'para', 'com', 'em', 'por', 'um', 'uma'],
    'ar': ['ال', 'و', 'من', 'إلى', 'عن', 'في', 'مع', 'على'],
    'pl': ['w', 'na', 'i', 'z', 'dla', 'do', 'od', 'o', 'jest'],
    'tr': ['ve', 'bir', 'bu', 'da', 'ile', 'için', 'de'],
  };

  static List locale = [
    {'name': 'English (US)', 'locale': Locale('en', 'US')},
    {'name': 'Français (FR)', 'locale': Locale('fr', 'FR')},
    {'name': 'Español (ES)', 'locale': Locale('es', 'ES')},
    {'name': 'Italiano (IT)', 'locale': Locale('it', 'IT')},
    {'name': 'العربية (AR)', 'locale': Locale('ar', 'AR')},
    {'name': 'Português (PT)', 'locale': Locale('pt', 'PT')},
    {'name': 'Deutsch (DE)', 'locale': Locale('de', 'DE')},
    {'name': 'Türkçe (TR)', 'locale': Locale('tr', 'TR')},
    {'name': 'Polski (PL)', 'locale': Locale('pl', 'PL')}
  ];

  static List emoji = [
    'assets/0.gif',
    'assets/1.gif',
    'assets/2.gif',
    'assets/3.gif',
    'assets/4.gif',
    'assets/5.gif',
    'assets/6.gif',
  ];

  static List<Map<String, dynamic>> genders = [
    {'label': 'homme', 'icon': Icons.male},
    {'label': 'femme', 'icon': Icons.female},
  ];

  static List<Map<String, dynamic>> categoriesVente = [
    {
      "title": "Immobilier & Hébergement",
      "icon": Icons.home,
      "subcategories": [
        "Vente immobilière",
        "Location immobilière",
        "Colocation & Sous-location",
        "Bureaux & Espaces de travail",
      ],
    },
    {
      "title": "Véhicules & Mobilité",
      "icon": Icons.directions_car,
      "subcategories": [
        "Voitures & 4x4",
        "Motos & Scooters",
        "Vélos & Trottinettes électriques",
        "Camions & Utilitaires",
        "Bateaux & Jet-skis",
        "Pièces & Accessoires auto/moto",
        "Services automobiles",
      ],
    },
    {
      "title": "Informatique, High-Tech & Jeux",
      "icon": Icons.computer,
      "subcategories": [
        "Ordinateurs & Accessoires",
        "Téléphones & Tablettes",
        "Consoles & Jeux vidéo",
        "TV, Audio & Vidéo",
        "Objets connectés & Gadgets",
      ],
    },
    {
      "title": "Maison, Meubles & Décoration",
      "icon": Icons.weekend,
      "subcategories": [
        "Meubles & Rangement",
        "Électroménager",
        "Décoration & Arts de la table",
        "Jardin & Bricolage",
      ],
    },
    {
      "title": "Mode & Accessoires",
      "icon": Icons.shopping_bag,
      "subcategories": [
        "Vêtements Hommes",
        "Vêtements Femmes",
        "Vêtements Enfants & Bébés",
        "Chaussures & Sneakers",
        "Montres & Bijoux",
        "Sacs & Accessoires de mode",
        "Lunettes de soleil & Optique",
      ],
    },
    {
      "title": "Entreprises, Services & Événements",
      "icon": Icons.business,
      "subcategories": [
        "Offres d’emploi & Recrutement",
        "Cours & Formations",
        "Services à domicile",
        "Marketing & Communication",
        "Services financiers & Juridiques",
        "Billetterie & Événements",
      ],
    },
    {
      "title": "Loisirs, Sports & Divertissement",
      "icon": Icons.sports_soccer,
      "subcategories": [
        "Équipements sportifs",
        "Musique & Instruments",
        "Jouets & Jeux de société",
        "Camping & Plein air",
      ],
    },
    {
      "title": "Éducation & Fournitures scolaires",
      "icon": Icons.menu_book,
      "subcategories": [
        "Livres & Manuels scolaires",
        "Fournitures de bureau",
        "Équipements scolaires",
      ],
    },
    {
      "title": "Autres catégories",
      "icon": Icons.category,
      "subcategories": [
        "Produits alimentaires & Bio",
        "Animaux & Accessoires",
        "Santé & Bien-être",
        "Équipements professionnels",
        "Antiquités & Objets de collection",
        "Articles de fête & Cadeaux",
      ],
    },
  ];

  static List<Map<String, dynamic>> list_Following_Followers = [
    {'label': 'Followers', 'icon': Icons.list},
    {'label': 'Following', 'icon': Icons.list},
  ];

  static List<Map<String, String>> ListeNationaliteHelper = [
    {
      'country': 'Afghanistan',
      'nationality': 'Afghane',
      'languageCode': 'fa',
      'flagCode': '🇦🇫'
    },
    {
      'country': 'Albania',
      'nationality': 'Albanaise',
      'languageCode': 'sq',
      'flagCode': '🇦🇱'
    },
    {
      'country': 'Algeria',
      'nationality': 'Algérienne',
      'languageCode': 'ar',
      'flagCode': '🇩🇿'
    },
    {
      'country': 'Andorra',
      'nationality': 'Andorrane',
      'languageCode': 'ca',
      'flagCode': '🇦🇩'
    },
    {
      'country': 'Angola',
      'nationality': 'Angolaise',
      'languageCode': 'pt',
      'flagCode': '🇦🇴'
    },
    {
      'country': 'Argentina',
      'nationality': 'Argentine',
      'languageCode': 'es',
      'flagCode': '🇦🇷'
    },
    {
      'country': 'Armenia',
      'nationality': 'Arménienne',
      'languageCode': 'hy',
      'flagCode': '🇦🇲'
    },
    {
      'country': 'Australia',
      'nationality': 'Australienne',
      'languageCode': 'en',
      'flagCode': '🇦🇺'
    },
    {
      'country': 'Austria',
      'nationality': 'Autrichienne',
      'languageCode': 'de',
      'flagCode': '🇦🇹'
    },
    {
      'country': 'Azerbaijan',
      'nationality': 'Azerbaïdjanaise',
      'languageCode': 'az',
      'flagCode': '🇦🇿'
    },
    {
      'country': 'Bahamas',
      'nationality': 'Bahamienne',
      'languageCode': 'en',
      'flagCode': '🇧🇸'
    },
    {
      'country': 'Bahrain',
      'nationality': 'Bahreïnie',
      'languageCode': 'ar',
      'flagCode': '🇧🇭'
    },
    {
      'country': 'Bangladesh',
      'nationality': 'Bangladaise',
      'languageCode': 'bn',
      'flagCode': '🇧🇩'
    },
    {
      'country': 'Belarus',
      'nationality': 'Bélarussienne',
      'languageCode': 'be',
      'flagCode': '🇧🇾'
    },
    {
      'country': 'Belgium',
      'nationality': 'Belge',
      'languageCode': 'nl',
      'flagCode': '🇧🇪'
    },
    {
      'country': 'Belize',
      'nationality': 'Bélizienne',
      'languageCode': 'en',
      'flagCode': '🇧🇿'
    },
    {
      'country': 'Benin',
      'nationality': 'Béninoise',
      'languageCode': 'fr',
      'flagCode': '🇧🇯'
    },
    {
      'country': 'Bhutan',
      'nationality': 'Bhoutanaise',
      'languageCode': 'dz',
      'flagCode': '🇧🇹'
    },
    {
      'country': 'Bolivia',
      'nationality': 'Bolivienne',
      'languageCode': 'es',
      'flagCode': '🇧🇴'
    },
    {
      'country': 'Bosnia and Herzegovina',
      'nationality': 'Bosnienne',
      'languageCode': 'bs',
      'flagCode': '🇧🇦'
    },
    {
      'country': 'Botswana',
      'nationality': 'Botswanaise',
      'languageCode': 'en',
      'flagCode': '🇧🇼'
    },
    {
      'country': 'Brazil',
      'nationality': 'Brésilienne',
      'languageCode': 'pt',
      'flagCode': '🇧🇷'
    },
    {
      'country': 'Brunei',
      'nationality': 'Brunéienne',
      'languageCode': 'ms',
      'flagCode': '🇧🇳'
    },
    {
      'country': 'Bulgaria',
      'nationality': 'Bulgare',
      'languageCode': 'bg',
      'flagCode': '🇧🇬'
    },
    {
      'country': 'Burkina Faso',
      'nationality': 'Burkinabé',
      'languageCode': 'fr',
      'flagCode': '🇧🇫'
    },
    {
      'country': 'Burundi',
      'nationality': 'Burundaise',
      'languageCode': 'fr',
      'flagCode': '🇧🇮'
    },
    {
      'country': 'Cambodia',
      'nationality': 'Cambodgienne',
      'languageCode': 'km',
      'flagCode': '🇰🇭'
    },
    {
      'country': 'Cameroon',
      'nationality': 'Camerounaise',
      'languageCode': 'fr',
      'flagCode': '🇨🇲'
    },
    {
      'country': 'Canada',
      'nationality': 'Canadienne',
      'languageCode': 'en',
      'flagCode': '🇨🇦'
    },
    {
      'country': 'Cape Verde',
      'nationality': 'Cap-verdienne',
      'languageCode': 'pt',
      'flagCode': '🇨🇻'
    },
    {
      'country': 'Central African Republic',
      'nationality': 'Centrafricaine',
      'languageCode': 'fr',
      'flagCode': '🇨🇫'
    },
    {
      'country': 'Chad',
      'nationality': 'Tchadienne',
      'languageCode': 'fr',
      'flagCode': '🇹🇩'
    },
    {
      'country': 'Chile',
      'nationality': 'Chilienne',
      'languageCode': 'es',
      'flagCode': '🇨🇱'
    },
    {
      'country': 'China',
      'nationality': 'Chinoise',
      'languageCode': 'zh',
      'flagCode': '🇨🇳'
    },
    {
      'country': 'Colombia',
      'nationality': 'Colombienne',
      'languageCode': 'es',
      'flagCode': '🇨🇴'
    },
    {
      'country': 'Comoros',
      'nationality': 'Comorienne',
      'languageCode': 'fr',
      'flagCode': '🇰🇲'
    },
    {
      'country': 'Congo (Brazzaville)',
      'nationality': 'Congolaise',
      'languageCode': 'fr',
      'flagCode': '🇨🇬'
    },
    {
      'country': 'Congo (Kinshasa)',
      'nationality': 'Congolaise',
      'languageCode': 'fr',
      'flagCode': '🇨🇩'
    },
    {
      'country': 'Costa Rica',
      'nationality': 'Costaricaine',
      'languageCode': 'es',
      'flagCode': '🇨🇷'
    },
    {
      'country': 'Croatia',
      'nationality': 'Croate',
      'languageCode': 'hr',
      'flagCode': '🇭🇷'
    },
    {
      'country': 'Cuba',
      'nationality': 'Cubaine',
      'languageCode': 'es',
      'flagCode': '🇨🇺'
    },
    {
      'country': 'Cyprus',
      'nationality': 'Chypriote',
      'languageCode': 'el',
      'flagCode': '🇨🇾'
    },
    {
      'country': 'Czech Republic',
      'nationality': 'Tchèque',
      'languageCode': 'cs',
      'flagCode': '🇨🇿'
    },
    {
      'country': 'Denmark',
      'nationality': 'Danoise',
      'languageCode': 'da',
      'flagCode': '🇩🇰'
    },
    {
      'country': 'Djibouti',
      'nationality': 'Djiboutienne',
      'languageCode': 'fr',
      'flagCode': '🇩🇯'
    },
    {
      'country': 'Dominica',
      'nationality': 'Dominicaine',
      'languageCode': 'en',
      'flagCode': '🇩🇲'
    },
    {
      'country': 'Dominican Republic',
      'nationality': 'Dominicaine',
      'languageCode': 'es',
      'flagCode': '🇩🇴'
    },
    {
      'country': 'East Timor',
      'nationality': 'Timoraise',
      'languageCode': 'pt',
      'flagCode': '🇹🇱'
    },
    {
      'country': 'Ecuador',
      'nationality': 'Équatorienne',
      'languageCode': 'es',
      'flagCode': '🇪🇨'
    },
    {
      'country': 'Egypt',
      'nationality': 'Égyptienne',
      'languageCode': 'ar',
      'flagCode': '🇪🇬'
    },
    {
      'country': 'El Salvador',
      'nationality': 'Salvadorienne',
      'languageCode': 'es',
      'flagCode': '🇸🇻'
    },
    {
      'country': 'Equatorial Guinea',
      'nationality': 'Guinéenne',
      'languageCode': 'es',
      'flagCode': '🇬🇶'
    },
    {
      'country': 'Eritrea',
      'nationality': 'Érythréenne',
      'languageCode': 'ti',
      'flagCode': '🇪🇷'
    },
    {
      'country': 'Estonia',
      'nationality': 'Estonienne',
      'languageCode': 'et',
      'flagCode': '🇪🇪'
    },
    {
      'country': 'Eswatini',
      'nationality': 'Swazie',
      'languageCode': 'en',
      'flagCode': '🇸🇿'
    },
    {
      'country': 'Ethiopia',
      'nationality': 'Éthiopienne',
      'languageCode': 'am',
      'flagCode': '🇪🇹'
    },
    {
      'country': 'Fiji',
      'nationality': 'Fidjienne',
      'languageCode': 'en',
      'flagCode': '🇫🇯'
    },
    {
      'country': 'Finland',
      'nationality': 'Finlandaise',
      'languageCode': 'fi',
      'flagCode': '🇫🇮'
    },
    {
      'country': 'France',
      'nationality': 'Française',
      'languageCode': 'fr',
      'flagCode': '🇫🇷'
    },
    {
      'country': 'Gabon',
      'nationality': 'Gabonaise',
      'languageCode': 'fr',
      'flagCode': '🇬🇦'
    },
    {
      'country': 'Gambia',
      'nationality': 'Gambienne',
      'languageCode': 'en',
      'flagCode': '🇬🇲'
    },
    {
      'country': 'Georgia',
      'nationality': 'Géorgienne',
      'languageCode': 'ka',
      'flagCode': '🇬🇪'
    },
    {
      'country': 'Germany',
      'nationality': 'Allemande',
      'languageCode': 'de',
      'flagCode': '🇩🇪'
    },
    {
      'country': 'Ghana',
      'nationality': 'Ghanéenne',
      'languageCode': 'en',
      'flagCode': '🇬🇭'
    },
    {
      'country': 'Greece',
      'nationality': 'Grecque',
      'languageCode': 'el',
      'flagCode': '🇬🇷'
    },
    {
      'country': 'Grenada',
      'nationality': 'Grenadienne',
      'languageCode': 'en',
      'flagCode': '🇬🇩'
    },
    {
      'country': 'Guatemala',
      'nationality': 'Guatémaltèque',
      'languageCode': 'es',
      'flagCode': '🇬🇹'
    },
    {
      'country': 'Guinea',
      'nationality': 'Guinéenne',
      'languageCode': 'fr',
      'flagCode': '🇬🇳'
    },
    {
      'country': 'Guinea-Bissau',
      'nationality': 'Bissau-guinéenne',
      'languageCode': 'pt',
      'flagCode': '🇬🇼'
    },
    {
      'country': 'Guyana',
      'nationality': 'Guyanienne',
      'languageCode': 'en',
      'flagCode': '🇬🇾'
    },
    {
      'country': 'Haiti',
      'nationality': 'Haïtienne',
      'languageCode': 'fr',
      'flagCode': '🇭🇹'
    },
    {
      'country': 'Honduras',
      'nationality': 'Hondurienne',
      'languageCode': 'es',
      'flagCode': '🇭🇳'
    },
    {
      'country': 'Hungary',
      'nationality': 'Hongroise',
      'languageCode': 'hu',
      'flagCode': '🇭🇺'
    },
    {
      'country': 'Iceland',
      'nationality': 'Islandaise',
      'languageCode': 'is',
      'flagCode': '🇮🇸'
    },
    {
      'country': 'India',
      'nationality': 'Indienne',
      'languageCode': 'hi',
      'flagCode': '🇮🇳'
    },
    {
      'country': 'Indonesia',
      'nationality': 'Indonésienne',
      'languageCode': 'id',
      'flagCode': '🇮🇩'
    },
    {
      'country': 'Iran',
      'nationality': 'Iranienne',
      'languageCode': 'fa',
      'flagCode': '🇮🇷'
    },
    {
      'country': 'Iraq',
      'nationality': 'Iraquienne',
      'languageCode': 'ar',
      'flagCode': '🇮🇶'
    },
    {
      'country': 'Ireland',
      'nationality': 'Irlandaise',
      'languageCode': 'en',
      'flagCode': '🇮🇪'
    },
    {
      'country': 'Israel',
      'nationality': 'Israélienne',
      'languageCode': 'he',
      'flagCode': '🇮🇱'
    },
    {
      'country': 'Italy',
      'nationality': 'Italienne',
      'languageCode': 'it',
      'flagCode': '🇮🇹'
    },
    {
      'country': 'Jamaica',
      'nationality': 'Jamaïcaine',
      'languageCode': 'en',
      'flagCode': '🇯🇲'
    },
    {
      'country': 'Japan',
      'nationality': 'Japonaise',
      'languageCode': 'ja',
      'flagCode': '🇯🇵'
    },
    {
      'country': 'Jordan',
      'nationality': 'Jordanienne',
      'languageCode': 'ar',
      'flagCode': '🇯🇴'
    },
    {
      'country': 'Kazakhstan',
      'nationality': 'Kazakhstanaise',
      'languageCode': 'kk',
      'flagCode': '🇰🇿'
    },
    {
      'country': 'Kenya',
      'nationality': 'Kényane',
      'languageCode': 'sw',
      'flagCode': '🇰🇪'
    },
    {
      'country': 'Kiribati',
      'nationality': 'Kiribatienne',
      'languageCode': 'en',
      'flagCode': '🇰🇮'
    },
    {
      'country': 'Kuwait',
      'nationality': 'Koweïtienne',
      'languageCode': 'ar',
      'flagCode': '🇰🇼'
    },
    {
      'country': 'Kyrgyzstan',
      'nationality': 'Kirghize',
      'languageCode': 'ky',
      'flagCode': '🇰🇬'
    },
    {
      'country': 'Laos',
      'nationality': 'Laotienne',
      'languageCode': 'lo',
      'flagCode': '🇱🇦'
    },
    {
      'country': 'Latvia',
      'nationality': 'Lettonne',
      'languageCode': 'lv',
      'flagCode': '🇱🇻'
    },
    {
      'country': 'Lebanon',
      'nationality': 'Libanaise',
      'languageCode': 'ar',
      'flagCode': '🇱🇧'
    },
    {
      'country': 'Lesotho',
      'nationality': 'Lésothienne',
      'languageCode': 'en',
      'flagCode': '🇱🇸'
    },
    {
      'country': 'Liberia',
      'nationality': 'Libérienne',
      'languageCode': 'en',
      'flagCode': '🇱🇷'
    },
    {
      'country': 'Libya',
      'nationality': 'Libyenne',
      'languageCode': 'ar',
      'flagCode': '🇱🇾'
    },
    {
      'country': 'Liechtenstein',
      'nationality': 'Liechtensteinoise',
      'languageCode': 'de',
      'flagCode': '🇱🇮'
    },
    {
      'country': 'Lithuania',
      'nationality': 'Lituanienne',
      'languageCode': 'lt',
      'flagCode': '🇱🇹'
    },
    {
      'country': 'Luxembourg',
      'nationality': 'Luxembourgeoise',
      'languageCode': 'fr',
      'flagCode': '🇱🇺'
    },
    {
      'country': 'Madagascar',
      'nationality': 'Malagasy',
      'languageCode': 'fr',
      'flagCode': '🇲🇬'
    },
    {
      'country': 'Malawi',
      'nationality': 'Malawienne',
      'languageCode': 'en',
      'flagCode': '🇲🇼'
    },
    {
      'country': 'Malaysia',
      'nationality': 'Malaisienne',
      'languageCode': 'ms',
      'flagCode': '🇲🇾'
    },
    {
      'country': 'Maldives',
      'nationality': 'Maldivienne',
      'languageCode': 'dv',
      'flagCode': '🇲🇻'
    },
    {
      'country': 'Mali',
      'nationality': 'Malienne',
      'languageCode': 'fr',
      'flagCode': '🇲🇱'
    },
    {
      'country': 'Malta',
      'nationality': 'Maltaise',
      'languageCode': 'mt',
      'flagCode': '🇲🇹'
    },
    {
      'country': 'Marshall Islands',
      'nationality': 'Marshallaise',
      'languageCode': 'en',
      'flagCode': '🇲🇭'
    },
    {
      'country': 'Mauritania',
      'nationality': 'Mauritanienne',
      'languageCode': 'ar',
      'flagCode': '🇲🇷'
    },
    {
      'country': 'Mauritius',
      'nationality': 'Mauricienne',
      'languageCode': 'en',
      'flagCode': '🇲🇺'
    },
    {
      'country': 'Mexico',
      'nationality': 'Mexicaine',
      'languageCode': 'es',
      'flagCode': '🇲🇽'
    },
    {
      'country': 'Micronesia',
      'nationality': 'Micronésienne',
      'languageCode': 'en',
      'flagCode': '🇫🇲'
    },
    {
      'country': 'Moldova',
      'nationality': 'Moldave',
      'languageCode': 'ro',
      'flagCode': '🇲🇩'
    },
    {
      'country': 'Monaco',
      'nationality': 'Monégasque',
      'languageCode': 'fr',
      'flagCode': '🇲🇨'
    },
    {
      'country': 'Mongolia',
      'nationality': 'Mongole',
      'languageCode': 'mn',
      'flagCode': '🇲🇳'
    },
    {
      'country': 'Montenegro',
      'nationality': 'Monténégrine',
      'languageCode': 'sr',
      'flagCode': '🇲🇪'
    },
    {
      'country': 'Morocco',
      'nationality': 'Marocaine',
      'languageCode': 'ar',
      'flagCode': '🇲🇦'
    },
    {
      'country': 'Mozambique',
      'nationality': 'Mozambicaine',
      'languageCode': 'pt',
      'flagCode': '🇲🇿'
    },
    {
      'country': 'Myanmar (Burma)',
      'nationality': 'Birmane',
      'languageCode': 'my',
      'flagCode': '🇲🇲'
    },
    {
      'country': 'Namibia',
      'nationality': 'Namibienne',
      'languageCode': 'en',
      'flagCode': '🇳🇦'
    },
    {
      'country': 'Nauru',
      'nationality': 'Nauruane',
      'languageCode': 'na',
      'flagCode': '🇳🇷'
    },
    {
      'country': 'Nepal',
      'nationality': 'Népalaise',
      'languageCode': 'ne',
      'flagCode': '🇳🇵'
    },
    {
      'country': 'Netherlands',
      'nationality': 'Néerlandaise',
      'languageCode': 'nl',
      'flagCode': '🇳🇱'
    },
    {
      'country': 'New Zealand',
      'nationality': 'Néo-zélandaise',
      'languageCode': 'en',
      'flagCode': '🇳🇿'
    },
    {
      'country': 'Nicaragua',
      'nationality': 'Nicaraguayenne',
      'languageCode': 'es',
      'flagCode': '🇳🇮'
    },
    {
      'country': 'Niger',
      'nationality': 'Nigérienne',
      'languageCode': 'fr',
      'flagCode': '🇳🇪'
    },
    {
      'country': 'Nigeria',
      'nationality': 'Nigériane',
      'languageCode': 'en',
      'flagCode': '🇳🇬'
    },
    {
      'country': 'North Korea',
      'nationality': 'Nord-coréenne',
      'languageCode': 'ko',
      'flagCode': '🇰🇵'
    },
    {
      'country': 'North Macedonia',
      'nationality': 'Macédonienne',
      'languageCode': 'mk',
      'flagCode': '🇲🇰'
    },
    {
      'country': 'Norway',
      'nationality': 'Norvégienne',
      'languageCode': 'no',
      'flagCode': '🇳🇴'
    },
    {
      'country': 'Oman',
      'nationality': 'Omanaise',
      'languageCode': 'ar',
      'flagCode': '🇴🇲'
    },
    {
      'country': 'Pakistan',
      'nationality': 'Pakistanaise',
      'languageCode': 'ur',
      'flagCode': '🇵🇰'
    },
    {
      'country': 'Palau',
      'nationality': 'Palauane',
      'languageCode': 'en',
      'flagCode': '🇵🇼'
    },
    {
      'country': 'Panama',
      'nationality': 'Panaméenne',
      'languageCode': 'es',
      'flagCode': '🇵🇦'
    },
    {
      'country': 'Papua New Guinea',
      'nationality': 'Papouane-néo-guinéenne',
      'languageCode': 'en',
      'flagCode': '🇵🇬'
    },
    {
      'country': 'Paraguay',
      'nationality': 'Paraguayenne',
      'languageCode': 'es',
      'flagCode': '🇵🇾'
    },
    {
      'country': 'Peru',
      'nationality': 'Péruvienne',
      'languageCode': 'es',
      'flagCode': '🇵🇪'
    },
    {
      'country': 'Philippines',
      'nationality': 'Philippine',
      'languageCode': 'tl',
      'flagCode': '🇵🇭'
    },
    {
      'country': 'Poland',
      'nationality': 'Polonaise',
      'languageCode': 'pl',
      'flagCode': '🇵🇱'
    },
    {
      'country': 'Portugal',
      'nationality': 'Portugaise',
      'languageCode': 'pt',
      'flagCode': '🇵🇹'
    },
    {
      'country': 'Qatar',
      'nationality': 'Qatarienne',
      'languageCode': 'ar',
      'flagCode': '🇶🇦'
    },
    {
      'country': 'Romania',
      'nationality': 'Roumaine',
      'languageCode': 'ro',
      'flagCode': '🇷🇴'
    },
    {
      'country': 'Russia',
      'nationality': 'Russe',
      'languageCode': 'ru',
      'flagCode': '🇷🇺'
    },
    {
      'country': 'Rwanda',
      'nationality': 'Rwandaise',
      'languageCode': 'rw',
      'flagCode': '🇷🇼'
    },
    {
      'country': 'Saint Kitts and Nevis',
      'nationality': 'Saint-Kitts-et-Nevisienne',
      'languageCode': 'en',
      'flagCode': '🇰🇳'
    },
    {
      'country': 'Saint Lucia',
      'nationality': 'Saint-Lucienne',
      'languageCode': 'en',
      'flagCode': '🇱🇨'
    },
    {
      'country': 'Saint Vincent and the Grenadines',
      'nationality': 'Saint-Vincentaise',
      'languageCode': 'en',
      'flagCode': '🇻🇨'
    },
    {
      'country': 'Samoa',
      'nationality': 'Samoane',
      'languageCode': 'sm',
      'flagCode': '🇼🇸'
    },
    {
      'country': 'San Marino',
      'nationality': 'Saint-marinaise',
      'languageCode': 'it',
      'flagCode': '🇸🇲'
    },
    {
      'country': 'Sao Tome and Principe',
      'nationality': 'Santoméenne',
      'languageCode': 'pt',
      'flagCode': '🇸🇹'
    },
    {
      'country': 'Saudi Arabia',
      'nationality': 'Saoudienne',
      'languageCode': 'ar',
      'flagCode': '🇸🇦'
    },
    {
      'country': 'Senegal',
      'nationality': 'Sénégalaise',
      'languageCode': 'fr',
      'flagCode': '🇸🇳'
    },
    {
      'country': 'Serbia',
      'nationality': 'Serbe',
      'languageCode': 'sr',
      'flagCode': '🇷🇸'
    },
    {
      'country': 'Seychelles',
      'nationality': 'Seychelloise',
      'languageCode': 'fr',
      'flagCode': '🇸🇨'
    },
    {
      'country': 'Sierra Leone',
      'nationality': 'Sierraléonaise',
      'languageCode': 'en',
      'flagCode': '🇸🇱'
    },
    {
      'country': 'Singapore',
      'nationality': 'Singapourienne',
      'languageCode': 'en',
      'flagCode': '🇸🇬'
    },
    {
      'country': 'Slovakia',
      'nationality': 'Slovaque',
      'languageCode': 'sk',
      'flagCode': '🇸🇰'
    },
    {
      'country': 'Slovenia',
      'nationality': 'Slovène',
      'languageCode': 'sl',
      'flagCode': '🇸🇮'
    },
    {
      'country': 'Solomon Islands',
      'nationality': 'Salomonaise',
      'languageCode': 'en',
      'flagCode': '🇸🇧'
    },
    {
      'country': 'Somalia',
      'nationality': 'Somalienne',
      'languageCode': 'so',
      'flagCode': '🇸🇴'
    },
    {
      'country': 'South Africa',
      'nationality': 'Sud-africaine',
      'languageCode': 'en',
      'flagCode': '🇿🇦'
    },
    {
      'country': 'South Korea',
      'nationality': 'Sud-coréenne',
      'languageCode': 'ko',
      'flagCode': '🇰🇷'
    },
    {
      'country': 'South Sudan',
      'nationality': 'Sud-soudanaise',
      'languageCode': 'en',
      'flagCode': '🇸🇸'
    },
    {
      'country': 'Spain',
      'nationality': 'Espagnole',
      'languageCode': 'es',
      'flagCode': '🇪🇸'
    },
    {
      'country': 'Sri Lanka',
      'nationality': 'Sri-lankaise',
      'languageCode': 'si',
      'flagCode': '🇱🇰'
    },
    {
      'country': 'Sudan',
      'nationality': 'Soudanaise',
      'languageCode': 'ar',
      'flagCode': '🇸🇩'
    },
    {
      'country': 'Suriname',
      'nationality': 'Surinamaise',
      'languageCode': 'nl',
      'flagCode': '🇸🇷'
    },
    {
      'country': 'Sweden',
      'nationality': 'Suédoise',
      'languageCode': 'sv',
      'flagCode': '🇸🇪'
    },
    {
      'country': 'Switzerland',
      'nationality': 'Suisse',
      'languageCode': 'de',
      'flagCode': '🇨🇭'
    },
    {
      'country': 'Syria',
      'nationality': 'Syrienne',
      'languageCode': 'ar',
      'flagCode': '🇸🇾'
    },
    {
      'country': 'Taiwan',
      'nationality': 'Taïwanaise',
      'languageCode': 'zh',
      'flagCode': '🇹🇼'
    },
    {
      'country': 'Tajikistan',
      'nationality': 'Tadjike',
      'languageCode': 'tg',
      'flagCode': '🇹🇯'
    },
    {
      'country': 'Tanzania',
      'nationality': 'Tanzanienne',
      'languageCode': 'sw',
      'flagCode': '🇹🇿'
    },
    {
      'country': 'Thailand',
      'nationality': 'Thaïlandaise',
      'languageCode': 'th',
      'flagCode': '🇹🇭'
    },
    {
      'country': 'Togo',
      'nationality': 'Togolaise',
      'languageCode': 'fr',
      'flagCode': '🇹🇬'
    },
    {
      'country': 'Tonga',
      'nationality': 'Tongienne',
      'languageCode': 'to',
      'flagCode': '🇹🇴'
    },
    {
      'country': 'Trinidad and Tobago',
      'nationality': 'Trinidadienne',
      'languageCode': 'en',
      'flagCode': '🇹🇹'
    },
    {
      'country': 'Tunisia',
      'nationality': 'Tunisienne',
      'languageCode': 'ar',
      'flagCode': '🇹🇳'
    },
    {
      'country': 'Turkey',
      'nationality': 'Turque',
      'languageCode': 'tr',
      'flagCode': '🇹🇷'
    },
    {
      'country': 'Turkmenistan',
      'nationality': 'Turkmène',
      'languageCode': 'tk',
      'flagCode': '🇹🇲'
    },
    {
      'country': 'Tuvalu',
      'nationality': 'Tuvaluane',
      'languageCode': 'en',
      'flagCode': '🇹🇻'
    },
    {
      'country': 'Uganda',
      'nationality': 'Ougandaise',
      'languageCode': 'en',
      'flagCode': '🇺🇬'
    },
    {
      'country': 'Ukraine',
      'nationality': 'Ukrainienne',
      'languageCode': 'uk',
      'flagCode': '🇺🇦'
    },
    {
      'country': 'United Arab Emirates',
      'nationality': 'Émirienne',
      'languageCode': 'ar',
      'flagCode': '🇦🇪'
    },
    {
      'country': 'United Kingdom',
      'nationality': 'Britannique',
      'languageCode': 'en',
      'flagCode': '🇬🇧'
    },
    {
      'country': 'United States',
      'nationality': 'Américaine',
      'languageCode': 'en',
      'flagCode': '🇺🇸'
    },
    {
      'country': 'Uruguay',
      'nationality': 'Uruguayenne',
      'languageCode': 'es',
      'flagCode': '🇺🇾'
    },
    {
      'country': 'Uzbekistan',
      'nationality': 'Ouzbèke',
      'languageCode': 'uz',
      'flagCode': '🇺🇿'
    },
    {
      'country': 'Vanuatu',
      'nationality': 'Vanuataise',
      'languageCode': 'bi',
      'flagCode': '🇻🇺'
    },
    {
      'country': 'Vatican City',
      'nationality': 'Vaticane',
      'languageCode': 'it',
      'flagCode': '🇻🇦'
    },
    {
      'country': 'Venezuela',
      'nationality': 'Vénézuélienne',
      'languageCode': 'es',
      'flagCode': '🇻🇪'
    },
    {
      'country': 'Vietnam',
      'nationality': 'Vietnamienne',
      'languageCode': 'vi',
      'flagCode': '🇻🇳'
    },
    {
      'country': 'Yemen',
      'nationality': 'Yéménite',
      'languageCode': 'ar',
      'flagCode': '🇾🇪'
    },
    {
      'country': 'Zambia',
      'nationality': 'Zambienne',
      'languageCode': 'en',
      'flagCode': '🇿🇲'
    },
    {
      'country': 'Zimbabwe',
      'nationality': 'Zimbabwéenne',
      'languageCode': 'en',
      'flagCode': '🇿🇼'
    },
  ];
}

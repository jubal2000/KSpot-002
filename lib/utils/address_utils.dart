import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/utils/utils.dart';

import '../data/app_data.dart';

class AddressSearchDlg extends StatelessWidget {
  AddressSearchDlg(this.address,  this.onChanged, {Key? key, this.language = 'ko'}) : super(key: key);

  String address;
  String language;
  Function(Address)? onChanged;

  late final TextEditingController _controller = TextEditingController(text: address);

  @override
  Widget build(BuildContext context) {
    LOG('--> CountryCodes[${AppData.currentCountry}] : ${CountryCodeSmall(AppData.currentCountry)}');
    late GeoMethods geoMethods = GeoMethods(
        googleApiKey: GOOGLE_MAP_KEY,
        language: language,
        // country: AppData.currentCountry,
        // city: AppData.currentState,
        // country: '대한민국',
        // city: '서울',
        countryCodes: [CountryCodeSmall(AppData.currentCountry)],
        mode: DirectionsMode.transit
    );
    return AddressSearchDialog(
      geoMethods: geoMethods,
      controller: _controller,
      texts: AddressDialogTexts (
        hintText: 'Please enter the address to search'.tr,
        noResultsText: 'No results were found for your search'.tr,
        cancelText: 'Cancel'.tr,
        continueText: 'OK'.tr,
      ),
      style: AddressDialogStyle(
        color: Theme.of(context).textTheme.bodyMedium!.color!,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      onDone: (address) async {
        LOG("--> AddressSearchBuilder : $address");
        if (onChanged != null) {
          onChanged!(address);
        }
      },
    );
  }
}

void showAddressSearchDialog(BuildContext context, String address, Function(Address) onChanged) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: true,
    barrierLabel: '',
    builder: (context) {
      return AddressSearchDlg(address, onChanged);
    }
  );
}

void showAddressSearchDialog2(BuildContext context) {
  var dlg = AddressSearchDlg('', null);
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: dlg,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 100),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return dlg;
      });
}

void showAddressSearchDialog3(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return AddressSearchDlg('', null);
      // return Center(
      //   child: Container(
      //     height: 240,
      //     child: SizedBox.expand(child: FlutterLogo()),
      //     margin: EdgeInsets.symmetric(horizontal: 20),
      //     decoration: BoxDecoration(
      //         color: Colors.white, borderRadius: BorderRadius.circular(40)),
      //   ),
      // );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
      } else {
        tween = Tween(begin: Offset(1, 0), end: Offset.zero);
      }

      return SlideTransition(
        position: tween.animate(anim),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

const Map<String, int> CountryNumbers = {
  "Afghanistan": 0,
  "Aland Islands": 1,
  "Albania": 2,
  "Algeria": 3,
  "American Samoa": 4,
  "Andorra": 5,
  "Angola": 6,
  "Anguilla": 7,
  "Antarctica": 8,
  "Antigua And Barbuda": 9,
  "Argentina": 10,
  "Armenia": 11,
  "Aruba": 12,
  "Australia": 13,
  "Austria": 14,
  "Azerbaijan": 15,
  "Bahamas The": 16,
  "Bahrain": 17,
  "Bangladesh": 18,
  "Barbados": 19,
  "Belarus": 20,
  "Belgium": 21,
  "Belize": 22,
  "Benin": 23,
  "Bermuda": 24,
  "Bhutan": 25,
  "Bolivia": 26,
  "Bosnia and Herzegovina": 27,
  "Botswana": 28,
  "Bouvet Island": 29,
  "Brazil": 30,
  "British Indian Ocean Territory": 31,
  "Brunei": 32,
  "Bulgaria": 33,
  "Burkina Faso": 34,
  "Burundi": 35,
  "Cambodia": 36,
  "Cameroon": 37,
  "Canada": 38,
  "Cape Verde": 39,
  "Cayman Islands": 40,
  "Central African Republic": 41,
  "Chad": 42,
  "Chile": 43,
  "China": 44,
  "Christmas Island": 45,
  "Cocos (Keeling) Islands": 46,
  "Colombia": 47,
  "Comoros": 48,
  "Congo": 49,
  "Congo The Democratic Republic Of The": 50,
  "Cook Islands": 51,
  "Costa Rica": 52,
  "Cote D'Ivoire (Ivory Coast)": 53,
  "Croatia (Hrvatska)": 54,
  "Cuba": 55,
  "Cyprus": 56,
  "Czech Republic": 57,
  "Denmark": 58,
  "Djibouti": 59,
  "Dominica": 60,
  "Dominican Republic": 61,
  "East Timor": 62,
  "Ecuador": 63,
  "Egypt": 64,
  "El Salvador": 65,
  "Equatorial Guinea": 66,
  "Eritrea": 67,
  "Estonia": 68,
  "Ethiopia": 69,
  "Falkland Islands": 70,
  "Faroe Islands": 71,
  "Fiji Islands": 72,
  "Finland": 73,
  "France": 74,
  "French Guiana": 75,
  "French Polynesia": 76,
  "French Southern Territories": 77,
  "Gabon": 78,
  "Gambia The": 79,
  "Georgia": 80,
  "Germany": 81,
  "Ghana": 82,
  "Gibraltar": 83,
  "Greece": 84,
  "Greenland": 85,
  "Grenada": 86,
  "Guadeloupe": 87,
  "Guam": 88,
  "Guatemala": 89,
  "Guernsey and Alderney": 90,
  "Guinea": 91,
  "Guinea Bissau": 92,
  "Guyana": 93,
  "Haiti": 94,
  "Heard Island and McDonald Islands": 95,
  "Honduras": 96,
  "Hong Kong S.A.R": 97,
  "Hungary": 98,
  "Iceland": 99,
  "India": 100,
  "Indonesia": 101,
  "Iran": 102,
  "Iraq": 103,
  "Ireland": 104,
  "Israel": 105,
  "Italy": 106,
  "Jamaica": 107,
  "Japan": 108,
  "Jersey": 109,
  "Jordan": 110,
  "Kazakhstan": 111,
  "Kenya": 112,
  "Kiribati": 113,
  "Korea North": 114,
  "Korea South": 115,
  "Kuwait": 116,
  "Kyrgyzstan": 117,
  "Laos": 118,
  "Latvia": 119,
  "Lebanon": 120,
  "Lesotho": 121,
  "Liberia": 122,
  "Libya": 123,
  "Liechtenstein": 124,
  "Lithuania": 125,
  "Luxembourg": 126,
  "Macau S.A.R": 127,
  "Macedonia": 128,
  "Madagascar": 129,
  "Malawi": 130,
  "Malaysia": 131,
  "Maldives": 132,
  "Mali": 133,
  "Malta": 134,
  "Man (Isle of)": 135,
  "Marshall Islands": 136,
  "Martinique": 137,
  "Mauritania": 138,
  "Mauritius": 139,
  "Mayotte": 140,
  "Mexico": 141,
  "Micronesia": 142,
  "Moldova": 143,
  "Monaco": 144,
  "Mongolia": 145,
  "Montenegro": 146,
  "Montserrat": 147,
  "Morocco": 148,
  "Mozambique": 149,
  "Myanmar": 150,
  "Namibia": 151,
  "Nauru": 152,
  "Nepal": 153,
  "Bonaire, Sint Eustatius and Saba": 154,
  "Netherlands The": 155,
  "New Caledonia": 156,
  "New Zealand": 157,
  "Nicaragua": 158,
  "Niger": 159,
  "Nigeria": 160,
  "Niue": 161,
  "Norfolk Island": 162,
  "Northern Mariana Islands": 163,
  "Norway": 164,
  "Oman": 165,
  "Pakistan": 166,
  "Palau": 167,
  "Palestinian Territory Occupied": 168,
  "Panama": 169,
  "Papua new Guinea": 170,
  "Paraguay": 171,
  "Peru": 172,
  "Philippines": 173,
  "Pitcairn Island": 174,
  "Poland": 175,
  "Portugal": 176,
  "Puerto Rico": 177,
  "Qatar": 178,
  "Reunion": 179,
  "Romania": 180,
  "Russia": 181,
  "Rwanda": 182,
  "Saint Helena": 183,
  "Saint Kitts And Nevis": 184,
  "Saint Lucia": 185,
  "Saint Pierre and Miquelon": 186,
  "Saint Vincent And The Grenadines": 187,
  "Saint-Barthelemy": 188,
  "Saint-Martin (French part)": 189,
  "Samoa": 190,
  "San Marino": 191,
  "Sao Tome and Principe": 192,
  "Saudi Arabia": 193,
  "Senegal": 194,
  "Serbia": 195,
  "Seychelles": 196,
  "Sierra Leone": 197,
  "Singapore": 198,
  "Slovakia": 199,
  "Slovenia": 200,
  "Solomon Islands": 201,
  "Somalia": 202,
  "South Africa": 203,
  "South Georgia": 204,
  "South Sudan": 205,
  "Spain": 206,
  "Sri Lanka": 207,
  "Sudan": 208,
  "Suriname": 209,
  "Svalbard And Jan Mayen Islands": 210,
  "Swaziland": 211,
  "Sweden": 212,
  "Switzerland": 213,
  "Syria": 214,
  "Taiwan": 215,
  "Tajikistan": 216,
  "Tanzania": 217,
  "Thailand": 218,
  "Togo": 219,
  "Tokelau": 220,
  "Tonga": 221,
  "Trinidad And Tobago": 222,
  "Tunisia": 223,
  "Turkey": 224,
  "Turkmenistan": 225,
  "Turks And Caicos Islands": 226,
  "Tuvalu": 227,
  "Uganda": 228,
  "Ukraine": 229,
  "United Arab Emirates": 230,
  "United Kingdom": 231,
  "United States": 232,
  "United States Minor Outlying Islands": 233,
  "Uruguay": 234,
  "Uzbekistan": 235,
  "Vanuatu": 236,
  "Vatican City State (Holy See)": 237,
  "Venezuela": 238,
  "Vietnam": 239,
  "Virgin Islands (British)": 240,
  "Virgin Islands (US)": 241,
  "Wallis And Futuna Islands": 242,
  "Western Sahara": 243,
  "Yemen": 244,
  "Zambia": 245,
  "Zimbabwe": 246,
  "Kosovo": 247,
  "Curacao": 248,
  "Sint Maarten (Dutch part)": 249,
};

CountryCodeSmall(String country) {
  var code = CountryCodes[country];
  if (code != null) {
    return code.toLowerCase();
  }
  return 'kr';
}

const Map<String, String> CountryCodes = {
  "Afghanistan": "AF",
  "Aland Islands": "AX",
  "Albania": "AL",
  "Algeria": "DZ",
  "American Samoa": "AS",
  "Andorra": "AD",
  "Angola": "AO",
  "Anguilla": "AI",
  "Antarctica": "AQ",
  "Antigua And Barbuda": "AG",
  "Argentina": "AR",
  "Armenia": "AM",
  "Aruba": "AW",
  "Australia": "AU",
  "Austria": "AT",
  "Azerbaijan": "AZ",
  "Bahamas The": "BS",
  "Bahrain": "BH",
  "Bangladesh": "BD",
  "Barbados": "BB",
  "Belarus": "BY",
  "Belgium": "BE",
  "Belize": "BZ",
  "Benin": "BJ",
  "Bermuda": "BM",
  "Bhutan": "BT",
  "Bolivia": "BO",
  "Bosnia and Herzegovina": "BA",
  "Botswana": "BW",
  "Bouvet Island": "",
  "Brazil": "BR",
  "British Indian Ocean Territory": "IO",
  "Brunei": "BN",
  "Bulgaria": "BG",
  "Burkina Faso": "BF",
  "Burundi": "BI",
  "Cambodia": "KH",
  "Cameroon": "CM",
  "Canada": "CA",
  "Cape Verde": "CV",
  "Cayman Islands": "KY",
  "Central African Republic": "CF",
  "Chad": "TD",
  "Chile": "CL",
  "China": "CN",
  "Christmas Island": "CX",
  "Cocos (Keeling) Islands": "CC",
  "Colombia": "CO",
  "Comoros": "KM",
  "Congo": "CG",
  "Congo The Democratic Republic Of The": "CD",
  "Cook Islands": "CK",
  "Costa Rica": "CR",
  "Cote D'Ivoire (Ivory Coast)": "CI",
  "Croatia (Hrvatska)": "HR",
  "Cuba": "CU",
  "Cyprus": "CY",
  "Czech Republic": "CZ",
  "Denmark": "DK",
  "Djibouti": "DJ",
  "Dominica": "DM",
  "Dominican Republic": "DO",
  "East Timor": "",
  "Ecuador": "EC",
  "Egypt": "EG",
  "El Salvador": "SV",
  "Equatorial Guinea": "GQ",
  "Eritrea": "ER",
  "Estonia": "EE",
  "Ethiopia": "ET",
  "Falkland Islands": "FK",
  "Faroe Islands": "FO",
  "Fiji Islands": "FJ",
  "Finland": "FI",
  "France": "FR",
  "French Guiana": "GF",
  "French Polynesia": "PF",
  "French Southern Territories": "",
  "Gabon": "GA",
  "Gambia The": "GM",
  "Georgia": "GE",
  "Germany": "DE",
  "Ghana": "GH",
  "Gibraltar": "GI",
  "Greece": "GR",
  "Greenland": "GL",
  "Grenada": "GD",
  "Guadeloupe": "GP",
  "Guam": "GU",
  "Guatemala": "GT",
  "Guernsey and Alderney": "GG",
  "Guinea":"GN",
  "Guinea Bissau": "GW",
  "Guyana": "GY",
  "Haiti": "HT",
  "Heard Island and McDonald Islands": "VA",
  "Honduras": "HN",
  "Hong Kong S.A.R": "HK",
  "Hungary": "HU",
  "Iceland": "IS",
  "India": "IN",
  "Indonesia": "ID",
  "Iran": "IR",
  "Iraq": "IQ",
  "Ireland": "IE",
  "Israel": "IL",
  "Italy": "IT",
  "Jamaica": "JM",
  "Japan": "JP",
  "Jersey": "JE",
  "Jordan": "JO",
  "Kazakhstan": "KZ",
  "Kenya": "KE",
  "Kiribati": "KI",
  "Korea North": "KP",
  "Korea South": "KR",
  "Kuwait": "KW",
  "Kyrgyzstan": "KG",
  "Laos": "LA",
  "Latvia": "LV",
  "Lebanon": "LB",
  "Lesotho": "LS",
  "Liberia": "LR",
  "Libya": "LY",
  "Liechtenstein": "LI",
  "Lithuania": "LT",
  "Luxembourg": "LU",
  "Macau S.A.R": "MO",
  "Macedonia": "MK",
  "Madagascar": "MG",
  "Malawi": "MW",
  "Malaysia": "MY",
  "Maldives": "MV",
  "Mali": "ML",
  "Malta": "MT",
  "Man (Isle of)": "IM",
  "Marshall Islands": "MH",
  "Martinique": "MQ",
  "Mauritania": "MR",
  "Mauritius": "MU",
  "Mayotte": "YT",
  "Mexico": "MX1",
  "Micronesia": "FM",
  "Moldova": "MD",
  "Monaco": "MC",
  "Mongolia": "MN",
  "Montenegro": "ME",
  "Montserrat": "MS",
  "Morocco": "MA",
  "Mozambique": "MZ",
  "Myanmar": "MM",
  "Namibia": "NA",
  "Nauru": "NR",
  "Nepal": "NP",
  "Bonaire Sint Eustatius and Saba": "",
  "Netherlands The": "NL",
  "New Caledonia": "NC",
  "New Zealand": "NZ",
  "Nicaragua": "NI",
  "Niger": "NE",
  "Nigeria": "NG",
  "Niue": "NU",
  "Norfolk Island": "NF",
  "Northern Mariana Islands": "MP",
  "Norway": "NO",
  "Oman": "OM",
  "Pakistan": "PK",
  "Palau": "PW",
  "Palestinian Territory Occupied": "PS",
  "Panama": "PA",
  "Papua new Guinea": "PG",
  "Paraguay": "PY",
  "Peru": "PE",
  "Philippines": "PH",
  "Pitcairn Island": "PN",
  "Poland": "PL",
  "Portugal": "PT",
  "Puerto Rico": "PR",
  "Qatar": "QA",
  "Reunion": "",
  "Romania": "RO",
  "Russia": "RU",
  "Rwanda": "RW",
  "Saint Helena": "SH",
  "Saint Kitts And Nevis": "KN",
  "Saint Lucia": "LC",
  "Saint Pierre and Miquelon": "",
  "Saint Vincent And The Grenadines": "VC",
  "Saint-Barthelemy": "",
  "Saint-Martin (French part)": "MF",
  "Samoa": "WS",
  "San Marino": "SM",
  "Sao Tome and Principe": "ST",
  "Saudi Arabia": "SA",
  "Senegal": "SN",
  "Serbia": "RS",
  "Seychelles": "SC",
  "Sierra Leone": "SL",
  "Singapore": "SG",
  "Slovakia": "SK",
  "Slovenia": "SI",
  "Solomon Islands": "SB",
  "Somalia": "SO",
  "South Africa": "ZA",
  "South Georgia": "GS",
  "South Sudan": "SS",
  "Spain": "ES",
  "Sri Lanka": "LK",
  "Sudan": "SD",
  "Suriname": "SR",
  "Svalbard And Jan Mayen Islands": "SJ",
  "Swaziland": "SZ",
  "Sweden": "SE",
  "Switzerland": "SZ",
  "Syria": "SY",
  "Taiwan": "TW",
  "Tajikistan": "TJ",
  "Tanzania": "TZ",
  "Thailand": "TH",
  "Togo": "TG",
  "Tokelau": "TK",
  "Tonga": "TO",
  "Trinidad And Tobago": "TT",
  "Tunisia": "TN",
  "Turkey": "TR",
  "Turkmenistan": "TM",
  "Turks And Caicos Islands": "TC",
  "Tuvalu": "TV",
  "Uganda": "UG",
  "Ukraine": "UA",
  "United Arab Emirates": "AE",
  "United Kingdom": "GB",
  "United States": "US",
  "United States Minor Outlying Islands": "",
  "Uruguay": "UY",
  "Uzbekistan": "UZ",
  "Vanuatu": "VU",
  "Vatican City State (Holy See)": "",
  "Venezuela": "VE",
  "Vietnam": "VN",
  "Virgin Islands (British)": "VG",
  "Virgin Islands (US)": "VI",
  "Wallis And Futuna Islands": "WF",
  "Western Sahara": "",
  "Yemen": "YE",
  "Zambia": "ZM",
  "Zimbabwe": "ZW",
  "Kosovo": "",
  "Curacao": "",
  "Sint Maarten (Dutch part)": "",
};


#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <SFML/Graphics.hpp>
#include <SFML/window.hpp>
#include <SFML/Audio.hpp>
#include <cURL/curl/curl.h>
#include <windows.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846264338327950288
#endif
using namespace std;
using namespace sf;
class Ulkeler {
public:
	string trisim, isim, enisim, din, kita, baskent, yonetimbicimi, yuzolcum, nufus, ekonomi, enlem, boylam, bayrak;
	Ulkeler(string aa0, string aa1, string aa2, string aa3, string aa4, string aa5, string aa6, string aa7, string aa8, string aa9, string aa10, string aa11, string aa12) {
		bayrak = aa0, trisim = aa1, isim = aa2, enisim = aa3, din = aa4, kita = aa5, yonetimbicimi = aa6, baskent = aa7, yuzolcum = aa8, nufus = aa9, ekonomi = aa10, enlem = aa11, boylam = aa12;
	}
	bool ks(string yapilantahmin) { return (yapilantahmin == trisim || yapilantahmin == isim || yapilantahmin == enisim); }
};
class Sehirler {
public:
	string isim, trisim;
	int plaka, bolge;
	bool bilgi = false;
	Sehirler(string ccc, string cc0, int cc1, int cc2) {
		isim = cc0, trisim = ccc, plaka = cc1, bolge = cc2;
	}
	bool ks(string yapilantahmin) { return (yapilantahmin == trisim || yapilantahmin == isim); }
};
//               bayrak                                 trisim			  isim			enisim			 din              kita			   yonetimbicimi				  	 baskent		 yuzolcum		  nufus         ekonomi		    enlem    boylam
Ulkeler ulke1("dosyalar/bayraklar/amerika.png", "Abd", "Amerika", "Unitedstates", "Hristiyanlýk", "Kuzey Amerika", "Federal cumhuriyet", "Washington", "9,631,418 km²", "331 milyon", "22000 milyar $", "37.0902", "-95.7129");
Ulkeler ulke2("dosyalar/bayraklar/cin.png", "In", "Cin", "China", "Budizm", "Asya", "Tek parti sosyalist cumhuriyet", "Pekin", "9,596,960 km²", "1410 milyon", "16000 milyar $", "35.8616", "104.1954");
Ulkeler ulke3("dosyalar/bayraklar/japonya.png", "Japonya", "Japonya", "Japan", "Budizm", "Asya", "Parlamentar monarsi", "Tokyo", "377,975 km²", "125 milyon", "6000 milyar $", "36.2048", "138.2529");
Ulkeler ulke4("dosyalar/bayraklar/almanya.png", "Almanya", "Almanya", "Germany", "Hristiyanlýk", "Avrupa", "Federal parlamentar cumhuriyet", "Berlin", "357,022 km²", "83 milyon", "4000 milyar $", "51.1657", "10.4515");
Ulkeler ulke5("dosyalar/bayraklar/hindistan.png", "Hindistan", "Hindistan", "India", "Hinduizm", "Asya", "Federal parlamentar cumhuriyet", "Yeni delhi", "3,287,260 km²", "1370 milyon", "3000 milyar $", "20.5937", "78.9629");
Ulkeler ulke6("dosyalar/bayraklar/ingiltere.png", "Birleikkralk", "Ingiltere", "Unitedkingdom", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Londra", "243,610 km²", "68 milyon", "3000 milyar $", "51.5001", "-0.1262");
Ulkeler ulke7("dosyalar/bayraklar/fransa.png", "Fransa", "Fransa", "France", "Hristiyanlýk", "Avrupa", "Yari baskanlik cumhruriyeti", "Paris", "551,695 km²", "67 milyon", "3000 milyar $", "48.8566", "2.3488");
Ulkeler ulke8("dosyalar/bayraklar/rusya.png", "Rusya", "Rusya", "Russia", "Hristiyanlýk", "Asya", "Federal cumhuriyet", "Moskova", "17,125,191 km²", "146 milyon", "2000 milyar $", "61.5240", "105.3188");
Ulkeler ulke9("dosyalar/bayraklar/brezilya.png", "Brezilya", "Brezilya", "Brazil", "Hristiyanlýk", "Guney Amerika", "Federal cumhuriyet", "Brasilia", "8,515,767 km²", "215 milyon", "1600 milyar $", "-14.2350", "-51.9253");
Ulkeler ulke10("dosyalar/bayraklar/italya.png", "Talya", "Italya", "Italy", "Hristiyanlýk", "Avrupa", "Parlamentar cumhruriyet", "Roma", "301,340 km²", "60 milyon", "2000 milyar $", "41.8902", "12.4823");
Ulkeler ulke11("dosyalar/bayraklar/kanada.png", "Kanada", "Kanada", "Canada", "Hristiyanlýk", "Kuzey Amerika", "Federal parlamentar monarsi", "Ottawa", "9,984,670 km²", "38 milyon", "1800 milyar $", "56.1304", "-106.3468");
Ulkeler ulke12("dosyalar/bayraklar/guneykore.png", "Gneykore", "Guneykore", "Southkorea", "Dinsiz", "Asya", "Cumhuriyet", "Seul", "100,210 km²", "52 milyon", "1600 milyar $", "37.5139", "127.0097");
Ulkeler ulke13("dosyalar/bayraklar/avusturalya.png", "Avusturalya", "Avusturalya", "Australia", "Hristiyanlýk", "Avustralasya", "Federal parlamentar monarsi", "Canberra", "7,692,024 km²", "26 milyon", "1500 milyar $", "-25.2744", "133.7751");
Ulkeler ulke14("dosyalar/bayraklar/ispanya.png", "Spanya", "Ispanya", "Spain", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Madrid", "505,992 km²", "47 milyon", "1400 milyar $", "40.4167", "-3.7039");
Ulkeler ulke15("dosyalar/bayraklar/meksika.png", "Meksika", "Meksika", "Mexico", "Hristiyanlýk", "Kuzey Amerika", "Federal cumhuriyet", "Meksiko", "1,964,375 km²", "130 milyon", "1300 milyar $", "23.6345", "-102.5528");
Ulkeler ulke16("dosyalar/bayraklar/endonezya.png", "Endonezya", "Endonezya", "Indonesia", "Islam", "Asya", "Cumhuriyet", "Cakarta", "1,904,569 km²", "273 milyon", "1200 milyar $", "-1.5528", "120.2955");
Ulkeler ulke17("dosyalar/bayraklar/turkiye.png", "Trkiye", "Turkiye", "Turkey", "Islam", "Asya", "Cumhuriyet", "Ankara", "783,356 km²", "84 milyon", "1000 milyar $", "39.9333", "32.8597");
Ulkeler ulke18("dosyalar/bayraklar/hollanda.png", "Hollanda", "Hollanda", "Netherlands", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Amsterdam", "41,543 km²", "17 milyon", "1000 milyar $", "52.3702", "5.8223");
Ulkeler ulke19("dosyalar/bayraklar/arabistan.png", "Suudiarabistan", "Arabistan", "Saudiarabia", "Islam", "Asya", "Mutlak monarsi", "Riyad", "2,149,690 km²", "35 milyon", "700 milyar $", "24.6408", "46.7727");
Ulkeler ulke20("dosyalar/bayraklar/isvicre.png", "Isvire", "Isvicre", "Switzerland", "Hristiyanlýk", "Avrupa", "Federal parlamentar cumhuriyet", "Bern", "41,290 km²", "8.5 milyon", "800 milyar $", "46.8182", "8.2275");
Ulkeler ulke21("dosyalar/bayraklar/tayvan.png", "Tayvan", "Tayvan", "Taiwan", "Budizm", "Asya", "Özerk", "Taipei", "6,193 km²", "23.8 milyon", "800 milyar $", "23.6978", "120.9605");
Ulkeler ulke22("dosyalar/bayraklar/polonya.png", "Polonya", "Polonya", "Poland", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Varsova", "312,696 km²", "38 milyon", "700 milyar $", "51.9194", "19.1451");
Ulkeler ulke23("dosyalar/bayraklar/arjantin.png", "Arjantin", "Arjantin", "Argentina", "Hristiyanlýk", "Guney Amerika", "Federal cumhuriyet", "Buenos aires", "2,780,400 km²", "45 milyon", "400 milyar $", "-38.4161", "-63.5709");
Ulkeler ulke24("dosyalar/bayraklar/isvec.png", "Isve", "Isvec", "Sweden", "Hristiyanlýk", "Avrupa", "Parlementar monarsi", "Stockholm", "450,295 km²", "10.5 milyon", "600 milyar $", "60.1282", "18.6435");
Ulkeler ulke25("dosyalar/bayraklar/pakistan.png", "Pakistan", "Pakistan", "Pakistan", "Islam", "Asya", "Federal parlamentar Monarsi", "Islamabad", "881,913 km²", "232 milyon", "300 milyar $", "30.3753", "69.3451");
Ulkeler ulke26("dosyalar/bayraklar/belcika.png", "Belika", "Belcika", "Belgium", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Bruksel", "30,528 km²", "11.5 milyon", "600 milyar $", "50.8503", "4.3517");
Ulkeler ulke27("dosyalar/bayraklar/norvec.png", "Norve", "Norvec", "Norway", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Oslo", "323,802 km²", "5.4 milyon", "600 milyar $", "60.4722", "8.4689");
Ulkeler ulke28("dosyalar/bayraklar/guneyafrika.png", "Gneyafrika", "Guneyafrika", "Southafrica", "Hristiyanlýk", "Afrika", "Parlamentar monarsi", "Pretoria", "1,219,090 km²", "61 milyon", "350 milyar $", "-30.5595", "22.9375");
Ulkeler ulke29("dosyalar/bayraklar/malezya.png", "Malezya", "Malezya", "Malaysia", "Islam", "Asya", "Federal parlamentar monarsi", "Kualalumpur", "330,803 km²", "32 milyon", "360 milyar $", "4.2105", "101.9757");
Ulkeler ulke30("dosyalar/bayraklar/katar.png", "Katar", "Katar", "Qatar", "Islam", "Asya", "Mutlak monarsi", "Doha", "11,586 km²", "2.8 milyon", "180 milyar $", "25.3548", "51.1839");
Ulkeler ulke31("dosyalar/bayraklar/misir.png", "Msr", "Misir", "Egypt", "Islam", "Afrika", "Cumhuriyet", "Kahire", "1,010,408 km²", "104 milyon", "400 milyar $", "26.8205", "30.8025");
Ulkeler ulke32("dosyalar/bayraklar/sili.png", "Ili", "Sili", "Chile", "Hristiyanlýk", "Güney Amerika", "Cumhuriyet", "Santiago", "756,102 km²", "19 milyon", "300 milyar $", "-35.6751", "-71.5429");
Ulkeler ulke33("dosyalar/bayraklar/yunanistan.png", "Yunanistan", "Yunanistan", "Greece", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Atina", "131,957 km²", "10 milyon", "200 milyar $", "39.0742", "21.8243");
Ulkeler ulke34("dosyalar/bayraklar/iran.png", "Iran", "Iran", "Iran", "Islam", "Asya", "Cumhuriyet", "Tahran", "1,648,195 km²", "85 milyon", "430 milyar $", "32.4279", "53.6880");
Ulkeler ulke35("dosyalar/bayraklar/israil.png", "Israil", "Israil", "Israel", "Yahudilik", "Asya", "Parlamentar cumhuriyet", "Tel aviv", "20,770 km²", "9 milyon", "370 milyar $", "31.0461", "34.8516");
Ulkeler ulke36("dosyalar/bayraklar/romanya.png", "Romanya", "Romanya", "Romania", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Bukres", "238,397 km²", "19 milyon", "250 milyar $", "44.4375", "26.1025");
Ulkeler ulke37("dosyalar/bayraklar/ukrayna.png", "Ukrayna", "Ukrayna", "Ukraine", "Hristiyanlýk", "Avrupa", "Parlamenter cumhuriyet", "Kiev", "603,500 km²", "41 milyon", "490 milyar $", "48.3739", "31.1764");
Ulkeler ulke38("dosyalar/bayraklar/kazakistan.png", "Kazakistan", "Kazakistan", "Kazakhstan", "Islam", "Asya", "Cumhuriyet", "Nur sultan", "2,724,900 km²", "18 milyon", "350 milyar $", "48.0196", "66.9237");
Ulkeler ulke39("dosyalar/bayraklar/finlandiya.png", "Finlandiya", "Finlandiya", "Finland", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Helsinki", "338,455 km²", "5.5 milyon", "280 milyar $", "60.1699", "24.9463");
Ulkeler ulke40("dosyalar/bayraklar/azerbaycan.png", "Azerbaycan", "Azerbaycan", "Azerbaijan", "Islam", "Asya", "Cumhuriyet", "Baku", "86,600 km²", "10 milyon", "170 milyar $", "40.395", "49.882");
Ulkeler ulke41("dosyalar/bayraklar/singapur.png", "Singapur", "Singapur", "Singapore", "Budizm", "Asya", "Parlamenter cumhuriyet", "Singapur", "719 km²", "5.8 milyon", "550 milyar $", "1.3521", "103.8198");
Ulkeler ulke42("dosyalar/bayraklar/gurcistan.png", "Grcistan", "Gurcistan", "Georgia", "Hristiyanlýk", "Asya", "Yari baskanlik cumhruriyeti", "Tiflis", "69,700 km²", "3.7 milyon", "17 milyar $", "41.7151", "44.7871 ");
Ulkeler ulke43("dosyalar/bayraklar/vietnam.png", "Vietnam", "Vietnam", "Vietnam", "Budizm", "Asya", "Tek parti sosyalist cumhuriyet", "Hanoi", "331,212 km²", "98 milyon", "261 milyar $", "21.0278", "105.8502 ");
Ulkeler ulke44("dosyalar/bayraklar/avusturya.png", "Avusturya", "Avusturya", "Austria", "Hristiyanlýk", "Avrupa", "Federal parlamentar cumhuriyet", "Viyana", "83,879 km²", "9 milyon", "480 milyar $", "48.2082 ", "16.3738 ");
Ulkeler ulke45("dosyalar/bayraklar/nijerya.png", "Nijerya", "Nijerya", "Nigeria", "Islam", "Afrika", "Federal cumhuriyet", "Abuja", "923,768 km²", "211 milyon", "450 milyar $", "9.0819", "7.9389 ");
Ulkeler ulke46("dosyalar/bayraklar/kuba.png", "Kba", "Kuba", "Cuba", "Hristiyanlýk", "Kuzey Amerika", "Sosyalist cumhuriyet", "Havana", "109,884 km²", "11 milyon", "100 milyar $", "23.1139", "-82.3669");
Ulkeler ulke47("dosyalar/bayraklar/kirgizistan.png", "Krgzistan", "Kirgizistan", "Kyrgyz", "Islam", "Asya", "Parlamentar cumhuriyet", "Biskek", "199,951 km²", "6.5 milyon", "8 milyar $", "42.8746", "74.5981");
Ulkeler ulke48("dosyalar/bayraklar/cezayir.png", "Cezayir", "Cezayir", "Algeria", "Islam", "Afrika", "Yari baskanlik cumhruriyeti", "Cezayir", "2.382.000 km²", "44 milyon", "164 milyar $", "36.7", "3.216667 ");
Ulkeler ulke49("dosyalar/bayraklar/malta.png", "Malta", "Malta", "Malta", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Valetta", "316 km²", "0.5 milyon", "12 milyar $", "35.9375", "14.5001 ");
Ulkeler ulke50("dosyalar/bayraklar/panama.png", "Panama", "Panama", "Panama", "Hristiyanlýk", "Orta Amerika", "Baþkanlýk cumhuriyeti", "Panama", "75,417 km²", "4.3 milyon", "68 milyar $", "8.5386", "-80.7821");

Sehirler sehir1(".", "Adana", 1, 1);
Sehirler sehir2("Adyaman", "Adiyaman", 2, 4);
Sehirler sehir3("Afyon", "Afyonkarahisar", 3, 3);
Sehirler sehir4("Ar", "Agri", 4, 2);
Sehirler sehir5(".", "Amasya", 5, 6);
Sehirler sehir6(".", "Ankara", 6, 5);
Sehirler sehir7(".", "Antalya", 7, 1);
Sehirler sehir8(".", "Artvin", 8, 6);
Sehirler sehir9("Aydn", "Aydin", 9, 3);
Sehirler sehir10("Balkesir", "Balikesir", 10, 7);
Sehirler sehir11(".", "Bilecik", 11, 7);
Sehirler sehir12("Bingl", "Bingol", 12, 2);
Sehirler sehir13(".", "Bitlis", 13, 2);
Sehirler sehir14(".", "Bolu", 14, 6);
Sehirler sehir15(".", "Burdur", 15, 1);
Sehirler sehir16(".", "Bursa", 16, 7);
Sehirler sehir17("Anakkale", "Canakkale", 17, 7);
Sehirler sehir18("Ankr", "Cankiri", 18, 5);
Sehirler sehir19("Orum", "Corum", 19, 6);
Sehirler sehir20(".", "Denizli", 20, 3);
Sehirler sehir21("Diyarbakr", "Diyarbakir", 21, 4);
Sehirler sehir22(".", "Edirne", 22, 7);
Sehirler sehir23("Elaz", "Elazýg", 23, 2);
Sehirler sehir24(".", "Erzincan", 24, 2);
Sehirler sehir25(".", "Erzurum", 25, 2);
Sehirler sehir26("Eskiehir", "Eskisehir", 26, 5);
Sehirler sehir27("Antep", "Gaziantep", 27, 4);
Sehirler sehir28(".", "Giresun", 28, 6);
Sehirler sehir29("Gmhane", "Gumushane", 29, 6);
Sehirler sehir30(".", "Hakkari", 30, 2);
Sehirler sehir31(".", "Hatay", 31, 1);
Sehirler sehir32(".", "Isparta", 32, 1);
Sehirler sehir33(".", "Mersin", 33, 1);
Sehirler sehir34(".", "Istanbul", 34, 7);
Sehirler sehir35(".", "Izmir", 35, 3);
Sehirler sehir36(".", "Kars", 36, 2);
Sehirler sehir37(".", "Kastamonu", 37, 6);
Sehirler sehir38(".", "Kayseri", 38, 5);
Sehirler sehir39("Krklareli", "Kirklareli", 39, 7);
Sehirler sehir40("krehir", "Kirsehir", 40, 5);
Sehirler sehir41(".", "Kocaeli", 41, 7);
Sehirler sehir42(".", "Konya", 42, 5);
Sehirler sehir43("Ktahya", "Kutahya", 43, 3);
Sehirler sehir44(".", "Malatya", 44, 2);
Sehirler sehir45(".", "Manisa", 45, 3);
Sehirler sehir46("Kahramanmara", "Kahramanmaras", 46, 1);
Sehirler sehir47(".", "Mardin", 47, 4);
Sehirler sehir48("Mula", "Mugla", 48, 3);
Sehirler sehir49("Mu", "Mus", 49, 2);
Sehirler sehir50("Nevehir", "Nevsehir", 50, 5);
Sehirler sehir51("Nide", "Nigde", 51, 5);
Sehirler sehir52(".", "Ordu", 52, 6);
Sehirler sehir53(".", "Rize", 53, 6);
Sehirler sehir54(".", "Sakarya", 54, 7);
Sehirler sehir55(".", "Samsun", 55, 6);
Sehirler sehir56(".", "Siirt", 56, 4);
Sehirler sehir57(".", "Sinop", 57, 6);
Sehirler sehir58(".", "Sivas", 58, 5);
Sehirler sehir59("Tekirda", "Tekirdag", 59, 7);
Sehirler sehir60(".", "Tokat", 60, 6);
Sehirler sehir61(".", "Trabzon", 61, 6);
Sehirler sehir62(".", "Tunceli", 62, 2);
Sehirler sehir63("Sanlurfa", "Sanliurfa", 63, 4);
Sehirler sehir64("Uak", "Usak", 64, 3);
Sehirler sehir65(".", "Van", 65, 2);
Sehirler sehir66(".", "Yozgat", 66, 5);
Sehirler sehir67(".", "Zonguldak", 67, 6);
Sehirler sehir68(".", "Aksaray", 68, 5);
Sehirler sehir69(".", "Bayburt", 69, 6);
Sehirler sehir70(".", "Karaman", 70, 5);
Sehirler sehir71("Krkkale", "Kirikkale", 71, 5);
Sehirler sehir72(".", "Batman", 72, 4);
Sehirler sehir73("Rnak", "Sirnak", 73, 4);
Sehirler sehir74("Bartn", "Bartin", 74, 6);
Sehirler sehir75(".", "Ardahan", 75, 2);
Sehirler sehir76("Dr", "Igdir", 76, 2);
Sehirler sehir77(".", "Yalova", 77, 7);
Sehirler sehir78("Karabk", "Karabuk", 78, 6);
Sehirler sehir79(".", "Kilis", 79, 4);
Sehirler sehir80(".", "Osmaniye", 80, 1);
Sehirler sehir81("Dzce", "Duzce", 81, 6);
vector<Sehirler> sehir = { sehir1 , sehir2 , sehir3 , sehir4 , sehir5 , sehir6 , sehir7 , sehir8 , sehir9 , sehir10,
							sehir11, sehir12, sehir13, sehir14, sehir15, sehir16, sehir17, sehir18, sehir19, sehir20,
							sehir21, sehir22, sehir23, sehir24, sehir25, sehir26, sehir27, sehir28, sehir29, sehir30,
							sehir31, sehir32, sehir33, sehir34, sehir35, sehir36, sehir37, sehir38, sehir39, sehir40,
							sehir41, sehir42, sehir43, sehir44, sehir45, sehir46, sehir47, sehir48, sehir49, sehir50,
							sehir51, sehir52, sehir53, sehir54, sehir55, sehir56, sehir57, sehir58, sehir59, sehir60,
							sehir61, sehir62, sehir63, sehir64, sehir65, sehir66, sehir67, sehir68, sehir69, sehir70,
							sehir71, sehir72, sehir73, sehir74, sehir75, sehir76, sehir77, sehir78, sehir79, sehir80, sehir81,
};
vector<Ulkeler> ulke = { ulke1,  ulke2,  ulke3,  ulke4,  ulke5,  ulke6,  ulke7,  ulke8,  ulke9,  ulke10,
						 ulke11, ulke12, ulke13, ulke14, ulke15, ulke16, ulke17, ulke18, ulke19, ulke20,
						 ulke21, ulke22, ulke23, ulke24, ulke25, ulke26, ulke27, ulke28, ulke29, ulke30,
						 ulke31, ulke32, ulke33, ulke34, ulke35, ulke36, ulke37, ulke38, ulke39, ulke40,
						 ulke41, ulke42, ulke43, ulke44, ulke45, ulke46, ulke47, ulke48, ulke49, ulke50,
};
inline std::ostream& blue(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& red(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_INTENSITY);	return s; }
inline std::ostream& green(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& yellow(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY); return s; }
inline std::ostream& white(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE); return s; }
struct color { color(WORD attribute) :m_color(attribute) {};	WORD m_color; };
template <class _Elem, class _Traits> std::basic_ostream<_Elem, _Traits>& operator<<(std::basic_ostream<_Elem, _Traits>& i, color& c) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 	SetConsoleTextAttribute(hStdout, c.m_color); 	return i; }
string temizle(const string& str) {
	string temizString;
	for (char karakter : str) {
		if (isdigit(karakter) || karakter == '.') {
			temizString += karakter;
		}
	}
	return temizString;
}
string kelimeDuzelt(const string& kelime) {
	string sonuc, ilkislem; for (char karakter : kelime) {
		if (isalpha(karakter)) {
			ilkislem += karakter;
		}
	}
	sonuc += toupper(ilkislem[0]);
	for (size_t i = 1; i < ilkislem.length(); ++i) {
		sonuc += tolower(ilkislem[i]);
	}
	return sonuc;
}
string bolgeyaz(string isim, int aaa) {
	string yazilanlar;
	yazilanlar += isim + "\t";
	for (size_t a = 0;a < (sehir.size());a++) {
		if (sehir[a].bolge == aaa) {
			if (sehir[a].bilgi == true) {
				yazilanlar += to_string(sehir[a].plaka) + "-" + sehir[a].isim + "\t";
			}
			else
				yazilanlar += to_string(sehir[a].plaka) + "-" + "___\t";
			if (a == 29 || a == 62 || a == 49 || a == 36 || a == 38 || a == 68)
				yazilanlar += "\n";
		}
	}
	yazilanlar += "\n";
	return yazilanlar;
}
string ulkeyaz() {
	string kerem;
	kerem += "Ulkeler Listesi:\n";
	for (int b = 0;b < (ulke.size());b++) {
		kerem += ulke[b].isim + ", ";
		if ((b + 1) % 6 == 0)
			if (b + 1 != 50)
				kerem += "\n";
	}
	return kerem;
}
void website() {
	string komut;
	cout << yellow << "Websiteme göz atmak istermisin ? (evet/hayýr)" << endl;
	getline(cin, komut);
	komut = kelimeDuzelt(komut);
	if (komut == "Evet") {
		system("start https://kerem-kk.glitch.me/");
	}
}
double mesafehesapla(double latitude1, double longitude1, double latitude2, double longitude2, std::string unit = "kilometers") {
	double theta = longitude1 - longitude2;
	double distance = sin(latitude1 * M_PI / 180.0) * sin(latitude2 * M_PI / 180.0) +
		cos(latitude1 * M_PI / 180.0) * cos(latitude2 * M_PI / 180.0) * cos(theta * M_PI / 180.0);
	distance = acos(distance);
	distance = distance * 180.0 / M_PI;
	distance = distance * 60 * 1.1515;
	if (unit == "kilometers") {
		distance = distance * 1.609344;
	}
	return round(distance);
}
double yonal(double lat1, double lon1, double lat2, double lon2) {
	const double PI = 3.14159265358979323846264338327950288;
	lat1 = lat1 * PI / 180.0;
	lon1 = lon1 * PI / 180.0;
	lat2 = lat2 * PI / 180.0;
	lon2 = lon2 * PI / 180.0;
	double dLon = lon2 - lon1;
	double y = std::sin(dLon) * std::cos(lat2);
	double x = std::cos(lat1) * std::sin(lat2) - std::sin(lat1) * std::cos(lat2) * std::cos(dLon);
	double brng = std::atan2(y, x);
	brng = std::fmod(brng + 2 * PI, 2 * PI);
	brng = brng * 180 / PI;
	brng = std::fmod(brng + 360, 360); // Negatif deðerleri düzeltmek için
	return brng;
}
string Pusula(double derece) {
	if (derece < 0 || derece >= 360) {
		return "Geçersiz derece deðeri";
	}
	const char* yonler[] = { "Kuzey", "Kuzeydogu", "Dogu", "Guneydogu", "Guney", "Guneybati", "Bati", "Kuzeybati" };
	int indeks = static_cast<int>((derece + 22.5) / 45.0) % 8;
	return yonler[indeks];
}
size_t write_data(void* buffer, size_t size, size_t nmemb, void* userp)
{
	FILE* fp = (FILE*)userp;
	size_t written = fwrite(buffer, size, nmemb, fp);
	return written;
}
std::string to_lowercase(const std::string& str)
{
	std::string result(str);
	std::transform(result.begin(), result.end(), result.begin(),
		[](unsigned char c) -> unsigned char { return std::tolower(c); }
	);
	return result;
}
int download(const std::string& url, const std::string& country_code)
{
	CURL* curl;
	FILE* fp;
	CURLcode res;
	// Create the output filename with the country code and .png extension
	std::string outfilename = country_code;
	curl_global_init(CURL_GLOBAL_DEFAULT);
	curl = curl_easy_init();
	if (curl) {
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, false);
		if (fopen_s(&fp, outfilename.c_str(), "wb") != 0) {
			// handle error opening file
			return 1;
		}
		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
		res = curl_easy_perform(curl);
		if (res != CURLE_OK) {
			fprintf(stderr, "curl_easy_perform() failed: %s\n",
				curl_easy_strerror(res));
		}
		fclose(fp);
		curl_easy_cleanup(curl);
	}
	curl_global_cleanup();
	return 0;
}
//-------------------------------------------------------------------------------------------------------------------------
void Sehir() {
	sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
	sf::Font font;
	sf::Text text;
	sf::Event event;
	sf::Texture texture;
	text.setFont(font);
	text.setCharacterSize(24);
	text.setFillColor(sf::Color::Yellow);
	text.setPosition(10, 10);
	if (texture.loadFromFile("dosyalar/arkaplan2.png")) {}
	sf::Sprite sprite(texture);
	if (!font.loadFromFile("dosyalar/arial.ttf")) {}
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut, gecilenulke, yazilanlar, kaliciyazilanlar;
	clock_t start_time, end_time;
	bool oyun = false, bitis = false, pas = false, bilgi;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	std::string secilen[] = { "Sehir Bilme Oyunu","Sehir Bilme Oyununa hos geldiniz. \nAmaciniz, 81 ili teker teker yazmak.",
				"Puan Sistemi: Her sehir 10 puan.","Sure: Oyun suresi 5 dakikadir.Ne kadar sürenin kaldýgina bakmak icin.\nSayfanýn basina bakmaniz yeterli.",
				"Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear();
	text.setString(secilen[0] + "\n1. " + secilen[1] + "\n2. " + secilen[2] + "\n3. " + secilen[3] + "\n4. " + secilen[4] + "\n5. " + "Eger kapat yazarsaniz oyun aninda kapanir.\n");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
					window.close();
					oyun = true;
					yenitur.play();
					start_time = clock(); // Baþlangýç zamanýný al
					break;
				}
			}
			if (event.type == sf::Event::Closed)
			{
				window.close();
			}
		}
	}
	while (oyun) {
		while (true) {
			sf::RenderWindow window(sf::VideoMode(1600, 600), "Kerem_KK");
			bilgi = false;
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure && !bitis) {
				yazilanlar += "Kalan Sure: " + to_string(sure - elapsed_time) + " Saniye\n";
				yazilanlar += bolgeyaz("Akdeniz:", 1);
				yazilanlar += bolgeyaz("Dogu Anadolu:", 2);
				yazilanlar += bolgeyaz("Ege:", 3);
				yazilanlar += bolgeyaz("Güneydogu Anadolu:", 4);
				yazilanlar += bolgeyaz("Ic Anadolu:", 5);
				yazilanlar += bolgeyaz("Karadeniz:", 6);
				yazilanlar += bolgeyaz("Marmara:", 7);
				yazilanlar += "Lütfen bir tahmin girin:  ";
				text.setPosition(10, 10);
				text.setString(yazilanlar);
				window.clear();
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								yazilanlar = "";
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (event.type == sf::Event::Closed)
						{
							window.close();
							yazilanlar = "";
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				for (int i = 0; i < sehir.size(); i++) {
					if (sehir[i].ks(komut)) {
						if (sehir[i].bilgi == true) {
							yazilanlar += "Bu þehri zaten yazdýn.  ";
							yanlis.play();
						}
						else {
							elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
							if (elapsed_time > sure) {
							}
							else {
								sehir[i].bilgi = true;
								winstreak++;
								dogru.play();
								toplampuan += 10;
							}
						}
						bilgi = true;
						break;
					}
				}
			}
			else {
				yazilanlar += "Sure Bitti!\n";
				bitis = true;
				window.close();
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
				yazilanlar += "Oyun Bitti\tYapan Kerem Kuyucu\n";
				yazilanlar += "Dogru Sehir Sayiniz: " + to_string(winstreak) + "\n";
				yazilanlar += "Puaniniz: " + to_string(toplampuan) + "\n";
				yazilanlar += "Websiteme bakmak istermisin: (Evet/Hayir)\n";
				text.setString(yazilanlar);
				window.clear();
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								gecilenulke = "";
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (event.type == sf::Event::Closed)
						{
							window.close();
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				if (komut == "Evet")
					system("start https://kerem-kk.glitch.me/");
				oyun = 0;
				break;
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (!bilgi && !bitis) {
				yazilanlar += "Sehir bulunamadi!  ";
				yanlis.play();
			}
			for (int i = 0; i < sehir.size(); i++) {
				if (sehir[i].bilgi) {
					bitis = true;
				}
				else {
					bitis = false;
					break;
				}
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
void Mesafe() {
	sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
	sf::Font font;
	sf::Text text;
	sf::Event event;
	sf::Texture texture;
	text.setFont(font);
	text.setCharacterSize(24);
	text.setFillColor(sf::Color::Yellow);
	text.setPosition(10, 10);
	if (texture.loadFromFile("dosyalar/arkaplan.png")) {}
	sf::Sprite sprite(texture);
	if (!font.loadFromFile("dosyalar/arial.ttf")) {}
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut, gecilenulke, yazilanlar, kaliciyazilanlar;
	clock_t start_time, end_time;
	bool oyun = false, bitis = false, pas = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	std::string secilen[] = { "Mesafeden Ulke Bilme Oyunu","Mesafeden ulke bilme oyununa hos geldiniz. \nAmaciniz, 50 ülkeden rastgele secilen bir ulkeyi bilmek.\nMesafeler +-100 Km fark olabilir.\nKonum olarak ülkelerin baskentleri baz alinmýþtýr.",
				"Joker Sistemi: 3 tane baskenti ögrenme joker hakkiniz bulunmaktadir.\nJoker kullanmak icin 'Joker yazmaniz yeterlidir","Puan Sistemi: Her turda puaniniz 100 den baslar her yanlis tahminde\n10 puan azalir.8 Tahminden sonra kazanilan puan 25'e sabitlenir tur \nbitince tekrar 100'den baslar. Joker 25 puan azaltir. Ilk tahmin puan eksiltmez"
				"Sure: Oyun suresi 5 dakikadir.Ne kadar sürenin kaldýgina bakmak icin.\nSayfanýn basina bakmaniz yeterli.","Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear();
	text.setString(secilen[0] + "\n1. " + secilen[1] + "\n2. " + secilen[2] + "\n3. " + secilen[3] + "\n4. " + secilen[4] + "\n5. " + "Pas: Ulkeyi gecmek icin Pas yazmaniz yeterli." + "\n6. " + "Eger kapat yazarsaniz oyun aninda kapanir.\n7. Eger ekrandaki yaziler guzukmemeye basladi ise temizle yaziniz.\n8. Ulkeler listesini gormek icin 'Ulkeler' yazin");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
					window.close();
					oyun = true;
					yenitur.play();
					start_time = clock(); // Baþlangýç zamanýný al
					break;
				}
			}
			if (event.type == sf::Event::Closed)
			{
				window.close();
			}
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayný ülke gelirse tekrar seç
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.bayrak, seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 110;
		while (true) {
			sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				yazilanlar += "Kalan Sure: " + to_string(sure - elapsed_time) + " Saniye\t";
				yazilanlar += "Lutfen bir tahmin giriniz:\t";
				window.clear();
				text.setString(kaliciyazilanlar + yazilanlar);
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(kaliciyazilanlar + yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(kaliciyazilanlar + yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (event.type == sf::Event::Closed)
						{
							window.close();
						}
						if (window.hasFocus())
							break;
					}
				}
				if (komut.empty())
					komut = "Kapat";
				yazilanlar = "";
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.bayrak, secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
						puan -= 10;
						break; // Eþleþme bulundu, döngüden çýk
					}
				}
			}
			else {
				bitis = true;
				window.close();
				yazilanlar = "";
				yazilanlar += "Sure Bitti!\n";
				yazilanlar += "Dogru Ulke: " + kalici.isim + "\n";
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				if (elapsed_time < sure)
					yazilanlar = "";
				sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
				yazilanlar += "Oyun Bitti\tYapan Kerem Kuyucu\n";
				yazilanlar += "Dogru Ulke Sayiniz: " + to_string(winstreak) + "\n";
				yazilanlar += "Puaniniz: " + to_string(toplampuan) + "\n";
				yazilanlar += "Websiteme bakmak istermisin: (Evet/Hayir)\n";
				text.setString(yazilanlar);
				window.clear();
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (event.type == sf::Event::Closed)
						{
							window.close();
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				if (komut == "Evet")
					system("start https://kerem-kk.glitch.me/");
				oyun = 0;
				break;
			}
			if (komut == "Joker") {
				if (joker > 0) {
					joker -= 1;
					yazilanlar += "Ulkenin Baskenti: " + kalici.baskent + "  ";
					yazilanlar += to_string(joker) + " Joker hakkiniz kaldi.\n";
					puan -= 25;
				}
				else {
					yazilanlar += to_string(joker) + "Joker hakkiniz bitmiþtir.\n";
				}
			}
			if (komut == "Ulkeler" || komut == "Lkeler")
				yazilanlar += ulkeyaz() + "\n";
			if (komut == "Temizle")
				kaliciyazilanlar = "";
			if (komut != "Kapat" && komut != "Temizle" && komut != "Ulkeler" && komut != "Lkeler" && komut != "Joker" && komut != "Pas" && komut != "Bitir" && !gecici.ks(komut)) {
				yanlis.play();
				yazilanlar += "Boyle bir ulke bulunamadi.\n";
			}
			if (gecici.isim == kalici.isim) {
				dogru.play();
				kaliciyazilanlar = "";
				yazilanlar += "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (gecici.ks(komut)) {
				yanlis.play();
				komut = to_string(mesafehesapla(stod(gecici.enlem), stod(gecici.boylam), stod(kalici.enlem), stod(kalici.boylam)));
				komut.erase(komut.size() - 7);
				kaliciyazilanlar += "Tahmin:" + gecici.isim + "  ";
				kaliciyazilanlar += "Mesafe: " + komut + " kilometre  ";
				kaliciyazilanlar += "Yön: " + Pusula(yonal(stod(gecici.enlem), stod(gecici.boylam), stod(kalici.enlem), stod(kalici.boylam))) + "\n";
			}
			if (komut == "Pas") {
				yenitur.play();
				kaliciyazilanlar = "";
				yazilanlar += "Gecilen Ulke: " + kalici.isim + "  ";
				yazilanlar += "Kordinati Enlem: " + kalici.enlem + " Boylam: " + kalici.boylam + "\n";
				break;
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
void Bayrak() {
	sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
	sf::Font font;
	sf::Text text;
	sf::Event event;
	sf::Texture texture;
	text.setFont(font);
	text.setCharacterSize(24);
	text.setFillColor(sf::Color::Yellow);
	text.setPosition(10, 10);
	if (texture.loadFromFile("dosyalar/arkaplan.png")) {}
	if (!font.loadFromFile("dosyalar/arial.ttf")) {}
	sf::Sprite sprite(texture);
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut, gecilenulke, yazilanlar;
	clock_t start_time, end_time;
	bool oyun = false, bitis = false, pas = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	std::string secilen[] = { "Bayrak Bilme Oyunu", "Bayrak Bilme Oyununa hos geldiniz. ", "Amaciniz, 50 ulkeden rastgele secilen bir ulkenin bayragini bilmek.",
		"Tahminleri yazarken turkce harfleri gostermiyor bu yuzden harf eksik\nkaldi diye onemsemeyin tahminizi etkilemeyecektir.",
		"Puan Sistemi: Her turda puaniniz 50 den baslar her yanlis tahminde 10\npuan azalir. 3 Tahminden sonra kazanilan puan 20'e sabitlenir tur\nbitince tekrar 50'den baslar.",
		"Sure: Oyun suresi 5 dakikadir. Ne kadar sure kaldigina bakmak icin.\nPencerenin ismine bakmanýz yeterlidir.", "Pas: Bayragi gecmek icin Pas yazmaniz yeterli.",
		"Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear();
	text.setString(secilen[0] + "\n1. " + secilen[1] + "\n2. " + secilen[2] + "\n3. " + secilen[3] + "\n4. " + secilen[4] + "\n5. " + secilen[5] + "\n6. " + secilen[6] + "\n7." + secilen[7] + "\n8 ." + "Eger kapat yazarsaniz oyun aninda kapanir.\n");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed)
				window.close();
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
					window.close();
					oyun = true;
					yenitur.play();
					start_time = clock(); // Baþlangýç zamanýný al
					break;
				}
			}
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayný ülke gelirse tekrar seç
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.bayrak, seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 50;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				string kalansure = "Kalan Süre: " + to_string(sure - elapsed_time) + " Saniye";
				sf::RenderWindow window(sf::VideoMode(800, 600), kalansure);
				sf::Texture texture;
				if (texture.loadFromFile(kalici.bayrak)) {}
				sf::Sprite sprite(texture);
				window.clear();
				window.draw(sprite);
				if (!komut.empty()) {
					text.setString(gecilenulke);
					window.draw(text);
				}
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::Closed) {
							window.close();
							komut = "kapat";
							gecilenulke = "";
							break;
						}
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								gecilenulke = "";
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(gecilenulke + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(gecilenulke + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.bayrak, secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
						break; // Eþleþme bulundu, döngüden çýk
					}
				}
			}
			else {
				bitis = true;
				window.close();
				yazilanlar += "Sure Bitti!\n";
				yazilanlar += "Dogru Ulke: " + kalici.isim + "\n";
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
				yazilanlar += "Oyun Bitti\tYapan Kerem Kuyucu\n";
				yazilanlar += "Dogru Ulke Sayiniz: " + to_string(winstreak) + "\n";
				yazilanlar += "Puaniniz: " + to_string(toplampuan) + "\n";
				yazilanlar += "Websiteme bakmak istermisin: (Evet/Hayir)\n";
				text.setString(yazilanlar);
				window.clear();
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::Closed)
							window.close();
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								gecilenulke = "";
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(text);
								window.display();
							}
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				if (komut == "Evet")
					system("start https://kerem-kk.glitch.me/");
				oyun = 0;
				break;
			}
			if (komut != "Pas" && komut != "Bitir" && !gecici.ks(komut)) {
				yanlis.play();
				gecilenulke = "Boyle bir ulke bulunamadi.\n";
			}
			if (gecici.isim == kalici.isim) {
				dogru.play();
				gecilenulke = "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			if (gecici.ks(komut)) {
				yanlis.play();
				gecilenulke = "Yanlis tahmin!!\n";
				puan -= 10;
			}
			if (komut == "Pas") {
				yenitur.play();
				gecilenulke = "Geçilen Ülke: " + kalici.isim + "\n";
				break;
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
void Baskent() {
	sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
	sf::Font font;
	sf::Text text;
	sf::Event event;
	sf::Texture texture;
	text.setFont(font);
	text.setCharacterSize(24);
	text.setFillColor(sf::Color::Yellow);
	text.setPosition(10, 10);
	if (texture.loadFromFile("dosyalar/arkaplan.png")) {}
	sf::Sprite sprite(texture);
	if (!font.loadFromFile("dosyalar/arial.ttf")) {}
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut, gecilenulke, yazilanlar;
	clock_t start_time, end_time;
	bool oyun = false, bitis = false, pas = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	std::string secilen[] = { "Baskent Bilme Oyunu","Baskent Bilme Oyununa hos geldiniz. \nAmaciniz, 50 ulkeden rastgele secilen bir ulkenin baskentini bilmek.",
				"Puan Sistemi: Her turda puaniniz 50 den baslar her yanlis tahminde 10 azalir.\n3 Tahminden sonra kazanilan puan 20'e sabitlenir tur \nbitince tekrar 50'den baslar.",
				"Sure: Oyun suresi 5 dakikadir.Ne kadar sürenin kaldýgina bakmak icin.\nSayfanýn basina bakmaniz yeterli.","Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear();
	text.setString(secilen[0] + "\n1. " + secilen[1] + "\n2. " + secilen[2] + "\n3. " + secilen[3] + "\n4. " + secilen[4] + "\n5 ." + "Eger kapat yazarsaniz oyun aninda kapanir.\n6. Bitirmek icin 'Bitir' yazin.");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
					window.close();
					oyun = true;
					yenitur.play();
					start_time = clock(); // Baþlangýç zamanýný al
					break;
				}
			}
			if (event.type == sf::Event::Closed)
			{
				window.close();
			}
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayný ülke gelirse tekrar seç
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.bayrak, seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 50;
		while (true) {
			sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				yazilanlar += "Kalan Sure: " + to_string(sure - elapsed_time) + " Saniye\n";
				yazilanlar += "Baskent Adi: " + kalici.baskent + "\n";
				yazilanlar += "Lutfen bir tahmin giriniz : \n";
				window.clear();
				text.setString(yazilanlar);
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::Closed)
							window.close();
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.bayrak, secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
						break; // Eþleþme bulundu, döngüden çýk
					}
				}
			}
			else {
				yazilanlar = "";
				bitis = true;
				window.close();
				yazilanlar += "Sure Bitti!\n";
				yazilanlar += "Dogru Ulke: " + kalici.isim + "\n";
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
				yazilanlar += "Oyun Bitti\tYapan Kerem Kuyucu\n";
				yazilanlar += "Dogru Ulke Sayiniz: " + to_string(winstreak) + "\n";
				yazilanlar += "Puaniniz: " + to_string(toplampuan) + "\n";
				yazilanlar += "Websiteme bakmak istermisin: (Evet/Hayir)\n";
				text.setString(yazilanlar);
				window.clear();
				window.draw(sprite);
				window.draw(text);
				window.display();
				komut = "";
				while (window.isOpen()) {
					while (window.pollEvent(event)) {
						if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
							if (event.text.unicode == '\r') { // Enter tuþuna basýldýysa
								window.close();
								gecilenulke = "";
								break;
							}
							else if (event.text.unicode == '\b') { // Silme tuþuna basýldýysa
								if (!komut.empty()) {
									komut.erase(komut.size() - 1);
									text.setString(yazilanlar + komut);
									window.clear();
									window.draw(sprite);
									window.draw(text);
									window.display();
								}
							}
							else {
								komut += event.text.unicode;
								text.setString(yazilanlar + komut);
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						if (event.type == sf::Event::Closed)
						{
							window.close();
						}
						if (window.hasFocus())
							break;
					}
				}
				komut = kelimeDuzelt(komut);
				if (komut == "Evet")
					system("start https://kerem-kk.glitch.me/");
				oyun = 0;
				break;
			}
			if (komut != "Pas" && komut != "Bitir" && !gecici.ks(komut)) {
				yanlis.play();
				yazilanlar = "Boyle bir ulke bulunamadi.\n";
			}
			if (gecici.isim == kalici.isim) {
				dogru.play();
				yazilanlar = "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			if (gecici.ks(komut)) {
				yanlis.play();
				yazilanlar = "Yanlis tahmin\n";
				puan -= 10;
			}
			if (komut == "Pas") {
				yenitur.play();
				yazilanlar = "Gecilen Ulke: " + kalici.isim + "\n";
				break;
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
int main(void) {
	std::string remoteVersion, localVersion,komut;
	download("https://drive.usercontent.google.com/download?id=1KIYUZBqnagJmmD0WcfIYdVFjlb3ExyVM&export=download&authuser=0", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\remoteVersion.txt");
	std::ifstream file("dosyalar/remoteVersion.txt");
	std::ifstream file2("dosyalar/localVersion.txt");
	getline(file, remoteVersion);
	getline(file2, localVersion);
	file.close();
	file2.close();
	if (localVersion != remoteVersion) {
		sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
		sf::Font font;
		if (!font.loadFromFile("dosyalar/arial.ttf")) {}
		sf::Text text;
		sf::Texture texture;
		if (texture.loadFromFile("dosyalar/arkaplan.png")) {}
		sf::Sprite sprite(texture);
		text.setFont(font);
		text.setCharacterSize(24);
		text.setFillColor(sf::Color::Yellow);
		text.setPosition(10, 10);
		int secim = 0;
		while (window.isOpen()) {
			sf::Event event;
			while (window.pollEvent(event)) {
				if (event.type == sf::Event::Closed)
				{
					window.close();
					return 0;
				}
				if (event.type == sf::Event::KeyPressed) {
					if (event.key.code == sf::Keyboard::Up) {
						secim--;
						if (secim < 0) secim = 1;
					}
					else if (event.key.code == sf::Keyboard::Down) {
						secim++;
						if (secim > 1) secim = 0;
					}
					else if (event.key.code == sf::Keyboard::Return) {
						if (secim == 1) {
							window.close();
						}
						else if (secim == 0) {
							window.close();
						}
					}
				}
			}
			window.clear();
			if (secim == 1)
				komut = "Hayir";
			else
				komut = "Evet";
			text.setString("Internet Baglantin var mi?\nSectiginiz: " + komut +"\nEveti secersen ekran kapanacak oyun guncellenecek ardindan\noyun tekrar acilacak.");
			window.draw(sprite);
			window.draw(text);
			window.display();
		}
		if (komut == "Evet")
		{
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/logo.ico?v=1712323528221", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar\\logo.ico");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/dogru.ogg?v=1712246846428", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\dogru.ogg");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yanlis.ogg?v=1712246846933", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yanlis.ogg");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yenitur.ogg?v=1712246848934", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yenitur.ogg");
			download("https://drive.usercontent.google.com/download?id=1YYxo3mRZG0L6vK2f9b-sH39RkdlC6YRH&export=download&authuser=0&confirm=t&uuid=e8a908ac-9a17-4d68-937c-7da99e478739&at=APZUnTVncbTp9kdQem4Us1ukBrhY%3A1712266094378", "C:\\Users\\Public\\Documents\\cografyaoyun\\CografyaOyun.exe");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/CografyaOyun.lnk?v=1712323669142", "CografyaOyun.lnk");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan.png?v=1712610924818", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan.png");
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan2.png?v=1712610926441", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan2.png");
			std::ofstream file3("dosyalar/localVersion.txt");
			file3 << remoteVersion;
			file3.close();
		}
	}
	setlocale(LC_ALL, "Turkish");
	sf::Music dogru, yanlis, yenitur;
	if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	sf::RenderWindow window(sf::VideoMode(800, 600), "Kerem_KK");
	sf::Font font;
	if (!font.loadFromFile("dosyalar/arial.ttf")) {}
	sf::Text text;
	sf::Texture texture;
	if (texture.loadFromFile("dosyalar/arkaplan.png")) {}
	sf::Sprite sprite(texture);
	text.setFont(font);
	text.setCharacterSize(24);
	text.setFillColor(sf::Color::Yellow);
	text.setPosition(10, 10);
	int secim = 0;
	std::string secilen[] = { "Baskent Bilme Oyunu", "Mesafeden Ulke Bilme Oyunu", "Sehir Bilme Oyunu", "Bayrak Bilme Oyunu","Mesafeden Sehir Bilme Oyunu"};
	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed)
				window.close();
			if (event.type == sf::Event::KeyPressed) {
				if (event.key.code == sf::Keyboard::Up) {
					secim--;
					if (secim < 0) secim = 3; 
				}
				else if (event.key.code == sf::Keyboard::Down) {
					secim++;
					if (secim > 3) secim = 0;
				}
				else if (event.key.code == sf::Keyboard::Return) {
					komut = secilen[secim];
					if (secim == 0) {
						yenitur.play();
						window.close();
						Baskent();
					}
					else if (secim == 1) {
						yenitur.play();
						window.close();
						Mesafe();
					}
					else if (secim == 2) {
						yenitur.play();
						window.close();
						Sehir();
					}
					else if (secim == 3) {
						yenitur.play();
						window.close();
						Bayrak();
					}
				}
			}
		}
		window.clear();
		text.setString("Oyun Seciniz: (Ok tuslari ile)\nEger kapat yazarsaniz oyun aninda kapanir.\n\n1. " + secilen[0] + "\n2. " + secilen[1] + "\n3. " + secilen[2] + "\n4. " + secilen[3] + "\n\nSectiginiz: " + std::to_string(secim + 1));
		window.draw(sprite);
		window.draw(text);
		window.display();
	}
	return 0;
}

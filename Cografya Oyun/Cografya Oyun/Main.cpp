#include <iostream>
#include <string>
#include <iomanip> 
#include <vector>
#include <fstream>
#include <algorithm>
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
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
Ulkeler ulke12("dosyalar/bayraklar/guneykore.png", "Gneykore", "Guney kore", "Southkorea", "Dinsiz", "Asya", "Cumhuriyet", "Seul", "100,210 km²", "52 milyon", "1600 milyar $", "37.5139", "127.0097");
Ulkeler ulke13("dosyalar/bayraklar/avusturalya.png", "Avusturalya", "Avusturalya", "Australia", "Hristiyanlýk", "Avustralasya", "Federal parlamentar monarsi", "Canberra", "7,692,024 km²", "26 milyon", "1500 milyar $", "-25.2744", "133.7751");
Ulkeler ulke14("dosyalar/bayraklar/ispanya.png", "Spanya", "Ispanya", "Spain", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Madrid", "505,992 km²", "47 milyon", "1400 milyar $", "40.4167", "-3.7039");
Ulkeler ulke15("dosyalar/bayraklar/meksika.png", "Meksika", "Meksika", "Mexico", "Hristiyanlýk", "Kuzey Amerika", "Federal cumhuriyet", "Meksiko", "1,964,375 km²", "130 milyon", "1300 milyar $", "23.6345", "-102.5528");
Ulkeler ulke16("dosyalar/bayraklar/endonezya.png", "Endonezya", "Endonezya", "Indonesia", "Islam", "Asya", "Cumhuriyet", "Cakarta", "1,904,569 km²", "273 milyon", "1200 milyar $", "-1.5528", "120.2955");
Ulkeler ulke17("dosyalar/bayraklar/turkiye.png", "Trkiye", "Turkiye", "Turkey", "Islam", "Asya", "Cumhuriyet", "Ankara", "783,356 km²", "84 milyon", "1000 milyar $", "39.9333", "32.8597");
Ulkeler ulke18("dosyalar/bayraklar/hollanda.png", "Hollanda", "Hollanda", "Netherlands", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Amsterdam", "41,543 km²", "17 milyon", "1000 milyar $", "52.3702", "5.8223");
Ulkeler ulke19("dosyalar/bayraklar/suudiarabistan.png", "Suudiarabistan", "Arabistan", "Saudiarabia", "Islam", "Asya", "Mutlak monarsi", "Riyad", "2,149,690 km²", "35 milyon", "700 milyar $", "24.6408", "46.7727");
Ulkeler ulke20("dosyalar/bayraklar/isvicre.png", "Isvire", "Isvicre", "Switzerland", "Hristiyanlýk", "Avrupa", "Federal parlamentar cumhuriyet", "Bern", "41,290 km²", "8.5 milyon", "800 milyar $", "46.8182", "8.2275");
Ulkeler ulke21("dosyalar/bayraklar/tayvan.png", "Tayvan", "Tayvan", "Taiwan", "Budizm", "Asya", "Özerk", "Taipei", "6,193 km²", "23.8 milyon", "800 milyar $", "23.6978", "120.9605");
Ulkeler ulke22("dosyalar/bayraklar/polonya.png", "Polonya", "Polonya", "Poland", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Varsova", "312,696 km²", "38 milyon", "700 milyar $", "51.9194", "19.1451");
Ulkeler ulke23("dosyalar/bayraklar/arjantin.png", "Arjantin", "Arjantin", "Argentina", "Hristiyanlýk", "Guney Amerika", "Federal cumhuriyet", "Buenos aires", "2,780,400 km²", "45 milyon", "400 milyar $", "-38.4161", "-63.5709");
Ulkeler ulke24("dosyalar/bayraklar/isvec.png", "Isve", "Isvec", "Sweden", "Hristiyanlýk", "Avrupa", "Parlementar monarsi", "Stockholm", "450,295 km²", "10.5 milyon", "600 milyar $", "60.1282", "18.6435");
Ulkeler ulke25("dosyalar/bayraklar/pakistan.png", "Pakistan", "Pakistan", "Pakistan", "Islam", "Asya", "Federal parlamentar Monarsi", "Islamabad", "881,913 km²", "232 milyon", "300 milyar $", "30.3753", "69.3451");
Ulkeler ulke26("dosyalar/bayraklar/belcika.png", "Belika", "Belcika", "Belgium", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Bruksel", "30,528 km²", "11.5 milyon", "600 milyar $", "50.8503", "4.3517");
Ulkeler ulke27("dosyalar/bayraklar/norvec.png", "Norve", "Norvec", "Norway", "Hristiyanlýk", "Avrupa", "Parlamentar monarsi", "Oslo", "323,802 km²", "5.4 milyon", "600 milyar $", "60.4722", "8.4689");
Ulkeler ulke28("dosyalar/bayraklar/guneyafrika.png", "Gneyafrika", "Guney afrika", "Southafrica", "Hristiyanlýk", "Afrika", "Parlamentar monarsi", "Pretoria", "1,219,090 km²", "61 milyon", "350 milyar $", "-30.5595", "22.9375");
Ulkeler ulke29("dosyalar/bayraklar/malezya.png", "Malezya", "Malezya", "Malaysia", "Islam", "Asya", "Federal parlamentar monarsi", "Kualalumpur", "330,803 km²", "32 milyon", "360 milyar $", "4.2105", "101.9757");
Ulkeler ulke30("dosyalar/bayraklar/katar.png", "Katar", "Katar", "Qatar", "Islam", "Asya", "Mutlak monarsi", "Doha", "11,586 km²", "2.8 milyon", "180 milyar $", "25.3548", "51.1839");
Ulkeler ulke31("dosyalar/bayraklar/misir.png", "Msr", "Misir", "Egypt", "Islam", "Afrika", "Cumhuriyet", "Kahire", "1,010,408 km²", "104 milyon", "400 milyar $", "26.8205", "30.8025");
Ulkeler ulke32("dosyalar/bayraklar/sili.png", "Ili", "Sili", "Chile", "Hristiyanlýk", "Güney Amerika", "Cumhuriyet", "Santiago", "756,102 km²", "19 milyon", "300 milyar $", "-35.6751", "-71.5429");
Ulkeler ulke33("dosyalar/bayraklar/yunanistan.png", "Yunanistan", "Yunanistan", "Greece", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Atina", "131,957 km²", "10 milyon", "200 milyar $", "39.0742", "21.8243");
Ulkeler ulke34("dosyalar/bayraklar/iran.png", "Iran", "Iran", "Iran", "Islam", "Asya", "Cumhuriyet", "Tahran", "1,648,195 km²", "85 milyon", "430 milyar $", "32.4279", "53.6880");
Ulkeler ulke35("dosyalar/bayraklar/israil.png", "Israil", "Israil", "Israel", "Yahudilik", "Asya", "Parlamentar cumhuriyet", "Tel aviv", "20,770 km²", "9 milyon", "370 milyar $", "31.0461", "34.8516");
Ulkeler ulke36("dosyalar/bayraklar/romanya.png", "Romanya", "Romanya", "Romania", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Bükreþ", "238,397 km²", "19 milyon", "250 milyar $", "44.4375", "26.1025");
Ulkeler ulke37("dosyalar/bayraklar/ukrayna.png", "Ukrayna", "Ukrayna", "Ukraine", "Hristiyanlýk", "Avrupa", "Parlamenter cumhuriyet", "Kiev", "603,500 km²", "41 milyon", "490 milyar $", "48.3739", "31.1764");
Ulkeler ulke38("dosyalar/bayraklar/kazakistan.png", "Kazakistan", "Kazakistan", "Kazakhstan", "Islam", "Asya", "Cumhuriyet", "Nur sultan", "2,724,900 km²", "18 milyon", "350 milyar $", "48.0196", "66.9237");
Ulkeler ulke39("dosyalar/bayraklar/finlandiya.png", "Finlandiya", "Finlandiya", "Finland", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Helsinki", "338,455 km²", "5.5 milyon", "280 milyar $", "60.1699", "24.9463");
Ulkeler ulke40("dosyalar/bayraklar/azerbaycan.png", "Azerbaycan", "Azerbaycan", "Azerbaijan", "Islam", "Asya", "Cumhuriyet", "Bakü", "86,600 km²", "10 milyon", "170 milyar $", "40.395", "49.882");
Ulkeler ulke41("dosyalar/bayraklar/singapur.png", "Singapur", "Singapur", "Singapore", "Budizm", "Asya", "Parlamenter cumhuriyet", "Singapur", "719 km²", "5.8 milyon", "550 milyar $", "1.3521", "103.8198");
Ulkeler ulke42("dosyalar/bayraklar/gurcistan.png", "Grcistan", "Gurcistan", "Georgia", "Hristiyanlýk", "Asya", "Yari baskanlik cumhruriyeti", "Tiflis", "69,700 km²", "3.7 milyon", "17 milyar $", "41.7151", "44.7871 ");
Ulkeler ulke43("dosyalar/bayraklar/vietnam.png", "Vietnam", "Vietnam", "Vietnam", "Budizm", "Asya", "Tek parti sosyalist cumhuriyet", "Hanoi", "331,212 km²", "98 milyon", "261 milyar $", "21.0278", "105.8502 ");
Ulkeler ulke44("dosyalar/bayraklar/avusturya.png", "Avusturya", "Avusturya", "Austria", "Hristiyanlýk", "Avrupa", "Federal parlamentar cumhuriyet", "Viyana", "83,879 km²", "9 milyon", "480 milyar $", "48.2082 ", "16.3738 ");
Ulkeler ulke45("dosyalar/bayraklar/nijerya.png", "Nijerya", "Nijerya", "Nigeria", "Islam", "Afrika", "Federal cumhuriyet", "Abuja", "923,768 km²", "211 milyon", "450 milyar $", "9.0819", "7.9389 ");
Ulkeler ulke46("dosyalar/bayraklar/kuba.png", "Kba", "Kuba", "Cuba", "Hristiyanlýk", "Kuzey Amerika", "Sosyalist cumhuriyet", "Havana", "109,884 km²", "11 milyon", "100 milyar $", "23.1139", "-82.3669");
Ulkeler ulke47("dosyalar/bayraklar/kirgizistan.png", "Krgzistan", "Kirgizistan", "Kyrgyz", "Islam", "Asya", "Parlamentar cumhuriyet", "Biskek", "199,951 km²", "6.5 milyon", "8 milyar $", "42.8746", "74.5981");
Ulkeler ulke48("dosyalar/bayraklar/cezayir.png", "Cezayir", "Cezayir", "Algeria", "Islam", "Afrika", "Yari baskanlik cumhruriyeti", "Cezayir", "2.382.000 km²", "44 milyon", "164 milyar $", "36.7", "3.216667 ");
Ulkeler ulke49("dosyalar/bayraklar/malta.png", "Malta", "Malta", "Malta", "Hristiyanlýk", "Avrupa", "Parlamentar cumhuriyet", "Valetta", "316 km²", "0.5 milyon", "12 milyar $", "35.9375", "14.5001 ");
Ulkeler ulke50("dosyalar/bayraklar/panama.png", "		Panama", "Panama", "Panama", "Hristiyanlýk", "Orta Amerika", "Baþkanlýk cumhuriyeti", "Panama", "75,417 km²", "4.3 milyon", "68 milyar $", "8.5386", "-80.7821");

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
//1		Akdeniz Bölgesi
//2		Doðu Anadolu Bölgesi
//3		Ege Bölgesi
//4		Güneydoðu Anadolu Bölgesi
//5		Ýç Anadolu Bölgesi
//6		Karadeniz Bölgesi
//7		Marmara Bölgesi
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
		if (isalpha(karakter)) { ilkislem += karakter;
		}
	}
	sonuc += toupper(ilkislem[0]); 
	for (size_t i = 1; i < ilkislem.length(); ++i) { 
		sonuc += tolower(ilkislem[i]); } 
	return sonuc;
}
string trharita = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@,,,,,.@@@@@@@@@@@@@@,**,,,,,.,*.,**@@@@@@@@@@@@@@@@@@@@@@@@*@@@@@@@@@@@@\n@@@@@@@,,*,*,.,.****,***,*,*****,,.*,**.******,*% @@@%.*@@@%**,*,***,.@@@@@@@@@@\n@@@@@@@@@.@@@@@@.**,,***,* .,,**,***, * ,***,***.***,***,.,,,***,***,**@@@@@@@@@\n@@@@@@@,*,*,**********,***.*****,*****,,************,*****.**. *.*******%*@@@@@@\n@@@@@@.*@&************************,*******,*****,******,.*******,*,*******@@@@@@\n@@@@@@@@@*******************,,**,*..****,***********,******,.**, ********@@@@@@@\n@@@@@@@@ @,*****,**,*****.*******,,.,**,*****,*.**,******,,***,,*,,***,.*@@@@@@@\n@@@@@@@@@@@.****,**,***,,.******,****..****,....*,,****,*****,,*,,*******@@@@@@@\n@@@@@@@@@@@,****,*******,******,,**,**** .,*,***,********,*,****,**,******,@@@@@\n@@@@@@@@@@@@@@,,**,****/.*****,***********,**,,,**@@*****,@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@**, ,@@@@@@*,*,*,,@@@@@@,*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
string resimgoster(string konum) {
	string komut;
	sf::RenderWindow window(sf::VideoMode(275, 183), "Bayrak");
	sf::Texture texture;
	if (!texture.loadFromFile(konum))
		komut = "";
	sf::Sprite sprite(texture);
	window.clear();
	window.draw(sprite);
	window.display();
	cout << green << "Ülke Adýný Giriniz : " << endl << yellow;
	getline(cin, komut);
	return komut;
}
void bolgeyaz(string isim, int aaa) {
	cout << yellow << isim << "\t";
	for (size_t a = 0;a < (sehir.size());a++) {
		const Sehirler& secilensehir = sehir[a];
		if (sehir[a].bolge == aaa) {
			if (sehir[a].bilgi == true) {
				cout << yellow << sehir[a].plaka << " " << green << sehir[a].isim << "\t";
			}
			else
				cout << red << "_____\t";
		}
	}
	cout << endl;
}
void ulkeyaz() {
	cout << blue << "---------------------------------------------------------" << endl;
	cout << green << "Ülkeler: " << endl;
	for (int b = 0;b < (ulke.size());b++) {
		const Ulkeler& secilenulke = ulke[b];
		cout << yellow << secilenulke.isim << ", ";
		if ((b + 1) % 5 == 0)
			if (b + 1 != 50)
				cout << endl;
	}
	cout << blue << "\n---------------------------------------------------------" << endl;
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
	const char* yonler[] = { "Kuzey", "Kuzeydoðu", "Doðu", "Güneydoðu", "Güney", "Güneybatý", "Batý", "Kuzeybatý" };
	int indeks = static_cast<int>((derece + 22.5) / 45.0) % 8;
	return yonler[indeks];
}

struct OyunBilgileri {
	string isim;
	int puan;
	int tur;
	string tarih;
	string oyun;
};

bool cmpPuan(const OyunBilgileri& a, const OyunBilgileri& b) {
	return a.puan > b.puan;
}
void dosyaoku() {
	ifstream dosya("dosyalar/log.txt");
	vector<OyunBilgileri> mesafeBilgileri, ulkeBilgileri, baskentBilgileri, sehirBilgileri, bayrakBilgileri;
	string oyunBilgi, satirIsim, satirPuan, satirTur, satirTarih, komut;
	int a = 1;
	int b = 1;
	int c = 1;
	while (getline(dosya, oyunBilgi) && getline(dosya, satirIsim) && getline(dosya, satirPuan) &&
		getline(dosya, satirTur) && getline(dosya, satirTarih) && getline(dosya, komut)) {
		OyunBilgileri bilgi;
		bilgi.isim = satirIsim;
		bilgi.puan = stoi(satirPuan);
		bilgi.tur = stoi(satirTur);
		bilgi.tarih = satirTarih;

		if (oyunBilgi == "mesafe") {
			mesafeBilgileri.push_back(bilgi);
		}
		else if (oyunBilgi == "ulke") {
			ulkeBilgileri.push_back(bilgi);
		}
		else if (oyunBilgi == "baskent") {
			baskentBilgileri.push_back(bilgi);
		}
		else if (oyunBilgi == "sehir") {
			sehirBilgileri.push_back(bilgi);
		}
		else if (oyunBilgi == "bayrak") {
			bayrakBilgileri.push_back(bilgi);
		}
	}
	dosya.close();

	sort(mesafeBilgileri.begin(), mesafeBilgileri.end(), cmpPuan);
	sort(ulkeBilgileri.begin(), ulkeBilgileri.end(), cmpPuan);
	sort(baskentBilgileri.begin(), baskentBilgileri.end(), cmpPuan);
	sort(sehirBilgileri.begin(), sehirBilgileri.end(), cmpPuan);
	sort(bayrakBilgileri.begin(), bayrakBilgileri.end(), cmpPuan);

	cout << blue << "---------------------------------------------------------" << endl;
	cout << yellow << "Ülke Bilme Oyunu: " << red << "Tarih ay/gün/yýl saat þeklinde." << endl << green;
	for (const auto& ulke : ulkeBilgileri) {
		cout << a++ << ". Ýsmi: " << ulke.isim
			<< " Puaný: " << ulke.puan
			<< " Kazandýðý Tur: " << ulke.tur
			<< " Tarih: " << ulke.tarih << endl;
	}
	cout << blue << "---------------------------------------------------------" << endl;
	cout << yellow << "Baþkent Bilme Oyunu: " << red << "Tarih ay/gün/yýl saat þeklinde." << endl << green;
	for (const auto& baskent : baskentBilgileri) {
		cout << b++ << ". Ýsmi: " << baskent.isim
			<< " Puaný: " << baskent.puan
			<< " Kazandýðý Tur: " << baskent.tur
			<< " Tarih: " << baskent.tarih << endl;
	}
	cout << blue << "---------------------------------------------------------" << endl;
	cout << yellow << "Mesafeden Ülke Bilme Oyunu: " << red << "Tarih ay/gün/yýl saat þeklinde." << endl << green;
	for (const auto& mesafe : mesafeBilgileri) {
		cout << c++ << ". Ýsmi: " << mesafe.isim
			<< " Puaný: " << mesafe.puan
			<< " Kazandýðý Tur: " << mesafe.tur
			<< " Tarih: " << mesafe.tarih << endl;
	}
	cout << blue << "---------------------------------------------------------" << endl;
	cout << yellow << "Þehir Bilme Oyunu: " << red << "Tarih ay/gün/yýl saat þeklinde." << endl << green;
	for (const auto& sehir : sehirBilgileri) {
		cout << c++ << ". Ýsmi: " << sehir.isim
			<< " Puaný: " << sehir.puan
			<< " Kazandýðý Tur: " << sehir.tur
			<< " Tarih: " << sehir.tarih << endl;
	}
	cout << blue << "---------------------------------------------------------" << endl;
	cout << yellow << "Bayrak Bilme Oyunu: " << red << "Tarih ay/gün/yýl saat þeklinde." << endl << green;
	for (const auto& bayrak : bayrakBilgileri) {
		cout << c++ << ". Ýsmi: " << bayrak.isim
			<< " Puaný: " << bayrak.puan
			<< " Kazandýðý Tur: " << bayrak.tur
			<< " Tarih: " << bayrak.tarih << endl;
	}
	cout << blue << "---------------------------------------------------------" << endl;
}
void dosyayaz(string a, int b, int c, string d) {
	ofstream dosya("dosyalar/log.txt", ios::app);
	time_t currentTime; time(&currentTime); struct tm localTime; localtime_s(&localTime, &currentTime);
	dosya << d << endl
		<< a << endl
		<< b << endl
		<< c << endl
		<< put_time(&localTime, "%c") << endl
		<< "-------------------------------------" << endl;
	dosya.close();
}
//-------------------------------------------------------------------------------------------------------------------------
#include "Ulke_Oyun.h"
#include "Baskent_Oyun.h"
#include "Mesafe_Oyun.h"
#include "Sehir_Oyun.h"
#include "Bayrak_Oyun.h"
int main() {
	Music yasasinirkimiz; if (!yasasinirkimiz.openFromFile("dosyalar/sesler/yasasinirkimiz.ogg")) {};
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut, sayi;
	setlocale(LC_ALL, "Turkish");
	while (true) {
		cout << red << "Önceki Sýralamalara bakmak için " << yellow << "\"Liste\"" << red << " yazabilirsiniz." << endl;
		cout << yellow << "Oyun Seçini Yapýnýz." << endl;
		cout << yellow << "1" << green << " Ülke Bilme Oyunu" << endl;
		cout << yellow << "2" << green << " Baþkent Bilme Oyunu" << endl;
		cout << yellow << "3" << green << " Mesafeden Ülke Bilme Oyunu" << endl;
		cout << yellow << "4" << green << " Þehir Bilme Oyunu" << endl;
		cout << yellow << "5" << green << " Bayrak Bilme Oyunu" << endl;
		cout << yellow;
		getline(cin, komut);
		sayi = komut;
		komut = kelimeDuzelt(komut);
		if (komut == "Liste") {
			dosyaoku();
			yenitur.play();
			continue;
		}
		else if (sayi == "1" || komut == "Lkebilmeoyunu" || komut == "Ulkebilmeoyunu") {
			Ulke();
			yenitur.play();
			break;
		}
		else if (sayi == "2" || komut == "Bakentbilmeoyunu" || komut == "Baskentbilmeoyunu") {
			Baskent();
			yenitur.play();
			break;
		}
		else if (sayi == "3" || komut == "Mesafebilmeoyunu") {
			Mesafe();
			yenitur.play();
			break;
		}
		else if (sayi == "4" || komut == "Ehirbilmeoyunu" || komut == "Sehirbilmeoyunu") {
			Sehir();
			yenitur.play();
			break;
		}
		else if (sayi == "5" || komut == "Bayrakbilmeoyunu") {
			Bayrak();
			yenitur.play();
			break;
		}
		else {
			yanlis.play();
			cout << red << "Geçersiz Komut!" << endl;
			continue;
		}
	}
}
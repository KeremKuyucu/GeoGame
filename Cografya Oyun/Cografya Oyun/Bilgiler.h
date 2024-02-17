#pragma once
using namespace std;
class Ulkeler {
public:
	string trisim, isim, enisim, din, kita, baskent, yonetimbicimi, yuzolcum, nufus, ekonomi,enlem, boylam;
	Ulkeler(string aa0, string aa1, string aaa2, string aa2, string aa3, string aa4, string aa5, string aa6, string aa7, string aa8, string aa9, string aa10) {
		trisim = aa0, isim = aa1, enisim = aaa2, din = aa2, kita = aa3, yonetimbicimi = aa4, baskent = aa5, yuzolcum = aa6, nufus = aa7, ekonomi = aa8, enlem = aa9, boylam = aa10;
	}
	bool ks(string yapilantahmin) { return (yapilantahmin == trisim || yapilantahmin == isim || yapilantahmin == enisim);}
};
//             trisim			  isim			enisim			 din              kita			   yonetimbicimi				  	 baskent		 yuzolcum		  nufus         ekonomi		    enlem    boylam
Ulkeler ulke1 ("Abd",			 "Amerika",	   "Unitedstates",	"Hristiyanl�k", "Kuzey Amerika",  "Federal cumhuriyet",				"Washington",   "9,631,418 km�" ,"331 milyon" ,"22000 milyar $","37.0902", "-95.7129");
Ulkeler ulke2 ("In",			 "Cin",		   "China",			"Budizm",		"Asya",			  "Tek parti sosyalist cumhuriyet", "Pekin",		"9,596,960 km�" ,"1410 milyon","16000 milyar $","35.8616", "104.1954");
Ulkeler ulke3 ("Japonya",		 "Japonya",	   "Japan",			"Budizm",		"Asya",			  "Parlamentar monarsi",		    "Tokyo",		"377,975 km�"   ,"125 milyon" ,"6000 milyar $", "36.2048", "138.2529");
Ulkeler ulke4 ("Almanya",		 "Almanya",	   "Germany",		"Hristiyanl�k", "Avrupa",		  "Federal parlamentar cumhuriyet", "Berlin",		"357,022 km�"   ,"83 milyon"  ,"4000 milyar $", "51.1657", "10.4515");
Ulkeler ulke5 ("Hindistan",		 "Hindistan",  "India",			"Hinduizm",		"Asya",			  "Federal parlamentar cumhuriyet", "Yeni delhi",	"3,287,260 km�" ,"1370 milyon","3000 milyar $", "20.5937", "78.9629");
Ulkeler ulke6 ("Birleikkralk",	 "Ingiltere",  "Unitedkingdom", "Hristiyanl�k", "Avrupa",		  "Parlamentar monarsi",		    "Londra",		"243,610 km�"   ,"68 milyon"  ,"3000 milyar $", "51.5001", "-0.1262");
Ulkeler ulke7 ("Fransa",		 "Fransa",	   "France",		"Hristiyanl�k", "Avrupa",		  "Yari baskanlik cumhruriyeti",    "Paris",		"551,695 km�"   ,"67 milyon"  ,"3000 milyar $", "48.8566", "2.3488");
Ulkeler ulke8 ("Rusya",			 "Rusya",	   "Russia",		"Hristiyanl�k", "Asya",			  "Federal cumhuriyet",			    "Moskova",		"17,125,191 km�","146 milyon" ,"2000 milyar $", "61.5240", "105.3188");
Ulkeler ulke9 ("Brezilya",		 "Brezilya",   "Brazil",		"Hristiyanl�k", "Guney Amerika",  "Federal cumhuriyet",				"Brasilia",		"8,515,767 km�" ,"215 milyon" ,"1600 milyar $", "-14.2350","-51.9253");
Ulkeler ulke10("Talya",			 "Italya",	   "Italy",			"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhruriyet",		"Roma",			"301,340 km�"   ,"60 milyon"  ,"2000 milyar $", "41.8902", "12.4823");
Ulkeler ulke11("Kanada",		 "Kanada",	   "Canada",		"Hristiyanl�k", "Kuzey Amerika",  "Federal parlamentar monarsi",    "Ottawa",		"9,984,670 km�" ,"38 milyon"  ,"1800 milyar $", "56.1304", "-106.3468");
Ulkeler ulke12("Gneykore",		 "Guney kore", "Southkorea",	"Dinsiz",		"Asya",			  "Cumhuriyet",						"Seul",			"100,210 km�"   ,"52 milyon"  ,"1600 milyar $", "37.5139", "127.0097");
Ulkeler ulke13("Avusturalya",    "Avusturalya","Australia",		"Hristiyanl�k", "Avustralasya",   "Federal parlamentar monarsi",    "Canberra",		"7,692,024 km�" ,"26 milyon"  ,"1500 milyar $", "-25.2744","133.7751");
Ulkeler ulke14("Spanya",		 "Ispanya",	   "Spain",			"Hristiyanl�k", "Avrupa",		  "Parlamentar monarsi",		    "Madrid",		"505,992 km�"   ,"47 milyon"  ,"1400 milyar $", "40.4167", "-3.7039");
Ulkeler ulke15("Meksika",		 "Meksika",	   "Mexico",		"Hristiyanl�k", "Kuzey Amerika",  "Feoderal cumhuriyet",			"Meksiko",		"1,964,375 km�" ,"130 milyon" ,"1300 milyar $", "23.6345", "-102.5528");
Ulkeler ulke16("Endonezya",		 "Endonezya",  "Indonesia",		"Islam",		"Asya",			  "Cumhuriyet",						"Cakarta",		"1,904,569 km�" ,"273 milyon" ,"1200 milyar $", "-1.5528", "120.2955");
Ulkeler ulke17("Trkiye",         "Turkiye",	   "Turkey",		"Islam",		"Asya",			  "Cumhuriyet",						"Ankara",		"783,356 km�"   ,"84 milyon"  ,"1000 milyar $", "39.9333", "32.8597");
Ulkeler ulke18("Hollanda",       "Hollanda",   "Netherlands",	"Hristiyanl�k", "Avrupa",		  "Parlamentar monarsi",		    "Amsterdam",	"41,543 km�"    ,"17 milyon"  ,"1000 milyar $", "52.3702", "5.8223");
Ulkeler ulke19("Suudiarabistan", "Arabistan",  "Saudiarabia",	"Islam",		"Asya",			  "Mutlak monarsi",					"Riyad",		"2,149,690 km�" ,"35 milyon"  ,"700 milyar $", "24.6408",  "46.7727");
Ulkeler ulke20("Isvire",		 "Isvicre",	   "Switzerland",	"Hristiyanl�k", "Avrupa",		  "Federal parlamentar cumhuriyet", "Bern",			"41,290 km�"    ,"8.5 milyon" ,"800 milyar $", "46.8182",  "8.2275");
Ulkeler ulke21("Tayvan",		 "Tayvan",	   "Taiwan",		"Budizm",		"Asya",			  "�zerk",							"Taipei",		"6,193 km�"     ,"23.8 milyon","800 milyar $", "23.6978",  "120.9605");
Ulkeler ulke22("Polonya",		 "Polonya",	   "Poland",		"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhuriyet",			"Varsova",		"312,696 km�"   ,"38 milyon"  ,"700 milyar $", "51.9194",  "19.1451");
Ulkeler ulke23("Arjantin",		 "Arjantin",   "Argentina",		"Hristiyanl�k", "Guney Amerika",  "Federal cumhuriyet",				"Buenos aires", "2,780,400 km�" ,"45 milyon"  ,"400 milyar $", "-38.4161", "-63.5709");
Ulkeler ulke24("Isve",			 "Isvec",	   "Sweden",		"Hristiyanl�k", "Avrupa",		  "Parlementar monarsi",		    "Stockholm",	"450,295 km�"	,"10.5 milyon","600 milyar $", "60.1282",  "18.6435");
Ulkeler ulke25("Pakistan",		 "Pakistan",   "Pakistan",		"Islam",        "Asya",		      "Federal parlamentar Monarsi",	"Islamabad",	"881,913 km�"   ,"232 milyon" ,"300 milyar $", "30.3753",  "69.3451");
Ulkeler ulke26("Belika",		 "Belcika",	   "Belgium",		"Hristiyanl�k", "Avrupa",		  "Parlamentar monarsi",			"Bruksel",		"30,528 km�"    ,"11.5 milyon","600 milyar $", "50.8503",  "4.3517");
Ulkeler ulke27("Norve",			 "Norvec",	   "Norway",		"Hristiyanl�k", "Avrupa",		  "Parlamentar monarsi",			"Oslo",			"323,802 km�"   ,"5.4 milyon" ,"600 milyar $", "60.4722",  "8.4689");
Ulkeler ulke28("Gneyafrika",	 "Guney afrika","Southafrica",	"Hristiyanl�k", "Afrika",		  "Parlamentar monarsi",			"Pretoria",		"1,219,090 km�" ,"61 milyon"  ,"350 milyar $", "-30.5595", "22.9375");
Ulkeler ulke29("Malezya",		 "Malezya",	   "Malaysia",		"Islam",		"Asya",			  "Federal parlamentar monarsi",    "Kualalumpur",	"330,803 km�"   ,"32 milyon"  ,"360 milyar $", "4.2105",   "101.9757");
Ulkeler ulke30("Katar",			 "Katar",	   "Qatar",			"Islam",		"Asya",			  "Mutlak monarsi",				    "Doha",		 	"11,586 km�"    ,"2.8 milyon" ,"180 milyar $", "25.3548",  "51.1839");
Ulkeler ulke31("Msr",			 "Misir",	   "Egypt",			"Islam",		"Afrika",		  "Cumhuriyet",					    "Kahire",	    "1,010,408 km�" ,"104 milyon" ,"400 milyar $", "26.8205",  "30.8025");
Ulkeler ulke32("Ili",			 "Sili",	   "Chile",			"Hristiyanl�k", "G�ney Amerika",  "Cumhuriyet",						"Santiago",		"756,102 km�"   ,"19 milyon"  ,"300 milyar $", "-35.6751", "-71.5429");
Ulkeler ulke33("Yunanistan",	 "Yunanistan", "Greece",		"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhuriyet",		    "Atina",		"131,957 km�"   ,"10 milyon"  ,"200 milyar $", "39.0742",  "21.8243");
Ulkeler ulke34("Iran",			 "Iran",	   "Iran",			"Islam",		"Asya",			  "Cumhuriyet",						"Tahran",		"1,648,195 km�" ,"85 milyon"  ,"430 milyar $", "32.4279",  "53.6880");
Ulkeler ulke35("Israil",		 "Israil",	   "Israel",		"Yahudilik",	"Asya",			  "Parlamentar cumhuriyet",			"Tel aviv",		"20,770 km�"    ,"9 milyon"   ,"370 milyar $", "31.0461",  "34.8516");
Ulkeler ulke36("Romanya",		 "Romanya",	   "Romania",		"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhuriyet",		    "B�kre�",		"238,397 km�"   ,"19 milyon"  ,"250 milyar $", "44.4375",  "26.1025");
Ulkeler ulke37("Ukrayna",		 "Ukrayna",    "Ukraine",		"Hristiyanl�k", "Avrupa",		  "Parlamenter cumhuriyet",			"Kiev",			"603,500 km�"   ,"41 milyon"  ,"490 milyar $", "48.3739",  "31.1764");
Ulkeler ulke38("Kazakistan",	 "Kazakistan", "Kazakhstan",	"Islam",		"Asya",			  "Cumhuriyet",						"Nur sultan",	"2,724,900 km�" ,"18 milyon"  ,"350 milyar $", "48.0196",  "66.9237");
Ulkeler ulke39("Finlandiya",	 "Finlandiya", "Finland",		"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhuriyet",		    "Helsinki",		"338,455 km�"   ,"5.5 milyon" ,"280 milyar $", "60.1699",  "24.9463");
Ulkeler ulke40("Azerbaycan",	 "Azerbaycan", "Azerbaijan",	"Islam",		"Asya",			  "Cumhuriyet",					    "Bak�",			"86,600 km�"    ,"10 milyon"  ,"170 milyar $", "40.395",   "49.882");
Ulkeler ulke41("Singapur",		 "Singapur",   "Singapore",		"Budizm",		"Asya",			  "Parlamenter cumhuriyet",			"Singapur",		"719 km�"		,"5.8 milyon" ,"550 milyar $", "1.3521",   "103.8198");
Ulkeler ulke42("Grcistan",		 "Gurcistan",  "Georgia",		"Hristiyanl�k", "Asya",			  "Yar� ba�kanl�k cumhuriyeti",		"Tiflis",		"69,700 km�"	,"3.7 milyon" ,"17 milyar $",  "41.7151",  "44.7871 ");
Ulkeler ulke43("Vietnam",		 "Vietnam",    "Vietnam",		"Budizm",		"Asya",			  "Tek parti sosyalist cumhuriyet", "Hanoi",		"331,212 km�"	,"98 milyon"  ,"261 milyar $", "21.0278",  "105.8502 ");
Ulkeler ulke44("Avusturya",		 "Avusturya",  "Austria",		"Hristiyanl�k", "Avrupa",		  "Federal parlamentar cumhuriyet", "Viyana",		"83,879 km�"    ,"9 milyon"   ,"480 milyar $", "48.2082 ", "16.3738 ");
Ulkeler ulke45("Nijerya",		 "Nijerya",	   "Nigeria",		"Islam",		"Afrika",		  "Federal cumhuriyet",				"Abuja",		"923,768 km�"	,"211 milyon" ,"450 milyar $", "9.0819",   "7.9389 ");
Ulkeler ulke46("Kba",		     "Kuba",	   "Cuba",			"Hristiyanl�k", "Kuzey Amerika",  "Sosyalist cumhuriyet",			"Havana",		"109,884 km�"   ,"11 milyon"  ,"100 milyar $", "23.1139",  "-82.3669");
Ulkeler ulke47("Krg�zistan",     "Kirg�zistan","Kyrgyz",		"Islam",		"Asya",			  "Parlamentar cumhuriyet",			"Biskek",		"199,951 km�"   ,"6.5 milyon" ,"8 milyar $",   "42.8746",  "74.5981");
Ulkeler ulke48("Cezayir",	     "Cezayir",	   "Algeria",		"Islam",		"Afrika",		  "Yari baskanlik cumhruriyeti",	"Cezayir",	    "2.382.000 km�" ,"44 milyon"  ,"164 milyar $", "36.7",     "3.216667 ");
Ulkeler ulke49("Malta",			 "Malta",	   "Malta",			"Hristiyanl�k", "Avrupa",		  "Parlamentar cumhuriyet",		    "Valetta",		"316 km�"		,"0.5 milyon" ,"12 milyar $",  "35.9375",  "14.5001 " );
Ulkeler ulke50("Panama",		 "Panama",	   "Panama",		"Hristiyanl�k", "Orta Amerika",   "Ba�kanl�k cumhuriyeti",			"Panama",		"75,417 km�"	,"4.3 milyon" ,"68 milyar $",  "8.5386",   "-80.7821");

vector<Ulkeler> ulke = { ulke1,  ulke2,  ulke3,  ulke4,  ulke5,  ulke6,  ulke7,  ulke8,  ulke9,  ulke10,
						 ulke11, ulke12, ulke13, ulke14, ulke15, ulke16, ulke17, ulke18, ulke19, ulke20,
						 ulke21, ulke22, ulke23, ulke24, ulke25, ulke26, ulke27, ulke28, ulke29, ulke30,
						 ulke31, ulke32, ulke33, ulke34, ulke35, ulke36, ulke37, ulke38, ulke39, ulke40,
						 ulke41, ulke42, ulke43, ulke44, ulke45, ulke46, ulke47, ulke48, ulke49, ulke50, };


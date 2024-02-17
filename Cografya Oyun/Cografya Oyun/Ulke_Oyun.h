using namespace std;

void Ulke() {
	string komut, sayi;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300, yanl�s = 5;;
	//Oyunla �lgili A��klamalar�n Yazd��� Yer
	cout << yellow << "�lke Bilme Oyunu\n";
	cout << green << "�lke bilme oyununa ho� geldiniz. \nAmac�n�z, 50 �lkeden rastgele se�ilen bir �lkeyi tahmin etmektir. \nSordu�unuz sorulara g�re �lkeyi tahmin etmeniz gerekmektedir. \n5 yanl�� hakk�n�z bulunmaktad�r.";
	cout << green << "�nceki S�ralamalara bakmak i�in " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Joker Sistemi:" << endl << green << "3 tane ba�kenti ��renme joker hakk�n�z bulunmaktad�r. Joker kullanmak i�in" << yellow << " \"Joker\"" << green << " yazman�z yeterlidir.\n";
	cout << green << "Dinler en y�ksek inan�� oran�na g�re al�nm��t�r." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her turda puan�n�z 100 den ba�lar her soru 5 puan azalt�r.8 Soru sonra kazan�lan puan 25'e sabitlenir tur \nbitince tekrar 100'den ba�lar. Joker 25 puan azalt�r." << endl;
	cout << yellow << "S�re:" << endl << green << "Oyun s�resi 5 dakikad�r. Ne kadar s�renin kald���na bakmak i�in komut yazmadan �nce s�reye bakman�z yeterlidir." << endl;
	cout << blue << "---------------------------------------------------------" << endl;
	cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << yellow << endl;
	while (true) {
		getline(cin, komut);
		komut = kelimeDuzelt(komut);
		if (komut == "Liste") {
			dosyaoku();
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << white << endl;
		}
		else if (komut == "Ulkeler" || komut == "Lkeler") {
			ulkeyaz();
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << yellow << endl;
		}
		else if (komut == "Basla" || komut == "Bala" || komut == "Start") {
			cout << yellow << "Oyun Ba�l�yor" << endl;
			cout << blue << "---------------------------------------------------------" << endl;
			oyun = 1;
			start_time = clock(); // Ba�lang�� zaman�n� al
			break;
		}
		else if (komut == "Bitir") {
			cout << yellow << "Daha oyun ba�lamad� nereye." << endl;
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
		else {
			cout << red << "Ge�ersiz Komut" << endl;
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayn� �lke gelirse tekrar se�
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j","k","l");
		oncekiRandomSayi = randomSayi; // �nceki se�ilen �lkeyi g�ncelle
		puan = 100;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan S�re: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				cout << yellow << "1" << green << " Dini ile ilgili soru" << endl;
				cout << yellow << "2" << green << " Bulundu�u k�ta ile ilgili soru" << endl;
				cout << yellow << "3" << green << " Y�netim bi�imi ile ilgili soru" << endl;
				cout << yellow << "4" << green << " Y�z�l��m� ile ilgili soru" << endl;
				cout << yellow << "5" << green << " N�fusu ile ilgili soru" << endl;
				cout << yellow << "6" << green << " GSYF(Ekonomi) ile ilgili soru" << endl;
				cout << yellow << "7" << green << " Pas  " << yellow << "8" << green << " Joker  " << yellow << "9" << green << " Liste  " << yellow << "10" << green << " �lkeler  " << yellow << "11" << green << " Bitir" << endl;
				cout << red << "L�tfen bir soru, komut veya tahmin giriniz: " << yellow;
				getline(cin, komut);
				sayi = komut;
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi,secilenulke.enlem,secilenulke.boylam);
						break; // E�le�me bulundu, d�ng�den ��k
					}
				}
			}
			else
				bitis = true;
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time > sure) {
				cout << red << "S�re bitti!" << endl;
				bitis = true;
			}
			if (sayi == "11" || bitis) {
				cout << red << "Do�ru �lke: " << yellow << kalici.isim << endl;
				cout << red << "�lkenin �ngilizce �smi: " << yellow << kalici.enisim << endl;
				cout << red << "�lkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "�lkenin bulundu�u K�ta: " << yellow << kalici.kita << endl;
				cout << red << "�lkenin Yonetim Bi�imi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "�lkenin Y�z�l��m�: " << yellow << kalici.yuzolcum << endl;
				cout << red << "�lkenin N�fusu: " << yellow << kalici.nufus << endl;
				cout << red << "�lkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << red << "Oyun Bitti." << yellow << " Yapan Kerem Kuyucu" << endl;
				cout << red << "Do�ru �lke Say�n�z: " << yellow << winstreak << endl;
				cout << red << "Puan�n�z: " << yellow << toplampuan << endl;
				cout << green << "S�ralamaya ad�n�z� yazd�rmak istermisiniz: (Evet/Hay�r) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "�sminizi nas�l yazmak istersiniz? (T�rk�e karakter Kullanmay�n�z.) " << yellow;
					getline(cin, komut);
					dosyayaz(komut,toplampuan,winstreak,"ulke");
				}
				else
					dosyayaz("Yok", toplampuan, winstreak,"ulke");
				oyun = 0;
				break;
			}
			if (sayi == "1") {
				string a = "Islam";
				string b = "Hristiyanl�k";
				string c = "Budizm";
				string d = "Yahudilik";
				string e = "Hinduizm";
				string f = "Dinsiz";
				string aa = "dini ";
				cout << yellow << "1" << green << " �lkenin " << aa << a << " m� ?" << endl;
				cout << yellow << "2" << green << " �lkenin " << aa << b << " m� ?" << endl;
				cout << yellow << "3" << green << " �lkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " �lkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " �lkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " �lkenin " << aa << f << " mi ?" << endl;
				cout << red << "L�tfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "�lkenin " << aa << a<< endl;
					else
						cout << red << "�lkenin " << aa << a << " de�il" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "�lkenin " << aa << b<< endl;
					else
						cout << red << "�lkenin " << aa << b << " de�il" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "�lkenin " << aa << c << endl;
					else
						cout << red << "�lkenin " << aa << c << " de�il" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "�lkenin " << aa << d << endl;
					else
						cout << red << "�lkenin " << aa << d << " de�il" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "�lkenin " << aa << e << endl;
					else
						cout << red << "�lkenin " << aa << e << " de�il" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "�lkenin " << aa << f << endl;
					else
						cout << red << "�lkenin " << aa << f << " de�il" << endl;
				}
				else
					cout << red << "Hata!" << endl;
				puan -= 5;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
			}
			if (sayi == "2") {
				string a = "Avrupa";
				string b = "Asya";
				string c = "Afrika";
				string d = "Kuzey Amerika";
				string e = "Guney Amerika";
				string f = "Avusturalya";
				string aa = "k�tas� ";
				cout << yellow << "1" << green << " �lkenin " << aa << a << " m� ?" << endl;
				cout << yellow << "2" << green << " �lkenin " << aa << b << " m� ?" << endl;
				cout << yellow << "3" << green << " �lkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " �lkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " �lkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " �lkenin " << aa << f << " mi ?" << endl;
				cout << red << "L�tfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "�lkenin " << aa << a << endl;
					else
						cout << red << "�lkenin " << aa << a << " de�il" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "�lkenin " << aa << b << endl;
					else
						cout << red << "�lkenin " << aa << b << " de�il" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "�lkenin " << aa << c << endl;
					else
						cout << red << "�lkenin " << aa << c << " de�il" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "�lkenin " << aa << d << endl;
					else
						cout << red << "�lkenin " << aa << d << " de�il" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "�lkenin " << aa << e << endl;
					else
						cout << red << "�lkenin " << aa << e << " de�il" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "�lkenin " << aa << f << endl;
					else
						cout << red << "�lkenin " << aa << f << " de�il" << endl;
				}
				else
					cout << red << "Hata!" << endl;
				puan -= 5;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
			}
			if (sayi == "3") {
				string a = "Federal cumhuriyet";
				string b = "Tek parti sosyalist cumhuriyet";
				string c = "Parlamentar monarsi";
				string d = "Federal parlamentar cumhuriyet";
				string e = "Yari baskanlik cumhruriyeti";
				string f = "Cumhuriyet";
				string g = "Feoderal cumhuriyet";
				string h = "Mutlak monarsi";
				string j = "�zerk";
				string k = "Parlamentar cumhuriyet";
				string l = "Parlementar monarsi";
				string m = "Yar� ba�kanl�k cumhuriyeti";
				string n = "Sosyalist cumhuriyet";
				string o = "Ba�kanl�k cumhuriyeti";
				string aa = "y�netim bi�imi ";
				cout << yellow << "1" << green << " �lkenin " << aa << a << " m� ?" << endl;
				cout << yellow << "2" << green << " �lkenin " << aa << b << " m� ?" << endl;
				cout << yellow << "3" << green << " �lkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " �lkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " �lkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " �lkenin " << aa << f << " mi ?" << endl;
				cout << yellow << "7" << green << " �lkenin " << aa << g << " m� ?" << endl;
				cout << yellow << "8" << green << " �lkenin " << aa << h << " m� ?" << endl;
				cout << yellow << "9" << green << " �lkenin " << aa << j << " mi ?" << endl;
				cout << yellow << "10" << green << " �lkenin " << aa << k << " mi ?" << endl;
				cout << yellow << "11" << green << " �lkenin " << aa << l << " mi ?" << endl;
				cout << yellow << "12" << green << " �lkenin " << aa << m << " mi ?" << endl;
				cout << yellow << "13" << green << " �lkenin " << aa << n << " mi ?" << endl;
				cout << yellow << "14" << green << " �lkenin " << aa << o << " mi ?" << endl;
				cout << red << "L�tfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "�lkenin " << aa << a << endl;
					else
						cout << red << "�lkenin " << aa << a << " de�il" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "�lkenin " << aa << b << endl;
					else
						cout << red << "�lkenin " << aa << b << " de�il" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "�lkenin " << aa << c << endl;
					else
						cout << red << "�lkenin " << aa << c << " de�il" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "�lkenin " << aa << d << endl;
					else
						cout << red << "�lkenin " << aa << d << " de�il" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "�lkenin " << aa << e << endl;
					else
						cout << red << "�lkenin " << aa << e << " de�il" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "�lkenin " << aa << f << endl;
					else
						cout << red << "�lkenin " << aa << f << " de�il" << endl;
				}
				else if (sayi == "7") {
					if (kalici.din == g)
						cout << green << "�lkenin " << aa << g << endl;
					else
						cout << red << "�lkenin " << aa << g << " de�il" << endl;
				}
				else if (sayi == "8") {
					if (kalici.din == h)
						cout << green << "�lkenin " << aa << h << endl;
					else
						cout << red << "�lkenin " << aa << h << " de�il" << endl;
				}
				else if (sayi == "9") {
					if (kalici.din == j)
						cout << green << "�lkenin " << aa << j << endl;
					else
						cout << red << "�lkenin " << aa << j << " de�il" << endl;
				}
				else if (sayi == "10") {
					if (kalici.din == k)
						cout << green << "�lkenin " << aa << k << endl;
					else
						cout << red << "�lkenin " << aa << k << " de�il" << endl;
				}
				else if (sayi == "11") {
					if (kalici.din == l)
						cout << green << "�lkenin " << aa << l << endl;
					else
						cout << red << "�lkenin " << aa << l << " de�il" << endl;
				}
				else if (sayi == "12") {
					if (kalici.din == m)
						cout << green << "�lkenin " << aa << m << endl;
					else
						cout << red << "�lkenin " << aa << m << " de�il" << endl;
				}
				else if (sayi == "13") {
					if (kalici.din == n)
						cout << green << "�lkenin " << aa << f << endl;
					else
						cout << red << "�lkenin " << aa << f << " de�il" << endl;
				}
				else if (sayi == "14") {
					if (kalici.din == o)
						cout << green << "�lkenin " << aa << o << endl;
					else
						cout << red << "�lkenin " << aa << o << " de�il" << endl;
				}
				else
					cout << red << "Hata!" << endl;
				puan -= 5;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
			}
			if (sayi == "4") {
				cout << red << "Y�z�l��m tahminini girer iken aralara nokta koymay�n." << endl;
				cout << red << "En az y�z�l��m 316 km�\nEn fazla y�z�l��m 17,125,191 km�" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.yuzolcum))
					cout << green << "�lkenin y�z�l��m� daha k���k" << endl;
				if (komut < temizle(kalici.yuzolcum))
					cout << green << "�lkenin y�z�l��m� daha b�y�k" << endl;
				if (komut == temizle(kalici.yuzolcum))
					cout << yellow << "�lkenin y�z�l��m� e�it" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (sayi == "5") {
				cout << red << "N�fus tahminini girer iken milyon cinsinden s�f�r kullanmadan yaz�n. K�s�rat i�in nokta kullanabilirsiniz." << endl;
				cout << red << "En az n�fus 0.5 milyon\nEn fazla n�fus 1410 milyon" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.nufus))
					cout << green << "�lkenin n�fusu daha k���k" << endl;
				if (komut < temizle(kalici.nufus))
					cout << green << "�lkenin n�fusu daha b�y�k" << endl;
				if (komut == temizle(kalici.nufus))
					cout << yellow << "�lkenin n�fusu e�it" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (sayi == "6") {
				cout << red << "Ekonomi tahminini girer iken milyar cinsinden s�f�r kullanmadan yaz�n. K�s�rat i�in nokta kullanabilirsiniz." << endl;
				cout << red << "En az ekonomi 8 milyar \nEn fazla ekonomi 220000 milyar" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.ekonomi))
					cout << green << "�lkenin ekonomisi daha k���k" << endl;
				if (komut < temizle(kalici.ekonomi))
					cout << green << "�lkenin ekonomisi daha b�y�k" << endl;
				if (komut == temizle(kalici.ekonomi))
					cout << yellow << "�lkenin ekonomisi e�it" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (kalici.ks(gecici.isim)) {
				cout << red << "�lkenin �ngilizce �smi: " << yellow << kalici.enisim << endl;
				cout << red << "�lkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "�lkenin bulundu�u K�ta: " << yellow << kalici.kita << endl;
				cout << red << "�lkenin Yonetim Bi�imi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "�lkenin Y�z�l��m�: " << yellow << kalici.yuzolcum << endl;
				cout << red << "�lkenin N�fusu: " << yellow << kalici.nufus << endl;
				cout << red << "�lkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << green << "Do�ru �lkeyi buldun Tebrikler!! Yeni bir �lke se�ildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				if (puan < 25)
					toplampuan += 25;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (gecici.ks(komut)) {
				yanl�s--;
				cout << red << "Yanl�� tahmin. Yanl�� hakk�n 1 azald�. Kalan hakk�n: " << yellow << yanl�s << endl;
				if (yanl�s < 0)
					bitis = true;
			}
			if (sayi == "7") {
				cout << red << "Ge�ilen �lke: " << yellow << kalici.isim << endl;
				cout << red << "�lkenin �ngilizce �smi: " << yellow << kalici.enisim << endl;
				cout << red << "�lkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "�lkenin bulundu�u K�ta: " << yellow << kalici.kita << endl;
				cout << red << "�lkenin Yonetim Bi�imi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "�lkenin Y�z�l��m�: " << yellow << kalici.yuzolcum << endl;
				cout << red << "�lkenin N�fusu: " << yellow << kalici.nufus << endl;
				cout << red << "�lkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << green << "Yeni bir �lke se�ildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				break;
			}
			if (sayi == "8") {
				if (joker > 0) {
					joker -= 1;
					cout << red << "Ulkenin Baskenti: " << yellow << kalici.baskent << endl;
					cout << yellow << joker << red << " joker hakk�n�z kald�." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
					puan -= 25;
				}
				else {
					cout << red << "Joker Hakk�n�z Bitmi�tir." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
				}
			}
			if (sayi == "9") { dosyaoku(); }

			if (sayi == "10") { ulkeyaz(); }

			if ( !(gecici.ks(komut)) &&
				komut != "1" && komut != "2" && komut != "3" && komut != "4" && komut != "5" && komut != "6" && 
				komut != "7" && komut != "8" && komut != "9" && komut != "10" && komut != "11") {
				cout << red << "B�yle bir komut bulunamad�. " << yellow << "\"�lkeler\"" << red << " yazarak �lke listesine bakabilirsiniz." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
		}
	}
}
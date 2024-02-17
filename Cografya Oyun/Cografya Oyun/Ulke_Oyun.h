using namespace std;

void Ulke() {
	string komut, sayi;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300, yanlýs = 5;;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	cout << yellow << "Ülke Bilme Oyunu\n";
	cout << green << "Ülke bilme oyununa hoþ geldiniz. \nAmacýnýz, 50 ülkeden rastgele seçilen bir ülkeyi tahmin etmektir. \nSorduðunuz sorulara göre ülkeyi tahmin etmeniz gerekmektedir. \n5 yanlýþ hakkýnýz bulunmaktadýr.";
	cout << green << "Önceki Sýralamalara bakmak için " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Joker Sistemi:" << endl << green << "3 tane baþkenti öðrenme joker hakkýnýz bulunmaktadýr. Joker kullanmak için" << yellow << " \"Joker\"" << green << " yazmanýz yeterlidir.\n";
	cout << green << "Dinler en yüksek inanýþ oranýna göre alýnmýþtýr." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her turda puanýnýz 100 den baþlar her soru 5 puan azaltýr.8 Soru sonra kazanýlan puan 25'e sabitlenir tur \nbitince tekrar 100'den baþlar. Joker 25 puan azaltýr." << endl;
	cout << yellow << "Süre:" << endl << green << "Oyun süresi 5 dakikadýr. Ne kadar sürenin kaldýðýna bakmak için komut yazmadan önce süreye bakmanýz yeterlidir." << endl;
	cout << blue << "---------------------------------------------------------" << endl;
	cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << yellow << endl;
	while (true) {
		getline(cin, komut);
		komut = kelimeDuzelt(komut);
		if (komut == "Liste") {
			dosyaoku();
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << white << endl;
		}
		else if (komut == "Ulkeler" || komut == "Lkeler") {
			ulkeyaz();
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << yellow << endl;
		}
		else if (komut == "Basla" || komut == "Bala" || komut == "Start") {
			cout << yellow << "Oyun Baþlýyor" << endl;
			cout << blue << "---------------------------------------------------------" << endl;
			oyun = 1;
			start_time = clock(); // Baþlangýç zamanýný al
			break;
		}
		else if (komut == "Bitir") {
			cout << yellow << "Daha oyun baþlamadý nereye." << endl;
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
		else {
			cout << red << "Geçersiz Komut" << endl;
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayný ülke gelirse tekrar seç
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j","k","l");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 100;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan Süre: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				cout << yellow << "1" << green << " Dini ile ilgili soru" << endl;
				cout << yellow << "2" << green << " Bulunduðu kýta ile ilgili soru" << endl;
				cout << yellow << "3" << green << " Yönetim biçimi ile ilgili soru" << endl;
				cout << yellow << "4" << green << " Yüzölçümü ile ilgili soru" << endl;
				cout << yellow << "5" << green << " Nüfusu ile ilgili soru" << endl;
				cout << yellow << "6" << green << " GSYF(Ekonomi) ile ilgili soru" << endl;
				cout << yellow << "7" << green << " Pas  " << yellow << "8" << green << " Joker  " << yellow << "9" << green << " Liste  " << yellow << "10" << green << " Ülkeler  " << yellow << "11" << green << " Bitir" << endl;
				cout << red << "Lütfen bir soru, komut veya tahmin giriniz: " << yellow;
				getline(cin, komut);
				sayi = komut;
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi,secilenulke.enlem,secilenulke.boylam);
						break; // Eþleþme bulundu, döngüden çýk
					}
				}
			}
			else
				bitis = true;
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time > sure) {
				cout << red << "Süre bitti!" << endl;
				bitis = true;
			}
			if (sayi == "11" || bitis) {
				cout << red << "Doðru ülke: " << yellow << kalici.isim << endl;
				cout << red << "Ülkenin Ýngilizce Ýsmi: " << yellow << kalici.enisim << endl;
				cout << red << "Ülkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "Ülkenin bulunduðu Kýta: " << yellow << kalici.kita << endl;
				cout << red << "Ülkenin Yonetim Biçimi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "Ülkenin Yüzölçümü: " << yellow << kalici.yuzolcum << endl;
				cout << red << "Ülkenin Nüfusu: " << yellow << kalici.nufus << endl;
				cout << red << "Ülkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << red << "Oyun Bitti." << yellow << " Yapan Kerem Kuyucu" << endl;
				cout << red << "Doðru Ülke Sayýnýz: " << yellow << winstreak << endl;
				cout << red << "Puanýnýz: " << yellow << toplampuan << endl;
				cout << green << "Sýralamaya adýnýzý yazdýrmak istermisiniz: (Evet/Hayýr) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "Ýsminizi nasýl yazmak istersiniz? (Türkçe karakter Kullanmayýnýz.) " << yellow;
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
				string b = "Hristiyanlýk";
				string c = "Budizm";
				string d = "Yahudilik";
				string e = "Hinduizm";
				string f = "Dinsiz";
				string aa = "dini ";
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mý ?" << endl;
				cout << yellow << "2" << green << " Ülkenin " << aa << b << " mý ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "Ülkenin " << aa << a<< endl;
					else
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "Ülkenin " << aa << b<< endl;
					else
						cout << red << "Ülkenin " << aa << b << " deðil" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "Ülkenin " << aa << c << endl;
					else
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "Ülkenin " << aa << d << endl;
					else
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "Ülkenin " << aa << e << endl;
					else
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "Ülkenin " << aa << f << endl;
					else
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
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
				string aa = "kýtasý ";
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mý ?" << endl;
				cout << yellow << "2" << green << " Ülkenin " << aa << b << " mý ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "Ülkenin " << aa << a << endl;
					else
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "Ülkenin " << aa << b << endl;
					else
						cout << red << "Ülkenin " << aa << b << " deðil" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "Ülkenin " << aa << c << endl;
					else
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "Ülkenin " << aa << d << endl;
					else
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "Ülkenin " << aa << e << endl;
					else
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "Ülkenin " << aa << f << endl;
					else
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
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
				string j = "Özerk";
				string k = "Parlamentar cumhuriyet";
				string l = "Parlementar monarsi";
				string m = "Yarý baþkanlýk cumhuriyeti";
				string n = "Sosyalist cumhuriyet";
				string o = "Baþkanlýk cumhuriyeti";
				string aa = "yönetim biçimi ";
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mý ?" << endl;
				cout << yellow << "2" << green << " Ülkenin " << aa << b << " mý ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << yellow << "7" << green << " Ülkenin " << aa << g << " mý ?" << endl;
				cout << yellow << "8" << green << " Ülkenin " << aa << h << " mý ?" << endl;
				cout << yellow << "9" << green << " Ülkenin " << aa << j << " mi ?" << endl;
				cout << yellow << "10" << green << " Ülkenin " << aa << k << " mi ?" << endl;
				cout << yellow << "11" << green << " Ülkenin " << aa << l << " mi ?" << endl;
				cout << yellow << "12" << green << " Ülkenin " << aa << m << " mi ?" << endl;
				cout << yellow << "13" << green << " Ülkenin " << aa << n << " mi ?" << endl;
				cout << yellow << "14" << green << " Ülkenin " << aa << o << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a)
						cout << green << "Ülkenin " << aa << a << endl;
					else
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
				}
				else if (sayi == "2") {
					if (kalici.din == b)
						cout << green << "Ülkenin " << aa << b << endl;
					else
						cout << red << "Ülkenin " << aa << b << " deðil" << endl;
				}
				else if (sayi == "3") {
					if (kalici.din == c)
						cout << green << "Ülkenin " << aa << c << endl;
					else
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
				}
				else if (sayi == "4") {
					if (kalici.din == d)
						cout << green << "Ülkenin " << aa << d << endl;
					else
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
				}
				else if (sayi == "5") {
					if (kalici.din == e)
						cout << green << "Ülkenin " << aa << e << endl;
					else
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
				}
				else if (sayi == "6") {
					if (kalici.din == f)
						cout << green << "Ülkenin " << aa << f << endl;
					else
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
				}
				else if (sayi == "7") {
					if (kalici.din == g)
						cout << green << "Ülkenin " << aa << g << endl;
					else
						cout << red << "Ülkenin " << aa << g << " deðil" << endl;
				}
				else if (sayi == "8") {
					if (kalici.din == h)
						cout << green << "Ülkenin " << aa << h << endl;
					else
						cout << red << "Ülkenin " << aa << h << " deðil" << endl;
				}
				else if (sayi == "9") {
					if (kalici.din == j)
						cout << green << "Ülkenin " << aa << j << endl;
					else
						cout << red << "Ülkenin " << aa << j << " deðil" << endl;
				}
				else if (sayi == "10") {
					if (kalici.din == k)
						cout << green << "Ülkenin " << aa << k << endl;
					else
						cout << red << "Ülkenin " << aa << k << " deðil" << endl;
				}
				else if (sayi == "11") {
					if (kalici.din == l)
						cout << green << "Ülkenin " << aa << l << endl;
					else
						cout << red << "Ülkenin " << aa << l << " deðil" << endl;
				}
				else if (sayi == "12") {
					if (kalici.din == m)
						cout << green << "Ülkenin " << aa << m << endl;
					else
						cout << red << "Ülkenin " << aa << m << " deðil" << endl;
				}
				else if (sayi == "13") {
					if (kalici.din == n)
						cout << green << "Ülkenin " << aa << f << endl;
					else
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
				}
				else if (sayi == "14") {
					if (kalici.din == o)
						cout << green << "Ülkenin " << aa << o << endl;
					else
						cout << red << "Ülkenin " << aa << o << " deðil" << endl;
				}
				else
					cout << red << "Hata!" << endl;
				puan -= 5;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
			}
			if (sayi == "4") {
				cout << red << "Yüzölçüm tahminini girer iken aralara nokta koymayýn." << endl;
				cout << red << "En az yüzölçüm 316 km²\nEn fazla yüzölçüm 17,125,191 km²" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.yuzolcum))
					cout << green << "Ülkenin yüzölçümü daha küçük" << endl;
				if (komut < temizle(kalici.yuzolcum))
					cout << green << "Ülkenin yüzölçümü daha büyük" << endl;
				if (komut == temizle(kalici.yuzolcum))
					cout << yellow << "Ülkenin yüzölçümü eþit" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (sayi == "5") {
				cout << red << "Nüfus tahminini girer iken milyon cinsinden sýfýr kullanmadan yazýn. Küsürat için nokta kullanabilirsiniz." << endl;
				cout << red << "En az nüfus 0.5 milyon\nEn fazla nüfus 1410 milyon" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.nufus))
					cout << green << "Ülkenin nüfusu daha küçük" << endl;
				if (komut < temizle(kalici.nufus))
					cout << green << "Ülkenin nüfusu daha büyük" << endl;
				if (komut == temizle(kalici.nufus))
					cout << yellow << "Ülkenin nüfusu eþit" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (sayi == "6") {
				cout << red << "Ekonomi tahminini girer iken milyar cinsinden sýfýr kullanmadan yazýn. Küsürat için nokta kullanabilirsiniz." << endl;
				cout << red << "En az ekonomi 8 milyar \nEn fazla ekonomi 220000 milyar" << endl;
				getline(cin, komut);
				komut = temizle(komut);
				if (komut > temizle(kalici.ekonomi))
					cout << green << "Ülkenin ekonomisi daha küçük" << endl;
				if (komut < temizle(kalici.ekonomi))
					cout << green << "Ülkenin ekonomisi daha büyük" << endl;
				if (komut == temizle(kalici.ekonomi))
					cout << yellow << "Ülkenin ekonomisi eþit" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				sayi = "";
				puan -= 5;
			}
			if (kalici.ks(gecici.isim)) {
				cout << red << "Ülkenin Ýngilizce Ýsmi: " << yellow << kalici.enisim << endl;
				cout << red << "Ülkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "Ülkenin bulunduðu Kýta: " << yellow << kalici.kita << endl;
				cout << red << "Ülkenin Yonetim Biçimi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "Ülkenin Yüzölçümü: " << yellow << kalici.yuzolcum << endl;
				cout << red << "Ülkenin Nüfusu: " << yellow << kalici.nufus << endl;
				cout << red << "Ülkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << green << "Doðru ülkeyi buldun Tebrikler!! Yeni bir ülke seçildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				if (puan < 25)
					toplampuan += 25;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (gecici.ks(komut)) {
				yanlýs--;
				cout << red << "Yanlýþ tahmin. Yanlýþ hakkýn 1 azaldý. Kalan hakkýn: " << yellow << yanlýs << endl;
				if (yanlýs < 0)
					bitis = true;
			}
			if (sayi == "7") {
				cout << red << "Geçilen ülke: " << yellow << kalici.isim << endl;
				cout << red << "Ülkenin Ýngilizce Ýsmi: " << yellow << kalici.enisim << endl;
				cout << red << "Ülkenin Dini: " << yellow << kalici.din << endl;
				cout << red << "Ülkenin bulunduðu Kýta: " << yellow << kalici.kita << endl;
				cout << red << "Ülkenin Yonetim Biçimi: " << yellow << kalici.yonetimbicimi << endl;
				cout << red << "Ülkenin Yüzölçümü: " << yellow << kalici.yuzolcum << endl;
				cout << red << "Ülkenin Nüfusu: " << yellow << kalici.nufus << endl;
				cout << red << "Ülkenin Ekonomisi: " << yellow << kalici.ekonomi << endl;
				cout << green << "Yeni bir ülke seçildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				break;
			}
			if (sayi == "8") {
				if (joker > 0) {
					joker -= 1;
					cout << red << "Ulkenin Baskenti: " << yellow << kalici.baskent << endl;
					cout << yellow << joker << red << " joker hakkýnýz kaldý." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
					puan -= 25;
				}
				else {
					cout << red << "Joker Hakkýnýz Bitmiþtir." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
				}
			}
			if (sayi == "9") { dosyaoku(); }

			if (sayi == "10") { ulkeyaz(); }

			if ( !(gecici.ks(komut)) &&
				komut != "1" && komut != "2" && komut != "3" && komut != "4" && komut != "5" && komut != "6" && 
				komut != "7" && komut != "8" && komut != "9" && komut != "10" && komut != "11") {
				cout << red << "Böyle bir komut bulunamadý. " << yellow << "\"Ülkeler\"" << red << " yazarak ülke listesine bakabilirsiniz." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
		}
	}
}
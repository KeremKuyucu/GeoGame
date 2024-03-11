void Ulke() {
	Music yasasinirkimiz; if (!yasasinirkimiz.openFromFile("dosyalar/sesler/yasasinirkimiz.ogg")) {};
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
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
			yenitur.play();
			cout << yellow << "Oyun Baþlýyor" << endl;
			cout << blue << "---------------------------------------------------------" << endl;
			oyun = 1;
			start_time = clock(); // Baþlangýç zamanýný al
			break;
		}
		else if (komut == "Bitir") {
			yanlis.play();
			cout << yellow << "Daha oyun baþlamadý nereye." << endl;
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
		else {
			yanlis.play();
			cout << red << "Geçersiz Komut" << endl;
			cout << red << "Baþlamak için " << yellow << "\"Baþla\"" << red << " ülke isimlerini öðrenmek için " << yellow << "\"Ülkeler\"" << red << " oyunu bitirmek için " << yellow << "\"Bitir\"" << red << " yazýnýz: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayný ülke gelirse tekrar seç
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.bayrak,seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 100;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << green << "Soru Sorarak ülkenin doðru bilgisini bulursanýz burdaki bilgiler güncellenir. \n(Sayýsal bilgiler en yakýn tahminleri gösterir.)";
				cout << red << "  Kalan Süre: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
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
						gecici = Ulkeler(secilenulke.bayrak, secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi,secilenulke.enlem,secilenulke.boylam);
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
				cout << blue << "---------------------------------------------------------" << endl;
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mý ?" << endl;
				cout << yellow << "2" << green << " Ülkenin " << aa << b << " mý ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a) {
						cout << green << "Ülkenin " << aa << a << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "2") {
					if (kalici.din == b) {
						cout << green << "Ülkenin " << aa << b << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << b << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "3") {
					if (kalici.din == c) {
						cout << green << "Ülkenin " << aa << c << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "4") {
					if (kalici.din == d) {
						cout << green << "Ülkenin " << aa << d << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "5") {
					if (kalici.din == e) {
						cout << green << "Ülkenin " << aa << e << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "6") {
					if (kalici.din == f) {
						cout << green << "Ülkenin " << aa << f << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
						yanlis.play();
					}
				}
				else
					cout << red << "Hata!" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (sayi == "2") {
				string a = "Avrupa";
				string b = "Asya";
				string c = "Afrika";
				string d = "Kuzey Amerika";
				string e = "Guney Amerika";
				string f = "Avusturalya";
				string aa = "kýtasý ";
				cout << blue << "---------------------------------------------------------" << endl;
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mý ?" << endl;
				cout << yellow << "2" << green << " Ülkenin " << aa << b << " mý ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a) {
						cout << green << "Ülkenin " << aa << a << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "2") {
					if (kalici.din == b) {
						cout << green << "Ülkenin " << aa << b << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << b << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "3") {
					if (kalici.din == c) {
						cout << green << "Ülkenin " << aa << c << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "4") {
					if (kalici.din == d) {
						cout << green << "Ülkenin " << aa << d << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "5") {
					if (kalici.din == e) {
						cout << green << "Ülkenin " << aa << e << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "6") {
					if (kalici.din == f) {
						cout << green << "Ülkenin " << aa << f << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
						yanlis.play();
					}
				}
				else
					cout << red << "Hata!" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (sayi == "3") {
				string a = "Federal cumhuriyet";
				string c = "Parlamentar monarsi";
				string d = "Federal parlamentar cumhuriyet";
				string e = "Yari baskanlik cumhruriyeti";
				string f = "Cumhuriyet";
				string h = "Mutlak monarsi";
				string j = "Özerk";
				string k = "Parlamentar cumhuriyet";
				string l = "Parlementar monarsi";
				string n = "Sosyalist cumhuriyet";
				string o = "Baþkanlýk cumhuriyeti";
				string aa = "yönetim biçimi ";
				cout << blue << "---------------------------------------------------------" << endl;
				cout << yellow << "1" << green << " Ülkenin " << aa << a << " mi ?" << endl;
				cout << yellow << "3" << green << " Ülkenin " << aa << c << " mi ?" << endl;
				cout << yellow << "4" << green << " Ülkenin " << aa << d << " mi ?" << endl;
				cout << yellow << "5" << green << " Ülkenin " << aa << e << " mi ?" << endl;
				cout << yellow << "6" << green << " Ülkenin " << aa << f << " mi ?" << endl;
				cout << yellow << "7" << green << " Ülkenin " << aa << h << " mý ?" << endl;
				cout << yellow << "8" << green << " Ülkenin " << aa << j << " mi ?" << endl;
				cout << yellow << "9" << green << " Ülkenin " << aa << k << " mi ?" << endl;
				cout << yellow << "10" << green << " Ülkenin " << aa << l << " mi ?" << endl;
				cout << yellow << "11" << green << " Ülkenin " << aa << n << " mi ?" << endl;
				cout << yellow << "12" << green << " Ülkenin " << aa << o << " mi ?" << endl;
				cout << red << "Lütfen bir soru sayisi giriniz: " << yellow;
				getline(cin, sayi);
				if (sayi == "1") {
					if (kalici.din == a) {
						cout << green << "Ülkenin " << aa << a << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << a << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "2") {
					if (kalici.din == c) {
						cout << green << "Ülkenin " << aa << c << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << c << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "3") {
					if (kalici.din == d) {
						cout << green << "Ülkenin " << aa << d << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << d << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "4") {
					if (kalici.din == e) {
						cout << green << "Ülkenin " << aa << e << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << e << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "5") {
					if (kalici.din == f) {
						cout << green << "Ülkenin " << aa << f << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << f << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "6") {
					if (kalici.din == h) {
						cout << green << "Ülkenin " << aa << h << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << h << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "7") {
					if (kalici.din == j) {
						cout << green << "Ülkenin " << aa << j << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << j << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "8") {
					if (kalici.din == k) {
						cout << green << "Ülkenin " << aa << k << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << k << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "9") {
					if (kalici.din == l) {
						cout << green << "Ülkenin " << aa << l << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << l << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "10") {
					if (kalici.din == n) {
						cout << green << "Ülkenin " << aa << n << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << n << " deðil" << endl;
						yanlis.play();
					}
				}
				else if (sayi == "11") {
					if (kalici.din == o) {
						cout << green << "Ülkenin " << aa << o << endl;
						dogru.play();
					}
					else
					{
						cout << red << "Ülkenin " << aa << o << " deðil" << endl;
						yanlis.play();
					}
				}
				else
					cout << red << "Hata!" << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (sayi == "4") {
				cout << blue << "---------------------------------------------------------" << endl;
				cout << green << "Yüzölçüm tahminini girer iken aralara nokta koymayýn." << endl;
				cout << green << "En az yüzölçüm 316 km²\nEn fazla yüzölçüm 17,125,191 km²" << endl << yellow;
				getline(cin, komut);

				try {
					double komutt = stod(temizle(komut));
					cout << red << "Ülkenin Yüzölçümü: " << yellow << komutt << (komutt > stod(temizle(kalici.yuzolcum)) ? red : green) << (komutt > stod(temizle(kalici.yuzolcum)) ? "'dan Daha Düþük" : "'dan Daha Yüksek") << endl;
				}
				catch (const std::invalid_argument& e) {
					cerr << "Hata: Geçersiz argüman: " << e.what() << endl;
				}
				catch (const std::out_of_range& e) {
					cerr << "Hata: Aralýk dýþý deðer: " << e.what() << endl;
				}

				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (sayi == "5") {
				cout << blue << "---------------------------------------------------------" << endl;
				cout << green << "Nüfus tahminini girer iken milyon cinsinden sýfýr kullanmadan yazýn. Küsürat için nokta kullanabilirsiniz." << endl;
				cout << green << "En az nüfus 0.5 milyon\nEn fazla nüfus 1410 milyon" << endl << yellow;

				string komut;
				getline(cin, komut);

				try {
					double komutt = stod(temizle(komut));
					cout << red << "  Ülkenin Nüfusu: " << yellow << komutt;
					cout << (komutt > stod(temizle(kalici.nufus)) ? red : green);
					cout << (komutt > stod(temizle(kalici.nufus)) ? "'dan Daha Düþük" : "'dan Daha Yüksek") << endl;
				}
				catch (const std::invalid_argument& e) {
					cerr << "Hata: Geçersiz argüman: " << e.what() << endl;
				}
				catch (const std::out_of_range& e) {
					cerr << "Hata: Aralýk dýþý deðer: " << e.what() << endl;
				}

				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (sayi == "6") {
				cout << blue << "---------------------------------------------------------" << endl;
				cout << green << "Ekonomi tahminini girer iken milyar cinsinden sýfýr kullanmadan yazýn. Küsürat için nokta kullanabilirsiniz." << endl;
				cout << green << "En az ekonomi 8 milyar \nEn fazla ekonomi 22000 milyar" << endl << yellow;

				string komut;
				getline(cin, komut);

				try {
					double komutt = stod(temizle(komut));
					cout << red << "  Ülkenin Ekonomisi: " << yellow << komutt;
					cout << (komutt > stod(temizle(kalici.ekonomi)) ? red : green);
					cout << (komutt > stod(temizle(kalici.ekonomi)) ? "'dan Daha Düþük" : "'dan Daha Yüksek") << endl;
				}
				catch (const std::invalid_argument& e) {
					cerr << "Hata: Geçersiz argüman: " << e.what() << endl;
				}
				catch (const std::out_of_range& e) {
					cerr << "Hata: Aralýk dýþý deðer: " << e.what() << endl;
				}

				cout << blue << "---------------------------------------------------------" << endl;
				puan -= 5;
				sayi = "0";
			}
			if (kalici.ks(gecici.isim)) {
				dogru.play();
				cout << blue << "---------------------------------------------------------" << endl;
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
				yanlis.play();
				cout << red << "Yanlýþ tahmin. Yanlýþ hakkýn 1 azaldý. Kalan hakkýn: " << yellow << yanlýs << endl;
				if (yanlýs < 0)
					bitis = true;
			}
			if (sayi == "7") {
				yenitur.play();
				cout << blue << "---------------------------------------------------------" << endl;
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
				sayi = "0";
				break;
			}
			if (sayi == "8") {
				if (joker > 0) {
					joker -= 1;
					cout << blue << "---------------------------------------------------------" << endl;
					cout << red << "Ulkenin Baskenti: " << yellow << kalici.baskent << endl;
					cout << yellow << joker << red << " joker hakkýnýz kaldý." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
					puan -= 25;
				}
				else {
					cout << blue << "---------------------------------------------------------" << endl;
					cout << yellow << "Joker Hakkýnýz Bitmiþtir." << endl;
					cout << blue << "---------------------------------------------------------" << endl;
				}
			}
			if (sayi == "9") { dosyaoku(); }

			if (sayi == "10") { ulkeyaz(); }

			if ( !(gecici.ks(komut)) &&
				sayi != "0" && sayi != "1" && sayi != "2" && sayi != "3" && sayi != "4" && sayi != "5" && sayi != "6" &&
				sayi != "7" && sayi != "8" && sayi != "9" && sayi != "10" && sayi != "11" &&
				komut != "1" && komut != "2" && komut != "3" && komut != "4" && komut != "5" && komut != "6" &&
				komut != "7" && komut != "8" && komut != "9" && komut != "10" && komut != "11") {
				yanlis.play();
				cout << yellow << "Geçersiz komut. "<< endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
		}
	}
}
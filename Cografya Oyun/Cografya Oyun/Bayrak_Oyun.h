void Bayrak() {
	Music yasasinirkimiz; if (!yasasinirkimiz.openFromFile("dosyalar/sesler/yasasinirkimiz.ogg")) {};
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla �lgili A��klamalar�n Yazd��� Yer
	cout << yellow << "Bayrak Bilme Oyunu\n";
	cout << green << "Bayrak Bilme Oyununa ho� geldiniz. \nAmac�n�z, 50 �lkeden rastgele se�ilen bir �lkenin bayra��n� bilmek.\n";
	cout << green << "�nceki S�ralamalara bakmak i�in " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her turda puan�n�z 50 den ba�lar her yanl�� tahminde 10 azarl�r.3 Tahminden sonra kazan�lan puan 20'e sabitlenir tur \nbitince tekrar 50'den ba�lar." << endl;
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
			yenitur.play();
			start_time = clock(); // Ba�lang�� zaman�n� al
			break;
		}
		else if (komut == "Bitir") {
			yanlis.play();
			cout << yellow << "Daha oyun ba�lamad� nereye." << endl;
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
		else {
			yanlis.play();
			cout << red << "Ge�ersiz Komut" << endl;
			cout << red << "Ba�lamak i�in " << yellow << "\"Ba�la\"" << red << " �lke isimlerini ��renmek i�in " << yellow << "\"�lkeler\"" << red << " oyunu bitirmek i�in " << yellow << "\"Bitir\"" << red << " yaz�n�z: " << white << endl;
			cout << blue << "---------------------------------------------------------" << yellow << endl;
		}
	}
	while (oyun) {
		srand(static_cast<unsigned int>(time(0)));
		do { randomSayi = rand() % ulke.size(); } while (randomSayi == oncekiRandomSayi); // Ayn� �lke gelirse tekrar se�
		const Ulkeler& seciliUlke = ulke[randomSayi];
		Ulkeler kalici(seciliUlke.bayrak, seciliUlke.trisim, seciliUlke.isim, seciliUlke.enisim, seciliUlke.din, seciliUlke.kita, seciliUlke.yonetimbicimi, seciliUlke.baskent, seciliUlke.yuzolcum, seciliUlke.nufus, seciliUlke.ekonomi, seciliUlke.enlem, seciliUlke.boylam);
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m");
		oncekiRandomSayi = randomSayi; // �nceki se�ilen �lkeyi g�ncelle
		puan = 50;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan S�re: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				komut = resimgoster(kalici.bayrak);
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.bayrak, secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
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
				cout << red << "Do�ru �lke: " << kalici.isim << endl;
			}
			if (komut == "Bitir" || bitis) {
				cout << red << "Oyun Bitti." << yellow << " Yapan Kerem Kuyucu" << endl;
				cout << red << "Do�ru �lke Say�n�z: " << yellow << winstreak << endl;
				cout << red << "Puan�n�z: " << yellow << toplampuan << endl;
				cout << green << "S�ralamaya ad�n�z� yazd�rmak istermisiniz: (Evet/Hay�r) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "�sminizi nas�l yazmak istersiniz? (T�rk�e karakter Kullanmay�n�z.) " << yellow;
					getline(cin, komut);
					dosyayaz(komut, toplampuan, winstreak, "bayrak");
				}
				else
					dosyayaz("Yok", toplampuan, winstreak, "bayrak");
				oyun = 0;
				break;
			}
			if (komut == "Liste")
				dosyaoku();
			if (komut != "Ulkeler" && komut != "Lkeler" && komut != "Pas" && komut != "Bitir" &&
				komut != "Sure" && komut != "Sre" && komut != "Liste" && !gecici.ks(komut)) {
				yanlis.play();
				cout << red << "B�yle bir �lke bulunamad�. " << yellow << "\"�lkeler\"" << red << " yazarak �lke listesine bakabilirsiniz." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
			if (gecici.isim == kalici.isim || gecici.trisim == kalici.trisim || gecici.enisim == kalici.enisim) {
				dogru.play();
				cout << green << "Do�ru �lkeyi buldun Tebrikler!! Yeni bir �lke se�ildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			if (gecici.ks(komut)) {
				yanlis.play();
				cout << red << "Yanl�� Tahmin!" << endl;
				puan -= 10;
			}
			if (komut == "Ulkeler" || komut == "Lkeler")
				ulkeyaz();
			if (komut == "Pas") {
				yenitur.play();
				cout << red << "Ge�ilen �lke: " << yellow << kalici.isim << endl;
				cout << green << "Yeni bir �lke se�ildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				break;
			}
		}
	}
}
void Sehir() {
	Music yasasinirkimiz; if (!yasasinirkimiz.openFromFile("dosyalar/sesler/yasasinirkimiz.ogg")) {};
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false, bilgi=false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla �lgili A��klamalar�n Yazd��� Yer
	cout << red << trharita << endl;
	cout << yellow << "�ehir Bilme Oyunu" << endl;
	cout << green << "�ehir Bilme Oyununa ho� geldiniz. \nAmac�n�z, 81 ili teker teker yazmak." << endl;
	cout << green << "�nceki S�ralamalara bakmak i�in " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her �ehir 10 puan." << endl;
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
			yenitur.play();
			cout << blue << "---------------------------------------------------------" << endl;
			oyun = 1;
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
		while (true) {
			end_time = clock();
			bilgi = false;
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan S�re: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				bolgeyaz("Akdeniz B�lgesi", 1);
				bolgeyaz("Do�u Anadolu B�lgesi", 2);
				bolgeyaz("Ege B�lgesi", 3);
				bolgeyaz("G�neydo�u Anadolu B�lgesi", 4);
				bolgeyaz("�� Anadolu B�lgesi", 5);
				bolgeyaz("Karadeniz B�lgesi", 6);
				bolgeyaz("Marmara B�lgesi", 7);
				cout << red << "L�tfen bir tahmin giriniz: " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				for (int i = 0; i< sehir.size(); i++) {
					if (sehir[i].ks(komut)) {
						if (sehir[i].bilgi == true) {
							cout << yellow << "Bu �ehri zaten yazd�n.";
							yanlis.play();
						}
						else {
							sehir[i].bilgi = true;
							winstreak++;
							dogru.play();
							toplampuan += 10;
						}
						bilgi = true;
						break;
					}
				}
			}
			else
				bitis = true;
			if (bilgi == false)
				cout << yellow << "�ehir bulunamad�!" << endl;
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time > sure) {
				cout << red << "S�re bitti!" << endl;
				bitis = true;
			}
			for (int i = 0; i < sehir.size(); i++) {
				if (sehir[i].bilgi == false) {
					break;
				}
				else
					bitis = true;
			}
			if (komut == "Bitir" || bitis) {
				cout << red << "Oyun Bitti." << yellow << " Yapan Kerem Kuyucu" << endl;
				cout << red << "Do�ru �ehir Say�n�z: " << yellow << winstreak << endl;
				cout << red << "Puan�n�z: " << yellow << toplampuan << endl;
				cout << green << "S�ralamaya ad�n�z� yazd�rmak istermisiniz: (Evet/Hay�r) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "�sminizi nas�l yazmak istersiniz? (T�rk�e karakter Kullanmay�n�z.) " << yellow;
					getline(cin, komut);
					dosyayaz(komut, toplampuan, winstreak, "sehir");
				}
				else
					dosyayaz("Yok", toplampuan, winstreak, "sehir");
				oyun = 0;
				break;
			}
			if (komut == "Liste")
				dosyaoku();
		}
	}
}

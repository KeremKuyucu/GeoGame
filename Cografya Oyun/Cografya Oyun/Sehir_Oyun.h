void Sehir() {
	Music yasasinirkimiz; if (!yasasinirkimiz.openFromFile("dosyalar/sesler/yasasinirkimiz.ogg")) {};
	Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) {};
	Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) {};
	Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) {};
	string komut;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false, bilgi=false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	cout << red << trharita << endl;
	cout << yellow << "Þehir Bilme Oyunu" << endl;
	cout << green << "Þehir Bilme Oyununa hoþ geldiniz. \nAmacýnýz, 81 ili teker teker yazmak." << endl;
	cout << green << "Önceki Sýralamalara bakmak için " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her þehir 10 puan." << endl;
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
			yenitur.play();
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
		while (true) {
			end_time = clock();
			bilgi = false;
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan Süre: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				bolgeyaz("Akdeniz Bölgesi", 1);
				bolgeyaz("Doðu Anadolu Bölgesi", 2);
				bolgeyaz("Ege Bölgesi", 3);
				bolgeyaz("Güneydoðu Anadolu Bölgesi", 4);
				bolgeyaz("Ýç Anadolu Bölgesi", 5);
				bolgeyaz("Karadeniz Bölgesi", 6);
				bolgeyaz("Marmara Bölgesi", 7);
				cout << red << "Lütfen bir tahmin giriniz: " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				for (int i = 0; i< sehir.size(); i++) {
					if (sehir[i].ks(komut)) {
						if (sehir[i].bilgi == true) {
							cout << yellow << "Bu þehri zaten yazdýn.";
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
				cout << yellow << "Þehir bulunamadý!" << endl;
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time > sure) {
				cout << red << "Süre bitti!" << endl;
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
				cout << red << "Doðru Þehir Sayýnýz: " << yellow << winstreak << endl;
				cout << red << "Puanýnýz: " << yellow << toplampuan << endl;
				cout << green << "Sýralamaya adýnýzý yazdýrmak istermisiniz: (Evet/Hayýr) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "Ýsminizi nasýl yazmak istersiniz? (Türkçe karakter Kullanmayýnýz.) " << yellow;
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

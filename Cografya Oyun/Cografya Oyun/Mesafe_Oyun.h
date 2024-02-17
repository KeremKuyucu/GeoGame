using namespace std;

void Mesafe() {
	string komut;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla Ýlgili Açýklamalarýn Yazdýðý Yer
	cout << yellow << "Mesafeden Ülke Bilme Oyunu\n";
	cout << green << "Mesafeden ülke bilme oyununa hoþ geldiniz. \nAmacýnýz, 50 ülkeden rastgele seçilen bir ülkeyi bilmek.\nMesafeler +-100 Km fark olabilir. Konum olarak ülkelerin baþkentleri baz alýnmýþtýr."<<endl;
	cout << green << "Önceki Sýralamalara bakmak için " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her turda puanýnýz 100 den baþlar her yanlýþ tahminde 10 azarlýr.8 Tahminden sonra kazanýlan puan 25'e sabitlenir tur \nbitince tekrar 100'den baþlar. Joker 25 puan azaltýr. Ýlk tahmin puan eksiltmez" << endl;
	cout << yellow << "Süre:" << endl << green << "Oyun süresi 5 dakikadýr. Ne kadar sürenin kaldýðýna bakmak için " << yellow << "\"Süre\"" << green << " yazmanýz yeterlidir." << endl;
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
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l");
		oncekiRandomSayi = randomSayi; // Önceki seçilen ülkeyi güncelle
		puan = 110;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan Süre: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				cout << red << "Lütfen bir tahmin giriniz: " << yellow << endl;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
						puan -= 10;
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
				cout << red << "Doðru Ülke: " << kalici.isim << endl;
			}
			if (komut == "Bitir" || bitis) {
				cout << red << "Oyun Bitti." << yellow << " Yapan Kerem Kuyucu" << endl;
				cout << red << "Doðru Ülke Sayýnýz: " << yellow << winstreak << endl;
				cout << red << "Puanýnýz: " << yellow << toplampuan << endl;
				cout << green << "Sýralamaya adýnýzý yazdýrmak istermisiniz: (Evet/Hayýr) " << yellow;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				if (komut == "Evet") {
					cout << red << "Ýsminizi nasýl yazmak istersiniz? (Türkçe karakter Kullanmayýnýz.) " << yellow;
					getline(cin, komut);
					dosyayaz(komut, toplampuan, winstreak,"mesafe");
				}
				else
					dosyayaz("Yok", toplampuan, winstreak,"mesafe");
				oyun = 0;
				break;
			}
			if (komut == "Sure" || komut == "Sre") {
				end_time = clock();
				elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
				cout << red << "Kalan süre: " << yellow << sure - elapsed_time << red << " saniye" << endl;
				cout << blue << "---------------------------------------------------------" << yellow << endl;
			}
			if (komut == "Liste") {
				dosyaoku();
			}
			if (komut != "Ulkeler" &&
				komut != "Lkeler" &&
				komut != "Pas" &&
				komut != "Bitir" &&
				komut != "Sure" &&
				komut != "Sre" &&
				komut != "Liste" &&
				komut != gecici.isim &&
				komut != gecici.enisim &&
				komut != gecici.trisim) {
				cout << red << "Böyle bir ülke bulunamadý. " << yellow << "\"Ülkeler\"" << red << " yazarak ülke listesine bakabilirsiniz." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
			if (gecici.isim == kalici.isim || gecici.trisim == kalici.trisim || gecici.enisim == kalici.enisim) {
				cout << green << "Doðru ülkeyi buldun Tebrikler!! Yeni bir ülke seçildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				if (puan < 25)
					toplampuan += 25;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (gecici.isim == komut || gecici.trisim == komut || gecici.enisim == komut) {
				cout << red << "Mesafe: " << yellow << mesafehesapla(stod(gecici.enlem), stod(gecici.boylam), stod(kalici.enlem), stod(kalici.boylam)) << red << " kilometre" << endl;
				cout << red << "Yön:" << yellow << Pusula(yonal(stod(gecici.enlem), stod(gecici.boylam), stod(kalici.enlem), stod(kalici.boylam))) << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
			if (komut == "Ulkeler" || komut == "Lkeler") {
				ulkeyaz();
			}
			if (komut == "Pas") {
				cout << red << "Geçilen ülke: " << yellow << kalici.isim << endl;
				cout << red << "Kordinatý"<<" Enlem: "<<kalici.enlem<<" Boylam: "<<kalici.boylam << endl;
				cout << green << "Yeni bir ülke seçildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				break;
			}
		}
	}
}
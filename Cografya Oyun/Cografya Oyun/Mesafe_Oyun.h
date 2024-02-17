using namespace std;

void Mesafe() {
	string komut;
	clock_t start_time, end_time;
	bool oyun = true, bitis = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0, oncekiRandomSayi = -1, elapsed_time, sure = 300;
	//Oyunla �lgili A��klamalar�n Yazd��� Yer
	cout << yellow << "Mesafeden �lke Bilme Oyunu\n";
	cout << green << "Mesafeden �lke bilme oyununa ho� geldiniz. \nAmac�n�z, 50 �lkeden rastgele se�ilen bir �lkeyi bilmek.\nMesafeler +-100 Km fark olabilir. Konum olarak �lkelerin ba�kentleri baz al�nm��t�r."<<endl;
	cout << green << "�nceki S�ralamalara bakmak i�in " << yellow << "\"Liste\"" << green << " yazabilirsiniz." << endl;
	cout << yellow << "Puan Sistemi:" << endl;
	cout << green << "Her turda puan�n�z 100 den ba�lar her yanl�� tahminde 10 azarl�r.8 Tahminden sonra kazan�lan puan 25'e sabitlenir tur \nbitince tekrar 100'den ba�lar. Joker 25 puan azalt�r. �lk tahmin puan eksiltmez" << endl;
	cout << yellow << "S�re:" << endl << green << "Oyun s�resi 5 dakikad�r. Ne kadar s�renin kald���na bakmak i�in " << yellow << "\"S�re\"" << green << " yazman�z yeterlidir." << endl;
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
		Ulkeler gecici("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l");
		oncekiRandomSayi = randomSayi; // �nceki se�ilen �lkeyi g�ncelle
		puan = 110;
		while (true) {
			end_time = clock();
			elapsed_time = static_cast<int>(end_time - start_time) / CLOCKS_PER_SEC;
			if (elapsed_time <= sure) {
				cout << red << "Kalan S�re: " << yellow << sure - elapsed_time << red << " Saniye" << endl;
				cout << red << "L�tfen bir tahmin giriniz: " << yellow << endl;
				getline(cin, komut);
				komut = kelimeDuzelt(komut);
				for (size_t a = 0;a < (ulke.size());a++) {
					const Ulkeler& secilenulke = ulke[a];
					if (ulke[a].ks(komut)) {
						gecici = Ulkeler(secilenulke.trisim, secilenulke.isim, secilenulke.enisim, secilenulke.din, secilenulke.kita, secilenulke.yonetimbicimi, secilenulke.baskent, secilenulke.yuzolcum, secilenulke.nufus, secilenulke.ekonomi, secilenulke.enlem, secilenulke.boylam);
						puan -= 10;
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
				cout << red << "Kalan s�re: " << yellow << sure - elapsed_time << red << " saniye" << endl;
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
				cout << red << "B�yle bir �lke bulunamad�. " << yellow << "\"�lkeler\"" << red << " yazarak �lke listesine bakabilirsiniz." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
			if (gecici.isim == kalici.isim || gecici.trisim == kalici.trisim || gecici.enisim == kalici.enisim) {
				cout << green << "Do�ru �lkeyi buldun Tebrikler!! Yeni bir �lke se�ildi oyuna devam edin." << endl;
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
				cout << red << "Y�n:" << yellow << Pusula(yonal(stod(gecici.enlem), stod(gecici.boylam), stod(kalici.enlem), stod(kalici.boylam))) << endl;
				cout << blue << "---------------------------------------------------------" << endl;
			}
			if (komut == "Ulkeler" || komut == "Lkeler") {
				ulkeyaz();
			}
			if (komut == "Pas") {
				cout << red << "Ge�ilen �lke: " << yellow << kalici.isim << endl;
				cout << red << "Kordinat�"<<" Enlem: "<<kalici.enlem<<" Boylam: "<<kalici.boylam << endl;
				cout << green << "Yeni bir �lke se�ildi oyuna devam edin." << endl;
				cout << blue << "---------------------------------------------------------" << endl;
				break;
			}
		}
	}
}
using namespace std;

void oyun() {
	string komut, sayi;
	while (true) {
		setlocale(LC_ALL, "Turkish");
		cout << red << "Önceki Sýralamalara bakmak için " << yellow << "\"Liste\"" << red << " yazabilirsiniz." << endl;
		cout << yellow << "Oyun Seçini Yapýnýz." << endl;
		cout << yellow << "1" << green << " Ülke Bilme Oyunu" << endl;
		cout << yellow << "2" << green << " Baþkent Bilme Oyunu" << endl;
		cout << yellow << "3" << green << " Mesafeden Ülke Bilme Oyunu" << endl;
		cout << yellow;
		getline(cin, komut);
		sayi = komut;
		komut = kelimeDuzelt(komut);
		if (komut == "Liste") {
			dosyaoku();
			continue;
		}
		else if (sayi == "1" || komut == "Lkebilmeoyunu" || komut == "Ulkebilmeoyunu") {
			Ulke();
			break;
		}
		else if (sayi == "2" || komut == "Bakentbilmeoyunu" || komut == "Baskentbilmeoyunu") {
			Baskent();
			break;
		}
		else if (sayi == "3" || komut == "Mesafebilmeoyunu") {
			Mesafe();
			break;
		}
		else {
			cout << red << "Geçersiz Komut!" << endl;
			continue;
		}
	}
}
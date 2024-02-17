#include <iostream>
#include <string>
#include <iomanip> 
#include <vector>
#include <fstream>
#include <ctime>
#include <cmath>
#include <algorithm>
#include "Renkler.h"
#include "Ozellikler.h"
#include "Ulke_Oyun.h"
#include "Baskent_Oyun.h"
#include "Mesafe_Oyun.h"
int main() {
	string komut, sayi;
	while (true) {
		setlocale(LC_ALL, "Turkish");
		cout << red << "�nceki S�ralamalara bakmak i�in " << yellow << "\"Liste\"" << red << " yazabilirsiniz." << endl;
		cout << yellow << "Oyun Se�ini Yap�n�z." << endl;
		cout << yellow << "1" << green << " �lke Bilme Oyunu" << endl;
		cout << yellow << "2" << green << " Ba�kent Bilme Oyunu" << endl;
		cout << yellow << "3" << green << " Mesafeden �lke Bilme Oyunu" << endl;
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
			cout << red << "Ge�ersiz Komut!" << endl;
			continue;
		}
	}
	return 0;
}
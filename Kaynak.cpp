#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <windows.h>
#include <cstdlib>
#include <filesystem>
using namespace std;
#ifndef _LMCONS_H
#define _LMCONS_H
#define UNLEN 256  // Kullanýcý adýnýn maksimum uzunluðu
#endif
inline std::ostream& blue(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& red(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_INTENSITY);	return s; }
inline std::ostream& green(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& yellow(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY); return s; }
inline std::ostream& white(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE); return s; }
struct color { color(WORD attribute) :m_color(attribute) {};	WORD m_color; };
template <class _Elem, class _Traits> std::basic_ostream<_Elem, _Traits>& operator<<(std::basic_ostream<_Elem, _Traits>& i, color& c) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 	SetConsoleTextAttribute(hStdout, c.m_color); 	return i; }
struct Ulkeler {
	string isim;
};
vector<Ulkeler> ulke = { {"amerika"}, {"cin"}, {"japonya"}, {"almanya"}, {"hindistan"}, {"ingiltere"}, {"fransa"}, {"rusya"}, {"brezilya"}, {"italya"}, {"kanada"}, {"guneykore"}, {"avusturalya"}, {"ispanya"}, {"meksika"}, {"endonezya"}, {"turkiye"}, {"hollanda"}, {"arabistan"}, {"isvicre"}, {"tayvan"}, {"polonya"}, {"arjantin"}, {"isvec"}, {"pakistan"}, {"belcika"}, {"norvec"}, {"guneyafrika"}, {"malezya"}, {"katar"}, {"misir"}, {"sili"}, {"yunanistan"}, {"iran"}, {"israil"}, {"romanya"}, {"ukrayna"}, {"kazakistan"}, {"finlandiya"}, {"azerbaycan"}, {"singapur"}, {"gurcistan"}, {"vietnam"}, {"avusturya"}, {"nijerya"}, {"kuba"}, {"kirgizistan"}, {"cezayir"}, {"malta"}, {"panama"}, };
void download(const std::string& url, const std::string& file) {
	std::string powershellCommand = "powershell -Command \"Invoke-WebRequest -Uri '" + url + "' -OutFile '" + file + "'\"";
	int result = system(powershellCommand.c_str());
	if (result == 0) {
		std::cout << yellow << file << ", " << green<< "Baþarý ile indirildi" << endl;
	}
	else {
		std::cout << yellow << file << ", " << red << "Ýndirme Hatasý" << std::endl;
	}
}
bool dosyaVarMi(const std::string& dosyaYolu) {
	std::string komut = "dir /B " + dosyaYolu + " > nul 2>&1";
	return system(komut.c_str()); // Komut baþarýlý ise 0 döner
}
bool checkInternetConnection() {
	// Ping komutunu kullanarak google.com'a bir ICMP isteði gönder ve cevap al
	int result = std::system("ping -n 1 google.com > nul");

	// Eðer ping baþarýlý olduysa (0 döndüyse), internet baðlantýsý var demektir
	return result == 0;
}
int main(void) {
	namespace fs = std::filesystem;
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun");
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar");
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler");
	setlocale(LC_ALL, "Turkish");
	cout << yellow << "Dosyalar Yükleniyor..." << endl << red;
	int i = 1;
	for (const Ulkeler& secilenulke : ulke) {
		const std::string url = "https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/" + secilenulke.isim + ".png?v=1712566998750";
		string filename = "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar\\" + secilenulke.isim + ".png";
		if (dosyaVarMi(filename))
		{
			cout << endl;
			download(url, filename);
		}
		else
		{
			if (i <= 9)
			cout << green << "Bayrak " << yellow << i << blue << "  zaten var. " << red;
			else 
			cout << green << "Bayrak " << yellow << i << blue << " zaten var. " << red;
		}
		if (i % 5 == 0)
			cout << endl;
		i++;
	}
		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan.png"))
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan.png?v=1712610924818", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan.png");
		else
			cout << yellow << "arkaplan.png, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan2.png"))
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan2.png?v=1712610926441", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan2.png");
		else
			cout << yellow << "arkaplan2.png " << blue << "zaten var." << endl << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-system-2.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-system-2.dll?v=1712246175041", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-system-2.dll");
		else
			cout << yellow << "sfml-system-2.dll, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-audio-2.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-audio-2.dll?v=1712246181544", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-audio-2.dll");
		else
			cout << yellow << "sfml-audio-2.dll, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-graphics-2.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-graphics-2.dll?v=1712246183016", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-graphics-2.dll");
		else
			cout << yellow << "sfml-graphics-2.dll, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-network-2.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-network-2.dll?v=1712246185360", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-network-2.dll");
		else
			cout << yellow << "sfml-network-2.dll, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-window-2.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-window-2.dll?v=1712246185972", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-window-2.dll");
		else
			cout << yellow << "sfml-window-2.dll, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\openal32.dll"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/openal32.dll?v=1712246180211", "C:\\Users\\Public\\Documents\\cografyaoyun\\openal32.dll");
		else
			cout << yellow << "openal32.dll, " << endl << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\dogru.ogg"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/dogru.ogg?v=1712246846428", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\dogru.ogg");
		else
			cout << yellow << "dogru.ogg, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yanlis.ogg"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yanlis.ogg?v=1712246846933", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yanlis.ogg");
		else
			cout << yellow << "yanlis.ogg, " << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yenitur.ogg"))
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yenitur.ogg?v=1712246848934", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yenitur.ogg");
		else
			cout << yellow << "yenitur.ogg "<< blue <<"zaten var." << endl << red;

		if (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arial.ttf"))
			download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arial.ttf?v=1712527873856", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arial.ttf");
		else
			cout << yellow << "arial.ttf " << blue << "zaten var." << endl << red;

		std::string remoteVersion, localVersion, komut;
		download("https://drive.usercontent.google.com/download?id=1KIYUZBqnagJmmD0WcfIYdVFjlb3ExyVM&export=download&authuser=0", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\remoteVersion.txt");
		std::ifstream file("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\remoteVersion.txt");
		std::ifstream file2("C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\localVersion.txt");
		getline(file, remoteVersion);
		getline(file2, localVersion);
		file.close();
		file2.close();
		if ((localVersion != remoteVersion && checkInternetConnection()) || (dosyaVarMi("C:\\Users\\Public\\Documents\\cografyaoyun\\CografyaOyun.exe"))) {
			download("https://drive.usercontent.google.com/download?id=1WmFuztUD3X80v5NpfWgrSSaCeCocdO7Q&export=download&authuser=0&confirm=t&uuid=6f08aa2c-d401-443f-9c87-2a74a8d638d9&at=APZUnTWZ2IKEbvXC5cwg30y9hFuQ%3A1713449915808", "C:\\Users\\Public\\Documents\\cografyaoyun\\CografyaOyun.exe");
			download("https://drive.usercontent.google.com/download?id=1KIYUZBqnagJmmD0WcfIYdVFjlb3ExyVM&export=download&authuser=0", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\localVersion.txt");
		}
		cout << yellow << "Oyunu indirme Baþarýlý!" << endl << "Eðer oyun açýldýysa bu sekmeyi isterseniz kapatabilirsiniz. Fakat açýlmadý veya hatalý açýldý ise\nC:\\Users\\Public\\Documents\\cografyaoyun konunuma giderek oyunu CografyaOyun.exe dosyasýný açarak baþlatabilirsiniz" << endl << red;
		std::filesystem::current_path("C:\\Users\\Public\\Documents\\cografyaoyun");
		fs::path exePath = "C:\\Users\\Public\\Documents\\cografyaoyun\\CografyaOyun.exe";
		std::system(exePath.string().c_str());
	return 0;
}
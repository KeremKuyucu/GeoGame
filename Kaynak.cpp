#include <iostream>
#include <string>
#include <vector>
#include <algorithm> 
#include <fstream>
#include <windows.h>
#include <filesystem>
using namespace std;
struct Ulkeler {
	string isim;
};
vector<Ulkeler> ulke = { {"amerika"}, {"cin"}, {"japonya"}, {"almanya"}, {"hindistan"}, {"ingiltere"}, {"fransa"}, {"rusya"}, {"brezilya"}, {"italya"}, {"kanada"}, {"guneykore"}, {"avusturalya"}, {"ispanya"}, {"meksika"}, {"endonezya"}, {"turkiye"}, {"hollanda"}, {"arabistan"}, {"isvicre"}, {"tayvan"}, {"polonya"}, {"arjantin"}, {"isvec"}, {"pakistan"}, {"belcika"}, {"norvec"}, {"guneyafrika"}, {"malezya"}, {"katar"}, {"misir"}, {"sili"}, {"yunanistan"}, {"iran"}, {"israil"}, {"romanya"}, {"ukrayna"}, {"kazakistan"}, {"finlandiya"}, {"azerbaycan"}, {"singapur"}, {"gurcistan"}, {"vietnam"}, {"avusturya"}, {"nijerya"}, {"kuba"}, {"kirgizistan"}, {"cezayir"}, {"malta"}, {"panama"}, };
void download(const std::string& url, const std::string& file) {
	system(("powershell -Command \"Invoke-WebRequest -Uri " + url + " -OutFile " + file + "\"").c_str());
}
inline std::ostream& blue(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& red(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_INTENSITY);	return s; }
inline std::ostream& green(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_INTENSITY); return s; }
inline std::ostream& yellow(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY); return s; }
inline std::ostream& white(std::ostream& s) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); SetConsoleTextAttribute(hStdout, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE); return s; }
struct color { color(WORD attribute) :m_color(attribute) {};	WORD m_color; };
template <class _Elem, class _Traits> std::basic_ostream<_Elem, _Traits>& operator<<(std::basic_ostream<_Elem, _Traits>& i, color& c) { HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 	SetConsoleTextAttribute(hStdout, c.m_color); 	return i; }

int main(void) {
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun");
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar");
	system("mkdir C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler");
	setlocale(LC_ALL, "Turkish");
	cout << yellow << "Dosyalar Yükleniyor..." << endl << red;
	int i = 1;
	for (const Ulkeler& secilenulke : ulke) {
		const std::string url = "https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/" + secilenulke.isim + ".png?v=1712566998750";
		string filename = "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar\\" + secilenulke.isim + ".png";
		download(url, filename);
		cout << yellow << "Bayrak: "<< i <<" indirildi." << endl << red;
		i++;
	}
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/logo.ico?v=1712323528221", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\bayraklar\\logo.ico");
		cout << yellow << "Logo indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-system-2.dll?v=1712246175041", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-system-2.dll");
		cout << yellow << "sfml-system-2.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/openal32.dll?v=1712246180211", "C:\\Users\\Public\\Documents\\cografyaoyun\\openal32.dll");
		cout << yellow << "openal32.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-audio-2.dll?v=1712246181544", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-audio-2.dll");
		cout << yellow << "sfml-audio-2.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-graphics-2.dll?v=1712246183016", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-graphics-2.dll");
		cout << yellow << "sfml-graphics-2.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-network-2.dll?v=1712246185360", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-network-2.dll");
		cout << yellow << "sfml-network-2.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/sfml-window-2.dll?v=1712246185972", "C:\\Users\\Public\\Documents\\cografyaoyun\\sfml-window-2.dll");
		cout << yellow << "sfml-window-2.dll indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/dogru.ogg?v=1712246846428", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\dogru.ogg");
		cout << yellow << "dogru.ogg indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yanlis.ogg?v=1712246846933", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yanlis.ogg");
		cout << yellow << "yanlis.ogg indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/yenitur.ogg?v=1712246848934", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\sesler\\yenitur.ogg");
		cout << yellow << "yenitur.ogg indirildi." << endl << red;
		download("https://drive.usercontent.google.com/download?id=1YYxo3mRZG0L6vK2f9b-sH39RkdlC6YRH&export=download&authuser=0&confirm=t&uuid=e8a908ac-9a17-4d68-937c-7da99e478739&at=APZUnTVncbTp9kdQem4Us1ukBrhY%3A1712266094378", "C:\\Users\\Public\\Documents\\cografyaoyun\\CografyaOyun.exe");
		cout << yellow << "Cografyaoyun.exe indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/CografyaOyun.lnk?v=1712323669142", "CografyaOyun.lnk");
		cout << yellow << "CografyaOyun.lnk indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arial.ttf?v=1712527873856", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arial.ttf");
		cout << yellow << "arial.ttf indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan.png?v=1712610924818", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan.png");
		cout << yellow << "arkaplan.png indirildi." << endl << red;
		download("https://cdn.glitch.global/71699e1d-0b18-447f-880a-38316c508937/arkaplan2.png?v=1712610926441", "C:\\Users\\Public\\Documents\\cografyaoyun\\dosyalar\\arkaplan2.png");
		cout << yellow << "arkaplan2.png indirildi." << endl << red;
		cout << yellow << red << "Dosyalar baþarýlý þekilde indirildi." << endl << red;
	return 0;
}

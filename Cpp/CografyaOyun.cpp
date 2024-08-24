#include <iostream>
#include <fstream>
#include <SFML/Graphics.hpp>
#include <SFML/audio.hpp>
#include <filesystem>
#include <array>
using namespace std;
using namespace filesystem;
//------------------------------------------------------------------------------------------------------------------------- ulkeler
class Ulkeler {
public:
	string bayrak, trisim, enisim, isim, baskent, kita, url;
	bool bilgi = false, bm = false;
	double enlem, boylam;
	int dosyaboyut;
	Ulkeler(const string& bayrak0, const string& trisim0, const string& enisim0, const string& isim0, const string& baskent0, const string& kita0, const string& url0, const double& enlem0, const double& boylam0, const bool& bm0, const int& dosyaboyut0) {
		bayrak = bayrak0; trisim = trisim0; enisim = enisim0; isim = isim0; baskent = baskent0; kita = kita0; url = url0; enlem = enlem0; boylam = boylam0; bm = bm0; dosyaboyut = dosyaboyut0;
	}
	bool ks(const string& yapilantahmin) const { return (yapilantahmin == trisim || yapilantahmin == isim || yapilantahmin == enisim); }
};
Ulkeler ulke1("dosyalar/bayraklar/moldova.png", "Moldova", "Moldova", "Moldova", "Chisinau", "Europe", "https://flagcdn.com/w320/md.png", 47.0, 29.0, true, 2600);
Ulkeler ulke2("dosyalar/bayraklar/amerikabirlesikdevletleri.png", "Amerikabirleikdevletleri", "Unitedstates", "Amerikabirlesikdevletleri", "Washingtondc", "Americas", "https://flagcdn.com/w320/us.png", 38.0, -97.0, true, 1289);
Ulkeler ulke3("dosyalar/bayraklar/mayotte.png", "Mayotte", "Mayotte", "Mayotte", "Mamoudzou", "Africa", "https://flagcdn.com/w320/yt.png", -12.83, 45.17, false, 8185);
Ulkeler ulke4("dosyalar/bayraklar/nauru.png", "Nauru", "Nauru", "Nauru", "Yaren", "Oceania", "https://flagcdn.com/w320/nr.png", -0.53, 166.92, true, 651);
Ulkeler ulke5("dosyalar/bayraklar/mozambik.png", "Mozambik", "Mozambique", "Mozambik", "Maputo", "Africa", "https://flagcdn.com/w320/mz.png", -18.25, 35.0, true, 2298);
Ulkeler ulke6("dosyalar/bayraklar/brezilya.png", "Brezilya", "Brazil", "Brezilya", "Brasília", "Americas", "https://flagcdn.com/w320/br.png", -10.0, -55.0, true, 2883);
Ulkeler ulke7("dosyalar/bayraklar/yesilburun.png", "Yeilburun", "Capeverde", "Yesilburun", "Praia", "Africa", "https://flagcdn.com/w320/cv.png", 16.54, -23.04, true, 909);
Ulkeler ulke8("dosyalar/bayraklar/ekvatorginesi.png", "Ekvatorginesi", "Equatorialguinea", "Ekvatorginesi", "Malabo", "Africa", "https://flagcdn.com/w320/gq.png", 2.0, 10.0, true, 1923);
Ulkeler ulke9("dosyalar/bayraklar/arnavutluk.png", "Arnavutluk", "Albania", "Arnavutluk", "Tirana", "Europe", "https://flagcdn.com/w320/al.png", 41.0, 20.0, true, 3044);
Ulkeler ulke10("dosyalar/bayraklar/abdvirjinadalari.png", "Abdvirjinadalar", "Unitedstatesvirginislands", "Abdvirjinadalari", "Charlotteamalie", "Americas", "https://flagcdn.com/w320/vi.png", 18.35, -64.93, false, 9362);
Ulkeler ulke11("dosyalar/bayraklar/niue.png", "Niue", "Niue", "Niue", "Alofi", "Oceania", "https://flagcdn.com/w320/nu.png", -19.03, -169.87, false, 1457);
Ulkeler ulke12("dosyalar/bayraklar/palau.png", "Palau", "Palau", "Palau", "Ngerulmud", "Oceania", "https://flagcdn.com/w320/pw.png", 7.5, 134.5, true, 738);
Ulkeler ulke13("dosyalar/bayraklar/nijerya.png", "Nijerya", "Nigeria", "Nijerya", "Abuja", "Africa", "https://flagcdn.com/w320/ng.png", 10.0, 8.0, true, 157);
Ulkeler ulke14("dosyalar/bayraklar/virjinadalari.png", "Virjinadalar", "Britishvirginislands", "Virjinadalari", "Roadtown", "Americas", "https://flagcdn.com/w320/vg.png", 18.43, -64.62, false, 4437);
Ulkeler ulke15("dosyalar/bayraklar/gambiya.png", "Gambiya", "Gambia", "Gambiya", "Banjul", "Africa", "https://flagcdn.com/w320/gm.png", 13.47, -16.57, true, 248);
Ulkeler ulke16("dosyalar/bayraklar/somali.png", "Somali", "Somalia", "Somali", "Mogadishu", "Africa", "https://flagcdn.com/w320/so.png", 10.0, 49.0, true, 693);
Ulkeler ulke17("dosyalar/bayraklar/yemen.png", "Yemen", "Yemen", "Yemen", "Sanaa", "Asia", "https://flagcdn.com/w320/ye.png", 15.0, 48.0, true, 153);
Ulkeler ulke18("dosyalar/bayraklar/malezya.png", "Malezya", "Malaysia", "Malezya", "Kualalumpur", "Asia", "https://flagcdn.com/w320/my.png", 2.5, 112.5, true, 1139);
Ulkeler ulke19("dosyalar/bayraklar/dominika.png", "Dominika", "Dominica", "Dominika", "Roseau", "Americas", "https://flagcdn.com/w320/dm.png", 15.42, -61.33, true, 1715);
Ulkeler ulke20("dosyalar/bayraklar/birlesikkrallik.png", "Birleikkrallk", "Unitedkingdom", "Birlesikkrallik", "London", "Europe", "https://flagcdn.com/w320/gb.png", 54.0, -2.0, true, 980);
Ulkeler ulke21("dosyalar/bayraklar/madagaskar.png", "Madagaskar", "Madagascar", "Madagaskar", "Antananarivo", "Africa", "https://flagcdn.com/w320/mg.png", -20.0, 47.0, true, 266);
Ulkeler ulke22("dosyalar/bayraklar/sahrademokratikarapcumhuriyeti.png", "Sahrademokratikarapcumhuriyeti", "Westernsahara", "Sahrademokratikarapcumhuriyeti", "Elaaiun", "Africa", "https://flagcdn.com/w320/eh.png", 24.5, -13.0, false, 1083);
Ulkeler ulke23("dosyalar/bayraklar/kibris.png", "Kbrs", "Cyprus", "Kibris", "Nicosia", "Europe", "https://flagcdn.com/w320/cy.png", 35.0, 33.0, true, 2172);
Ulkeler ulke24("dosyalar/bayraklar/antiguavebarbuda.png", "Antiguavebarbuda", "Antiguaandbarbuda", "Antiguavebarbuda", "Saintjohns", "Americas", "https://flagcdn.com/w320/ag.png", 17.05, -61.8, true, 2325);
Ulkeler ulke25("dosyalar/bayraklar/irlanda.png", "Rlanda", "Ireland", "Irlanda", "Dublin", "Europe", "https://flagcdn.com/w320/ie.png", 53.0, -8.0, true, 219);
Ulkeler ulke26("dosyalar/bayraklar/paraguay.png", "Paraguay", "Paraguay", "Paraguay", "Asunción", "Americas", "https://flagcdn.com/w320/py.png", -23.0, -58.0, true, 1190);
Ulkeler ulke27("dosyalar/bayraklar/srilanka.png", "Srilanka", "Srilanka", "Srilanka", "Srijayawardenepurakotte", "Asia", "https://flagcdn.com/w320/lk.png", 7.0, 81.0, true, 3493);
Ulkeler ulke28("dosyalar/bayraklar/guneyafrika.png", "Gneyafrika", "Southafrica", "Guneyafrika", "Pretoriabloemfonteincapetown", "Africa", "https://flagcdn.com/w320/za.png", -29.0, 24.0, true, 985);
Ulkeler ulke29("dosyalar/bayraklar/kuveyt.png", "Kuveyt", "Kuwait", "Kuveyt", "Kuwaitcity", "Asia", "https://flagcdn.com/w320/kw.png", 29.5, 45.75, true, 527);
Ulkeler ulke30("dosyalar/bayraklar/cezayir.png", "Cezayir", "Algeria", "Cezayir", "Algiers", "Africa", "https://flagcdn.com/w320/dz.png", 28.0, 3.0, true, 989);
Ulkeler ulke31("dosyalar/bayraklar/hirvatistan.png", "Hrvatistan", "Croatia", "Hirvatistan", "Zagreb", "Europe", "https://flagcdn.com/w320/hr.png", 45.17, 15.5, true, 1810);
Ulkeler ulke32("dosyalar/bayraklar/martinik.png", "Martinik", "Martinique", "Martinik", "Fortdefrance", "Americas", "https://flagcdn.com/w320/mq.png", 14.67, -61.0, false, 957);
Ulkeler ulke33("dosyalar/bayraklar/sierraleone.png", "Sierraleone", "Sierraleone", "Sierraleone", "Freetown", "Africa", "https://flagcdn.com/w320/sl.png", 8.5, -11.5, true, 153);
Ulkeler ulke34("dosyalar/bayraklar/kuzeymarianaadalari.png", "Kuzeymarianaadalar", "Northernmarianaislands", "Kuzeymarianaadalari", "Saipan", "Oceania", "https://flagcdn.com/w320/mp.png", 15.2, 145.75, false, 9029);
Ulkeler ulke35("dosyalar/bayraklar/ruanda.png", "Ruanda", "Rwanda", "Ruanda", "Kigali", "Africa", "https://flagcdn.com/w320/rw.png", -2.0, 30.0, true, 1180);
Ulkeler ulke36("dosyalar/bayraklar/suriye.png", "Suriye", "Syria", "Suriye", "Damascus", "Asia", "https://flagcdn.com/w320/sy.png", 35.0, 38.0, true, 819);
Ulkeler ulke37("dosyalar/bayraklar/saintvincentvegrenadinler.png", "Saintvincentvegrenadinler", "Saintvincentandthegrenadines", "Saintvincentvegrenadinler", "Kingstown", "Americas", "https://flagcdn.com/w320/vc.png", 13.25, -61.2, true, 1087);
Ulkeler ulke38("dosyalar/bayraklar/kosova.png", "Kosova", "Kosovo", "Kosova", "Pristina", "Europe", "https://flagcdn.com/w320/xk.png", 42.67, 21.17, false, 1730);
Ulkeler ulke39("dosyalar/bayraklar/saintlucia.png", "Saintlucia", "Saintlucia", "Saintlucia", "Castries", "Americas", "https://flagcdn.com/w320/lc.png", 13.88, -60.97, true, 1552);
Ulkeler ulke40("dosyalar/bayraklar/honduras.png", "Honduras", "Honduras", "Honduras", "Tegucigalpa", "Americas", "https://flagcdn.com/w320/hn.png", 15.0, -86.5, true, 595);
Ulkeler ulke41("dosyalar/bayraklar/urdun.png", "Rdn", "Jordan", "Urdun", "Amman", "Asia", "https://flagcdn.com/w320/jo.png", 31.0, 36.0, true, 658);
Ulkeler ulke42("dosyalar/bayraklar/tuvalu.png", "Tuvalu", "Tuvalu", "Tuvalu", "Funafuti", "Oceania", "https://flagcdn.com/w320/tv.png", -8.0, 178.0, true, 1820);
Ulkeler ulke43("dosyalar/bayraklar/nepal.png", "Nepal", "Nepal", "Nepal", "Kathmandu", "Asia", "https://flagcdn.com/w320/np.png", 28.0, 84.0, true, 3611);
Ulkeler ulke44("dosyalar/bayraklar/liberya.png", "Liberya", "Liberia", "Liberya", "Monrovia", "Africa", "https://flagcdn.com/w320/lr.png", 6.5, -9.5, true, 606);
Ulkeler ulke45("dosyalar/bayraklar/heardadasivemcdonaldadalari.png", "Heardadasvemcdonaldadalar", "Heardislandandmcdonaldislands", "Heardadasivemcdonaldadalari", "", "Antarctic", "https://flagcdn.com/w320/hm.png", 53.08, 73.5, false, 1577);
Ulkeler ulke46("dosyalar/bayraklar/avusturya.png", "Avusturya", "Austria", "Avusturya", "Vienna", "Europe", "https://flagcdn.com/w320/at.png", 47.33, 13.33, true, 118);
Ulkeler ulke47("dosyalar/bayraklar/guernsey.png", "Guernsey", "Guernsey", "Guernsey", "Stpeterport", "Europe", "https://flagcdn.com/w320/gg.png", 49.47, -2.58, false, 570);
Ulkeler ulke48("dosyalar/bayraklar/ortaafrikacumhuriyeti.png", "Ortaafrikacumhuriyeti", "Centralafricanrepublic", "Ortaafrikacumhuriyeti", "Bangui", "Africa", "https://flagcdn.com/w320/cf.png", 7.0, 21.0, true, 622);
Ulkeler ulke49("dosyalar/bayraklar/moritanya.png", "Moritanya", "Mauritania", "Moritanya", "Nouakchott", "Africa", "https://flagcdn.com/w320/mr.png", 20.0, -12.0, true, 1002);
Ulkeler ulke50("dosyalar/bayraklar/cibuti.png", "Cibuti", "Djibouti", "Cibuti", "Djibouti", "Africa", "https://flagcdn.com/w320/dj.png", 11.5, 43.0, true, 1474);
Ulkeler ulke51("dosyalar/bayraklar/fiji.png", "Fiji", "Fiji", "Fiji", "Suva", "Oceania", "https://flagcdn.com/w320/fj.png", 17.71, 178.06, true, 3250);
Ulkeler ulke52("dosyalar/bayraklar/norvec.png", "Norve", "Norway", "Norvec", "Oslo", "Europe", "https://flagcdn.com/w320/no.png", 62.0, 10.0, true, 323);
Ulkeler ulke53("dosyalar/bayraklar/letonya.png", "Letonya", "Latvia", "Letonya", "Riga", "Europe", "https://flagcdn.com/w320/lv.png", 57.0, 25.0, true, 112);
Ulkeler ulke54("dosyalar/bayraklar/falklandmalvinaadalari.png", "Falklandmalvinaadalar", "Falklandislands", "Falklandmalvinaadalari", "Stanley", "Americas", "https://flagcdn.com/w320/fk.png", -51.75, -59.0, false, 5318);
Ulkeler ulke55("dosyalar/bayraklar/kazakistan.png", "Kazakistan", "Kazakhstan", "Kazakistan", "Nursultan", "Asia", "https://flagcdn.com/w320/kz.png", 48.02, 66.92, true, 2960);
Ulkeler ulke56("dosyalar/bayraklar/aland.png", "Aland", "Alandislands", "Aland", "Mariehamn", "Europe", "https://flagcdn.com/w320/ax.png", 60.12, 19.9, false, 311);
Ulkeler ulke57("dosyalar/bayraklar/turkmenistan.png", "Trkmenistan", "Turkmenistan", "Turkmenistan", "Ashgabat", "Asia", "https://flagcdn.com/w320/tm.png", 40.0, 60.0, true, 7750);
Ulkeler ulke58("dosyalar/bayraklar/cocoskeelingadalari.png", "Cocoskeelingadalar", "Cocoskeelingislands", "Cocoskeelingadalari", "Westisland", "Oceania", "https://flagcdn.com/w320/cc.png", 12.16, 96.87, false, 1989);
Ulkeler ulke59("dosyalar/bayraklar/bulgaristan.png", "Bulgaristan", "Bulgaria", "Bulgaristan", "Sofia", "Europe", "https://flagcdn.com/w320/bg.png", 43.0, 25.0, true, 151);
Ulkeler ulke60("dosyalar/bayraklar/tokelau.png", "Tokelau", "Tokelau", "Tokelau", "Fakaofo", "Oceania", "https://flagcdn.com/w320/tk.png", -9.0, -172.0, false, 1418);
Ulkeler ulke61("dosyalar/bayraklar/yenikaledonya.png", "Yenikaledonya", "Newcaledonia", "Yenikaledonya", "Nouméa", "Oceania", "https://flagcdn.com/w320/nc.png", -21.5, 165.5, false, 1715);
Ulkeler ulke62("dosyalar/bayraklar/barbados.png", "Barbados", "Barbados", "Barbados", "Bridgetown", "Americas", "https://flagcdn.com/w320/bb.png", 13.17, -59.53, true, 998);
Ulkeler ulke63("dosyalar/bayraklar/saotomeandprincipe.png", "Saotomeandprincipe", "Saotomeandprincipe", "Saotomeandprincipe", "Saotome", "Africa", "https://flagcdn.com/w320/st.png", 1.0, 7.0, true, 1077);
Ulkeler ulke64("dosyalar/bayraklar/antarktika.png", "Antarktika", "Antarctica", "Antarktika", "", "Antarctic", "https://flagcdn.com/w320/aq.png", -90.0, 0.0, false, 1354);
Ulkeler ulke65("dosyalar/bayraklar/brunei.png", "Brunei", "Brunei", "Brunei", "Bandarseribegawan", "Asia", "https://flagcdn.com/w320/bn.png", 4.5, 114.67, true, 3402);
Ulkeler ulke66("dosyalar/bayraklar/butan.png", "Butan", "Bhutan", "Butan", "Thimphu", "Asia", "https://flagcdn.com/w320/bt.png", 27.5, 90.5, true, 8230);
Ulkeler ulke67("dosyalar/bayraklar/kamerun.png", "Kamerun", "Cameroon", "Kamerun", "Yaoundé", "Africa", "https://flagcdn.com/w320/cm.png", 6.0, 12.0, true, 637);
Ulkeler ulke68("dosyalar/bayraklar/arjantin.png", "Arjantin", "Argentina", "Arjantin", "Buenosaires", "Americas", "https://flagcdn.com/w320/ar.png", -34.0, -64.0, true, 1578);
Ulkeler ulke69("dosyalar/bayraklar/azerbaycan.png", "Azerbaycan", "Azerbaijan", "Azerbaycan", "Baku", "Asia", "https://flagcdn.com/w320/az.png", 40.5, 47.5, true, 706);
Ulkeler ulke70("dosyalar/bayraklar/meksika.png", "Meksika", "Mexico", "Meksika", "Mexicocity", "Americas", "https://flagcdn.com/w320/mx.png", 23.0, -102.0, true, 3655);
Ulkeler ulke71("dosyalar/bayraklar/fas.png", "Fas", "Morocco", "Fas", "Rabat", "Africa", "https://flagcdn.com/w320/ma.png", 32.0, -5.0, true, 928);
Ulkeler ulke72("dosyalar/bayraklar/guatemala.png", "Guatemala", "Guatemala", "Guatemala", "Guatemalacity", "Americas", "https://flagcdn.com/w320/gt.png", 15.5, -90.25, true, 2518);
Ulkeler ulke73("dosyalar/bayraklar/kenya.png", "Kenya", "Kenya", "Kenya", "Nairobi", "Africa", "https://flagcdn.com/w320/ke.png", 1.0, 38.0, true, 1966);
Ulkeler ulke74("dosyalar/bayraklar/malta.png", "Malta", "Malta", "Malta", "Valletta", "Europe", "https://flagcdn.com/w320/mt.png", 35.94, 14.38, true, 1073);
Ulkeler ulke75("dosyalar/bayraklar/cekya.png", "Ekya", "Czechia", "Cekya", "Prague", "Europe", "https://flagcdn.com/w320/cz.png", 49.75, 15.5, true, 940);
Ulkeler ulke76("dosyalar/bayraklar/cebelitarik.png", "Cebelitark", "Gibraltar", "Cebelitarik", "Gibraltar", "Europe", "https://flagcdn.com/w320/gi.png", 36.13, -5.35, false, 2033);
Ulkeler ulke77("dosyalar/bayraklar/aruba.png", "Aruba", "Aruba", "Aruba", "Oranjestad", "Americas", "https://flagcdn.com/w320/aw.png", 12.5, -69.97, false, 735);
Ulkeler ulke78("dosyalar/bayraklar/saintbarthelemy.png", "Saintbarthelemy", "Saintbarthelemy", "Saintbarthelemy", "Gustavia", "Americas", "https://flagcdn.com/w320/bl.png", 18.5, -63.42, false, 11667);
Ulkeler ulke79("dosyalar/bayraklar/monako.png", "Monako", "Monaco", "Monako", "Monaco", "Europe", "https://flagcdn.com/w320/mc.png", 43.73, 7.4, true, 124);
Ulkeler ulke80("dosyalar/bayraklar/birlesikarapemirlikleri.png", "Birleikarapemirlikleri", "Unitedarabemirates", "Birlesikarapemirlikleri", "Abudhabi", "Asia", "https://flagcdn.com/w320/ae.png", 24.0, 54.0, true, 233);
Ulkeler ulke81("dosyalar/bayraklar/guneysudan.png", "Gneysudan", "Southsudan", "Guneysudan", "Juba", "Africa", "https://flagcdn.com/w320/ss.png", 7.0, 30.0, true, 1000);
Ulkeler ulke82("dosyalar/bayraklar/portoriko.png", "Portoriko", "Puertorico", "Portoriko", "Sanjuan", "Americas", "https://flagcdn.com/w320/pr.png", 18.25, -66.5, false, 1474);
Ulkeler ulke83("dosyalar/bayraklar/elsalvador.png", "Elsalvador", "Elsalvador", "Elsalvador", "Sansalvador", "Americas", "https://flagcdn.com/w320/sv.png", 13.83, -88.92, true, 2363);
Ulkeler ulke84("dosyalar/bayraklar/fransa.png", "Fransa", "France", "Fransa", "Paris", "Europe", "https://flagcdn.com/w320/fr.png", 46.0, 2.0, true, 253);
Ulkeler ulke85("dosyalar/bayraklar/nijer.png", "Nijer", "Niger", "Nijer", "Niamey", "Africa", "https://flagcdn.com/w320/ne.png", 16.0, 8.0, true, 645);
Ulkeler ulke86("dosyalar/bayraklar/fildisisahili.png", "Fildiisahili", "Ivorycoast", "Fildisisahili", "Yamoussoukro", "Africa", "https://flagcdn.com/w320/ci.png", 8.0, -5.0, true, 252);
Ulkeler ulke87("dosyalar/bayraklar/guneygeorgiaveguneysandwichadalari.png", "Gneygeorgiavegneysandwichadalar", "Southgeorgia", "Guneygeorgiaveguneysandwichadalari", "Kingedwardpoint", "Antarctic", "https://flagcdn.com/w320/gs.png", -54.5, -37.0, false, 6026);
Ulkeler ulke88("dosyalar/bayraklar/botsvana.png", "Botsvana", "Botswana", "Botsvana", "Gaborone", "Africa", "https://flagcdn.com/w320/bw.png", -22.0, 24.0, true, 199);
Ulkeler ulke89("dosyalar/bayraklar/britanyahintokyanusutopraklari.png", "Britanyahintokyanusutopraklar", "Britishindianoceanterritory", "Britanyahintokyanusutopraklari", "Diegogarcia", "Africa", "https://flagcdn.com/w320/io.png", -6.0, 71.5, false, 7213);
Ulkeler ulke90("dosyalar/bayraklar/ozbekistan.png", "Zbekistan", "Uzbekistan", "Ozbekistan", "Tashkent", "Asia", "https://flagcdn.com/w320/uz.png", 41.0, 64.0, true, 760);
Ulkeler ulke91("dosyalar/bayraklar/tunus.png", "Tunus", "Tunisia", "Tunus", "Tunis", "Africa", "https://flagcdn.com/w320/tn.png", 34.0, 9.0, true, 1128);
Ulkeler ulke92("dosyalar/bayraklar/hongkong.png", "Hongkong", "Hongkong", "Hongkong", "Cityofvictoria", "Asia", "https://flagcdn.com/w320/hk.png", 22.27, 114.19, false, 2045);
Ulkeler ulke93("dosyalar/bayraklar/kuzeymakedonya.png", "Kuzeymakedonya", "Northmacedonia", "Kuzeymakedonya", "Skopje", "Europe", "https://flagcdn.com/w320/mk.png", 41.83, 22.0, true, 1613);
Ulkeler ulke94("dosyalar/bayraklar/surinam.png", "Surinam", "Suriname", "Surinam", "Paramaribo", "Americas", "https://flagcdn.com/w320/sr.png", 4.0, -56.0, true, 686);
Ulkeler ulke95("dosyalar/bayraklar/belcika.png", "Belika", "Belgium", "Belgika", "Brussels", "Europe", "https://flagcdn.com/w320/be.png", 50.83, 4.0, true, 292);
Ulkeler ulke96("dosyalar/bayraklar/amerikansamoasi.png", "Amerikansamoas", "Americansamoa", "Amerikansamoasi", "Pagopago", "Oceania", "https://flagcdn.com/w320/as.png", -14.33, -170.0, false, 3763);
Ulkeler ulke97("dosyalar/bayraklar/solomonadalari.png", "Solomonadalar", "Solomonislands", "Solomonadalari", "Honiara", "Oceania", "https://flagcdn.com/w320/sb.png", -8.0, 159.0, true, 1446);
Ulkeler ulke98("dosyalar/bayraklar/ukrayna.png", "Ukrayna", "Ukraine", "Ukrayna", "Kyiv", "Europe", "https://flagcdn.com/w320/ua.png", 49.0, 32.0, true, 146);
Ulkeler ulke99("dosyalar/bayraklar/finlandiya.png", "Finlandiya", "Finland", "Finlandiya", "Helsinki", "Europe", "https://flagcdn.com/w320/fi.png", 64.0, 26.0, true, 240);
Ulkeler ulke100("dosyalar/bayraklar/burkinafaso.png", "Burkinafaso", "Burkinafaso", "Burkinafaso", "Ouagadougou", "Africa", "https://flagcdn.com/w320/bf.png", 13.0, -2.0, true, 702);
Ulkeler ulke101("dosyalar/bayraklar/bosnahersek.png", "Bosnahersek", "Bosniaandherzegovina", "Bosnahersek", "Sarajevo", "Europe", "https://flagcdn.com/w320/ba.png", 44.0, 18.0, true, 1197);
Ulkeler ulke102("dosyalar/bayraklar/iran.png", "Ran", "Iran", "Iran", "Tehran", "Asia", "https://flagcdn.com/w320/ir.png", 32.0, 53.0, true, 2156);
Ulkeler ulke103("dosyalar/bayraklar/kuba.png", "Kba", "Cuba", "Kuba", "Havana", "Americas", "https://flagcdn.com/w320/cu.png", 21.5, -80.0, true, 1059);
Ulkeler ulke104("dosyalar/bayraklar/eritre.png", "Eritre", "Eritrea", "Eritre", "Asmara", "Africa", "https://flagcdn.com/w320/er.png", 15.0, 39.0, true, 2447);
Ulkeler ulke105("dosyalar/bayraklar/slovakya.png", "Slovakya", "Slovakia", "Slovakya", "Bratislava", "Europe", "https://flagcdn.com/w320/sk.png", 48.67, 19.5, true, 1366);
Ulkeler ulke106("dosyalar/bayraklar/litvanya.png", "Litvanya", "Lithuania", "Litvanya", "Vilnius", "Europe", "https://flagcdn.com/w320/lt.png", 56.0, 24.0, true, 151);
Ulkeler ulke107("dosyalar/bayraklar/saintmartin.png", "Saintmartin", "Saintmartin", "Saintmartin", "Marigot", "Americas", "https://flagcdn.com/w320/mf.png", 18.07, 63.05, false, 253);
Ulkeler ulke108("dosyalar/bayraklar/pitcairnadalari.png", "Pitcairnadalar", "Pitcairnislands", "Pitcairnadalari", "Adamstown", "Oceania", "https://flagcdn.com/w320/pn.png", -25.07, -130.1, false, 4822);
Ulkeler ulke109("dosyalar/bayraklar/ginebissau.png", "Ginebissau", "Guineabissau", "Ginebissau", "Bissau", "Africa", "https://flagcdn.com/w320/gw.png", 12.0, -15.0, false, 519);
Ulkeler ulke110("dosyalar/bayraklar/montserrat.png", "Montserrat", "Montserrat", "Montserrat", "Plymouth", "Americas", "https://flagcdn.com/w320/ms.png", 16.75, -62.2, false, 2440);
Ulkeler ulke111("dosyalar/bayraklar/turkiye.png", "Trkiye", "Turkey", "Turkiye", "Ankara", "Asia", "https://flagcdn.com/w320/tr.png", 39.0, 35.0, true, 947);
Ulkeler ulke112("dosyalar/bayraklar/filipinler.png", "Filipinler", "Philippines", "Filipinler", "Manila", "Asia", "https://flagcdn.com/w320/ph.png", 13.0, 122.0, true, 1665);
Ulkeler ulke113("dosyalar/bayraklar/vanuatu.png", "Vanuatu", "Vanuatu", "Vanuatu", "Portvila", "Oceania", "https://flagcdn.com/w320/vu.png", -16.0, 167.0, true, 1682);
Ulkeler ulke114("dosyalar/bayraklar/bolivya.png", "Bolivya", "Bolivia", "Bolivya", "Sucre", "Americas", "https://flagcdn.com/w320/bo.png", -17.0, -65.0, true, 3978);
Ulkeler ulke115("dosyalar/bayraklar/saintkittsvenevis.png", "Saintkittsvenevis", "Saintkittsandnevis", "Saintkittsvenevis", "Basseterre", "Americas", "https://flagcdn.com/w320/kn.png", 17.33, -62.75, true, 2098);
Ulkeler ulke116("dosyalar/bayraklar/romanya.png", "Romanya", "Romania", "Romanya", "Bucharest", "Europe", "https://flagcdn.com/w320/ro.png", 46.0, 25.0, true, 253);
Ulkeler ulke117("dosyalar/bayraklar/kambocya.png", "Kamboya", "Cambodia", "Kambocya", "Phnompenh", "Asia", "https://flagcdn.com/w320/kh.png", 13.0, 105.0, true, 2613);
Ulkeler ulke118("dosyalar/bayraklar/zimbabve.png", "Zimbabve", "Zimbabwe", "Zimbabve", "Harare", "Africa", "https://flagcdn.com/w320/zw.png", -20.0, 30.0, true, 1548);
Ulkeler ulke119("dosyalar/bayraklar/jersey.png", "Jersey", "Jersey", "Jersey", "Sainthelier", "Europe", "https://flagcdn.com/w320/je.png", 49.25, -2.17, false, 2978);
Ulkeler ulke120("dosyalar/bayraklar/kirgizistan.png", "Krgzistan", "Kyrgyzstan", "Kirgizistan", "Bishkek", "Asia", "https://flagcdn.com/w320/kg.png", 41.0, 75.0, true, 3399);
Ulkeler ulke121("dosyalar/bayraklar/karayiphollandasi.png", "Karayiphollandas", "Caribbeannetherlands", "Karayiphollandasi", "Kralendijk", "Americas", "https://flagcdn.com/w320/bq.png", 12.18, -68.25, false, 2386);
Ulkeler ulke122("dosyalar/bayraklar/guyana.png", "Guyana", "Guyana", "Guyana", "Georgetown", "Americas", "https://flagcdn.com/w320/gy.png", 5.0, -59.0, true, 1438);
Ulkeler ulke123("dosyalar/bayraklar/amerikabirlesikdevletlerikucukdisadalari.png", "Amerikabirleikdevletlerikkdadalar", "Unitedstatesminoroutlyingislands", "Amerikabirlesikdevletlerikucukdisadalari", "Washingtondc", "Americas", "https://flagcdn.com/w320/um.png", 19.3, 166.63, false, 1289);
Ulkeler ulke124("dosyalar/bayraklar/ermenistan.png", "Ermenistan", "Armenia", "Ermenistan", "Yerevan", "Asia", "https://flagcdn.com/w320/am.png", 40.0, 45.0, true, 198);
Ulkeler ulke125("dosyalar/bayraklar/lubnan.png", "Lbnan", "Lebanon", "Lubnan", "Beirut", "Asia", "https://flagcdn.com/w320/lb.png", 33.83, 35.83, true, 1239);
Ulkeler ulke126("dosyalar/bayraklar/karadag.png", "Karada", "Montenegro", "Karadag", "Podgorica", "Europe", "https://flagcdn.com/w320/me.png", 42.5, 19.3, true, 3568);
Ulkeler ulke127("dosyalar/bayraklar/gronland.png", "Grnland", "Greenland", "Gronland", "Nuuk", "Americas", "https://flagcdn.com/w320/gl.png", 72.0, -40.0, false, 1104);
Ulkeler ulke128("dosyalar/bayraklar/papuayenigine.png", "Papuayenigine", "Papuanewguinea", "Papuayenigine", "Portmoresby", "Oceania", "https://flagcdn.com/w320/pg.png", -6.0, 147.0, true, 2772);
Ulkeler ulke129("dosyalar/bayraklar/zambiya.png", "Zambiya", "Zambia", "Zambiya", "Lusaka", "Africa", "https://flagcdn.com/w320/zm.png", -15.0, 30.0, true, 1062);
Ulkeler ulke130("dosyalar/bayraklar/trinidadvetobago.png", "Trinidadvetobago", "Trinidadandtobago", "Trinidadvetobago", "Portofspain", "Americas", "https://flagcdn.com/w320/tt.png", 10.69, -61.22, true, 1236);
Ulkeler ulke131("dosyalar/bayraklar/fransizguneyveantarktikatopraklari.png", "Franszgneyveantarktikatopraklar", "Frenchsouthernandantarcticlands", "Fransizguneyveantarktikatopraklari", "Portauxfrançais", "Antarctic", "https://flagcdn.com/w320/tf.png", -49.25, 69.17, false, 1257);
Ulkeler ulke132("dosyalar/bayraklar/peru.png", "Peru", "Peru", "Peru", "Lima", "Americas", "https://flagcdn.com/w320/pe.png", -10.0, -76.0, true, 172);
Ulkeler ulke133("dosyalar/bayraklar/isvec.png", "Sve", "Sweden", "Isvec", "Stockholm", "Europe", "https://flagcdn.com/w320/se.png", 62.0, 15.0, true, 142);
Ulkeler ulke134("dosyalar/bayraklar/sudan.png", "Sudan", "Sudan", "Sudan", "Khartoum", "Africa", "https://flagcdn.com/w320/sd.png", 15.0, 30.0, true, 744);
Ulkeler ulke135("dosyalar/bayraklar/saintpierrevemiquelon.png", "Saintpierrevemiquelon", "Saintpierreandmiquelon", "Saintpierrevemiquelon", "Saintpierre", "Americas", "https://flagcdn.com/w320/pm.png", 46.83, -56.33, false, 14300);
Ulkeler ulke136("dosyalar/bayraklar/umman.png", "Umman", "Oman", "Umman", "Muscat", "Asia", "https://flagcdn.com/w320/om.png", 21.0, 57.0, true, 789);
Ulkeler ulke137("dosyalar/bayraklar/hindistan.png", "Hindistan", "India", "Hindistan", "Newdelhi", "Asia", "https://flagcdn.com/w320/in.png", 20.0, 77.0, true, 1254);
Ulkeler ulke138("dosyalar/bayraklar/tayvan.png", "Tayvan", "Taiwan", "Tayvan", "Taipei", "Asia", "https://flagcdn.com/w320/tw.png", 23.5, 121.0, false, 1352);
Ulkeler ulke139("dosyalar/bayraklar/mogolistan.png", "Moolistan", "Mongolia", "Mogolistan", "Ulanbator", "Asia", "https://flagcdn.com/w320/mn.png", 46.0, 105.0, true, 796);
Ulkeler ulke140("dosyalar/bayraklar/senegal.png", "Senegal", "Senegal", "Senegal", "Dakar", "Africa", "https://flagcdn.com/w320/sn.png", 14.0, -14.0, true, 681);
Ulkeler ulke141("dosyalar/bayraklar/tanzanya.png", "Tanzanya", "Tanzania", "Tanzanya", "Dodoma", "Africa", "https://flagcdn.com/w320/tz.png", -6.0, 35.0, true, 1191);
Ulkeler ulke142("dosyalar/bayraklar/kanada.png", "Kanada", "Canada", "Kanada", "Ottawa", "Americas", "https://flagcdn.com/w320/ca.png", 60.0, -95.0, true, 1317);
Ulkeler ulke143("dosyalar/bayraklar/kostarika.png", "Kostarika", "Costarica", "Kostarika", "Sanjosé", "Americas", "https://flagcdn.com/w320/cr.png", 10.0, -84.0, true, 1665);
Ulkeler ulke144("dosyalar/bayraklar/cin.png", "In", "China", "Cin", "Beijing", "Asia", "https://flagcdn.com/w320/cn.png", 35.0, 105.0, true, 955);
Ulkeler ulke145("dosyalar/bayraklar/kolombiya.png", "Kolombiya", "Colombia", "Kolombiya", "Bogotá", "Americas", "https://flagcdn.com/w320/co.png", 4.0, -72.0, true, 231);
Ulkeler ulke146("dosyalar/bayraklar/myanmar.png", "Myanmar", "Myanmar", "Myanmar", "Naypyidaw", "Asia", "https://flagcdn.com/w320/mm.png", 22.0, 98.0, true, 1315);
Ulkeler ulke147("dosyalar/bayraklar/rusya.png", "Rusya", "Russia", "Rusya", "Moscow", "Europe", "https://flagcdn.com/w320/ru.png", 60.0, 100.0, true, 153);
Ulkeler ulke148("dosyalar/bayraklar/kuzeykore.png", "Kuzeykore", "Northkorea", "Kuzeykore", "Pyongyang", "Asia", "https://flagcdn.com/w320/kp.png", 40.0, 127.0, true, 1133);
Ulkeler ulke149("dosyalar/bayraklar/caymanadalari.png", "Caymanadalar", "Caymanislands", "Caymanadalari", "Georgetown", "Americas", "https://flagcdn.com/w320/ky.png", 19.31, -81.25, false, 4625);
Ulkeler ulke150("dosyalar/bayraklar/bouvetadasi.png", "Bouvetadas", "Bouvetisland", "Bouvetadasi", "", "Antarctic", "https://flagcdn.com/w320/bv.png", 54.42, 3.35, false, 323);
Ulkeler ulke151("dosyalar/bayraklar/belarus.png", "Belarus", "Belarus", "Belarus", "Minsk", "Europe", "https://flagcdn.com/w320/by.png", 53.0, 28.0, true, 1717);
Ulkeler ulke152("dosyalar/bayraklar/portekiz.png", "Portekiz", "Portugal", "Portekiz", "Lisbon", "Europe", "https://flagcdn.com/w320/pt.png", 39.5, -8.0, true, 4980);
Ulkeler ulke153("dosyalar/bayraklar/esvatini.png", "Esvatini", "Eswatini", "Esvatini", "Mbabane", "Africa", "https://flagcdn.com/w320/sz.png", -26.5, 31.5, true, 2803);
Ulkeler ulke154("dosyalar/bayraklar/polonya.png", "Polonya", "Poland", "Polonya", "Warsaw", "Europe", "https://flagcdn.com/w320/pl.png", 52.0, 20.0, true, 119);
Ulkeler ulke155("dosyalar/bayraklar/isvicre.png", "Svire", "Switzerland", "Isvicre", "Bern", "Europe", "https://flagcdn.com/w320/ch.png", 47.0, 8.0, true, 154);
Ulkeler ulke156("dosyalar/bayraklar/kongocumhuriyeti.png", "Kongocumhuriyeti", "Republicofthecongo", "Kongocumhuriyeti", "Brazzaville", "Africa", "https://flagcdn.com/w320/cg.png", -1.0, 15.0, true, 980);
Ulkeler ulke157("dosyalar/bayraklar/venezuela.png", "Venezuela", "Venezuela", "Venezuela", "Caracas", "Americas", "https://flagcdn.com/w320/ve.png", 8.0, -66.0, true, 906);
Ulkeler ulke158("dosyalar/bayraklar/panama.png", "Panama", "Panama", "Panama", "Panamacity", "Americas", "https://flagcdn.com/w320/pa.png", 9.0, -80.0, true, 1123);
Ulkeler ulke159("dosyalar/bayraklar/hollanda.png", "Hollanda", "Netherlands", "Hollanda", "Amsterdam", "Europe", "https://flagcdn.com/w320/nl.png", 52.5, 5.75, true, 153);
Ulkeler ulke160("dosyalar/bayraklar/bagimsizsamoadevleti.png", "Bamszsamoadevleti", "Samoa", "Bagimsizsamoadevleti", "Apia", "Oceania", "https://flagcdn.com/w320/ws.png", -13.58, -172.33, true, 699);
Ulkeler ulke161("dosyalar/bayraklar/danimarka.png", "Danimarka", "Denmark", "Danimarka", "Copenhagen", "Europe", "https://flagcdn.com/w320/dk.png", 56.0, 10.0, true, 292);
Ulkeler ulke162("dosyalar/bayraklar/luksemburg.png", "Lksemburg", "Luxembourg", "Luksemburg", "Luxembourg", "Europe", "https://flagcdn.com/w320/lu.png", 49.75, 6.17, true, 151);
Ulkeler ulke163("dosyalar/bayraklar/faroeadalari.png", "Faroeadalar", "Faroeislands", "Faroeadalari", "Tórshavn", "Europe", "https://flagcdn.com/w320/fo.png", 62.0, -7.0, false, 321);
Ulkeler ulke164("dosyalar/bayraklar/slovenya.png", "Slovenya", "Slovenia", "Slovenya", "Ljubljana", "Europe", "https://flagcdn.com/w320/si.png", 46.12, 14.82, true, 930);
Ulkeler ulke165("dosyalar/bayraklar/togo.png", "Togo", "Togo", "Togo", "Lomé", "Africa", "https://flagcdn.com/w320/tg.png", 8.0, 1.17, true, 751);
Ulkeler ulke166("dosyalar/bayraklar/tayland.png", "Tayland", "Thailand", "Tayland", "Bangkok", "Asia", "https://flagcdn.com/w320/th.png", 15.0, 100.0, true, 172);
Ulkeler ulke167("dosyalar/bayraklar/wallisvefutunaadalaribolgesi.png", "Wallisvefutunaadalarblgesi", "Wallisandfutuna", "Wallisvefutunaadalaribolgesi", "Matautu", "Oceania", "https://flagcdn.com/w320/wf.png", -13.3, -176.2, false, 669);
Ulkeler ulke168("dosyalar/bayraklar/bahamalar.png", "Bahamalar", "Bahamas", "Bahamalar", "Nassau", "Americas", "https://flagcdn.com/w320/bs.png", 25.03, -77.4, true, 735);
Ulkeler ulke169("dosyalar/bayraklar/tonga.png", "Tonga", "Tonga", "Tonga", "Nukualofa", "Oceania", "https://flagcdn.com/w320/to.png", -20.0, -175.0, true, 163);
Ulkeler ulke170("dosyalar/bayraklar/yunanistan.png", "Yunanistan", "Greece", "Yunanistan", "Athens", "Europe", "https://flagcdn.com/w320/gr.png", 39.0, 22.0, true, 306);
Ulkeler ulke171("dosyalar/bayraklar/sanmarino.png", "Sanmarino", "Sanmarino", "Sanmarino", "Cityofsanmarino", "Europe", "https://flagcdn.com/w320/sm.png", 43.77, 12.42, true, 7872);
Ulkeler ulke172("dosyalar/bayraklar/reunion.png", "Reunion", "Reunion", "Reunion", "Saintdenis", "Africa", "https://flagcdn.com/w320/re.png", -21.15, 55.5, false, 2106);
Ulkeler ulke173("dosyalar/bayraklar/vatikan.png", "Vatikan", "Vaticancity", "Vatikan", "Vaticancity", "Europe", "https://flagcdn.com/w320/va.png", 41.9, 12.45, false, 7956);
Ulkeler ulke174("dosyalar/bayraklar/burundi.png", "Burundi", "Burundi", "Burundi", "Gitega", "Africa", "https://flagcdn.com/w320/bi.png", -3.5, 30.0, true, 1841);
Ulkeler ulke175("dosyalar/bayraklar/bahreyn.png", "Bahreyn", "Bahrain", "Bahreyn", "Manama", "Asia", "https://flagcdn.com/w320/bh.png", 26.0, 50.55, true, 827);
Ulkeler ulke176("dosyalar/bayraklar/marshalladalari.png", "Marshalladalar", "Marshallislands", "Marshalladalari", "Majuro", "Oceania", "https://flagcdn.com/w320/mh.png", 9.0, 168.0, true, 2699);
Ulkeler ulke177("dosyalar/bayraklar/turksvecaicosadalari.png", "Turksvecaicosadalar", "Turksandcaicosislands", "Turksvecaicosadalari", "Cockburntown", "Americas", "https://flagcdn.com/w320/tc.png", 21.75, -71.58, false, 2293);
Ulkeler ulke178("dosyalar/bayraklar/manadasi.png", "Manadas", "Isleofman", "Manadasi", "Douglas", "Europe", "https://flagcdn.com/w320/im.png", 54.25, -4.5, false, 2201);
Ulkeler ulke179("dosyalar/bayraklar/haiti.png", "Haiti", "Haiti", "Haiti", "Portauprince", "Americas", "https://flagcdn.com/w320/ht.png", 19.0, -72.42, true, 1972);
Ulkeler ulke180("dosyalar/bayraklar/afganistan.png", "Afganistan", "Afghanistan", "Afganistan", "Kabul", "Asia", "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_the_Taliban.svg/320px-Flag_of_the_Taliban.svg.png", 33.0, 65.0, true, 8285);
Ulkeler ulke181("dosyalar/bayraklar/israil.png", "Srail", "Israel", "Israil", "Jerusalem", "Asia", "https://flagcdn.com/w320/il.png", 31.47, 35.13, true, 893);
Ulkeler ulke182("dosyalar/bayraklar/libya.png", "Libya", "Libya", "Libya", "Tripoli", "Africa", "https://flagcdn.com/w320/ly.png", 25.0, 17.0, true, 579);
Ulkeler ulke183("dosyalar/bayraklar/uruguay.png", "Uruguay", "Uruguay", "Uruguay", "Montevideo", "Americas", "https://flagcdn.com/w320/uy.png", -33.0, -56.0, true, 2392);
Ulkeler ulke184("dosyalar/bayraklar/norfolkadasi.png", "Norfolkadas", "Norfolkisland", "Norfolkadasi", "Kingston", "Oceania", "https://flagcdn.com/w320/nf.png", -29.03, 167.95, false, 2349);
Ulkeler ulke185("dosyalar/bayraklar/nikaragua.png", "Nikaragua", "Nicaragua", "Nikaragua", "Managua", "Americas", "https://flagcdn.com/w320/ni.png", 13.0, -85.0, true, 1481);
Ulkeler ulke186("dosyalar/bayraklar/cookadalari.png", "Cookadalar", "Cookislands", "Cookadalari", "Avarua", "Oceania", "https://flagcdn.com/w320/ck.png", -21.23, -159.77, false, 2699);
Ulkeler ulke187("dosyalar/bayraklar/laos.png", "Laos", "Laos", "Laos", "Vientiane", "Asia", "https://flagcdn.com/w320/la.png", 18.0, 105.0, true, 666);
Ulkeler ulke188("dosyalar/bayraklar/christmasadasi.png", "Christmasadas", "Christmasisland", "Christmasadasi", "Flyingfishcove", "Oceania", "https://flagcdn.com/w320/cx.png", -10.5, 105.67, false, 2256);
Ulkeler ulke189("dosyalar/bayraklar/sainthelena.png", "Sainthelena", "Sainthelenaascensionandtristandacunha", "Sainthelena", "Jamestown", "Africa", "https://flagcdn.com/w320/sh.png", -15.95, -5.72, false, 2484);
Ulkeler ulke190("dosyalar/bayraklar/anguilla.png", "Anguilla", "Anguilla", "Anguilla", "Thevalley", "Americas", "https://flagcdn.com/w320/ai.png", 18.25, -63.17, false, 1929);
Ulkeler ulke191("dosyalar/bayraklar/mikronezya.png", "Mikronezya", "Micronesia", "Mikronezya", "Palikir", "Oceania", "https://flagcdn.com/w320/fm.png", 6.92, 158.25, true, 676);
Ulkeler ulke192("dosyalar/bayraklar/almanya.png", "Almanya", "Germany", "Almanya", "Berlin", "Europe", "https://flagcdn.com/w320/de.png", 51.0, 9.0, true, 151);
Ulkeler ulke193("dosyalar/bayraklar/guam.png", "Guam", "Guam", "Guam", "Hagåtña", "Oceania", "https://flagcdn.com/w320/gu.png", 13.47, 144.78, false, 2205);
Ulkeler ulke194("dosyalar/bayraklar/kiribati.png", "Kiribati", "Kiribati", "Kiribati", "Southtarawa", "Oceania", "https://flagcdn.com/w320/ki.png", 1.42, 173.0, true, 3872);
Ulkeler ulke195("dosyalar/bayraklar/sintmaarten.png", "Sintmaarten", "Sintmaarten", "Sintmaarten", "Philipsburg", "Americas", "https://flagcdn.com/w320/sx.png", 18.03, -63.05, false, 3972);
Ulkeler ulke196("dosyalar/bayraklar/ispanya.png", "Spanya", "Spain", "Ispanya", "Madrid", "Europe", "https://flagcdn.com/w320/es.png", 40.0, -4.0, true, 3623);
Ulkeler ulke197("dosyalar/bayraklar/jamaika.png", "Jamaika", "Jamaica", "Jamaika", "Kingston", "Americas", "https://flagcdn.com/w320/jm.png", 18.25, -77.5, true, 972);
Ulkeler ulke198("dosyalar/bayraklar/filistin.png", "Filistin", "Palestine", "Filistin", "Ramallahjerusalem", "Asia", "https://flagcdn.com/w320/ps.png", 31.9, 35.2, false, 689);
Ulkeler ulke199("dosyalar/bayraklar/fransizguyanasi.png", "Franszguyanas", "Frenchguiana", "Fransizguyanasi", "Cayenne", "Americas", "https://flagcdn.com/w320/gf.png", 4.0, -53.0, false, 1316);
Ulkeler ulke200("dosyalar/bayraklar/andorra.png", "Andorra", "Andorra", "Andorra", "Andorralavella", "Europe", "https://flagcdn.com/w320/ad.png", 42.5, 1.5, true, 3895);
Ulkeler ulke201("dosyalar/bayraklar/sili.png", "Ili", "Chile", "Sili", "Santiago", "Americas", "https://flagcdn.com/w320/cl.png", -30.0, -71.0, true, 578);
Ulkeler ulke202("dosyalar/bayraklar/lesotho.png", "Lesotho", "Lesotho", "Lesotho", "Maseru", "Africa", "https://flagcdn.com/w320/ls.png", -29.5, 28.5, true, 1065);
Ulkeler ulke203("dosyalar/bayraklar/avustralya.png", "Avustralya", "Australia", "Avustralya", "Canberra", "Oceania", "https://flagcdn.com/w320/au.png", -27.0, 133.0, true, 1618);
Ulkeler ulke204("dosyalar/bayraklar/grenada.png", "Grenada", "Grenada", "Grenada", "Stgeorges", "Americas", "https://flagcdn.com/w320/gd.png", 12.12, -61.67, true, 1950);
Ulkeler ulke205("dosyalar/bayraklar/gana.png", "Gana", "Ghana", "Gana", "Accra", "Africa", "https://flagcdn.com/w320/gh.png", 8.0, -2.0, true, 639);
Ulkeler ulke206("dosyalar/bayraklar/seyseller.png", "Seyeller", "Seychelles", "Seyseller", "Victoria", "Africa", "https://flagcdn.com/w320/sc.png", -4.58, 55.67, true, 1411);
Ulkeler ulke207("dosyalar/bayraklar/angola.png", "Angola", "Angola", "Angola", "Luanda", "Africa", "https://flagcdn.com/w320/ao.png", -12.5, 18.5, true, 1581);
Ulkeler ulke208("dosyalar/bayraklar/bermuda.png", "Bermuda", "Bermuda", "Bermuda", "Hamilton", "Americas", "https://flagcdn.com/w320/bm.png", 32.33, -64.75, false, 3942);
Ulkeler ulke209("dosyalar/bayraklar/pakistan.png", "Pakistan", "Pakistan", "Pakistan", "Islamabad", "Asia", "https://flagcdn.com/w320/pk.png", 30.0, 70.0, true, 1281);
Ulkeler ulke210("dosyalar/bayraklar/mali.png", "Mali", "Mali", "Mali", "Bamako", "Africa", "https://flagcdn.com/w320/ml.png", 17.0, -4.0, true, 253);
Ulkeler ulke211("dosyalar/bayraklar/suudiarabistan.png", "Suudiarabistan", "Saudiarabia", "Suudiarabistan", "Riyadh", "Asia", "https://flagcdn.com/w320/sa.png", 25.0, 45.0, true, 3003);
Ulkeler ulke212("dosyalar/bayraklar/curacao.png", "Curaao", "Curaçao", "Curacao", "Willemstad", "Americas", "https://flagcdn.com/w320/cw.png", 12.12, -68.93, false, 643);
Ulkeler ulke213("dosyalar/bayraklar/guneykore.png", "Gneykore", "Southkorea", "Guneykore", "Seoul", "Asia", "https://flagcdn.com/w320/kr.png", 37.0, 127.5, true, 2667);
Ulkeler ulke214("dosyalar/bayraklar/etiyopya.png", "Etiyopya", "Ethiopia", "Etiyopya", "Addisababa", "Africa", "https://flagcdn.com/w320/et.png", 8.0, 38.0, true, 1887);
Ulkeler ulke215("dosyalar/bayraklar/guadeloupe.png", "Guadeloupe", "Guadeloupe", "Guadeloupe", "Basseterre", "Americas", "https://flagcdn.com/w320/gp.png", 16.25, -61.58, false, 5294);
Ulkeler ulke216("dosyalar/bayraklar/banglades.png", "Banglade", "Bangladesh", "Banglades", "Dhaka", "Asia", "https://flagcdn.com/w320/bd.png", 24.0, 90.0, true, 807);
Ulkeler ulke217("dosyalar/bayraklar/yenizelanda.png", "Yenizelanda", "Newzealand", "Yenizelanda", "Wellington", "Oceania", "https://flagcdn.com/w320/nz.png", -41.0, 174.0, true, 1564);
Ulkeler ulke218("dosyalar/bayraklar/komorlar.png", "Komorlar", "Comoros", "Komorlar", "Moroni", "Africa", "https://flagcdn.com/w320/km.png", -12.17, 44.25, true, 1587);
Ulkeler ulke219("dosyalar/bayraklar/belize.png", "Belize", "Belize", "Belize", "Belmopan", "Americas", "https://flagcdn.com/w320/bz.png", 17.25, -88.75, true, 6797);
Ulkeler ulke220("dosyalar/bayraklar/uganda.png", "Uganda", "Uganda", "Uganda", "Kampala", "Africa", "https://flagcdn.com/w320/ug.png", 1.0, 32.0, true, 1457);
Ulkeler ulke221("dosyalar/bayraklar/singapur.png", "Singapur", "Singapore", "Singapur", "Singapore", "Asia", "https://flagcdn.com/w320/sg.png", 1.37, 103.8, true, 974);
Ulkeler ulke222("dosyalar/bayraklar/lihtenstayn.png", "Lihtentayn", "Liechtenstein", "Lihtenstayn", "Vaduz", "Europe", "https://flagcdn.com/w320/li.png", 47.27, 9.53, true, 1336);
Ulkeler ulke223("dosyalar/bayraklar/macaristan.png", "Macaristan", "Hungary", "Macaristan", "Budapest", "Europe", "https://flagcdn.com/w320/hu.png", 47.0, 20.0, true, 199);
Ulkeler ulke224("dosyalar/bayraklar/izlanda.png", "Zlanda", "Iceland", "Izlanda", "Reykjavik", "Europe", "https://flagcdn.com/w320/is.png", 65.0, -18.0, true, 330);
Ulkeler ulke225("dosyalar/bayraklar/tacikistan.png", "Tacikistan", "Tajikistan", "Tacikistan", "Dushanbe", "Asia", "https://flagcdn.com/w320/tj.png", 39.0, 71.0, true, 874);
Ulkeler ulke226("dosyalar/bayraklar/namibya.png", "Namibya", "Namibia", "Namibya", "Windhoek", "Africa", "https://flagcdn.com/w320/na.png", -22.0, 17.0, true, 1896);
Ulkeler ulke227("dosyalar/bayraklar/dogutimor.png", "Doutimor", "Timorleste", "Dogutimor", "Dili", "Asia", "https://flagcdn.com/w320/tl.png", -8.83, 125.92, true, 1305);
Ulkeler ulke228("dosyalar/bayraklar/misir.png", "Msr", "Egypt", "Misir", "Cairo", "Africa", "https://flagcdn.com/w320/eg.png", 27.0, 30.0, true, 1198);
Ulkeler ulke229("dosyalar/bayraklar/sirbistan.png", "Srbistan", "Serbia", "Sirbistan", "Belgrade", "Europe", "https://flagcdn.com/w320/rs.png", 44.0, 21.0, true, 6204);
Ulkeler ulke230("dosyalar/bayraklar/mauritius.png", "Mauritius", "Mauritius", "Mauritius", "Portlouis", "Africa", "https://flagcdn.com/w320/mu.png", -20.28, 57.55, true, 245);
Ulkeler ulke231("dosyalar/bayraklar/makao.png", "Makao", "Macau", "Makao", "", "Asia", "https://flagcdn.com/w320/mo.png", 22.17, 113.55, false, 2255);
Ulkeler ulke232("dosyalar/bayraklar/fransizpolinezyasi.png", "Franszpolinezyas", "Frenchpolynesia", "Fransizpolinezyasi", "Papeete", "Oceania", "https://flagcdn.com/w320/pf.png", 17.68, 149.41, false, 2561);
Ulkeler ulke233("dosyalar/bayraklar/maldivler.png", "Maldivler", "Maldives", "Maldivler", "Malé", "Asia", "https://flagcdn.com/w320/mv.png", 3.25, 73.0, true, 704);
Ulkeler ulke234("dosyalar/bayraklar/endonezya.png", "Endonezya", "Indonesia", "Endonezya", "Jakarta", "Asia", "https://flagcdn.com/w320/id.png", -5.0, 120.0, true, 146);
Ulkeler ulke235("dosyalar/bayraklar/kongodemokratikcumhuriyeti.png", "Kongodemokratikcumhuriyeti", "Drcongo", "Kongodemokratikcumhuriyeti", "Kinshasa", "Africa", "https://flagcdn.com/w320/cd.png", 0.0, 25.0, true, 1486);
Ulkeler ulke236("dosyalar/bayraklar/estonya.png", "Estonya", "Estonia", "Estonya", "Tallinn", "Europe", "https://flagcdn.com/w320/ee.png", 59.0, 26.0, true, 153);
Ulkeler ulke237("dosyalar/bayraklar/vietnam.png", "Vietnam", "Vietnam", "Vietnam", "Hanoi", "Asia", "https://flagcdn.com/w320/vn.png", 16.17, 107.83, true, 913);
Ulkeler ulke238("dosyalar/bayraklar/italya.png", "Talya", "Italy", "Italya", "Rome", "Europe", "https://flagcdn.com/w320/it.png", 42.83, 12.83, true, 253);
Ulkeler ulke239("dosyalar/bayraklar/gine.png", "Gine", "Guinea", "Gine", "Conakry", "Africa", "https://flagcdn.com/w320/gn.png", 11.0, -10.0, true, 253);
Ulkeler ulke240("dosyalar/bayraklar/cad.png", "Ad", "Chad", "Cad", "Ndjamena", "Africa", "https://flagcdn.com/w320/td.png", 15.0, 19.0, true, 253);
Ulkeler ulke241("dosyalar/bayraklar/ekvador.png", "Ekvador", "Ecuador", "Ekvador", "Quito", "Americas", "https://flagcdn.com/w320/ec.png", -2.0, -77.5, true, 5052);
Ulkeler ulke242("dosyalar/bayraklar/gurcistan.png", "Grcistan", "Georgia", "Gurcistan", "Tbilisi", "Asia", "https://flagcdn.com/w320/ge.png", 42.0, 43.5, true, 1046);
Ulkeler ulke243("dosyalar/bayraklar/malavi.png", "Malavi", "Malawi", "Malavi", "Lilongwe", "Africa", "https://flagcdn.com/w320/mw.png", -13.5, 34.0, true, 1467);
Ulkeler ulke244("dosyalar/bayraklar/irak.png", "Irak", "Iraq", "Irak", "Baghdad", "Asia", "https://flagcdn.com/w320/iq.png", 33.0, 44.0, true, 789);
Ulkeler ulke245("dosyalar/bayraklar/svalbardvejanmayen.png", "Svalbardvejanmayen", "Svalbardandjanmayen", "Svalbardvejanmayen", "Longyearbyen", "Europe", "https://flagcdn.com/w320/sj.png", 78.0, 20.0, false, 323);
Ulkeler ulke246("dosyalar/bayraklar/benin.png", "Benin", "Benin", "Benin", "Portonovo", "Africa", "https://flagcdn.com/w320/bj.png", 9.5, 2.25, true, 176);
Ulkeler ulke247("dosyalar/bayraklar/japonya.png", "Japonya", "Japan", "Japonya", "Tokyo", "Asia", "https://flagcdn.com/w320/jp.png", 36.0, 138.0, true, 932);
Ulkeler ulke248("dosyalar/bayraklar/dominikcumhuriyeti.png", "Dominikcumhuriyeti", "Dominicanrepublic", "Dominikcumhuriyeti", "Santodomingo", "Americas", "https://flagcdn.com/w320/do.png", 19.0, -70.67, true, 1658);
Ulkeler ulke249("dosyalar/bayraklar/katar.png", "Katar", "Qatar", "Katar", "Doha", "Asia", "https://flagcdn.com/w320/qa.png", 25.5, 51.25, true, 336);
Ulkeler ulke250("dosyalar/bayraklar/gabon.png", "Gabon", "Gabon", "Gabon", "Libreville", "Africa", "https://flagcdn.com/w320/ga.png", -1.0, 11.75, true, 161);
array<Ulkeler, 250> ulke = { ulke1, ulke2, ulke3, ulke4, ulke5, ulke6, ulke7, ulke8, ulke9, ulke10, ulke11, ulke12, ulke13, ulke14, ulke15, ulke16, ulke17, ulke18, ulke19, ulke20, ulke21, ulke22, ulke23, ulke24, ulke25, ulke26, ulke27, ulke28, ulke29, ulke30, ulke31, ulke32, ulke33, ulke34, ulke35, ulke36, ulke37, ulke38, ulke39, ulke40, ulke41, ulke42, ulke43, ulke44, ulke45, ulke46, ulke47, ulke48, ulke49, ulke50, ulke51, ulke52, ulke53, ulke54, ulke55, ulke56, ulke57, ulke58, ulke59, ulke60, ulke61, ulke62, ulke63, ulke64, ulke65, ulke66, ulke67, ulke68, ulke69, ulke70, ulke71, ulke72, ulke73, ulke74, ulke75, ulke76, ulke77, ulke78, ulke79, ulke80, ulke81, ulke82, ulke83, ulke84, ulke85, ulke86, ulke87, ulke88, ulke89, ulke90, ulke91, ulke92, ulke93, ulke94, ulke95, ulke96, ulke97, ulke98, ulke99, ulke100, ulke101, ulke102, ulke103, ulke104, ulke105, ulke106, ulke107, ulke108, ulke109, ulke110, ulke111, ulke112, ulke113, ulke114, ulke115, ulke116, ulke117, ulke118, ulke119, ulke120, ulke121, ulke122, ulke123, ulke124, ulke125, ulke126, ulke127, ulke128, ulke129, ulke130, ulke131, ulke132, ulke133, ulke134, ulke135, ulke136, ulke137, ulke138, ulke139, ulke140, ulke141, ulke142, ulke143, ulke144, ulke145, ulke146, ulke147, ulke148, ulke149, ulke150, ulke151, ulke152, ulke153, ulke154, ulke155, ulke156, ulke157, ulke158, ulke159, ulke160, ulke161, ulke162, ulke163, ulke164, ulke165, ulke166, ulke167, ulke168, ulke169, ulke170, ulke171, ulke172, ulke173, ulke174, ulke175, ulke176, ulke177, ulke178, ulke179, ulke180, ulke181, ulke182, ulke183, ulke184, ulke185, ulke186, ulke187, ulke188, ulke189, ulke190, ulke191, ulke192, ulke193, ulke194, ulke195, ulke196, ulke197, ulke198, ulke199, ulke200, ulke201, ulke202, ulke203, ulke204, ulke205, ulke206, ulke207, ulke208, ulke209, ulke210, ulke211, ulke212, ulke213, ulke214, ulke215, ulke216, ulke217, ulke218, ulke219, ulke220, ulke221, ulke222, ulke223, ulke224, ulke225, ulke226, ulke227, ulke228, ulke229, ulke230, ulke231, ulke232, ulke233, ulke234, ulke235, ulke236, ulke237, ulke238, ulke239, ulke240, ulke241, ulke242, ulke243, ulke244, ulke245, ulke246, ulke247, ulke248, ulke249, ulke250 };
//-------------------------------------------------------------------------------------------------------------------------
bool amerikakitasi = true, asyakitasi = true, afrikakitasi = true, avrupakitasi = true, okyanusyakitasi = true, antartikakitasi = true, bmuyeligi = true;
void yaz(bool& amerikakitasi, bool& asyakitasi, bool& afrikakitasi, bool& avrupakitasi, bool& okyanusyakitasi, bool& antartikakitasi, bool& bmuyeligi, const string& dosyaAdi) {
	ofstream dosya(dosyaAdi);  dosya << amerikakitasi << endl << asyakitasi << endl << afrikakitasi << endl << avrupakitasi << endl << okyanusyakitasi << endl << antartikakitasi << endl << bmuyeligi << endl; }
void oku(bool& amerikakitasi, bool& asyakitasi, bool& afrikakitasi, bool& avrupakitasi, bool& okyanusyakitasi, bool& antartikakitasi, bool& bmuyeligi, const string& dosyaAdi) {
	ifstream dosya(dosyaAdi); dosya >> amerikakitasi >> asyakitasi >> afrikakitasi >> avrupakitasi >> okyanusyakitasi >> antartikakitasi >> bmuyeligi; }
void download(const string& url, const string& file, const bool& kesinlik, const int& dosyaboyut) {
	create_directories(path(file).parent_path());
	if (kesinlik || (!exists(file)) || (dosyaboyut != 0 && dosyaboyut != file_size(file))) 
		system(("powershell -Command \"Invoke-WebRequest -Uri '" + url + "' -OutFile '" + file + "'\"").c_str());
}
void endGameMenu(sf::RenderWindow& window, sf::Event& event, std::string& komut, std::string& yazilanlar, sf::Text& text, sf::Sprite& sprite, bool& oyun, int winstreak, int toplampuan) {
	yazilanlar += "Oyun Bitti\tYapan Kerem Kuyucu\n";
	yazilanlar += "Dogru Sayiniz: " + std::to_string(winstreak) + "\n";
	yazilanlar += "Puaniniz: " + std::to_string(toplampuan) + "\n";
	yazilanlar += "Websiteme bakmak istermisin: (Evet/Hayir)\n";
	text.setString(yazilanlar);
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Texture texture; if (!texture.loadFromFile("dosyalar/arkaplan.png")) { download("https://drive.usercontent.google.com/download?id=1RDknWZSI6vPpCqL5NvCPohnWTG9T2_mW", "dosyalar\\arkaplan.png", 0, 66286); };
	sf::Sprite sprite2(texture);
	sf::Text menuText;
	string menuMetni;
	int secim = 0;
	menuText.setFont(font);
	menuText.setCharacterSize(40);
	menuText.setFillColor(sf::Color::Black);
	menuText.setPosition(10, 10);
	window.clear();
	window.draw(sprite);
	window.draw(text);
	window.display();
	komut = "";
	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed) {
				window.close();
				komut = "Kapat";
			}
			if (event.type == sf::Event::KeyPressed) {
				if (event.key.code == sf::Keyboard::Up) {
					secim--;
					if (secim < 0) secim = 1;
				}
				else if (event.key.code == sf::Keyboard::Down) {
					secim++;
					if (secim >= 2) secim = 0;
				}
				else if (event.key.code == sf::Keyboard::Return) {
					window.close();
					switch (secim) {
					case 0: komut = "Evet"; break;
					case 1: komut = "Hayir"; break;
					}
				}
			}
		}
		for (size_t i = 0; i < 2; ++i) {
			if (i == secim) 
				menuMetni += "> ";
			else 
				menuMetni += "  ";
			menuMetni += (i == 0 ? "Evet\n" : "Hayir\n");
		}
		window.clear(sf::Color(30, 30, 30)); // Arka plan rengi
		menuText.setString(yazilanlar + menuMetni);
		window.draw(sprite2);
		window.draw(menuText);
		window.display();
	}
	if (komut == "Evet")
		system("start https://geogame.glitch.me");
	oyun = 0;
}
void ulkekurallari() {
	sf::Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) { download("https://drive.usercontent.google.com/download?id=1lfBSgz9ja7oSyLb3XQBbbMLDm_vzchRg", "dosyalar\\sesler\\yanlis.ogg", 0, 10769); };
	oku(amerikakitasi, asyakitasi, afrikakitasi, avrupakitasi, okyanusyakitasi, antartikakitasi, bmuyeligi, "dosyalar/ulkekurallari.txt");
	sf::Event event;
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Text text("Text", font, 40);
	std::vector<std::string> secenekler = { "Amerika Kitasi", "Asya Kitasi", "Afrika Kitasi", "Avrupa Kitasi", "Okyanusya Kitasi", "Antartika Kitasi", "Birlesmis Milletler Uyeligi", "Ayarlari Kapatmak Icin seciniz" };
	bool oyun = true;
	int secim = 0, a = 0;
	int ulkesayisi = 0;
	while (oyun) {
		sf::RenderWindow window(sf::VideoMode(800, 500), "GeoGame");
		while (window.isOpen()) {
			while (window.pollEvent(event)) {
				if (event.type == sf::Event::Closed) {
					if (ulkesayisi < 10) {
						window.close();
						yanlis.play();
					}
					else {
						window.close();
						oyun = false;
						break;
					}
				}
				if (event.type == sf::Event::KeyPressed) {
					if (event.key.code == sf::Keyboard::Up || event.key.code == sf::Keyboard::Left) {
						secim--;
						if (secim < 0) secim = static_cast<int>(secenekler.size()) - 1;
					}
					else if (event.key.code == sf::Keyboard::Down || event.key.code == sf::Keyboard::Right) {
						secim++;
						if (secim >= secenekler.size()) secim = 0;
					}
					else if (event.key.code == sf::Keyboard::Return) {
						window.close();
						switch (secim) {
						case 0: amerikakitasi = !amerikakitasi; break;
						case 1: asyakitasi = !asyakitasi; break;
						case 2: afrikakitasi = !afrikakitasi; break;
						case 3: avrupakitasi = !avrupakitasi; break;
						case 4: okyanusyakitasi = !okyanusyakitasi; break;
						case 5: antartikakitasi = !antartikakitasi; break;
						case 6: bmuyeligi = !bmuyeligi; break;
						case 7:
							if (ulkesayisi < 10) {
								yanlis.play();
							}
							else {
								window.close();
								oyun = false;
								break;
							}
						}
					}
					if (event.key.code >= sf::Keyboard::Num1 && event.key.code <= sf::Keyboard::Num8) 
						secim = event.key.code - sf::Keyboard::Num1;
				}
			}
			window.clear(sf::Color(30, 30, 30)); // Arka plan rengi
			ulkesayisi = 0;
			for (int i = 0; i < ulke.size(); i++) {
				if (((amerikakitasi && ulke[i].kita == "Americas") ||
					(asyakitasi && ulke[i].kita == "Asia") ||
					(afrikakitasi && ulke[i].kita == "Africa") ||
					(avrupakitasi && ulke[i].kita == "Europe") ||
					(okyanusyakitasi && ulke[i].kita == "Oceania") ||
					(antartikakitasi && ulke[i].kita == "Antarctic")
					) && (bmuyeligi ? true : ulke[i].bm ))
				{
					ulkesayisi++;
				}
			}
			text.setString(ulkesayisi<10 ? "Secilen ulke sayisi 10 dan az olamaz." : "Ayarlar ----(Sari ise aktiftir)---->");
			if (ulkesayisi < 10) {
				text.setFillColor(sf::Color(255, 165, 0));
			}
			else {
				text.setFillColor(sf::Color::Blue);
			}
			text.setPosition(10, 0); // adjust position as needed
			window.draw(text);
			text.setString("Seçeneklere Uyan Ulke Sayisi: " + to_string(ulkesayisi));
			text.setFillColor(sf::Color::Magenta);
			text.setPosition(10, 50); // adjust position as needed
			window.draw(text);
			std::vector<bool> kurallar = { amerikakitasi, asyakitasi, afrikakitasi, avrupakitasi, okyanusyakitasi, antartikakitasi, bmuyeligi};
			for (int i = 0; i < secenekler.size(); ++i) {
				text.setString(((secim == i) ? " >  " : "") + secenekler[i]);
				text.setPosition(10, 100 + static_cast<float>(i) * 50);
				if (i == secenekler.size() - 1)
					text.setFillColor(sf::Color::White);
				else if (kurallar[i]==false)
					text.setFillColor(sf::Color::Red);
				else
					text.setFillColor(sf::Color::Green);
				window.draw(text);
			}
			window.display();
		}
	}
	yaz(amerikakitasi, asyakitasi, afrikakitasi, avrupakitasi, okyanusyakitasi, antartikakitasi, bmuyeligi, "dosyalar/ulkekurallari.txt");
}
double mesafehesapla(const double& latitude1, const double& longitude1, const double& latitude2, const double& longitude2) {
	const double PI = 3.14159265358979323846264338327950288;
	double theta = longitude1 - longitude2;
	double distance = acos(sin(latitude1 * PI / 180.0) * sin(latitude2 * PI / 180.0) +
		cos(latitude1 * PI / 180.0) * cos(latitude2 * PI / 180.0) * cos(theta * PI / 180.0)) * 180.0 / PI;
	distance *= 60 * 1.1515 * 1.609344;
	return round(distance);
}
string Pusula(double lat1, double lon1, double lat2, double lon2) {
	const double PI = 3.14159265358979323846264338327950288;
	lat1 *= PI / 180.0;
	lon1 *= PI / 180.0;
	lat2 *= PI / 180.0;
	lon2 *= PI / 180.0;
	double brng = fmod(atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)) * 180 / PI + 360, 360);
	const char* yonler[] = { "Kuzey", "Kuzeydogu", "Dogu", "Guneydogu", "Guney", "Guneybati", "Bati", "Kuzeybati" };
	return (brng < 0 || brng >= 360) ? "Geçersiz derece değeri" : yonler[static_cast<int>((brng + 22.5) / 45.0) % 8];
}
string kelimeDuzelt(const string& kelime) {
	string sonuc;
	for (char karakter : kelime) {
		if (isalpha(karakter))
			sonuc += (sonuc.empty()) ? toupper(karakter) : tolower(karakter);
	}
	return sonuc;
}
string bulunanBenzerUlke(const string& komut) {
	int en_yuksek_benzerlik = 0;
	string en_benzer_ulke;
	string duzeltilmis_komut = kelimeDuzelt(komut);
	for (const auto& ulke : ulke) {
		const string& ulke_isim = ulke.isim;
		const string& ulke_trisim = ulke.trisim;
		const string& ulke_enisim = ulke.enisim;
		auto benzerlik = [&](const string& ulke_ad) {
			int benzerlik_degeri = 0;
			for (size_t i = 0; i < duzeltilmis_komut.size(); ++i) {
				if (i < ulke_ad.size() && tolower(duzeltilmis_komut[i]) == tolower(ulke_ad[i]))  benzerlik_degeri++;
				else break;
			}
			return benzerlik_degeri;
			};

		int benzerlik_toplam = benzerlik(ulke_isim) + benzerlik(ulke_trisim) + benzerlik(ulke_enisim);
		if (benzerlik_toplam > en_yuksek_benzerlik) {
			en_yuksek_benzerlik = benzerlik_toplam;
			en_benzer_ulke = ulke_isim;
		}
	}
	if (duzeltilmis_komut == "Pas" || duzeltilmis_komut == "Bitir" || duzeltilmis_komut == "Kapat" || duzeltilmis_komut == "Ayarlar" || duzeltilmis_komut == "Temizle") 
		return duzeltilmis_komut;
	return en_benzer_ulke;
}
//-------------------------------------------------------------------------------------------------------------------------
void Mesafe() {
	std::srand(static_cast<unsigned int>(std::time(0)));
	sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
	sf::Event event;
	sf::Text text;
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Texture texture; if (!texture.loadFromFile("dosyalar/arkaplan.png")) { download("https://drive.usercontent.google.com/download?id=1RDknWZSI6vPpCqL5NvCPohnWTG9T2_mW", "dosyalar\\arkaplan.png", 0, 66286); };
	sf::Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) { download("https://drive.usercontent.google.com/download?id=14QeyRRW8J2sZvGFQMmyY-Gjj6qavEa3J", "dosyalar\\sesler\\dogru.ogg", 0, 7703); };
	sf::Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) { download("https://drive.usercontent.google.com/download?id=1lfBSgz9ja7oSyLb3XQBbbMLDm_vzchRg", "dosyalar\\sesler\\yanlis.ogg", 0, 10769); };
	sf::Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) { download("https://drive.usercontent.google.com/download?id=1M4JCY_AFmVbnWNn24Zbnq5rIfd3zR3zZ", "dosyalar\\sesler\\yenitur.ogg", 0, 23217); };
	dogru.setVolume(45); yanlis.setVolume(45); yenitur.setVolume(45);
	text.setFont(font); text.setCharacterSize(35); text.setFillColor(sf::Color::Black); text.setPosition(10, 10);
	sf::Sprite sprite(texture);
	string komut, yazilanlar, kaliciyazilanlar;
	bool oyun = false, bitis = false, pas = false, gecicibilgi = false;
	int joker = 3, winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0;
	//Oyunla İlgili Açıklamaların Yazdığı Yer
	std::string secilen[] = { "Mesafeden Ulke Bilme Oyunu","Mesafeden ulke bilme oyununa hos geldiniz. \nAmaciniz, " + to_string(ulke.size()) + " ülkeden rastgele secilen bir ulkeyi bilmek.\nMesafeler +-100 Km fark olabilir.\nKonum olarak ülkelerin tam ortalari baz alinmistir.",
		"Tahminleri yazarken turkce harfleri gostermiyor bu yuzden harf eksik kaldi diye onemsemeyin tahminizi etkilemeyecektir.",
		"Puan Sistemi: Her turda puaniniz 100 den baslar her yanlis tahminde 10 puan azalir.\n8 Tahminden sonra kazanilan puan 20'e sabitlenir tur bitince tekrar 100'den baslar.",
		"Ulkeyi gecmek icin Pas yazin\nOyunu kapatmak icin 'Kapat' yazin.\nAyarlari duzenlemek icin Ayarlar yazin, sonraki turda etki eder.",
		"Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin.","Eger ekrandaki yaziler guzukmemeye basladi ise temizle yaziniz." };
	window.clear();
	text.setString(secilen[0] + "\n" + secilen[1] + "\n" + secilen[2] + "\n" + secilen[3] + "\n" + secilen[4] + "\n" + secilen[5] + "\n" + secilen[6] + "\n");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
					window.close();
					oyun = true;
					yenitur.play();
					break;
				}
			}
			if (event.type == sf::Event::Closed)
				window.close();
		}
	}
	while (oyun) {
		do {
			randomSayi = std::rand() % ulke.size();
		} while (ulke[randomSayi].bilgi
			|| (!amerikakitasi && ulke[randomSayi].kita == "Americas")
			|| (!asyakitasi && ulke[randomSayi].kita == "Asia")
			|| (!afrikakitasi && ulke[randomSayi].kita == "Africa")
			|| (!avrupakitasi&& ulke[randomSayi].kita == "Europe")
			|| (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania")
			|| (!antartikakitasi && ulke[randomSayi].kita == "Antarctic")
			|| (!bmuyeligi && !ulke[randomSayi].bm));
		Ulkeler kalici(ulke[randomSayi].bayrak, ulke[randomSayi].trisim, ulke[randomSayi].enisim, ulke[randomSayi].isim, ulke[randomSayi].baskent, ulke[randomSayi].kita, ulke[randomSayi].url, ulke[randomSayi].enlem, ulke[randomSayi].boylam, ulke[randomSayi].bm, ulke[randomSayi].dosyaboyut);
		Ulkeler gecici("a", "a", "a", "a", "a", "a", "a", 0, 0, 0,0);
		ulke[randomSayi].bilgi = true;
		if (!kalici.bm)
			kaliciyazilanlar += "Secilen Ulke Birlesmis Milletler Uyesi Degil. Isterseniz Ulkeyi Gecebilirsiniz\n";
		for (int i = 0; i < ulke.size(); i++) {
			if (ulke[i].bilgi
				|| (!amerikakitasi && ulke[i].kita == "Americas")
				|| (!asyakitasi && ulke[i].kita == "Asia")
				|| (!afrikakitasi && ulke[i].kita == "Africa")
				|| (!avrupakitasi && ulke[i].kita == "Europe")
				|| (!okyanusyakitasi && ulke[i].kita == "Oceania")
				|| (!antartikakitasi && ulke[i].kita == "Antarctic")
				|| (!bmuyeligi && !ulke[i].bm))
			{
			}
			else {
				gecicibilgi = true;
				break;
			}
		}
		if (gecicibilgi == false) {
			for (int i = 0; i < ulke.size(); i++)
				ulke[i].bilgi = false;
			kaliciyazilanlar += "Tum ulkeler bir kere secildi en tum ulkeler tekrar seciliyor.\n";
		}
		gecicibilgi = false;
		puan = 110;
		while (true) {
			sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
			window.clear();
			text.setString(kaliciyazilanlar + yazilanlar + " Lütfen bir tahmin girin:  ");
			window.draw(sprite);
			window.draw(text);
			window.display();
			komut = "";
			while (window.isOpen()) {
				while (window.pollEvent(event)) {
					if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
						if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
							window.close();
							break;
						}
						else if (event.text.unicode == '\b') { // Silme tuşuna basıldıysa
							if (!komut.empty()) {
								komut.erase(komut.size() - 1);
								text.setString(kaliciyazilanlar + yazilanlar + " Lütfen bir tahmin girin:  " + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						else {
							komut += event.text.unicode;
							text.setString(kaliciyazilanlar + yazilanlar + " Lütfen bir tahmin girin:  " + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
							window.clear();
							window.draw(sprite);
							window.draw(text);
							window.display();
						}
					}
					else if (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Tab) { // Tab tuşuna basıldıysa
						komut = bulunanBenzerUlke(komut);
						window.close();
						break;
					}
					if (event.type == sf::Event::Closed)
					{
						window.close();
						oyun = false;
					}
					if (window.hasFocus())
						break;
				}
			}
			if (komut.empty())
				komut = "Kapat";
			yazilanlar = "";
			komut = kelimeDuzelt(komut);
			for (size_t a = 0;a < (ulke.size());a++) {
				if (ulke[a].ks(komut)) {
					gecici = Ulkeler(ulke[a].bayrak, ulke[a].trisim, ulke[a].enisim, ulke[a].isim, ulke[a].baskent, ulke[a].kita, ulke[a].url, ulke[a].enlem, ulke[a].boylam, ulke[a].bm, ulke[a].dosyaboyut);
					puan -= 10;
					break; // Eşleşme bulundu, döngüden çık
				}
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
				endGameMenu(window, event, komut, yazilanlar, text, sprite, oyun, winstreak, toplampuan);
				komut = "Kapat";
				break;
			}
			if (komut == "Joker") {
				if (joker > 0) {
					joker -= 1;
					yazilanlar += "Ulkenin Baskenti: " + kalici.baskent + "  ";
					yazilanlar += to_string(joker) + " Joker hakkiniz kaldi.\n";
					puan -= 25;
				}
				else 
					yazilanlar += to_string(joker) + "Joker hakkiniz bitmiştir.\n";
			}
			else if (komut == "Pas") {
				yenitur.play();
				kaliciyazilanlar = "";
				yazilanlar += "Gecilen Ulke: " + kalici.isim + "  ";
				yazilanlar += "Kordinati Enlem: " + to_string(kalici.enlem) + " Boylam: " + to_string(kalici.boylam) + "\n";
				break;
			}
			else if (komut == "Temizle")
				kaliciyazilanlar = "";
			else if (komut == "Ayarlar")
				ulkekurallari();
			else if (gecici.isim == kalici.isim) {
				dogru.play();
				kaliciyazilanlar = "";
				yazilanlar += "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (gecici.ks(komut)) {
				yanlis.play();
				komut = to_string(mesafehesapla(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam));
				komut.erase(komut.size() - 7);
				kaliciyazilanlar += "Tahmin: " + gecici.isim + "  ";
				kaliciyazilanlar += "Mesafe: " + komut + " kilometre  ";
				kaliciyazilanlar += "Yön: " + Pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) + "\n";
			}
			else if (!gecici.ks(kalici.isim)) {
				yanlis.play();
				yazilanlar += "Boyle bir ulke bulunamadi.\n";
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
void Bayrak() {
	std::srand(static_cast<unsigned int>(std::time(0)));
	sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
	sf::Event event;
	sf::Text text;
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Texture texture; if (!texture.loadFromFile("dosyalar/arkaplan.png")) { download("https://drive.usercontent.google.com/download?id=1RDknWZSI6vPpCqL5NvCPohnWTG9T2_mW", "dosyalar\\arkaplan.png", 0, 66286); };
	sf::Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) { download("https://drive.usercontent.google.com/download?id=14QeyRRW8J2sZvGFQMmyY-Gjj6qavEa3J", "dosyalar\\sesler\\dogru.ogg", 0, 7703); };
	sf::Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) { download("https://drive.usercontent.google.com/download?id=1lfBSgz9ja7oSyLb3XQBbbMLDm_vzchRg", "dosyalar\\sesler\\yanlis.ogg", 0, 10769); };
	sf::Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) { download("https://drive.usercontent.google.com/download?id=1M4JCY_AFmVbnWNn24Zbnq5rIfd3zR3zZ", "dosyalar\\sesler\\yenitur.ogg", 0, 23217); };
	dogru.setVolume(45); yanlis.setVolume(45); yenitur.setVolume(45);
	text.setFont(font); text.setCharacterSize(35); text.setFillColor(sf::Color::Black); text.setPosition(10, 10);
	sf::Sprite sprite(texture);
	string komut, gecilenulke, yazilanlar;
	bool oyun = false, bitis = false, gecicibilgi = false;
	int winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0;
	//Oyunla İlgili Açıklamaların Yazdığı Yer
	std::string secilen[] = { "Bayrak Bilme Oyunu", "Bayrak Bilme Oyununa hos geldiniz. ", "Amaciniz, " + to_string(ulke.size()) + " ulkeden rastgele secilen bir ulkenin bayragini bilmek.",
		"Tahminleri yazarken turkce harfleri gostermiyor bu yuzden harf eksik kaldi diye onemsemeyin tahminizi etkilemeyecektir.",
		"Puan Sistemi: Her turda puaniniz 50 den baslar her yanlis tahminde 10 puan azalir.\n3 Tahminden sonra kazanilan puan 20'e sabitlenir tur bitince tekrar 50'den baslar.",
		"Ulkeyi gecmek icin Pas yazin\nOyunu kapatmak icin 'Kapat' yazin.\nAyarlari duzenlemek icin Ayarlar yazin, sonraki turda etki eder.",
		"Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear(sf::Color(30, 30, 30));
	text.setString(secilen[0] + "\n" + secilen[1] + "\n" + secilen[2] + "\n" + secilen[3] + "\n" + secilen[4] + "\n" + secilen[5] + "\n" + secilen[6] + "\n");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed) 
				window.close();
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
					window.close();
					oyun = true;
					yenitur.play();
					break;
				}
			}
		}
	}
	while (oyun) {
		do {
			randomSayi = std::rand() % ulke.size();
		} while (ulke[randomSayi].bilgi
			|| (!amerikakitasi && ulke[randomSayi].kita == "Americas")
			|| (!asyakitasi && ulke[randomSayi].kita == "Asia")
			|| (!afrikakitasi && ulke[randomSayi].kita == "Africa")
			|| (!avrupakitasi && ulke[randomSayi].kita == "Europe")
			|| (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania")
			|| (!antartikakitasi && ulke[randomSayi].kita == "Antarctic")
			|| (!bmuyeligi && !ulke[randomSayi].bm));
		Ulkeler kalici(ulke[randomSayi].bayrak, ulke[randomSayi].trisim, ulke[randomSayi].enisim, ulke[randomSayi].isim, ulke[randomSayi].baskent, ulke[randomSayi].kita, ulke[randomSayi].url, ulke[randomSayi].enlem, ulke[randomSayi].boylam, ulke[randomSayi].bm, ulke[randomSayi].dosyaboyut);
		Ulkeler gecici("a", "a", "a", "a", "a", "a", "a", 0, 0, 0, 0);
		ulke[randomSayi].bilgi = true;
		download(ulke[randomSayi].url, ulke[randomSayi].bayrak, 0, ulke[randomSayi].dosyaboyut);
		if (!kalici.bm)
			gecilenulke += "Secilen Ulke Birlesmis Milletler Uyesi Degil. Isterseniz Ulkeyi Gecebilirsiniz\n";
		for (int i = 0; i < ulke.size(); i++) {
			if (ulke[i].bilgi
				|| (!amerikakitasi && ulke[i].kita == "Americas")
				|| (!asyakitasi && ulke[i].kita == "Asia")
				|| (!afrikakitasi && ulke[i].kita == "Africa")
				|| (!avrupakitasi && ulke[i].kita == "Europe")
				|| (!okyanusyakitasi && ulke[i].kita == "Oceania")
				|| (!antartikakitasi && ulke[i].kita == "Antarctic")
				|| (!bmuyeligi && !ulke[i].bm))
			{
			}
			else {
				gecicibilgi = true;
				break;
			}
		}
		if (gecicibilgi == false) {
			for (int i = 0; i < ulke.size(); i++)
				ulke[i].bilgi = false;
			gecilenulke += "Tum ulkeler bir kere secildi en tum ulkeler tekrar seciliyor.\n";
		}
		gecicibilgi = false;
		puan = 50;
		while (true) {
			text.setFillColor(sf::Color::Yellow);
			sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
			sf::Texture texture, arkaplan;
			if (texture.loadFromFile(kalici.bayrak)) {}
			if (arkaplan.loadFromFile("dosyalar/arkaplan.png")) {}
			sf::Sprite sprite(texture);
			sf::Sprite sprite2(arkaplan);
			window.clear(sf::Color(30, 30, 30));
			sprite.setPosition(10, 200);
			window.draw(sprite2);
			window.draw(sprite);
			text.setString(gecilenulke);
			window.draw(text);
			window.display();
			komut = "";
			while (window.isOpen()) {
				while (window.pollEvent(event)) {
					if (event.type == sf::Event::Closed) {
						window.close();
						komut = "kapat";
						gecilenulke = "";
						break;
					}
					if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
						if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
							window.close();
							gecilenulke = "";
							break;
						}
						else if (event.text.unicode == '\b') { // Silme tuşuna basıldıysa
							if (!komut.empty()) {
								komut.erase(komut.size() - 1);
								text.setString(gecilenulke + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
								window.clear(sf::Color(30, 30, 30));
								window.draw(sprite2);
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						else {
							komut += event.text.unicode;
							text.setString(gecilenulke + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
							window.clear(sf::Color(30, 30, 30));
							window.draw(sprite2);
							window.draw(sprite);
							window.draw(text);
							window.display();
						}
					}
					else if (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Tab) { // Tab tuşuna basıldıysa
						komut = bulunanBenzerUlke(komut);
						window.close();
						gecilenulke = "";
						break;
					}
					if (window.hasFocus())
						break;
				}
			}
			komut = kelimeDuzelt(komut);
			for (size_t a = 0;a < (ulke.size());a++) {
				if (ulke[a].ks(komut)) {
					gecici = Ulkeler(ulke[a].bayrak, ulke[a].trisim, ulke[a].enisim, ulke[a].isim, ulke[a].baskent, ulke[a].kita, ulke[a].url, ulke[a].enlem, ulke[a].boylam, ulke[a].bm, ulke[a].dosyaboyut);
					break; // Eşleşme bulundu, döngüden çık
				}
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
				endGameMenu(window, event, komut, yazilanlar, text, sprite, oyun, winstreak, toplampuan);
				komut = "Kapat";
				break;
			}
			if (komut != "Pas" && komut != "Bitir" && !gecici.ks(kalici.isim)) {
				yanlis.play();
				gecilenulke = "Boyle bir ulke bulunamadi. Yazilan komut: " + komut + "\n";
			}
			if (gecici.isim == kalici.isim) {
				dogru.play();
				gecilenulke = "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			if (gecici.ks(komut)) {
				yanlis.play();
				gecilenulke = "Yanlis tahmin!!\n";
				puan -= 10;
			}
			if (komut == "Ayarlar")
				ulkekurallari();
			if (komut == "Pas") {
				yenitur.play();
				gecilenulke = "Geçilen Ülke: " + kalici.isim + "\n";
				break;
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
void Baskent() {
	std::srand(static_cast<unsigned int>(std::time(0)));
	sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
	sf::Text text;
	sf::Event event;
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Texture texture; if (!texture.loadFromFile("dosyalar/arkaplan.png")) { download("https://drive.usercontent.google.com/download?id=1RDknWZSI6vPpCqL5NvCPohnWTG9T2_mW", "dosyalar\\arkaplan.png", 0, 66286); };
	sf::Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) { download("https://drive.usercontent.google.com/download?id=14QeyRRW8J2sZvGFQMmyY-Gjj6qavEa3J", "dosyalar\\sesler\\dogru.ogg", 0, 7703); };
	sf::Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) { download("https://drive.usercontent.google.com/download?id=1lfBSgz9ja7oSyLb3XQBbbMLDm_vzchRg", "dosyalar\\sesler\\yanlis.ogg", 0, 10769); };
	sf::Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) { download("https://drive.usercontent.google.com/download?id=1M4JCY_AFmVbnWNn24Zbnq5rIfd3zR3zZ", "dosyalar\\sesler\\yenitur.ogg", 0, 23217); };
	dogru.setVolume(45); yanlis.setVolume(45); yenitur.setVolume(45);
	text.setFont(font); text.setCharacterSize(35); text.setFillColor(sf::Color::Black); text.setPosition(10, 10);
	sf::Sprite sprite(texture);
	string komut, yazilanlar, kaliciyazilanlar;
	bool oyun = false, bitis = false, gecicibilgi = false;
	int winstreak = 0, toplampuan = 0, puan = 0, randomSayi = 0;
	//Oyunla İlgili Açıklamaların Yazdığı Yer
	std::string secilen[] = { "Baskent Bilme Oyunu","Baskent Bilme Oyununa hos geldiniz. \nAmaciniz " + to_string(ulke.size()) + " ulkeden rastgele secilen bir ulkenin baskentini bilmek.",
		"Tahminleri yazarken turkce harfleri gostermiyor bu yuzden harf eksik kaldi diye onemsemeyin tahminizi etkilemeyecektir.",
		"Puan Sistemi: Her turda puaniniz 50 den baslar her yanlis tahminde 10 puan azalir.\n3 Tahminden sonra kazanilan puan 20'e sabitlenir tur bitince tekrar 50'den baslar.",
		"Ulkeyi gecmek icin Pas yazin","Oyunu kapatmak icin 'Kapat' yazin.\nAyarlari duzenlemek icin Ayarlar yazin, sonraki turda etki eder.",
		"Baslamak icin 'Enter' tusuna basin oyunu bitirmek icin ise 'Bitir' yazin." };
	window.clear();
	text.setString(secilen[0] + "\n" + secilen[1] + "\n" + secilen[2] + "\n" + secilen[3] + "\n" + secilen[4] + "\n" + secilen[5] + "\n" + secilen[6] + "\n");
	window.draw(sprite);
	window.draw(text);
	window.display();
	while (window.isOpen()) {
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
				if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
					window.close();
					oyun = true;
					yenitur.play();
					break;
				}
			}
			if (event.type == sf::Event::Closed)
				window.close();
		}
	}
	while (oyun) {
		do {
			randomSayi = std::rand() % ulke.size();
		} while (ulke[randomSayi].bilgi
			|| (!amerikakitasi && ulke[randomSayi].kita == "Americas")
			|| (!asyakitasi && ulke[randomSayi].kita == "Asia")
			|| (!afrikakitasi && ulke[randomSayi].kita == "Africa")
			|| (!avrupakitasi && ulke[randomSayi].kita == "Europe")
			|| (!okyanusyakitasi && ulke[randomSayi].kita == "Oceania")
			|| (!antartikakitasi && ulke[randomSayi].kita == "Antarctic")
			|| (!bmuyeligi && !ulke[randomSayi].bm));
		Ulkeler kalici(ulke[randomSayi].bayrak, ulke[randomSayi].trisim, ulke[randomSayi].enisim, ulke[randomSayi].isim, ulke[randomSayi].baskent, ulke[randomSayi].kita, ulke[randomSayi].url, ulke[randomSayi].enlem, ulke[randomSayi].boylam, ulke[randomSayi].bm, ulke[randomSayi].dosyaboyut);
		Ulkeler gecici("a", "a", "a", "a", "a", "a", "a", 0, 0, 0, 0);
		ulke[randomSayi].bilgi = true;
		if (!kalici.bm)
			kaliciyazilanlar = "Secilen Ulke Birlesmis Milletler Uyesi Degil. Isterseniz Ulkeyi Gecebilirsiniz\n";
		else
			kaliciyazilanlar = "";
		for (int i = 0; i < ulke.size(); i++) {
			if (ulke[i].bilgi
				|| (!amerikakitasi && ulke[i].kita == "Americas")
				|| (!asyakitasi && ulke[i].kita == "Asia")
				|| (!afrikakitasi && ulke[i].kita == "Africa")
				|| (!avrupakitasi && ulke[i].kita == "Europe")
				|| (!okyanusyakitasi && ulke[i].kita == "Oceania")
				|| (!antartikakitasi && ulke[i].kita == "Antarctic")
				|| (!bmuyeligi && !ulke[i].bm))
			{
			}
			else {
				gecicibilgi = true;
				break;
			}
		}
		if (gecicibilgi == false) {
			for (int i = 0; i < ulke.size(); i++) 
				ulke[i].bilgi = false;
			kaliciyazilanlar += "Tum ulkeler bir kere secildi en tum ulkeler tekrar seciliyor.\n";
		}
		gecicibilgi = false;
		puan = 50;
		while (true) {
			sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
			yazilanlar += "Baskent Adi: " + kalici.baskent + "\n";
			window.clear();
			text.setString(yazilanlar + "Lütfen bir tahmin girin:  ");
			window.draw(sprite);
			window.draw(text);
			window.display();
			komut = "";
			while (window.isOpen()) {
				while (window.pollEvent(event)) {
					if (event.type == sf::Event::Closed) {
						window.close();
						komut = "Kapat";
						break;
					}
					if (event.type == sf::Event::TextEntered && event.text.unicode < 128) {
						if (event.text.unicode == '\r') { // Enter tuşuna basıldıysa
							window.close();
							break;
						}
						else if (event.text.unicode == '\b') { // Silme tuşuna basıldıysa
							if (!komut.empty()) {
								komut.erase(komut.size() - 1);
								text.setString(kaliciyazilanlar+yazilanlar + "Lütfen bir tahmin girin:  " + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
								window.clear();
								window.draw(sprite);
								window.draw(text);
								window.display();
							}
						}
						else {
							komut += event.text.unicode;
							text.setString(kaliciyazilanlar+yazilanlar + "Lütfen bir tahmin girin:  " + komut + "\nSunumu demek istediniz (evet ise tab basiniz) : " + bulunanBenzerUlke(komut));
							window.clear();
							window.draw(sprite);
							window.draw(text);
							window.display();
						}
					}
					else if (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Tab) { // Tab tuşuna basıldıysa
						komut = bulunanBenzerUlke(komut);
						window.close();
						break;
					}
					if (window.hasFocus())
						break;
				}
			}
			komut = kelimeDuzelt(komut);
			for (size_t a = 0;a < (ulke.size());a++) {
				const Ulkeler& secilenulke = ulke[a];
				if (ulke[a].ks(komut)) {
					gecici = Ulkeler(ulke[a].bayrak, ulke[a].trisim, ulke[a].enisim, ulke[a].isim, ulke[a].baskent, ulke[a].kita, ulke[a].url, ulke[a].enlem, ulke[a].boylam, ulke[a].bm, ulke[a].dosyaboyut);
					break; // Eşleşme bulundu, döngüden çık
				}
			}
			if (komut == "Kapat") {
				oyun = 0;
				break;
			}
			if (komut == "Bitir" || bitis) {
				sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
				endGameMenu(window, event, komut, yazilanlar, text, sprite, oyun, winstreak, toplampuan);
				komut = "Kapat";
				break;
			}
			if (kalici.ks(gecici.isim) || kalici.ks(gecici.trisim) || kalici.ks(gecici.enisim)) {
				dogru.play();
				yazilanlar = "Dogru ulkeyi buldun Tebrikler!!\n";
				if (puan < 20)
					toplampuan += 20;
				else
					toplampuan += puan;
				winstreak++;
				break;
			}
			else if (komut != "Pas" && komut != "Bitir") {
				yanlis.play();
				yazilanlar = "Boyle bir ulke bulunamadi.\n";
			}
			if (gecici.ks(komut)) {
				yanlis.play();
				yazilanlar = "Yanlis tahmin\n";

				puan -= 10;
			}
			if (komut == "Ayarlar")
				ulkekurallari();
			if (komut == "Pas") {
				yenitur.play();
				yazilanlar = "Gecilen Ulke: " + kalici.isim + "\n";
				break;
			}
		}
	}
}
//-------------------------------------------------------------------------------------------------------------------------
int main() {
	setlocale(LC_ALL, "Turkish");
	sf::Event event;
	sf::Font font; if (!font.loadFromFile("dosyalar/arial.ttf")) { download("https://drive.usercontent.google.com/download?id=1uJAWWTlFir4tJ4sZ5EPzmG8Snd2A-7bf", "dosyalar\\arial.ttf", 0, 915212); };
	sf::Texture texture; if (!texture.loadFromFile("dosyalar/arkaplan.png")) { download("https://drive.usercontent.google.com/download?id=1RDknWZSI6vPpCqL5NvCPohnWTG9T2_mW", "dosyalar\\arkaplan.png", 0, 66286); };
	sf::Music dogru; if (!dogru.openFromFile("dosyalar/sesler/dogru.ogg")) { download("https://drive.usercontent.google.com/download?id=14QeyRRW8J2sZvGFQMmyY-Gjj6qavEa3J", "dosyalar\\sesler\\dogru.ogg", 0, 7703); };
	sf::Music yanlis; if (!yanlis.openFromFile("dosyalar/sesler/yanlis.ogg")) { download("https://drive.usercontent.google.com/download?id=1lfBSgz9ja7oSyLb3XQBbbMLDm_vzchRg", "dosyalar\\sesler\\yanlis.ogg", 0, 10769); };
	sf::Music yenitur; if (!yenitur.openFromFile("dosyalar/sesler/yenitur.ogg")) { download("https://drive.usercontent.google.com/download?id=1M4JCY_AFmVbnWNn24Zbnq5rIfd3zR3zZ", "dosyalar\\sesler\\yenitur.ogg", 0, 23217); };
	sf::Sprite sprite(texture);
	dogru.setVolume(45);
	yanlis.setVolume(45);
	yenitur.setVolume(45);
	sf::Text menuText("Menu Text", font, 40), Text("Text", font, 75), Text2("Text 2", font, 40);
	menuText.setFillColor(sf::Color::Red), Text.setFillColor(sf::Color::Yellow), Text2.setFillColor(sf::Color::Black);
	menuText.setPosition(10, 10), Text.setPosition(10, 10), Text2.setPosition(10, 10);
	std::vector<std::string> secenekler = { "1. Baskent Bilme Oyunu", "2. Mesafeden Ulke Bilme Oyunu", "3. Bayrak Bilme Oyunu", "4. Ulke Secim Ayarlari" };
	bool oyun = true;
	while (oyun) {
		int secim = 0;
		sf::RenderWindow window(sf::VideoMode(1920, 1080), "GeoGame");
		while (window.isOpen()) {
			while (window.pollEvent(event)) {
				if (event.type == sf::Event::Closed) {
					window.close(); oyun = false;
				}
				if (event.type == sf::Event::KeyPressed) {
					if (event.key.code == sf::Keyboard::Up || event.key.code == sf::Keyboard::Left) {
						secim--;
						if (secim < 0) secim = static_cast<int>(secenekler.size()) - 1;
					}
					else if (event.key.code == sf::Keyboard::Down || event.key.code == sf::Keyboard::Right) {
						secim++;
						if (secim >= secenekler.size()) secim = 0;
					}
					else if (event.key.code == sf::Keyboard::Return) {
						yenitur.play();
						window.close();
						switch (secim) {
						case 0: Baskent(); break;
						case 1: Mesafe(); break;
						case 2: Bayrak(); break;
						case 3: ulkekurallari(); break;
						}
					}
					if (event.key.code >= sf::Keyboard::Num1 && event.key.code <= sf::Keyboard::Num8) {
						secim = event.key.code - sf::Keyboard::Num1;
					}
				}
			}
			window.clear(sf::Color(30, 30, 30)); // Arka plan rengi
			window.draw(sprite);
			std::string menuMetni;
			int a = 0;
			for (int i = 0; i < secenekler.size(); ++i) {
				menuMetni += ((i == secim) ? " > " : "   ") + secenekler[i] + ((i != secenekler.size() - 1) ? "\n" : "");
				if (i == secim)
					a = i;
			}
			menuText.setString("\n\n" + menuMetni);
			menuText.setFillColor(sf::Color::Red);
			window.draw(menuText);
			menuText.setString(std::string(2 + a, '\n') + " > "+secenekler[a]);
			menuText.setFillColor(sf::Color::Blue);
			window.draw(menuText);
			Text.setString("\tGeoGame");
			window.draw(Text);
			window.display();
		}
	}
	return 0;
}

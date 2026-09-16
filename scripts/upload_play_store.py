#!/usr/bin/env python3
"""
Google Play Console AAB Yükleme Scripti (Android Publisher API v3)

Bu script, derlenen Android App Bundle (.aab) dosyasını Google Play Console'a
Service Account kimlik doğrulaması ile otomatik olarak yükler, RELEASE_PLAY_STORE_*.md
dosyasındaki çok dilli sürüm notlarını ayrıştırıp ilgili sürüme ekler ve
belirlenen kanala (internal, alpha, beta, production) dağıtır.
"""

import argparse
import os
import re
import sys
from typing import List, Dict, Optional

try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
    from googleapiclient.http import MediaFileUpload
except ImportError as e:
    print(f"[X] HATA: Gerekli Google API kütüphaneleri eksik: {e}", file=sys.stderr)
    print("    Yüklemek için: pip install google-api-python-client google-auth", file=sys.stderr)
    sys.exit(1)

SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]


def parse_release_notes(notes_file: str) -> List[Dict[str, str]]:
    """
    RELEASE_PLAY_STORE_*.md dosyasından <locale>...</locale> etiketleri arasındaki
    metinleri okur ve Google Play Console API formatına dönüştürür.
    Maksimum 500 Unicode karakter sınırı uygulanır.
    """
    if not os.path.isfile(notes_file):
        print(f"   [!] UYARI: Sürüm notu dosyası bulunamadı: {notes_file}")
        return []

    try:
        with open(notes_file, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception as e:
        print(f"   [!] UYARI: Sürüm notu dosyası okunamadı: {e}")
        return []

    # <en-US>...</en-US> etiketlerini eşleştir
    pattern = r"<([a-zA-Z]{2}-[a-zA-Z]{2})>\s*(.*?)\s*</\1>"
    matches = re.findall(pattern, content, re.DOTALL)

    release_notes = []
    for lang, text in matches:
        clean_text = text.strip()
        char_len = len(clean_text)

        if char_len > 500:
            print(f"   [!] UYARI: [{lang}] sürüm notu 500 karakterden uzun ({char_len}), ilk 500 karaktere kırpılıyor...")
            clean_text = clean_text[:500]

        if clean_text:
            release_notes.append({
                "language": lang,
                "text": clean_text
            })
            print(f"   [i] Sürüm notu eklendi: [{lang}] ({len(clean_text)} karakter)")

    return release_notes


def upload_aab(
    service_account_path: str,
    package_name: str,
    aab_path: str,
    track: str = "internal",
    status: str = "completed",
    release_notes_path: Optional[str] = None,
    user_fraction: Optional[float] = None
) -> int:
    """
    AAB dosyasını Google Play Console'a yükler ve sürüm notlarıyla birlikte yayınlar.
    """
    if not os.path.isfile(service_account_path):
        print(f"[X] HATA: Service account dosyası bulunamadı: {service_account_path}", file=sys.stderr)
        return 1

    if not os.path.isfile(aab_path):
        print(f"[X] HATA: AAB dosyası bulunamadı: {aab_path}", file=sys.stderr)
        return 1

    print(">> Google Play Console Bağlantısı Kuruluyor...")
    try:
        credentials = service_account.Credentials.from_service_account_file(
            service_account_path,
            scopes=SCOPES
        )
        service = build("androidpublisher", "v3", credentials=credentials, cache_discovery=False)
    except Exception as e:
        print(f"[X] HATA: Kimlik doğrulama veya API bağlantısı başarısız: {e}", file=sys.stderr)
        return 1

    edit_id = None
    try:
        # 1. Yeni bir edit oluştur
        print(f"   [i] Edit oluşturuluyor: Paket = {package_name}")
        edit_request = service.edits().insert(packageName=package_name, body={})
        edit_response = edit_request.execute()
        edit_id = edit_response["id"]
        print(f"   [OK] Edit ID: {edit_id}")

        # 2. AAB dosyasını yükle (Resumable Upload)
        file_size_mb = os.path.getsize(aab_path) / (1024 * 1024)
        print(f">> AAB Yükleniyor: {os.path.basename(aab_path)} ({file_size_mb:.2f} MB)...")

        media = MediaFileUpload(
            aab_path,
            mimetype="application/octet-stream",
            resumable=True,
            chunksize=1024 * 1024 * 2  # 2MB chunks
        )

        upload_req = service.edits().bundles().upload(
            packageName=package_name,
            editId=edit_id,
            media_body=media
        )

        response = None
        last_pct = -1
        while response is None:
            upload_status, response = upload_req.next_chunk()
            if upload_status:
                pct = int(upload_status.progress() * 100)
                if pct != last_pct and pct % 10 == 0:
                    print(f"   ... Yükleme: %{pct}")
                    last_pct = pct

        version_code = response.get("versionCode")
        print(f"   [OK] AAB başarıyla yüklendi! Sürüm Kodu (VersionCode): {version_code}")

        # 3. Sürüm notlarını hazırla
        release_notes = []
        if release_notes_path:
            print(">> Sürüm Notları Ayrıştırılıyor...")
            release_notes = parse_release_notes(release_notes_path)

        # 4. Kanal (Track) bilgilerini yapılandır
        print(f">> Kanal Güncelleniyor: '{track}' (Durum: {status})...")
        release_data = {
            "versionCodes": [str(version_code)],
            "status": status,
        }

        if release_notes:
            release_data["releaseNotes"] = release_notes

        if status == "inProgress" and user_fraction is not None:
            release_data["userFraction"] = user_fraction

        track_body = {
            "track": track,
            "releases": [release_data]
        }

        service.edits().tracks().update(
            packageName=package_name,
            editId=edit_id,
            track=track,
            body=track_body
        ).execute()
        print(f"   [OK] '{track}' kanalı güncellendi.")

        # 5. Değişiklikleri onayla (Commit)
        print(">> Değişiklikler Google Play'e Onaylanıyor (Commit)...")
        commit_request = service.edits().commit(
            packageName=package_name,
            editId=edit_id
        )
        commit_request.execute()
        edit_id = None  # Başarıyla commit edildi, delete çağrısına gerek yok

        print(f"\n[OK] TEBRİKLER! v{version_code} başarıyla Google Play Console '{track}' kanalına yüklendi!")
        return 0

    except HttpError as e:
        print(f"\n[X] Google Play API Hatası (HTTP {e.resp.status})", flush=True)
        try:
            import json
            err_data = json.loads(e.content.decode("utf-8"))
            err_obj = err_data.get("error", {})
            err_msg = err_obj.get("message", str(e))
            err_status = err_obj.get("status", "")
            print(f"   Hata Mesajı: {err_msg}")
        except Exception:
            print(f"   Detay: {e}")
        return 1
    except Exception as e:
        print(f"\n[X] Beklenmeyen Hata: {e}", flush=True)
        return 1
    finally:
        # Commit edilmemiş açık bir edit kaldıysa temizle
        if edit_id:
            try:
                print("   [i] Açık kalan edit oturumu temizleniyor...")
                service.edits().delete(packageName=package_name, editId=edit_id).execute()
            except Exception:
                pass


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(
        description="Google Play Console AAB Yükleme ve Dağıtım Aracı"
    )
    parser.add_argument(
        "--aab",
        required=True,
        help="Yüklenecek .aab dosyasının yolu"
    )
    parser.add_argument(
        "--service-account",
        required=True,
        help="Google Play Service Account JSON dosyasının yolu"
    )
    parser.add_argument(
        "--package-name",
        default="com.keremkuyucu.geogame",
        help="Uygulama paket adı (Varsayılan: com.keremkuyucu.geogame)"
    )
    parser.add_argument(
        "--track",
        default="internal",
        choices=["internal", "alpha", "beta", "production"],
        help="Yayın kanalı: internal, alpha, beta, production (Varsayılan: internal)"
    )
    parser.add_argument(
        "--status",
        default="completed",
        choices=["completed", "draft", "inProgress", "halted"],
        help="Yayın durumu: completed, draft, inProgress, halted (Varsayılan: completed)"
    )
    parser.add_argument(
        "--release-notes",
        help="RELEASE_PLAY_STORE_*.md dosyasının yolu (çok dilli sürüm notları için)"
    )
    parser.add_argument(
        "--user-fraction",
        type=float,
        help="Kademeli dağıtım oranı (0.0 - 1.0) - yalnızca inProgress durumu için"
    )

    args = parser.parse_args()

    exit_code = upload_aab(
        service_account_path=args.service_account,
        package_name=args.package_name,
        aab_path=args.aab,
        track=args.track,
        status=args.status,
        release_notes_path=args.release_notes,
        user_fraction=args.user_fraction
    )
    sys.exit(exit_code)


if __name__ == "__main__":
    main()

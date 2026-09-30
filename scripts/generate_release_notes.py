#!/usr/bin/env python3
"""
GeoGame Release Notes Generator
Generates RELEASE_<version>.md (GitHub) and RELEASE_PLAY_STORE_<version>.md (Play Store)
using either Google Gemini API or Antigravity CLI (agy).
"""

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

PROJECT_ROOT = Path(__file__).resolve().parent.parent

def get_current_version() -> str:
    pubspec = PROJECT_ROOT / "pubspec.yaml"
    if not pubspec.exists():
        raise FileNotFoundError(f"pubspec.yaml not found at {pubspec}")
    content = pubspec.read_text(encoding="utf-8")
    match = re.search(r"^version:\s*([^\+\s]+)", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not extract version from pubspec.yaml")
    return match.group(1).strip()

def get_git_context() -> tuple[str, str]:
    """Returns (last_tag, commit_log)"""
    try:
        last_tag = subprocess.check_output(
            ["git", "describe", "--tags", "--abbrev=0"],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
    except Exception:
        last_tag = ""

    if last_tag:
        rev_range = f"{last_tag}..HEAD"
        print(f"[*] Last tag detected: {last_tag}")
    else:
        rev_range = "HEAD~15..HEAD"
        print("[*] No previous tag detected; inspecting recent commits")

    try:
        commit_log = subprocess.check_output(
            ["git", "log", rev_range, "--oneline", "--no-merges"],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
    except Exception:
        commit_log = subprocess.check_output(
            ["git", "log", "-n", "10", "--oneline", "--no-merges"],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()

    if not commit_log:
        commit_log = "Maintenance and general bug fixes."

    return last_tag, commit_log

def find_gemini_api_key(explicit_key: str = None) -> str:
    if explicit_key:
        return explicit_key.strip()
    if os.environ.get("GEMINI_API_KEY"):
        return os.environ["GEMINI_API_KEY"].strip()

    # Check local key files if any
    key_file = Path("C:/Users/kerem/Projects/imza-bilgileri/gemini.key")
    if key_file.exists():
        key = key_file.read_text(encoding="utf-8").strip()
        if key:
            return key

    return ""

def generate_with_gemini(api_key: str, version: str, last_tag: str, commit_log: str) -> tuple[str, str]:
    print(f"[*] Requesting release notes from Gemini API for v{version}...")

    prompt = f"""You are a professional release manager and copywriter for a Flutter mobile & desktop game called "GeoGame" (a world/geography quiz and map exploration game).

Generate two separate release notes documents based on the following git changes for version {version}:

GIT COMMITS (since {last_tag or 'previous release'}):
{commit_log}

REQUIREMENT 1: GitHub Release Notes
- Follow this structure:
  - English section with: Version, Short Title, Changes (Feature/Fix Name with short description), Bug Fixes (bullet points), Breaking Changes (if any).
  - Turkish section with: Sürüm, Kısa Başlık, Değişiklikler, Hata Düzeltmeleri.
  - Professional, clean markdown format.

REQUIREMENT 2: Google Play Store Release Notes
- Must contain exactly 7 localized release notes using `<locale>` tags:
  <en-US>, <tr-TR>, <de-DE>, <fr-FR>, <pt-PT>, <ru-RU>, <es-ES>
- CRITICAL CONSTRAINT: Each language's text inside its `<locale>` and `</locale>` tag MUST BE UNDER 500 CHARACTERS (Google Play Console hard limit).
- Focus on user-facing benefits and improvements, clear and concise tone.

OUTPUT FORMAT:
Respond ONLY with a valid JSON object with exactly two keys (no surrounding text or markdown formatting except the JSON):
{{
  "github_notes": "# ... markdown content for RELEASE_{version}.md ...",
  "play_store_notes": "<en-US>\\n...\\n</en-US>\\n\\n<tr-TR>\\n...\\n</tr-TR>\\n\\n..."
}}
"""

    models = [
        "gemini-3.5-flash-lite",  # 500 RPD, 15 RPM
        "gemini-3.1-flash-lite",  # 500 RPD, 15 RPM
        "gemini-3.5-flash",       # 20 RPD, 5 RPM
        "gemini-2.5-flash",       # 20 RPD, 5 RPM
        "gemini-flash-lite-latest"
    ]
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseMimeType": "application/json"
        }
    }

    last_error = None
    for model in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(req, timeout=45) as resp:
                resp_json = json.loads(resp.read().decode("utf-8"))
                text_content = resp_json["candidates"][0]["content"]["parts"][0]["text"]
                data = json.loads(text_content)
                return data["github_notes"].strip(), data["play_store_notes"].strip()
        except Exception as e:
            last_error = e
            print(f"[!] Model {model} request failed: {e}. Trying fallback if available...")

    raise RuntimeError(f"Gemini API request failed on all models: {last_error}")

def generate_with_agy(version: str) -> tuple[str, str]:
    print(f"[*] Calling Antigravity CLI (agy) to generate release notes for v{version}...")
    agy_prompt = (
        f"GeoGame projesinin v{version} surumu icin surum notlarini olustur. "
        "1. Git commit loglarini ve son degisiklikleri incele. "
        f"2. RELEASE_TEMPLATE.md sablonuna birebir uyarak 'RELEASE_{version}.md' dosyasini olustur. "
        f"3. RELEASE_TEMPLATE_PLAYSTORE.md sablonuna birebir uyarak (her dil icin max 500 karakter, <locale> etiketleri ile) 'RELEASE_PLAY_STORE_{version}.md' dosyasini olustur. "
        "Dosyalari dogrudan proje kok dizininde olustur."
    )

    cmd = ["agy", "-p", agy_prompt, "--add-dir", str(PROJECT_ROOT), "--dangerously-skip-permissions"]
    res = subprocess.run(cmd, cwd=PROJECT_ROOT)
    if res.returncode != 0:
        raise RuntimeError(f"agy CLI exited with code {res.returncode}")

    gh_file = PROJECT_ROOT / f"RELEASE_{version}.md"
    play_file = PROJECT_ROOT / f"RELEASE_PLAY_STORE_{version}.md"

    if not gh_file.exists() or not play_file.exists():
        raise FileNotFoundError("agy completed but one or both release note files were not created.")

    return gh_file.read_text(encoding="utf-8"), play_file.read_text(encoding="utf-8")

def validate_play_store_notes(content: str) -> bool:
    print("\n[*] Validating Play Store character limits (Max 500 per locale):")
    locales = ["en-US", "tr-TR", "de-DE", "fr-FR", "pt-PT", "ru-RU", "es-ES"]
    all_ok = True
    for loc in locales:
        pattern = rf"<{loc}>(.*?)</{loc}>"
        match = re.search(pattern, content, re.DOTALL)
        if match:
            text = match.group(1).strip()
            char_count = len(text)
            status = "OK" if char_count <= 500 else "EXCEEDED"
            if char_count > 500:
                all_ok = False
            print(f"    - {loc}: {char_count} chars [{status}]")
        else:
            print(f"    - {loc}: NOT FOUND (warning)")
    return all_ok

def main():
    parser = argparse.ArgumentParser(description="GeoGame Release Notes Generator")
    parser.add_argument("--version", "-v", help="Release version (default: from pubspec.yaml)")
    parser.add_argument("--engine", "-e", choices=["gemini", "agy", "auto"], default="auto",
                        help="Generator engine: gemini, agy, or auto (default: auto)")
    parser.add_argument("--api-key", "-k", help="Gemini API Key (optional)")
    args = parser.parse_args()

    version = args.version or get_current_version()
    print(f"=== GeoGame Release Notes Generator (v{version}) ===")

    last_tag, commit_log = get_git_context()
    print(f"[*] Commits to summarize:\n{commit_log}\n")

    api_key = find_gemini_api_key(args.api_key)
    engine = args.engine

    if engine == "auto":
        engine = "gemini" if api_key else "agy"

    print(f"[*] Using engine: {engine.upper()}")

    gh_notes = ""
    play_notes = ""

    if engine == "gemini":
        if not api_key:
            print("[!] Error: Gemini engine selected but no GEMINI_API_KEY found.")
            print("    Provide it via --api-key, GEMINI_API_KEY environment variable,")
            print("    or save it to C:/Users/kerem/Projects/imza-bilgileri/gemini.key")
            sys.exit(1)
        gh_notes, play_notes = generate_with_gemini(api_key, version, last_tag, commit_log)
    elif engine == "agy":
        gh_notes, play_notes = generate_with_agy(version)
    else:
        print(f"[!] Unknown engine: {engine}")
        sys.exit(1)

    gh_file = PROJECT_ROOT / f"RELEASE_{version}.md"
    play_file = PROJECT_ROOT / f"RELEASE_PLAY_STORE_{version}.md"

    gh_file.write_text(gh_notes, encoding="utf-8")
    play_file.write_text(play_notes, encoding="utf-8")

    print(f"\n[+] Successfully saved GitHub release notes: {gh_file.name}")
    print(f"[+] Successfully saved Play Store release notes: {play_file.name}")

    validate_play_store_notes(play_notes)

    print("\n=== Next Steps ===")
    print(f"1. Review {gh_file.name} and {play_file.name}")
    print("2. Commit and push:")
    print(f"   git add {gh_file.name} {play_file.name}")
    print(f"   git commit -m \"docs: add release notes for v{version}\"")
    print(f"   git push origin main")
    print(f"   git tag v{version}")
    print(f"   git push origin v{version}")

if __name__ == "__main__":
    main()

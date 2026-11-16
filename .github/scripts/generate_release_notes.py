#!/usr/bin/env python3
"""
GeoGame Release Notes Generator (CI/CD Workflow)
Generates RELEASE_<version>.md (GitHub) and RELEASE_PLAY_STORE_<version>.md (Play Store)
using Google Gemini API.
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

PROJECT_ROOT = Path(__file__).resolve().parents[2]


def get_current_version() -> str:
    pubspec = PROJECT_ROOT / "pubspec.yaml"
    if not pubspec.exists():
        raise FileNotFoundError(f"pubspec.yaml not found at {pubspec}")
    content = pubspec.read_text(encoding="utf-8")
    match = re.search(r"^version:\s*([^\+\s]+)", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not extract version from pubspec.yaml")
    return match.group(1).strip()


def get_git_context(version: str) -> tuple[str, str, str]:
    """
    Hedef sürümden önceki son tag'i ve iki sürüm arasındaki
    detaylı commit geçmişini ve dosya diff istatistiklerini döndürür.
    Returns: (last_tag, commit_log, diff_stat)
    """
    last_tag = ""
    target_tags = {f"v{version}", version}

    try:
        # Tarihe göre sıralı tag listesini al
        all_tags = subprocess.check_output(
            ["git", "tag", "--sort=-creatordate"],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip().splitlines()

        # Hedef sürüm tag'i hariç en güncel önceki tag'i bul
        for t in all_tags:
            t = t.strip()
            if t and t not in target_tags:
                last_tag = t
                break
    except Exception:
        pass

    if not last_tag:
        try:
            # Fallback: HEAD'in bir önceki ebeveynine göre en yakın tag
            last_tag = subprocess.check_output(
                ["git", "describe", "--tags", "--abbrev=0", "HEAD^"],
                cwd=PROJECT_ROOT,
                stderr=subprocess.DEVNULL,
                text=True
            ).strip()
        except Exception:
            last_tag = ""

    if last_tag:
        rev_range = f"{last_tag}..HEAD"
        print(f"[*] Previous release tag detected: {last_tag}")
        print(f"[*] Revision range: {rev_range}")
    else:
        rev_range = "HEAD~15..HEAD"
        print("[*] No previous tag detected; inspecting recent commits (HEAD~15..HEAD)")

    # 1. Commit Log (Başlık + gövde açıklamaları)
    try:
        commit_log = subprocess.check_output(
            ["git", "log", rev_range, "--format=- %s%n  %b", "--no-merges"],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
    except Exception:
        try:
            commit_log = subprocess.check_output(
                ["git", "log", "-n", "15", "--format=- %s%n  %b", "--no-merges"],
                cwd=PROJECT_ROOT,
                stderr=subprocess.DEVNULL,
                text=True
            ).strip()
        except Exception:
            commit_log = ""

    # 2. Dosya Diff İstatistikleri (Hangi dosyalarda ne kadar değişiklik yapıldı)
    try:
        diff_stat = subprocess.check_output(
            ["git", "diff", "--stat", rev_range],
            cwd=PROJECT_ROOT,
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
    except Exception:
        diff_stat = ""

    if not commit_log:
        commit_log = "- General improvements and routine maintenance."

    return last_tag, commit_log, diff_stat


def get_gemini_api_key(explicit_key: str = None) -> str:
    if explicit_key:
        return explicit_key.strip()
    return os.environ.get("GEMINI_API_KEY", "").strip()


def load_templates() -> tuple[str, str]:
    gh_tpl = PROJECT_ROOT / ".github" / "RELEASE_TEMPLATE.md"
    play_tpl = PROJECT_ROOT / ".github" / "RELEASE_TEMPLATE_PLAYSTORE.md"

    gh_content = gh_tpl.read_text(encoding="utf-8") if gh_tpl.exists() else ""
    play_content = play_tpl.read_text(encoding="utf-8") if play_tpl.exists() else ""

    return gh_content, play_content


def generate_with_gemini(
    api_key: str,
    version: str,
    last_tag: str,
    commit_log: str,
    diff_stat: str,
    gh_template: str,
    play_template: str
) -> tuple[str, str]:
    print(f"[*] Requesting release notes from Gemini API for v{version}...")

    prompt = f"""You are a principal release manager and technical copywriter for "GeoGame" (a modern cross-platform Flutter geography quiz & world map exploration game).

Generate two comprehensive, accurate, and highly professional release notes documents for version {version}.

============================================================
ACTUAL GIT CHANGES (since previous version: {last_tag or 'initial commit'}):
============================================================

COMMIT HISTORY:
{commit_log}

MODIFIED FILES & STATS:
{diff_stat}

============================================================
REQUIREMENT 1: GitHub Release Notes (RELEASE_{version}.md)
============================================================
You MUST strictly follow the format, style, and tone of this official repository template:

{gh_template}

Strict Rules for GitHub Notes:
1. English ONLY:
   - Generate release notes purely in English. Do NOT include any Turkish section, translations, or separators.
2. Title Format:
   - Start directly with: "## <Short Release Title in English>" (e.g., "## Architecture Refactoring & Build Automation").
   - DO NOT repeat or include the version number (e.g., do NOT write "GeoGame v{version}" or "Version {version}") in the title or anywhere in the body, as GitHub Release already displays the version number in its header.
3. Categories and Order:
   - "> **⚠️ Breaking Changes**":
     - Place this blockquote at the very top ONLY if there are breaking changes (e.g., breaking API alterations, migration requirements, minimum SDK bumps):
       > **⚠️ Breaking Changes**
       > - Description of breaking change
     - CRITICAL: If there are NO breaking changes, COMPLETELY OMIT AND SKIP this block entirely. Do NOT output the header, do NOT write "(if any)", and do NOT write "None".
   - "### 🚀 Features & Improvements":
     - Group into bold topic categories (e.g., "* **Feature or Improvement Name:**").
     - Include detailed sub-bullets explaining the technical architecture, key classes/files, and user impact.
     - DO NOT invent generic filler (such as "minor UI glitches" or "routine maintenance") if specific features or workflows were added in the commits!
   - "### 🐛 Bug Fixes":
     - Specific bug fixes with brief cause and resolution. If none, write "* None."
4. Do NOT output instruction remnants such as "(if any)" or "(varsa)".

============================================================
REQUIREMENT 2: Google Play Store Release Notes (RELEASE_PLAY_STORE_{version}.md)
============================================================
You MUST follow this template and provide localized release notes for all 7 supported languages of GeoGame:
1. eng -> <en-US> (English)
2. tur -> <tr-TR> (Türkçe)
3. deu -> <de-DE> (Deutsch)
4. spa -> <es-ES> (Español)
5. fra -> <fr-FR> (Français)
6. por -> <pt-BR> and <pt-PT> (Português)
7. rus -> <ru-RU> (Русский)

{play_template}

CRITICAL PLAY STORE INSTRUCTIONS:
- Full Localization Required: Unlike GitHub notes (which are English-only), Google Play Store notes MUST BE FULLY LOCALIZED AND TRANSLATED into ALL 7 supported languages above, especially <tr-TR> (Türkçe) and <pt-BR> / <pt-PT> (Português).
- ABSOLUTELY NO PLACEHOLDERS: NEVER output placeholder text (e.g. "buraya girin", "enter here", "[...]", "yapıştırın") or leave tags blank. Every single locale tag MUST contain fully written, engaging, and professional release notes.
- HARD LIMIT: Each language's text inside <locale> and </locale> MUST BE UNDER 500 CHARACTERS (Google Play Console strictly rejects anything over 500 characters). Aim for 250-400 characters per locale.
- Tone: User-facing, engaging, highlighting the most exciting features and stability improvements for players.

============================================================
RESPONSE FORMAT:
============================================================
Respond ONLY with a valid JSON object with exactly two keys:
{{
  "github_notes": "<markdown content for RELEASE_{version}.md>",
  "play_store_notes": "<en-US>\\n...\\n</en-US>\\n\\n<tr-TR>\\n...\\n</tr-TR>\\n\\n..."
}}
"""
    models = [
        "models/gemini-3.8-flash",
        "models/gemini-3.6-flash",
        "models/gemini-3.5-flash-lite"
    ]
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseMimeType": "application/json"
        }
    }

    last_error = None
    for model in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/{model}:generateContent?key={api_key}"
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


def validate_play_store_notes(content: str) -> bool:
    print("\n[*] Validating Play Store character limits (Max 500 per locale):")
    required_locales = ["en-US", "tr-TR", "de-DE", "es-ES", "fr-FR", "ru-RU"]
    pt_found = ("<pt-BR>" in content) or ("<pt-PT>" in content)

    pattern = r"<([a-zA-Z]{2}-[a-zA-Z]{2})>\s*(.*?)\s*</\1>"
    matches = dict(re.findall(pattern, content, re.DOTALL))

    all_ok = True
    for loc, text in matches.items():
        text = text.strip()
        char_count = len(text)
        is_placeholder = any(p in text.lower() for p in ["buraya girin", "enter here", "[", "yapıştırın"])
        status = "OK" if char_count <= 500 and not is_placeholder else "INVALID"
        if char_count > 500 or is_placeholder:
            all_ok = False
        print(f"    - {loc}: {char_count} chars [{status}]" + (" (PLACEHOLDER DETECTED!)" if is_placeholder else ""))

    for req in required_locales:
        if req not in matches:
            print(f"    - {req}: NOT FOUND (warning)")
            all_ok = False
    if not pt_found:
        print("    - pt-BR / pt-PT: NOT FOUND (warning)")
        all_ok = False

    return all_ok


def main():
    parser = argparse.ArgumentParser(description="GeoGame Release Notes Generator (Workflow)")
    parser.add_argument("--version", "-v", help="Release version (default: from pubspec.yaml)")
    parser.add_argument("--engine", "-e", default="gemini",
                        help="Generator engine (kept for workflow backward compatibility)")
    parser.add_argument("--api-key", "-k", help="Gemini API Key (optional, defaults to GEMINI_API_KEY env var)")
    args = parser.parse_args()

    version = args.version or get_current_version()
    print(f"=== GeoGame Release Notes Generator (v{version}) ===")

    last_tag, commit_log, diff_stat = get_git_context(version)
    print(f"[*] Commits to summarize:\n{commit_log}\n")
    if diff_stat:
        print(f"[*] Diff stat summary:\n{diff_stat}\n")

    api_key = get_gemini_api_key(args.api_key)
    if not api_key:
        print("[!] Error: No GEMINI_API_KEY found.")
        print("    Provide it via --api-key or set the GEMINI_API_KEY environment variable.")
        sys.exit(1)

    gh_template, play_template = load_templates()
    gh_notes, play_notes = generate_with_gemini(
        api_key=api_key,
        version=version,
        last_tag=last_tag,
        commit_log=commit_log,
        diff_stat=diff_stat,
        gh_template=gh_template,
        play_template=play_template
    )

    gh_file = PROJECT_ROOT / f"RELEASE_{version}.md"
    play_file = PROJECT_ROOT / f"RELEASE_PLAY_STORE_{version}.md"

    gh_file.write_text(gh_notes, encoding="utf-8")
    play_file.write_text(play_notes, encoding="utf-8")

    print(f"\n[+] Successfully saved GitHub release notes: {gh_file.name}")
    print(f"[+] Successfully saved Play Store release notes: {play_file.name}")

    validate_play_store_notes(play_notes)


if __name__ == "__main__":
    main()

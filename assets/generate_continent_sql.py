import json

INPUT_FILE = "countries.json"
OUTPUT_FILE = "continent_countries.sql"

# Tek kıta kuralı:
# Azerbaycan, Türkiye ve Rusya -> Asya
OVERRIDES = {
    "AZE": "Asia",
    "TUR": "Asia",
    "RUS": "Asia",
}

ALLOWED_CONTINENTS = {
    "Africa",
    "Asia",
    "Europe",
    "North America",
    "South America",
    "Oceania",
    "Antarctica",
}


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


with open(INPUT_FILE, "r", encoding="utf-8") as f:
    countries = json.load(f)

rows = []

for country in countries:
    cca3 = country["cca3"]
    continents = country.get("continents", [])

    # Özel mapping
    if cca3 in OVERRIDES:
        continent = OVERRIDES[cca3]

    else:
        if not continents:
            raise ValueError(
                f"{cca3} için continent bulunamadı."
            )

        # Birden fazla kıta varsa hata ver.
        # Böylece fark etmeden yanlış mapping yapmayız.
        if len(continents) != 1:
            raise ValueError(
                f"{cca3} birden fazla kıtada: {continents}"
            )

        continent = continents[0]

    if continent not in ALLOWED_CONTINENTS:
        raise ValueError(
            f"{cca3} bilinmeyen kıta: {continent}"
        )

    rows.append((cca3, continent))


# CCA3'e göre sırala
rows.sort(key=lambda x: x[0])


sql = """\
-- countries.json -> achievement_continent_countries
-- Toplam ülke: {count}

INSERT INTO public.achievement_continent_countries
    (cca3, continent)
VALUES
{values}
ON CONFLICT (cca3, continent) DO NOTHING;

""".format(
    count=len(rows),
    values=",\n".join(
        f"    ('{sql_escape(cca3)}', '{sql_escape(continent)}')"
        for cca3, continent in rows
    )
    + ";"
)


# Doğrulama sorguları
sql += """

-- =========================================================
-- DOĞRULAMA
-- =========================================================

SELECT
    continent,
    COUNT(*) AS country_count
FROM public.achievement_continent_countries
GROUP BY continent
ORDER BY continent;


SELECT COUNT(*) AS total_countries
FROM public.achievement_continent_countries;
"""


with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(sql)


print(f"SQL oluşturuldu: {OUTPUT_FILE}")
print(f"Toplam ülke: {len(rows)}")

from collections import Counter

counts = Counter(continent for _, continent in rows)

for continent in sorted(counts):
    print(f"{continent}: {counts[continent]}")
-- 🐱 Query di analisi: gatti nel rifugio Austin Animal Center (ottobre 2013 – maggio 2025)
-- Database: gatti_rifugio.db (SQLite). Si considerano solo gli ingressi con un esito registrato.

-- ============================================================
-- 🧭 Q1. Il quadro generale: quanti gatti e quanti ingressi?
-- ============================================================
SELECT COUNT(DISTINCT id_gatto) AS gatti_diversi,
       COUNT(*)                 AS ingressi,
       MIN(data_ingresso)       AS primo_ingresso,
       MAX(data_ingresso)       AS ultimo_ingresso
FROM ingressi;

-- ============================================================
-- 🚪 Q2. Come escono i gatti dal rifugio? (esiti in %)
-- ============================================================
SELECT esito,
       COUNT(*) AS ingressi,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentuale
FROM ingressi
WHERE esito <> 'Senza esito registrato'
GROUP BY esito
ORDER BY ingressi DESC;

-- ============================================================
-- ⏱️ Q3. Quanti giorni aspetta un gatto prima di essere adottato?
-- (mediana calcolata con la riga centrale, SQLite non ha MEDIAN)
-- ============================================================
WITH adozioni AS (
    SELECT giorni_rifugio,
           ROW_NUMBER() OVER (ORDER BY giorni_rifugio) AS pos,
           COUNT(*) OVER () AS tot
    FROM ingressi
    WHERE esito = 'Adozione'
)
SELECT ROUND(AVG(giorni_rifugio), 1) AS giorni_mediana
FROM adozioni
WHERE pos IN ((tot + 1) / 2, (tot + 2) / 2);

-- ============================================================
-- 🍼 Q4. L'età conta? Adozioni e attesa media per fascia d'età
-- ============================================================
SELECT fascia_eta,
       COUNT(*) AS ingressi,
       ROUND(100.0 * AVG(adottato), 1) AS perc_adottati,
       ROUND(AVG(CASE WHEN adottato = 1 THEN giorni_rifugio END), 1) AS giorni_medi_adozione
FROM ingressi
WHERE esito <> 'Senza esito registrato' AND fascia_eta <> 'Sconosciuta'
GROUP BY fascia_eta
ORDER BY perc_adottati DESC;

-- ============================================================
-- 🐈‍⬛ Q5. I gatti neri vengono adottati meno? (per fascia d'età)
-- ============================================================
SELECT i.fascia_eta,
       CASE WHEN g.gatto_nero = 1 THEN 'Nero' ELSE 'Altri colori' END AS gruppo_colore,
       COUNT(*) AS ingressi,
       ROUND(100.0 * AVG(i.adottato), 1) AS perc_adottati,
       ROUND(AVG(CASE WHEN i.adottato = 1 THEN i.giorni_rifugio END), 1) AS giorni_medi_adozione
FROM ingressi i
JOIN gatti g ON g.id_gatto = i.id_gatto
WHERE i.esito <> 'Senza esito registrato' AND i.fascia_eta <> 'Sconosciuta'
GROUP BY i.fascia_eta, gruppo_colore
ORDER BY i.fascia_eta, gruppo_colore;

-- ============================================================
-- 🎨 Q6. Adozioni per colore principale (solo colori con almeno 2.000 ingressi)
-- ============================================================
SELECT g.colore_principale,
       COUNT(*) AS ingressi,
       ROUND(100.0 * AVG(i.adottato), 1) AS perc_adottati
FROM ingressi i
JOIN gatti g ON g.id_gatto = i.id_gatto
WHERE i.esito <> 'Senza esito registrato'
GROUP BY g.colore_principale
HAVING COUNT(*) >= 2000
ORDER BY perc_adottati DESC;

-- ============================================================
-- 🌸 Q7. La "stagione dei gattini": ingressi e adozioni mese per mese
-- ============================================================
SELECT m.mese,
       m.ingressi,
       COALESCE(a.adozioni, 0) AS adozioni
FROM (SELECT mese, COUNT(*) AS ingressi FROM ingressi GROUP BY mese) m
LEFT JOIN (SELECT CAST(strftime('%m', data_uscita) AS INTEGER) AS mese, COUNT(*) AS adozioni
           FROM ingressi WHERE esito = 'Adozione' GROUP BY 1) a
       ON a.mese = m.mese
ORDER BY m.mese;

-- ============================================================
-- 📈 Q8. Le adozioni crescono negli anni? (solo anni completi 2014-2024)
-- ============================================================
SELECT anno,
       COUNT(*) AS ingressi,
       SUM(adottato) AS adozioni,
       ROUND(100.0 * AVG(adottato), 1) AS perc_adottati
FROM ingressi
WHERE esito <> 'Senza esito registrato' AND anno BETWEEN 2014 AND 2024
GROUP BY anno
ORDER BY anno;

-- ============================================================
-- 🏥 Q9. Come arriva il gatto conta? Tipo di ingresso e condizione
-- ============================================================
SELECT tipo_ingresso,
       COUNT(*) AS ingressi,
       ROUND(100.0 * AVG(adottato), 1) AS perc_adottati
FROM ingressi
WHERE esito <> 'Senza esito registrato'
GROUP BY tipo_ingresso
HAVING COUNT(*) >= 100
ORDER BY perc_adottati DESC;

SELECT condizione,
       COUNT(*) AS ingressi,
       ROUND(100.0 * AVG(adottato), 1) AS perc_adottati
FROM ingressi
WHERE esito <> 'Senza esito registrato'
GROUP BY condizione
HAVING COUNT(*) >= 1000
ORDER BY perc_adottati DESC;

-- ============================================================
-- 🔁 Q10. Quanti gatti tornano nel rifugio più di una volta?
-- ============================================================
SELECT ingressi_per_gatto, COUNT(*) AS gatti
FROM (SELECT id_gatto, COUNT(*) AS ingressi_per_gatto FROM ingressi GROUP BY id_gatto)
GROUP BY ingressi_per_gatto
ORDER BY ingressi_per_gatto;

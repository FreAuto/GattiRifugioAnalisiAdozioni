-- 🗄️ Database dei gatti del rifugio Austin Animal Center (SQLite)
-- 2 tabelle: gatti (un gatto per riga) e ingressi (ogni volta che un gatto entra nel rifugio)

DROP TABLE IF EXISTS ingressi;
DROP TABLE IF EXISTS gatti;

CREATE TABLE gatti (
    id_gatto           TEXT PRIMARY KEY,     -- codice del rifugio, es. A664235
    nome               TEXT,                 -- può mancare
    razza              TEXT,
    razza_comune       INTEGER,              -- 1 = Domestic (gatto comune europeo)
    colore             TEXT,
    colore_principale  TEXT,
    gatto_nero         INTEGER               -- 1 = tutto nero
);

CREATE TABLE ingressi (
    id_ingresso        INTEGER PRIMARY KEY,
    id_gatto           TEXT NOT NULL REFERENCES gatti(id_gatto),
    data_ingresso      TEXT NOT NULL,        -- AAAA-MM-GG HH:MM:SS
    anno               INTEGER,
    mese               INTEGER,
    tipo_ingresso      TEXT,                 -- Randagio, Ceduto dal padrone, ...
    condizione         TEXT,                 -- Normale, Ferito, Malato, ...
    sesso              TEXT,
    eta_giorni         INTEGER,
    fascia_eta         TEXT,
    data_uscita        TEXT,                 -- vuota se non c'è un esito
    esito              TEXT,                 -- Adozione, Trasferimento, ...
    dettaglio_esito    TEXT,
    giorni_rifugio     REAL,
    adottato           INTEGER               -- 1 = adottato
);

CREATE INDEX idx_ingressi_gatto ON ingressi(id_gatto);
CREATE INDEX idx_ingressi_esito ON ingressi(esito);

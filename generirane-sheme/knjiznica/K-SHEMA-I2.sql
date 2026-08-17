CREATE TABLE clan (
    broj_clanske_iskaznice VARCHAR(30) NOT NULL,
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status_clanstva VARCHAR(10) NOT NULL,
    adresa VARCHAR(255) NULL,
    email VARCHAR(254) NULL,

    CONSTRAINT pk_clan
        PRIMARY KEY (broj_clanske_iskaznice),

    CONSTRAINT uq_clan_oib
        UNIQUE (oib),

    CONSTRAINT uq_clan_email
        UNIQUE (email),

    CONSTRAINT chk_clan_status
        CHECK (status_clanstva IN ('aktivno', 'blokirano', 'neaktivno'))
) ENGINE = InnoDB;


CREATE TABLE bibliografski_naslov (
    oznaka_naslova VARCHAR(30) NOT NULL,
    naslov VARCHAR(255) NOT NULL,
    godina_izdanja SMALLINT UNSIGNED NOT NULL,
    isbn VARCHAR(17) NULL,
    izdavac VARCHAR(255) NULL,

    CONSTRAINT pk_bibliografski_naslov
        PRIMARY KEY (oznaka_naslova)
) ENGINE = InnoDB;


CREATE TABLE autor (
    id_autora BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,

    CONSTRAINT pk_autor
        PRIMARY KEY (id_autora)
) ENGINE = InnoDB;


CREATE TABLE autorstvo (
    oznaka_naslova VARCHAR(30) NOT NULL,
    id_autora BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_autorstvo
        PRIMARY KEY (oznaka_naslova, id_autora),

    CONSTRAINT fk_autorstvo_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES bibliografski_naslov (oznaka_naslova)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_autorstvo_autor
        FOREIGN KEY (id_autora)
        REFERENCES autor (id_autora)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE primjerak (
    inventarni_broj VARCHAR(30) NOT NULL,
    oznaka_naslova VARCHAR(30) NOT NULL,
    datum_nabave DATE NOT NULL,
    status VARCHAR(10) NOT NULL,

    CONSTRAINT pk_primjerak
        PRIMARY KEY (inventarni_broj),

    CONSTRAINT chk_primjerak_status
        CHECK (status IN ('dostupan', 'posuđen', 'otpisan')),

    CONSTRAINT fk_primjerak_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES bibliografski_naslov (oznaka_naslova)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE zaposlenik (
    oib CHAR(11) NOT NULL,
    oznaka_zaposlenika VARCHAR(30) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    radno_mjesto VARCHAR(100) NOT NULL,

    CONSTRAINT pk_zaposlenik
        PRIMARY KEY (oib),

    CONSTRAINT uq_zaposlenik_oznaka
        UNIQUE (oznaka_zaposlenika)
) ENGINE = InnoDB;


CREATE TABLE posudba (
    id_posudbe BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    broj_clanske_iskaznice VARCHAR(30) NOT NULL,
    inventarni_broj VARCHAR(30) NOT NULL,
    oib_zaposlenika CHAR(11) NOT NULL,
    datum_posudbe DATE NOT NULL,
    predvideni_datum_povrata DATE NOT NULL,
    stvarni_datum_povrata DATE NULL,

    CONSTRAINT pk_posudba
        PRIMARY KEY (id_posudbe),

    CONSTRAINT fk_posudba_clan
        FOREIGN KEY (broj_clanske_iskaznice)
        REFERENCES clan (broj_clanske_iskaznice)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_primjerak
        FOREIGN KEY (inventarni_broj)
        REFERENCES primjerak (inventarni_broj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_zaposlenik
        FOREIGN KEY (oib_zaposlenika)
        REFERENCES zaposlenik (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_posudba_predvideni_datum
        CHECK (predvideni_datum_povrata >= datum_posudbe),

    CONSTRAINT chk_posudba_stvarni_datum
        CHECK (
            stvarni_datum_povrata IS NULL
            OR stvarni_datum_povrata >= datum_posudbe
        )
) ENGINE = InnoDB;

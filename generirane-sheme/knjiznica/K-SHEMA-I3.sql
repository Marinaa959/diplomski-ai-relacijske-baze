CREATE TABLE CLAN (
    broj_clanske_iskaznice VARCHAR(30) NOT NULL,
    OIB CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status_clanstva VARCHAR(10) NOT NULL,
    adresa VARCHAR(255) NULL,
    email VARCHAR(254) NULL,

    PRIMARY KEY (broj_clanske_iskaznice),
    UNIQUE KEY uq_clan_oib (OIB),
    UNIQUE KEY uq_clan_email (email),

    CONSTRAINT chk_clan_status
        CHECK (status_clanstva IN ('aktivno', 'blokirano', 'neaktivno'))
) ENGINE=InnoDB;


CREATE TABLE BIBLIOGRAFSKI_NASLOV (
    oznaka_naslova VARCHAR(30) NOT NULL,
    naslov VARCHAR(255) NOT NULL,
    godina_izdanja SMALLINT UNSIGNED NOT NULL,
    ISBN VARCHAR(17) NULL,
    izdavac VARCHAR(255) NULL,

    PRIMARY KEY (oznaka_naslova)
) ENGINE=InnoDB;


CREATE TABLE AUTOR (
    autor_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,

    PRIMARY KEY (autor_id)
) ENGINE=InnoDB;


CREATE TABLE AUTORSTVO (
    oznaka_naslova VARCHAR(30) NOT NULL,
    autor_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (oznaka_naslova, autor_id),

    CONSTRAINT fk_autorstvo_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES BIBLIOGRAFSKI_NASLOV (oznaka_naslova)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_autorstvo_autor
        FOREIGN KEY (autor_id)
        REFERENCES AUTOR (autor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE PRIMJERAK (
    inventarni_broj VARCHAR(30) NOT NULL,
    oznaka_naslova VARCHAR(30) NOT NULL,
    datum_nabave DATE NOT NULL,
    status VARCHAR(10) NOT NULL,

    PRIMARY KEY (inventarni_broj),

    CONSTRAINT chk_primjerak_status
        CHECK (status IN ('dostupan', 'posuđen', 'otpisan')),

    CONSTRAINT fk_primjerak_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES BIBLIOGRAFSKI_NASLOV (oznaka_naslova)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE ZAPOSLENIK (
    OIB CHAR(11) NOT NULL,
    oznaka_zaposlenika VARCHAR(30) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    radno_mjesto VARCHAR(100) NOT NULL,

    PRIMARY KEY (OIB),
    UNIQUE KEY uq_zaposlenik_oznaka (oznaka_zaposlenika)
) ENGINE=InnoDB;


CREATE TABLE POSUDBA (
    posudba_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    broj_clanske_iskaznice VARCHAR(30) NOT NULL,
    inventarni_broj VARCHAR(30) NOT NULL,
    OIB_zaposlenika CHAR(11) NOT NULL,
    datum_posudbe DATE NOT NULL,
    predvideni_datum_povrata DATE NOT NULL,
    stvarni_datum_povrata DATE NULL,

    PRIMARY KEY (posudba_id),

    CONSTRAINT fk_posudba_clan
        FOREIGN KEY (broj_clanske_iskaznice)
        REFERENCES CLAN (broj_clanske_iskaznice)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_primjerak
        FOREIGN KEY (inventarni_broj)
        REFERENCES PRIMJERAK (inventarni_broj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_zaposlenik
        FOREIGN KEY (OIB_zaposlenika)
        REFERENCES ZAPOSLENIK (OIB)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

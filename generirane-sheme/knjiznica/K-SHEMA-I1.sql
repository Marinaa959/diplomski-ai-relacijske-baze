CREATE TABLE clan (
    broj_iskaznice VARCHAR(50) NOT NULL,
    oib VARCHAR(50) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    status_clanstva ENUM('aktivno', 'blokirano', 'neaktivno') NOT NULL,
    adresa VARCHAR(255) NULL,
    email VARCHAR(254) NULL,

    CONSTRAINT pk_clan PRIMARY KEY (broj_iskaznice),
    CONSTRAINT uq_clan_oib UNIQUE (oib),
    CONSTRAINT uq_clan_email UNIQUE (email)
) ENGINE=InnoDB;


CREATE TABLE bibliografski_naslov (
    oznaka_naslova VARCHAR(50) NOT NULL,
    naslov VARCHAR(255) NOT NULL,
    godina_izdanja INT NOT NULL,
    isbn VARCHAR(50) NULL,
    izdavac VARCHAR(255) NULL,

    CONSTRAINT pk_bibliografski_naslov
        PRIMARY KEY (oznaka_naslova)
) ENGINE=InnoDB;


CREATE TABLE autor (
    autor_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,

    CONSTRAINT pk_autor PRIMARY KEY (autor_id)
) ENGINE=InnoDB;


CREATE TABLE naslov_autor (
    oznaka_naslova VARCHAR(50) NOT NULL,
    autor_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_naslov_autor
        PRIMARY KEY (oznaka_naslova, autor_id),

    CONSTRAINT fk_naslov_autor_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES bibliografski_naslov (oznaka_naslova)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_naslov_autor_autor
        FOREIGN KEY (autor_id)
        REFERENCES autor (autor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE primjerak (
    inventarni_broj VARCHAR(50) NOT NULL,
    oznaka_naslova VARCHAR(50) NOT NULL,
    datum_nabave DATE NOT NULL,
    status ENUM('dostupan', 'posuđen', 'otpisan') NOT NULL,

    CONSTRAINT pk_primjerak PRIMARY KEY (inventarni_broj),

    CONSTRAINT fk_primjerak_naslov
        FOREIGN KEY (oznaka_naslova)
        REFERENCES bibliografski_naslov (oznaka_naslova)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE zaposlenik (
    oib VARCHAR(50) NOT NULL,
    oznaka VARCHAR(50) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    radno_mjesto VARCHAR(150) NOT NULL,

    CONSTRAINT pk_zaposlenik PRIMARY KEY (oib),
    CONSTRAINT uq_zaposlenik_oznaka UNIQUE (oznaka)
) ENGINE=InnoDB;


CREATE TABLE posudba (
    posudba_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    broj_iskaznice VARCHAR(50) NOT NULL,
    inventarni_broj VARCHAR(50) NOT NULL,
    zaposlenik_oib VARCHAR(50) NOT NULL,
    datum_posudbe DATE NOT NULL,
    predvideni_datum_povrata DATE NOT NULL,
    stvarni_datum_povrata DATE NULL,

    CONSTRAINT pk_posudba PRIMARY KEY (posudba_id),

    CONSTRAINT fk_posudba_clan
        FOREIGN KEY (broj_iskaznice)
        REFERENCES clan (broj_iskaznice)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_primjerak
        FOREIGN KEY (inventarni_broj)
        REFERENCES primjerak (inventarni_broj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_posudba_zaposlenik
        FOREIGN KEY (zaposlenik_oib)
        REFERENCES zaposlenik (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

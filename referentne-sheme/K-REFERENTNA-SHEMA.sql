DROP DATABASE IF EXISTS diplomski_knjiznica_test;
CREATE DATABASE diplomski_knjiznica_test
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE diplomski_knjiznica_test;
SET NAMES utf8mb4;

CREATE TABLE clan (
    broj_iskaznice VARCHAR(30) NOT NULL,
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    adresa VARCHAR(255) NULL,
    email VARCHAR(254) NULL,
    datum_uclanjenja DATE NOT NULL,
    status_clanstva ENUM('aktivno', 'blokirano', 'neaktivno') NOT NULL,

    CONSTRAINT pk_clan PRIMARY KEY (broj_iskaznice),
    CONSTRAINT uq_clan_oib UNIQUE (oib),
    CONSTRAINT uq_clan_email UNIQUE (email)
) ENGINE = InnoDB;

CREATE TABLE naslov (
    id_naslova INT UNSIGNED NOT NULL,
    isbn VARCHAR(17) NULL,
    naslov VARCHAR(255) NOT NULL,
    godina_izdanja SMALLINT UNSIGNED NOT NULL,
    izdavac VARCHAR(255) NULL,

    CONSTRAINT pk_naslov PRIMARY KEY (id_naslova)
) ENGINE = InnoDB;

CREATE TABLE autor (
    id_autora INT UNSIGNED NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,

    CONSTRAINT pk_autor PRIMARY KEY (id_autora)
) ENGINE = InnoDB;

CREATE TABLE naslov_autor (
    id_naslova INT UNSIGNED NOT NULL,
    id_autora INT UNSIGNED NOT NULL,

    CONSTRAINT pk_naslov_autor PRIMARY KEY (id_naslova, id_autora),
    CONSTRAINT fk_naslov_autor_naslov
        FOREIGN KEY (id_naslova) REFERENCES naslov (id_naslova),
    CONSTRAINT fk_naslov_autor_autor
        FOREIGN KEY (id_autora) REFERENCES autor (id_autora)
) ENGINE = InnoDB;

CREATE TABLE primjerak (
    inventarni_broj VARCHAR(30) NOT NULL,
    id_naslova INT UNSIGNED NOT NULL,
    datum_nabave DATE NOT NULL,
    status_primjerka ENUM('dostupan', 'posuđen', 'otpisan') NOT NULL,

    CONSTRAINT pk_primjerak PRIMARY KEY (inventarni_broj),
    CONSTRAINT fk_primjerak_naslov
        FOREIGN KEY (id_naslova) REFERENCES naslov (id_naslova)
) ENGINE = InnoDB;

CREATE TABLE zaposlenik (
    id_zaposlenika INT UNSIGNED NOT NULL,
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    radno_mjesto VARCHAR(150) NOT NULL,

    CONSTRAINT pk_zaposlenik PRIMARY KEY (id_zaposlenika),
    CONSTRAINT uq_zaposlenik_oib UNIQUE (oib)
) ENGINE = InnoDB;

CREATE TABLE posudba (
    id_posudbe INT UNSIGNED NOT NULL,
    broj_iskaznice VARCHAR(30) NOT NULL,
    inventarni_broj VARCHAR(30) NOT NULL,
    id_zaposlenika INT UNSIGNED NOT NULL,
    datum_posudbe DATE NOT NULL,
    predvideni_povrat DATE NOT NULL,
    stvarni_povrat DATE NULL,

    CONSTRAINT pk_posudba PRIMARY KEY (id_posudbe),
    CONSTRAINT fk_posudba_clan
        FOREIGN KEY (broj_iskaznice) REFERENCES clan (broj_iskaznice),
    CONSTRAINT fk_posudba_primjerak
        FOREIGN KEY (inventarni_broj) REFERENCES primjerak (inventarni_broj),
    CONSTRAINT fk_posudba_zaposlenik
        FOREIGN KEY (id_zaposlenika) REFERENCES zaposlenik (id_zaposlenika),

    CONSTRAINT chk_posudba_predvideni_povrat
        CHECK (predvideni_povrat >= datum_posudbe),
    CONSTRAINT chk_posudba_stvarni_povrat
        CHECK (stvarni_povrat IS NULL OR stvarni_povrat >= datum_posudbe)
) ENGINE = InnoDB;

-- Pravilo: isti primjerak ne smije imati više istodobno aktivnih posudbi.
-- Aktivna posudba definirana je s STVARNI_POVRAT IS NULL.
DELIMITER //

CREATE TRIGGER trg_posudba_jedna_aktivna_insert
BEFORE INSERT ON posudba
FOR EACH ROW
BEGIN
    IF NEW.stvarni_povrat IS NULL
       AND EXISTS (
           SELECT 1
           FROM posudba
           WHERE inventarni_broj = NEW.inventarni_broj
             AND stvarni_povrat IS NULL
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Primjerak već ima aktivnu posudbu.';
    END IF;
END//

CREATE TRIGGER trg_posudba_jedna_aktivna_update
BEFORE UPDATE ON posudba
FOR EACH ROW
BEGIN
    IF NEW.stvarni_povrat IS NULL
       AND EXISTS (
           SELECT 1
           FROM posudba
           WHERE inventarni_broj = NEW.inventarni_broj
             AND stvarni_povrat IS NULL
             AND id_posudbe <> OLD.id_posudbe
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Primjerak već ima aktivnu posudbu.';
    END IF;
END//

DELIMITER ;

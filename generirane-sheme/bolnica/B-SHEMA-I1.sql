CREATE TABLE BOLNICKA_SOBA (
    oznaka_sobe VARCHAR(255) NOT NULL,
    tip_sobe VARCHAR(255) NOT NULL,
    broj_kreveta SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (oznaka_sobe),
    CHECK (broj_kreveta > 0)
) ENGINE = InnoDB;


CREATE TABLE PACIJENT (
    oib VARCHAR(255) NOT NULL,
    ime VARCHAR(255) NOT NULL,
    prezime VARCHAR(255) NOT NULL,
    datum_rodenja DATE NOT NULL,
    spol VARCHAR(255) NOT NULL,
    adresa VARCHAR(255) NULL,
    oznaka_sobe VARCHAR(255) NULL,
    PRIMARY KEY (oib),
    CONSTRAINT fk_pacijent_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES BOLNICKA_SOBA (oznaka_sobe)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE MEDICINSKA_SESTRA (
    oib VARCHAR(255) NOT NULL,
    ime VARCHAR(255) NOT NULL,
    prezime VARCHAR(255) NOT NULL,
    strucni_stupanj VARCHAR(255) NOT NULL,
    PRIMARY KEY (oib)
) ENGINE = InnoDB;


CREATE TABLE KIRURG (
    oib VARCHAR(255) NOT NULL,
    ime VARCHAR(255) NOT NULL,
    prezime VARCHAR(255) NOT NULL,
    adresa VARCHAR(255) NULL,
    broj_telefona VARCHAR(255) NULL,
    PRIMARY KEY (oib)
) ENGINE = InnoDB;


CREATE TABLE KONZULTANT (
    oib VARCHAR(255) NOT NULL,
    specijalnost VARCHAR(255) NOT NULL,
    PRIMARY KEY (oib),
    CONSTRAINT fk_konzultant_kirurg
        FOREIGN KEY (oib)
        REFERENCES KIRURG (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE OPERACIJSKA_SALA (
    oznaka_sale VARCHAR(255) NOT NULL,
    PRIMARY KEY (oznaka_sale)
) ENGINE = InnoDB;


CREATE TABLE OPERACIJA (
    oznaka_operacije VARCHAR(255) NOT NULL,
    tip_operacije VARCHAR(255) NOT NULL,
    datum DATE NOT NULL,
    vrijeme TIME NOT NULL,
    oib_pacijenta VARCHAR(255) NOT NULL,
    oib_kirurga VARCHAR(255) NOT NULL,
    oznaka_sale VARCHAR(255) NOT NULL,
    PRIMARY KEY (oznaka_operacije),

    CONSTRAINT fk_operacija_pacijent
        FOREIGN KEY (oib_pacijenta)
        REFERENCES PACIJENT (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES KIRURG (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE ZADUZENJE_SESTRE_SOBA (
    oib_sestre VARCHAR(255) NOT NULL,
    oznaka_sobe VARCHAR(255) NOT NULL,
    datum_zaduzivanja DATE NOT NULL,
    PRIMARY KEY (oib_sestre),

    CONSTRAINT fk_zss_sestra
        FOREIGN KEY (oib_sestre)
        REFERENCES MEDICINSKA_SESTRA (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_zss_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES BOLNICKA_SOBA (oznaka_sobe)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE ZADUZENJE_SESTRE_SALA (
    oib_sestre VARCHAR(255) NOT NULL,
    oznaka_sale VARCHAR(255) NOT NULL,
    PRIMARY KEY (oib_sestre),

    CONSTRAINT fk_zsal_sestra
        FOREIGN KEY (oib_sestre)
        REFERENCES MEDICINSKA_SESTRA (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_zsal_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE ASISTENCIJA (
    oznaka_operacije VARCHAR(255) NOT NULL,
    oib_kirurga VARCHAR(255) NOT NULL,
    PRIMARY KEY (oznaka_operacije, oib_kirurga),

    CONSTRAINT fk_asistencija_operacija
        FOREIGN KEY (oznaka_operacije)
        REFERENCES OPERACIJA (oznaka_operacije)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_asistencija_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES KIRURG (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE NADGLEDANJE (
    oib_konzultanta VARCHAR(255) NOT NULL,
    oib_kirurga VARCHAR(255) NOT NULL,
    PRIMARY KEY (oib_konzultanta, oib_kirurga),

    CONSTRAINT fk_nadgledanje_konzultant
        FOREIGN KEY (oib_konzultanta)
        REFERENCES KONZULTANT (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_nadgledanje_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES KIRURG (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CHECK (oib_konzultanta <> oib_kirurga)
) ENGINE = InnoDB;


CREATE TABLE PRIVATNI_PACIJENT (
    oib_konzultanta VARCHAR(255) NOT NULL,
    oib_pacijenta VARCHAR(255) NOT NULL,
    PRIMARY KEY (oib_konzultanta, oib_pacijenta),

    CONSTRAINT fk_pp_konzultant
        FOREIGN KEY (oib_konzultanta)
        REFERENCES KONZULTANT (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_pp_pacijent
        FOREIGN KEY (oib_pacijenta)
        REFERENCES PACIJENT (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE OPREMLJENOST_SALE (
    oznaka_sale VARCHAR(255) NOT NULL,
    tip_operacije VARCHAR(255) NOT NULL,
    PRIMARY KEY (oznaka_sale, tip_operacije),

    CONSTRAINT fk_opremljenost_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

Zabrana da izvođač operacije istodobno bude evidentiran kao asistent može se provesti okidačima:
DELIMITER //

CREATE TRIGGER bi_asistencija
BEFORE INSERT ON ASISTENCIJA
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM OPERACIJA o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.oib_kirurga = NEW.oib_kirurga
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne može na istoj operaciji biti asistent.';
    END IF;
END//

CREATE TRIGGER bu_operacija_izvodac
BEFORE UPDATE ON OPERACIJA
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ASISTENCIJA a
        WHERE a.oznaka_operacije = NEW.oznaka_operacije
          AND a.oib_kirurga = NEW.oib_kirurga
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Asistent iste operacije ne može postati njezin izvođač.';
    END IF;
END//

DELIMITER ;

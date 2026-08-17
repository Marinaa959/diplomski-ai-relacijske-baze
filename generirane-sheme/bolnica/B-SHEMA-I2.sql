CREATE TABLE PACIJENT (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_rodjenja DATE NOT NULL,
    spol VARCHAR(30) NOT NULL,
    adresa VARCHAR(255) NULL,
    PRIMARY KEY (oib)
) ENGINE=InnoDB;

CREATE TABLE BOLNICKA_SOBA (
    oznaka_sobe VARCHAR(64) NOT NULL,
    tip_sobe VARCHAR(100) NOT NULL,
    broj_kreveta INT UNSIGNED NOT NULL,
    PRIMARY KEY (oznaka_sobe)
) ENGINE=InnoDB;

CREATE TABLE MEDICINSKA_SESTRA (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    strucni_stupanj VARCHAR(100) NOT NULL,
    PRIMARY KEY (oib)
) ENGINE=InnoDB;

CREATE TABLE KIRURG (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    adresa VARCHAR(255) NULL,
    broj_telefona VARCHAR(50) NULL,
    PRIMARY KEY (oib)
) ENGINE=InnoDB;

CREATE TABLE KONZULTANT (
    oib VARCHAR(32) NOT NULL,
    specijalnost VARCHAR(150) NOT NULL,
    PRIMARY KEY (oib),
    CONSTRAINT fk_konzultant_kirurg
        FOREIGN KEY (oib) REFERENCES KIRURG(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE TIP_OPERACIJE (
    tip VARCHAR(100) NOT NULL,
    PRIMARY KEY (tip)
) ENGINE=InnoDB;

CREATE TABLE OPERACIJSKA_SALA (
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (oznaka_sale)
) ENGINE=InnoDB;

CREATE TABLE OPERACIJA (
    oznaka_operacije VARCHAR(64) NOT NULL,
    tip VARCHAR(100) NOT NULL,
    pacijent_oib VARCHAR(32) NOT NULL,
    kirurg_oib VARCHAR(32) NOT NULL,
    datum DATE NOT NULL,
    vrijeme TIME NOT NULL,
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (oznaka_operacije),

    CONSTRAINT fk_operacija_tip
        FOREIGN KEY (tip) REFERENCES TIP_OPERACIJE(tip)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_pacijent
        FOREIGN KEY (pacijent_oib) REFERENCES PACIJENT(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_kirurg
        FOREIGN KEY (kirurg_oib) REFERENCES KIRURG(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_sala
        FOREIGN KEY (oznaka_sale) REFERENCES OPERACIJSKA_SALA(oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE SMJESTAJ (
    pacijent_oib VARCHAR(32) NOT NULL,
    oznaka_sobe VARCHAR(64) NOT NULL,
    PRIMARY KEY (pacijent_oib),

    CONSTRAINT fk_smjestaj_pacijent
        FOREIGN KEY (pacijent_oib) REFERENCES PACIJENT(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_smjestaj_soba
        FOREIGN KEY (oznaka_sobe) REFERENCES BOLNICKA_SOBA(oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ZADUZENJE_SOBE (
    sestra_oib VARCHAR(32) NOT NULL,
    oznaka_sobe VARCHAR(64) NOT NULL,
    datum_zaduzivanja DATE NOT NULL,
    PRIMARY KEY (sestra_oib),

    CONSTRAINT fk_zad_sobe_sestra
        FOREIGN KEY (sestra_oib) REFERENCES MEDICINSKA_SESTRA(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_zad_sobe_soba
        FOREIGN KEY (oznaka_sobe) REFERENCES BOLNICKA_SOBA(oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ZADUZENJE_SALE (
    sestra_oib VARCHAR(32) NOT NULL,
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (sestra_oib),

    CONSTRAINT fk_zad_sale_sestra
        FOREIGN KEY (sestra_oib) REFERENCES MEDICINSKA_SESTRA(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_zad_sale_sala
        FOREIGN KEY (oznaka_sale) REFERENCES OPERACIJSKA_SALA(oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ASISTIRANJE (
    operacija_oznaka VARCHAR(64) NOT NULL,
    kirurg_oib VARCHAR(32) NOT NULL,
    PRIMARY KEY (operacija_oznaka, kirurg_oib),

    CONSTRAINT fk_asist_operacija
        FOREIGN KEY (operacija_oznaka) REFERENCES OPERACIJA(oznaka_operacije)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_asist_kirurg
        FOREIGN KEY (kirurg_oib) REFERENCES KIRURG(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE NADGLEDANJE (
    konzultant_oib VARCHAR(32) NOT NULL,
    kirurg_oib VARCHAR(32) NOT NULL,
    PRIMARY KEY (konzultant_oib, kirurg_oib),

    CONSTRAINT fk_nadgledanje_konzultant
        FOREIGN KEY (konzultant_oib) REFERENCES KONZULTANT(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_nadgledanje_kirurg
        FOREIGN KEY (kirurg_oib) REFERENCES KIRURG(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE PRIVATNI_PACIJENT (
    konzultant_oib VARCHAR(32) NOT NULL,
    pacijent_oib VARCHAR(32) NOT NULL,
    PRIMARY KEY (konzultant_oib, pacijent_oib),

    CONSTRAINT fk_priv_pacijent_konzultant
        FOREIGN KEY (konzultant_oib) REFERENCES KONZULTANT(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_priv_pacijent_pacijent
        FOREIGN KEY (pacijent_oib) REFERENCES PACIJENT(oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE OPREMLJENOST_SALE (
    oznaka_sale VARCHAR(64) NOT NULL,
    tip_operacije VARCHAR(100) NOT NULL,
    PRIMARY KEY (oznaka_sale, tip_operacije),

    CONSTRAINT fk_opremljenost_sala
        FOREIGN KEY (oznaka_sale) REFERENCES OPERACIJSKA_SALA(oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_opremljenost_tip
        FOREIGN KEY (tip_operacije) REFERENCES TIP_OPERACIJE(tip)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

Primarni ključ sestra_oib u tablicama ZADUZENJE_SOBE i ZADUZENJE_SALE ostvaruje ograničenje da sestra može imati najviše jedno zaduženje odgovarajuće vrste.
Za ograničenja koja ovise o podacima iz više tablica potrebni su okidači:
DELIMITER //

CREATE TRIGGER trg_asistiranje_bi
BEFORE INSERT ON ASISTIRANJE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM OPERACIJA o
        WHERE o.oznaka_operacije = NEW.operacija_oznaka
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Kirurg koji izvodi operaciju ne moze istodobno biti asistent.';
    END IF;
END//

CREATE TRIGGER trg_asistiranje_bu
BEFORE UPDATE ON ASISTIRANJE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM OPERACIJA o
        WHERE o.oznaka_operacije = NEW.operacija_oznaka
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Kirurg koji izvodi operaciju ne moze istodobno biti asistent.';
    END IF;
END//

CREATE TRIGGER trg_operacija_bu
BEFORE UPDATE ON OPERACIJA
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ASISTIRANJE a
        WHERE a.operacija_oznaka = NEW.oznaka_operacije
          AND a.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Kirurg koji izvodi operaciju ne moze biti evidentiran kao asistent.';
    END IF;
END//

CREATE TRIGGER trg_privatni_pacijent_bi
BEFORE INSERT ON PRIVATNI_PACIJENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM SMJESTAJ s
        JOIN BOLNICKA_SOBA b
          ON b.oznaka_sobe = s.oznaka_sobe
        WHERE s.pacijent_oib = NEW.pacijent_oib
          AND UPPER(b.tip_sobe) = 'PRIVATNA'
          AND b.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER trg_privatni_pacijent_bu
BEFORE UPDATE ON PRIVATNI_PACIJENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM SMJESTAJ s
        JOIN BOLNICKA_SOBA b
          ON b.oznaka_sobe = s.oznaka_sobe
        WHERE s.pacijent_oib = NEW.pacijent_oib
          AND UPPER(b.tip_sobe) = 'PRIVATNA'
          AND b.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER trg_smjestaj_bu
BEFORE UPDATE ON SMJESTAJ
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PRIVATNI_PACIJENT p
        WHERE p.pacijent_oib = NEW.pacijent_oib
    )
    AND NOT EXISTS (
        SELECT 1
        FROM BOLNICKA_SOBA b
        WHERE b.oznaka_sobe = NEW.oznaka_sobe
          AND UPPER(b.tip_sobe) = 'PRIVATNA'
          AND b.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Privatni pacijent mora ostati u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER trg_smjestaj_bd
BEFORE DELETE ON SMJESTAJ
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PRIVATNI_PACIJENT p
        WHERE p.pacijent_oib = OLD.pacijent_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Privatnom pacijentu ne moze se ukloniti smjestaj.';
    END IF;
END//

CREATE TRIGGER trg_soba_bu
BEFORE UPDATE ON BOLNICKA_SOBA
FOR EACH ROW
BEGIN
    IF (
        UPPER(NEW.tip_sobe) <> 'PRIVATNA'
        OR NEW.broj_kreveta <> 1
    )
    AND EXISTS (
        SELECT 1
        FROM SMJESTAJ s
        JOIN PRIVATNI_PACIJENT p
          ON p.pacijent_oib = s.pacijent_oib
        WHERE s.oznaka_sobe = OLD.oznaka_sobe
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Soba s privatnim pacijentom mora biti privatna i jednokrevetna.';
    END IF;
END//

DELIMITER ;

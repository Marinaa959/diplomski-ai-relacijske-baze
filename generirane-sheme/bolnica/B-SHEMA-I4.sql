CREATE TABLE soba (
    oznaka_sobe VARCHAR(64) NOT NULL,
    tip_sobe VARCHAR(100) NOT NULL,
    broj_kreveta SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (oznaka_sobe)
) ENGINE=InnoDB;

CREATE TABLE pacijent (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_rodenja DATE NOT NULL,
    spol VARCHAR(50) NOT NULL,
    adresa VARCHAR(255) NULL,
    oznaka_sobe VARCHAR(64) NULL,
    PRIMARY KEY (oib),
    CONSTRAINT fk_pacijent_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES soba (oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE medicinska_sestra (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    strucni_stupanj VARCHAR(100) NOT NULL,
    PRIMARY KEY (oib)
) ENGINE=InnoDB;

CREATE TABLE kirurg (
    oib VARCHAR(32) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    adresa VARCHAR(255) NULL,
    broj_telefona VARCHAR(50) NULL,
    PRIMARY KEY (oib)
) ENGINE=InnoDB;

CREATE TABLE konzultant (
    oib VARCHAR(32) NOT NULL,
    specijalnost VARCHAR(150) NOT NULL,
    PRIMARY KEY (oib),
    CONSTRAINT fk_konzultant_kirurg
        FOREIGN KEY (oib)
        REFERENCES kirurg (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tip_operacije (
    tip VARCHAR(150) NOT NULL,
    PRIMARY KEY (tip)
) ENGINE=InnoDB;

CREATE TABLE operacijska_sala (
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (oznaka_sale)
) ENGINE=InnoDB;

CREATE TABLE operacija (
    oznaka_operacije VARCHAR(64) NOT NULL,
    tip VARCHAR(150) NOT NULL,
    oib_pacijenta VARCHAR(32) NOT NULL,
    oib_kirurga VARCHAR(32) NOT NULL,
    datum DATE NOT NULL,
    vrijeme TIME NOT NULL,
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (oznaka_operacije),

    CONSTRAINT fk_operacija_tip
        FOREIGN KEY (tip)
        REFERENCES tip_operacije (tip)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_pacijent
        FOREIGN KEY (oib_pacijenta)
        REFERENCES pacijent (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES kirurg (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES operacijska_sala (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE zaduzenje_sobe (
    oib_sestre VARCHAR(32) NOT NULL,
    oznaka_sobe VARCHAR(64) NOT NULL,
    datum_zaduzivanja DATE NOT NULL,
    PRIMARY KEY (oib_sestre),

    CONSTRAINT fk_zs_sestra
        FOREIGN KEY (oib_sestre)
        REFERENCES medicinska_sestra (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_zs_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES soba (oznaka_sobe)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE zaduzenje_sale (
    oib_sestre VARCHAR(32) NOT NULL,
    oznaka_sale VARCHAR(64) NOT NULL,
    PRIMARY KEY (oib_sestre),

    CONSTRAINT fk_zsale_sestra
        FOREIGN KEY (oib_sestre)
        REFERENCES medicinska_sestra (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_zsale_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES operacijska_sala (oznaka_sale)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE asistencija (
    oznaka_operacije VARCHAR(64) NOT NULL,
    oib_kirurga VARCHAR(32) NOT NULL,
    PRIMARY KEY (oznaka_operacije, oib_kirurga),

    CONSTRAINT fk_asistencija_operacija
        FOREIGN KEY (oznaka_operacije)
        REFERENCES operacija (oznaka_operacije)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_asistencija_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES kirurg (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE opremljenost_sale (
    oznaka_sale VARCHAR(64) NOT NULL,
    tip VARCHAR(150) NOT NULL,
    PRIMARY KEY (oznaka_sale, tip),

    CONSTRAINT fk_opremljenost_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES operacijska_sala (oznaka_sale)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_opremljenost_tip
        FOREIGN KEY (tip)
        REFERENCES tip_operacije (tip)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE nadzor (
    oib_konzultanta VARCHAR(32) NOT NULL,
    oib_kirurga VARCHAR(32) NOT NULL,
    PRIMARY KEY (oib_konzultanta, oib_kirurga),

    CONSTRAINT fk_nadzor_konzultant
        FOREIGN KEY (oib_konzultanta)
        REFERENCES konzultant (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_nadzor_kirurg
        FOREIGN KEY (oib_kirurga)
        REFERENCES kirurg (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE privatni_pacijent (
    oib_konzultanta VARCHAR(32) NOT NULL,
    oib_pacijenta VARCHAR(32) NOT NULL,
    PRIMARY KEY (oib_konzultanta, oib_pacijenta),

    CONSTRAINT fk_pp_konzultant
        FOREIGN KEY (oib_konzultanta)
        REFERENCES konzultant (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_pp_pacijent
        FOREIGN KEY (oib_pacijenta)
        REFERENCES pacijent (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

Ograničenje da glavni kirurg ne smije istodobno biti asistent iste operacije zahtijeva provjeru između dviju tablica, pa se u MySQL-u provodi okidačima:
DELIMITER //

CREATE TRIGGER bi_asistencija_glavni_kirurg
BEFORE INSERT ON asistencija
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM operacija o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.oib_kirurga = NEW.oib_kirurga
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne moze biti njezin asistent.';
    END IF;
END//

CREATE TRIGGER bu_asistencija_glavni_kirurg
BEFORE UPDATE ON asistencija
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM operacija o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.oib_kirurga = NEW.oib_kirurga
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne moze biti njezin asistent.';
    END IF;
END//

CREATE TRIGGER bu_operacija_glavni_kirurg
BEFORE UPDATE ON operacija
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM asistencija a
        WHERE a.oznaka_operacije = NEW.oznaka_operacije
          AND a.oib_kirurga = NEW.oib_kirurga
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Odabrani glavni kirurg vec je evidentiran kao asistent.';
    END IF;
END//

DELIMITER ;

Pretpostavka P3: vrijednost tip_sobe = 'privatna' označava privatnu sobu. Uz tu pretpostavku zahtjev za privatne pacijente može se provjeravati okidačima.
DELIMITER //

CREATE TRIGGER bi_privatni_pacijent_soba
BEFORE INSERT ON privatni_pacijent
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pacijent p
        JOIN soba s ON s.oznaka_sobe = p.oznaka_sobe
        WHERE p.oib = NEW.oib_pacijenta
          AND LOWER(s.tip_sobe) = 'privatna'
          AND s.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER bu_pacijent_privatna_soba
BEFORE UPDATE ON pacijent
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM privatni_pacijent pp
        WHERE pp.oib_pacijenta = OLD.oib
    ) AND NOT EXISTS (
        SELECT 1
        FROM soba s
        WHERE s.oznaka_sobe = NEW.oznaka_sobe
          AND LOWER(s.tip_sobe) = 'privatna'
          AND s.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Privatni pacijent mora ostati u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER bu_soba_privatni_pacijenti
BEFORE UPDATE ON soba
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pacijent p
        JOIN privatni_pacijent pp
          ON pp.oib_pacijenta = p.oib
        WHERE p.oznaka_sobe = OLD.oznaka_sobe
    )
    AND (
        LOWER(NEW.tip_sobe) <> 'privatna'
        OR NEW.broj_kreveta <> 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Soba s privatnim pacijentom mora biti privatna i imati jedan krevet.';
    END IF;
END//

DELIMITER ;

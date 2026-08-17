CREATE TABLE SOBA (
    oznaka_sobe VARCHAR(50) NOT NULL,
    tip_sobe VARCHAR(100) NOT NULL,
    broj_kreveta SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_soba PRIMARY KEY (oznaka_sobe),
    CONSTRAINT chk_soba_broj_kreveta CHECK (broj_kreveta > 0)
) ENGINE=InnoDB;


CREATE TABLE PACIJENT (
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_rodenja DATE NOT NULL,
    spol VARCHAR(30) NOT NULL,
    adresa VARCHAR(255) NULL,
    oznaka_sobe VARCHAR(50) NULL,

    CONSTRAINT pk_pacijent PRIMARY KEY (oib),
    CONSTRAINT chk_pacijent_oib CHECK (oib REGEXP '^[0-9]{11}$'),

    CONSTRAINT fk_pacijent_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES SOBA (oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE OPERACIJSKA_SALA (
    oznaka_sale VARCHAR(50) NOT NULL,
    CONSTRAINT pk_operacijska_sala PRIMARY KEY (oznaka_sale)
) ENGINE=InnoDB;


CREATE TABLE MEDICINSKA_SESTRA (
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    strucni_stupanj VARCHAR(100) NOT NULL,
    oznaka_sobe VARCHAR(50) NULL,
    datum_zaduzivanja DATE NULL,
    oznaka_sale VARCHAR(50) NULL,

    CONSTRAINT pk_medicinska_sestra PRIMARY KEY (oib),
    CONSTRAINT chk_sestra_oib CHECK (oib REGEXP '^[0-9]{11}$'),

    CONSTRAINT chk_zaduzenje_sobe CHECK (
        (oznaka_sobe IS NULL AND datum_zaduzivanja IS NULL)
        OR
        (oznaka_sobe IS NOT NULL AND datum_zaduzivanja IS NOT NULL)
    ),

    CONSTRAINT fk_sestra_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES SOBA (oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_sestra_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE KIRURG (
    oib CHAR(11) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    adresa VARCHAR(255) NULL,
    broj_telefona VARCHAR(30) NULL,

    CONSTRAINT pk_kirurg PRIMARY KEY (oib),
    CONSTRAINT chk_kirurg_oib CHECK (oib REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;


CREATE TABLE KONZULTANT (
    kirurg_oib CHAR(11) NOT NULL,
    specijalnost VARCHAR(150) NOT NULL,

    CONSTRAINT pk_konzultant PRIMARY KEY (kirurg_oib),

    CONSTRAINT fk_konzultant_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES KIRURG (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE OPERACIJA (
    oznaka_operacije VARCHAR(50) NOT NULL,
    tip_operacije VARCHAR(150) NOT NULL,
    pacijent_oib CHAR(11) NOT NULL,
    kirurg_oib CHAR(11) NOT NULL,
    datum DATE NOT NULL,
    vrijeme TIME NOT NULL,
    oznaka_sale VARCHAR(50) NOT NULL,

    CONSTRAINT pk_operacija PRIMARY KEY (oznaka_operacije),

    CONSTRAINT fk_operacija_pacijent
        FOREIGN KEY (pacijent_oib)
        REFERENCES PACIJENT (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES KIRURG (oib)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_operacija_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE ASISTIRANJE (
    kirurg_oib CHAR(11) NOT NULL,
    oznaka_operacije VARCHAR(50) NOT NULL,

    CONSTRAINT pk_asistiranje
        PRIMARY KEY (kirurg_oib, oznaka_operacije),

    CONSTRAINT fk_asistiranje_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES KIRURG (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_asistiranje_operacija
        FOREIGN KEY (oznaka_operacije)
        REFERENCES OPERACIJA (oznaka_operacije)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE NADGLEDANJE (
    konzultant_oib CHAR(11) NOT NULL,
    kirurg_oib CHAR(11) NOT NULL,

    CONSTRAINT pk_nadgledanje
        PRIMARY KEY (konzultant_oib, kirurg_oib),

    CONSTRAINT fk_nadgledanje_konzultant
        FOREIGN KEY (konzultant_oib)
        REFERENCES KONZULTANT (kirurg_oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_nadgledanje_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES KIRURG (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE PRIVATNI_PACIJENT (
    konzultant_oib CHAR(11) NOT NULL,
    pacijent_oib CHAR(11) NOT NULL,

    CONSTRAINT pk_privatni_pacijent
        PRIMARY KEY (konzultant_oib, pacijent_oib),

    CONSTRAINT fk_privatni_pacijent_konzultant
        FOREIGN KEY (konzultant_oib)
        REFERENCES KONZULTANT (kirurg_oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_privatni_pacijent_pacijent
        FOREIGN KEY (pacijent_oib)
        REFERENCES PACIJENT (oib)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE OPREMLJENOST_SALE (
    oznaka_sale VARCHAR(50) NOT NULL,
    tip_operacije VARCHAR(150) NOT NULL,

    CONSTRAINT pk_opremljenost_sale
        PRIMARY KEY (oznaka_sale, tip_operacije),

    CONSTRAINT fk_opremljenost_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES OPERACIJSKA_SALA (oznaka_sale)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

Za pravilo da glavni kirurg ne može istodobno biti evidentiran kao asistent:
DELIMITER //

CREATE TRIGGER trg_asistiranje_bi
BEFORE INSERT ON ASISTIRANJE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM OPERACIJA o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne može na istoj operaciji biti asistent.';
    END IF;
END//

CREATE TRIGGER trg_asistiranje_bu
BEFORE UPDATE ON ASISTIRANJE
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM OPERACIJA o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne može na istoj operaciji biti asistent.';
    END IF;
END//

CREATE TRIGGER trg_operacija_bu
BEFORE UPDATE ON OPERACIJA
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ASISTIRANJE a
        WHERE a.oznaka_operacije = NEW.oznaka_operacije
          AND a.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Glavni kirurg već je evidentiran kao asistent na toj operaciji.';
    END IF;
END//

DELIMITER ;

Za pravilo o privatnim pacijentima nužno je provjeravati podatke iz više tablica. Uz pretpostavku P4 da se privatna soba u tip_sobe označava vrijednošću 'privatna':
DELIMITER //

CREATE TRIGGER trg_privatni_pacijent_bi
BEFORE INSERT ON PRIVATNI_PACIJENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM PACIJENT p
        JOIN SOBA s ON s.oznaka_sobe = p.oznaka_sobe
        WHERE p.oib = NEW.pacijent_oib
          AND s.tip_sobe = 'privatna'
          AND s.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END//

CREATE TRIGGER trg_pacijent_bu_private
BEFORE UPDATE ON PACIJENT
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PRIVATNI_PACIJENT pp
        WHERE pp.pacijent_oib = OLD.oib
    ) THEN
        IF NEW.oznaka_sobe IS NULL OR NOT EXISTS (
            SELECT 1
            FROM SOBA s
            WHERE s.oznaka_sobe = NEW.oznaka_sobe
              AND s.tip_sobe = 'privatna'
              AND s.broj_kreveta = 1
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Privatni pacijent mora ostati u jednokrevetnoj privatnoj sobi.';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_soba_bu_private
BEFORE UPDATE ON SOBA
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PACIJENT p
        JOIN PRIVATNI_PACIJENT pp
          ON pp.pacijent_oib = p.oib
        WHERE p.oznaka_sobe = OLD.oznaka_sobe
    ) THEN
        IF NEW.tip_sobe <> 'privatna'
           OR NEW.broj_kreveta <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Soba s privatnim pacijentom mora biti privatna i jednokrevetna.';
        END IF;
    END IF;
END//

DELIMITER ;

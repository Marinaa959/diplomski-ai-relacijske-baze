CREATE TABLE Soba (
    oznaka_sobe VARCHAR(50) NOT NULL,
    tip_sobe VARCHAR(100) NOT NULL,
    broj_kreveta SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_soba PRIMARY KEY (oznaka_sobe),
    CONSTRAINT chk_soba_broj_kreveta CHECK (broj_kreveta > 0)
) ENGINE=InnoDB;


CREATE TABLE Pacijent (
    oib VARCHAR(20) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    datum_rodjenja DATE NOT NULL,
    spol VARCHAR(50) NOT NULL,
    adresa VARCHAR(255) NULL,
    oznaka_sobe VARCHAR(50) NULL,

    CONSTRAINT pk_pacijent PRIMARY KEY (oib),

    CONSTRAINT fk_pacijent_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES Soba (oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Medicinska_Sestra (
    oib VARCHAR(20) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    strucni_stupanj VARCHAR(100) NOT NULL,

    CONSTRAINT pk_medicinska_sestra PRIMARY KEY (oib)
) ENGINE=InnoDB;


CREATE TABLE Zaduzenje_Sobe (
    sestra_oib VARCHAR(20) NOT NULL,
    oznaka_sobe VARCHAR(50) NOT NULL,
    datum_zaduzivanja DATE NOT NULL,

    CONSTRAINT pk_zaduzenje_sobe PRIMARY KEY (sestra_oib),

    CONSTRAINT fk_zad_sobe_sestra
        FOREIGN KEY (sestra_oib)
        REFERENCES Medicinska_Sestra (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_zad_sobe_soba
        FOREIGN KEY (oznaka_sobe)
        REFERENCES Soba (oznaka_sobe)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Kirurg (
    oib VARCHAR(20) NOT NULL,
    ime VARCHAR(100) NOT NULL,
    prezime VARCHAR(100) NOT NULL,
    adresa VARCHAR(255) NULL,
    broj_telefona VARCHAR(50) NULL,

    CONSTRAINT pk_kirurg PRIMARY KEY (oib)
) ENGINE=InnoDB;


CREATE TABLE Konzultant (
    oib VARCHAR(20) NOT NULL,
    specijalnost VARCHAR(150) NOT NULL,

    CONSTRAINT pk_konzultant PRIMARY KEY (oib),

    CONSTRAINT fk_konzultant_kirurg
        FOREIGN KEY (oib)
        REFERENCES Kirurg (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Tip_Operacije (
    tip VARCHAR(100) NOT NULL,
    CONSTRAINT pk_tip_operacije PRIMARY KEY (tip)
) ENGINE=InnoDB;


CREATE TABLE Operacijska_Sala (
    oznaka_sale VARCHAR(50) NOT NULL,
    CONSTRAINT pk_operacijska_sala PRIMARY KEY (oznaka_sale)
) ENGINE=InnoDB;


CREATE TABLE Opremljenost_Sale (
    oznaka_sale VARCHAR(50) NOT NULL,
    tip VARCHAR(100) NOT NULL,

    CONSTRAINT pk_opremljenost_sale
        PRIMARY KEY (oznaka_sale, tip),

    CONSTRAINT fk_opremljenost_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES Operacijska_Sala (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_opremljenost_tip
        FOREIGN KEY (tip)
        REFERENCES Tip_Operacije (tip)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Operacija (
    oznaka_operacije VARCHAR(50) NOT NULL,
    tip VARCHAR(100) NOT NULL,
    pacijent_oib VARCHAR(20) NOT NULL,
    kirurg_oib VARCHAR(20) NOT NULL,
    datum DATE NOT NULL,
    vrijeme TIME NOT NULL,
    oznaka_sale VARCHAR(50) NOT NULL,

    CONSTRAINT pk_operacija PRIMARY KEY (oznaka_operacije),

    CONSTRAINT fk_operacija_tip
        FOREIGN KEY (tip)
        REFERENCES Tip_Operacije (tip)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_operacija_pacijent
        FOREIGN KEY (pacijent_oib)
        REFERENCES Pacijent (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_operacija_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES Kirurg (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_operacija_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES Operacijska_Sala (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Asistiranje (
    oznaka_operacije VARCHAR(50) NOT NULL,
    kirurg_oib VARCHAR(20) NOT NULL,

    CONSTRAINT pk_asistiranje
        PRIMARY KEY (oznaka_operacije, kirurg_oib),

    CONSTRAINT fk_asistiranje_operacija
        FOREIGN KEY (oznaka_operacije)
        REFERENCES Operacija (oznaka_operacije)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_asistiranje_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES Kirurg (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Zaduzenje_Sale (
    sestra_oib VARCHAR(20) NOT NULL,
    oznaka_sale VARCHAR(50) NOT NULL,

    CONSTRAINT pk_zaduzenje_sale PRIMARY KEY (sestra_oib),

    CONSTRAINT fk_zad_sale_sestra
        FOREIGN KEY (sestra_oib)
        REFERENCES Medicinska_Sestra (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_zad_sale_sala
        FOREIGN KEY (oznaka_sale)
        REFERENCES Operacijska_Sala (oznaka_sale)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Nadzor (
    konzultant_oib VARCHAR(20) NOT NULL,
    kirurg_oib VARCHAR(20) NOT NULL,

    CONSTRAINT pk_nadzor
        PRIMARY KEY (konzultant_oib, kirurg_oib),

    CONSTRAINT chk_nadzor_razlicite_osobe
        CHECK (konzultant_oib <> kirurg_oib),

    CONSTRAINT fk_nadzor_konzultant
        FOREIGN KEY (konzultant_oib)
        REFERENCES Konzultant (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_nadzor_kirurg
        FOREIGN KEY (kirurg_oib)
        REFERENCES Kirurg (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;


CREATE TABLE Privatni_Pacijent (
    konzultant_oib VARCHAR(20) NOT NULL,
    pacijent_oib VARCHAR(20) NOT NULL,

    CONSTRAINT pk_privatni_pacijent
        PRIMARY KEY (konzultant_oib, pacijent_oib),

    CONSTRAINT fk_privatni_konzultant
        FOREIGN KEY (konzultant_oib)
        REFERENCES Konzultant (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT fk_privatni_pacijent
        FOREIGN KEY (pacijent_oib)
        REFERENCES Pacijent (oib)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE=InnoDB;

Uvjet da kirurg koji izvodi operaciju nije istodobno njezin asistent zahtijeva međutabličnu provjeru. U MySQL-u se može održavati okidačima:
DELIMITER $$

CREATE TRIGGER trg_asistiranje_bi
BEFORE INSERT ON Asistiranje
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Operacija o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne može na istoj operaciji biti asistent.';
    END IF;
END$$


CREATE TRIGGER trg_asistiranje_bu
BEFORE UPDATE ON Asistiranje
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Operacija o
        WHERE o.oznaka_operacije = NEW.oznaka_operacije
          AND o.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju ne može na istoj operaciji biti asistent.';
    END IF;
END$$


CREATE TRIGGER trg_operacija_bu
BEFORE UPDATE ON Operacija
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Asistiranje a
        WHERE a.oznaka_operacije = NEW.oznaka_operacije
          AND a.kirurg_oib = NEW.kirurg_oib
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Kirurg koji izvodi operaciju već je evidentiran kao asistent.';
    END IF;
END$$

DELIMITER ;

Pravilo o privatnim pacijentima također zahtijeva međutabličnu provjeru. Pri nastanku veze pacijent mora biti smješten u privatnoj sobi s jednim krevetom:
DELIMITER $$

CREATE TRIGGER trg_privatni_pacijent_bi
BEFORE INSERT ON Privatni_Pacijent
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Pacijent p
        JOIN Soba s ON s.oznaka_sobe = p.oznaka_sobe
        WHERE p.oib = NEW.pacijent_oib
          AND s.tip_sobe = 'privatna'
          AND s.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END$$


CREATE TRIGGER trg_privatni_pacijent_bu
BEFORE UPDATE ON Privatni_Pacijent
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Pacijent p
        JOIN Soba s ON s.oznaka_sobe = p.oznaka_sobe
        WHERE p.oib = NEW.pacijent_oib
          AND s.tip_sobe = 'privatna'
          AND s.broj_kreveta = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Privatni pacijent mora biti smjesten u jednokrevetnoj privatnoj sobi.';
    END IF;
END$$


CREATE TRIGGER trg_pacijent_soba_bu
BEFORE UPDATE ON Pacijent
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Privatni_Pacijent pp
        WHERE pp.pacijent_oib = OLD.oib
    ) THEN
        IF NEW.oznaka_sobe IS NULL OR NOT EXISTS (
            SELECT 1
            FROM Soba s
            WHERE s.oznaka_sobe = NEW.oznaka_sobe
              AND s.tip_sobe = 'privatna'
              AND s.broj_kreveta = 1
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Privatni pacijent mora ostati u jednokrevetnoj privatnoj sobi.';
        END IF;
    END IF;
END$$


CREATE TRIGGER trg_soba_bu
BEFORE UPDATE ON Soba
FOR EACH ROW
BEGIN
    IF (NEW.tip_sobe <> 'privatna' OR NEW.broj_kreveta <> 1)
       AND EXISTS (
           SELECT 1
           FROM Pacijent p
           JOIN Privatni_Pacijent pp ON pp.pacijent_oib = p.oib
           WHERE p.oznaka_sobe = OLD.oznaka_sobe
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Soba privatnog pacijenta mora biti privatna i imati jedan krevet.';
    END IF;
END$$

DELIMITER ;

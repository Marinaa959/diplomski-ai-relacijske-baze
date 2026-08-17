INSERT INTO clan
(broj_iskaznice, oib, ime, prezime, adresa, email, datum_uclanjenja, status_clanstva)
VALUES
('C001', '11111111111', 'Ana',   'Kovač', 'Zagreb',    'ana.kovac@example.hr',   '2024-01-15', 'aktivno'),
('C002', '22222222222', 'Marko', 'Babić', 'Split',     'marko.babic@example.hr', '2024-03-10', 'aktivno'),
('C003', '33333333333', 'Ivana', 'Marić', 'Rijeka',    NULL,                     '2024-05-20', 'blokirano'),
('C004', '44444444444', 'Luka',  'Jurić', 'Osijek',    'luka.juric@example.hr',  '2025-01-05', 'aktivno'),
('C005', '55555555555', 'Petra', 'Novak', NULL,        NULL,                     '2025-04-12', 'neaktivno'),
('C006', '66666666666', 'Toni',  'Radić', 'Zadar',     'toni.radic@example.hr',  '2025-06-01', 'aktivno'),
('C007', '77777777777', 'Sara',  'Matić', 'Pula',      'sara.matic@example.hr',  '2025-12-01', 'aktivno'),
('C008', '88888888888', 'Dario', 'Perić', 'Varaždin',  NULL,                     '2026-02-14', 'aktivno');

INSERT INTO naslov
(id_naslova, isbn, naslov, godina_izdanja, izdavac)
VALUES
(101, '9789530000001', 'Baze podataka',          2020, 'Alfa'),
(102, '9789530000002', 'SQL u praksi',           2021, 'Beta'),
(103, NULL,            'Modeliranje podataka',   2019, 'Gamma'),
(104, '9789530000004', 'Algoritmi',              2022, 'Delta'),
(105, NULL,            'Informacijski sustavi',  2018, NULL),
(106, '9789530000006', 'Arhitektura računala',   2023, 'Epsilon');

INSERT INTO autor
(id_autora, ime, prezime)
VALUES
(201, 'Ana',   'Horvat'),
(202, 'Marko', 'Marić'),
(203, 'Iva',   'Novak'),
(204, 'Petar', 'Kralj');

INSERT INTO naslov_autor
(id_naslova, id_autora)
VALUES
(101, 201),
(102, 201),
(103, 201),
(103, 203),
(104, 202),
(105, 204),
(106, 203);

INSERT INTO primjerak
(inventarni_broj, id_naslova, datum_nabave, status_primjerka)
VALUES
('INV-001', 101, '2025-01-10', 'posuđen'),
('INV-002', 101, '2026-07-05', 'dostupan'),
('INV-003', 102, '2026-06-15', 'posuđen'),
('INV-004', 102, '2026-07-20', 'dostupan'),
('INV-005', 103, '2025-11-11', 'dostupan'),
('INV-006', 103, '2026-07-31', 'posuđen'),
('INV-007', 104, '2026-05-20', 'posuđen'),
('INV-008', 104, '2025-10-10', 'dostupan'),
('INV-009', 105, '2024-09-01', 'dostupan'),
('INV-010', 105, '2026-06-01', 'otpisan');

INSERT INTO zaposlenik
(id_zaposlenika, oib, ime, prezime, radno_mjesto)
VALUES
(301, '90111111111', 'Maja', 'Klarić', 'knjižničar'),
(302, '90222222222', 'Ivan', 'Božić',  'knjižničar'),
(303, '90333333333', 'Nina', 'Lovrić', 'voditelj');

INSERT INTO posudba
(id_posudbe, broj_iskaznice, inventarni_broj, id_zaposlenika,
 datum_posudbe, predvideni_povrat, stvarni_povrat)
VALUES
( 1, 'C003', 'INV-002', 301, '2026-05-01', '2026-05-10', '2026-05-25'),
( 2, 'C003', 'INV-004', 303, '2026-06-01', '2026-06-10', '2026-06-22'),
( 3, 'C003', 'INV-005', 302, '2026-07-01', '2026-07-10', '2026-07-19'),
( 4, 'C004', 'INV-008', 302, '2026-05-05', '2026-05-15', '2026-05-17'),
( 5, 'C004', 'INV-009', 301, '2026-06-05', '2026-06-15', '2026-06-19'),
( 6, 'C004', 'INV-002', 303, '2026-07-05', '2026-07-15', '2026-07-18'),
( 7, 'C001', 'INV-001', 301, '2026-04-01', '2026-04-10', '2026-04-20'),
( 8, 'C001', 'INV-003', 301, '2026-05-10', '2026-05-20', '2026-05-26'),
( 9, 'C001', 'INV-005', 302, '2026-06-10', '2026-06-20', '2026-06-18'),
(10, 'C006', 'INV-009', 301, '2026-05-15', '2026-05-25', '2026-05-24'),
(11, 'C007', 'INV-005', 303, '2026-05-20', '2026-05-30', '2026-05-29'),
(12, 'C008', 'INV-002', 302, '2026-06-20', '2026-06-30', '2026-06-30'),
(13, 'C006', 'INV-004', 303, '2026-07-10', '2026-07-20', '2026-07-20'),
(14, 'C007', 'INV-008', 303, '2026-07-15', '2026-07-25', '2026-07-24'),
(15, 'C008', 'INV-009', 301, '2026-07-20', '2026-07-30', '2026-07-29'),
(16, 'C001', 'INV-001', 301, '2026-08-01', '2026-08-15', NULL),
(17, 'C001', 'INV-003', 302, '2026-08-02', '2026-08-16', NULL),
(18, 'C002', 'INV-006', 301, '2026-08-03', '2026-08-17', NULL),
(19, 'C002', 'INV-007', 302, '2026-08-03', '2026-08-17', NULL),
(20, 'C006', 'INV-008', 301, '2026-06-05', '2026-06-15', '2026-06-15');

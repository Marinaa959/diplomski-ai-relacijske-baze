# Elektronički prilog uz diplomski rad

Ovaj repozitorij sadrži elektronički prilog uz diplomski rad
„Primjena AI alata u oblikovanju relacijskih baza podataka”.

Skripte su korištene za provjeru izvršivosti generiranih relacijskih
shema i ispravnosti generiranih SQL upita u sustavu MySQL 8.4.

## Oznake

- `K` označava knjižnični informacijski sustav.
- `B` označava bolnički informacijski sustav.
- `J` označava jednostavan SQL zadatak.
- `S` označava srednje složen SQL zadatak.
- `Z` označava složen SQL zadatak.
- `I1` do `I5` označavaju pojedina izvođenja generiranja.

## Sadržaj

| Mapa ili datoteke | Sadržaj |
|---|---|
| `referentne-sheme/` | Skripte za stvaranje referentnih relacijskih shema |
| `kontrolni-podaci/` | Skripte za unos kontrolnih podataka |
| `K-SHEMA-I1.sql` – `K-SHEMA-I5.sql` | Pet generiranih implementacija knjižničnog sustava, provjerenih prema zahtjevima K1–K15 |
| `B-SHEMA-I1.sql` – `B-SHEMA-I5.sql` | Pet generiranih implementacija bolničkog sustava, provjerenih prema zahtjevima B1–B15 |
| `K-J1.sql` – `K-J5.sql` | Jednostavni zadaci knjižničnog sustava |
| `K-S1.sql` – `K-S5.sql` | Srednje složeni zadaci knjižničnog sustava |
| `K-Z1-I1.sql` – `K-Z5-I3.sql` | Tri izvođenja složenih zadataka knjižničnog sustava |
| `B-J1.sql` – `B-J5.sql` | Jednostavni zadaci bolničkog sustava |
| `B-S1.sql` – `B-S5.sql` | Srednje složeni zadaci bolničkog sustava |
| `B-Z1-I1.sql` – `B-Z5-I3.sql` | Tri izvođenja složenih zadataka bolničkog sustava |

## Pokretanje

Za provjeru SQL upita najprije treba izvršiti odgovarajuću skriptu iz
mape `referentne-sheme`, a zatim skriptu iz mape `kontrolni-podaci`.
Nakon toga mogu se izvršavati pripadajući generirani SQL upiti.

Generirane implementacije relacijskih shema izvršavaju se svaka u
zasebnoj praznoj bazi podataka.

Svi kontrolni podaci potpuno su izmišljeni i ne odnose se na stvarne
osobe, ustanove ni događaje.

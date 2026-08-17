WITH broj_operacija AS (
SELECT
YEAR(o.DATUM) AS godina,
MONTH(o.DATUM) AS mjesec,
o.ID_SALE,
COUNT(*) AS broj_operacija
FROM OPERACIJA AS o
GROUP BY
YEAR(o.DATUM),
MONTH(o.DATUM),
o.ID_SALE
),
rangirane_sale AS (
SELECT
godina,
mjesec,
ID_SALE,
broj_operacija,
DENSE_RANK() OVER (
PARTITION BY godina, mjesec
ORDER BY broj_operacija DESC
) AS rang
FROM broj_operacija
)
SELECT
r.godina,
r.mjesec,
r.ID_SALE,
s.TIP_SALE,
r.broj_operacija
FROM rangirane_sale AS r
JOIN SALA AS s
ON s.ID_SALE = r.ID_SALE
WHERE r.rang = 1
ORDER BY
r.godina,
r.mjesec,
r.ID_SALE;

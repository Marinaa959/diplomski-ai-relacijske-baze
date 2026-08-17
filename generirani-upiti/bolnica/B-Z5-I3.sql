WITH broj_operacija AS (
SELECT
YEAR(o.DATUM) AS godina,
MONTH(o.DATUM) AS mjesec,
o.ID_SALE,
s.TIP_SALE,
COUNT(*) AS broj_operacija
FROM OPERACIJA AS o
JOIN SALA AS s
ON s.ID_SALE = o.ID_SALE
GROUP BY
YEAR(o.DATUM),
MONTH(o.DATUM),
o.ID_SALE,
s.TIP_SALE
),
rangirane_sale AS (
SELECT
godina,
mjesec,
ID_SALE,
TIP_SALE,
broj_operacija,
DENSE_RANK() OVER (
PARTITION BY godina, mjesec
ORDER BY broj_operacija DESC
) AS rang
FROM broj_operacija
)
SELECT
godina,
mjesec,
ID_SALE,
TIP_SALE,
broj_operacija
FROM rangirane_sale
WHERE rang = 1
ORDER BY godina, mjesec, ID_SALE;

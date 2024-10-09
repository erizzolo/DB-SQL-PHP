-- SOLUZIONE !!!
-- Usando il database sakila, scrivere le query (istruzioni SQL) che soddisfano le seguenti richieste:
-- 1. Produrre l'elenco dei film (title, rating e rental_duration) ordinato per rental_duration decrescente.
SELECT title,
    rating,
    rental_duration
FROM film
ORDER BY rental_duration DESC;
-- 2. Produrre l'elenco dei pagamenti (amount, payment_date, customer_id) del mese di giugno 2005 con importo superiore a 3,00.
SELECT amount,
    payment_date,
    customer_id
FROM payment
WHERE amount > 3.00
    AND MONTH(payment_date) = 6
    AND YEAR(payment_date) = 2005;
-- alternativa payment_date BETWEEN '2005-06-01' AND '2005-06-30' (peggio per possibili errori e questioni di formato)
-- PESSIMO!!! payment_date LIKE '2005-06-%' (necessaria conversione a stringa e questioni di formato)
-- 3. Produrre l'elenco degli attori (last_name, first_name) per i quali la lunghezza del nome è maggiore di quella del cognome.
SELECT last_name,
    first_name
FROM actor
WHERE LENGTH(first_name) > LENGTH(last_name);
-- 4. Determinare il numero di film con rating ‘PG-13’ (PG-13: Parents Strongly Cautioned, Some Material May Be Inappropriate for Children Under 13).
-- Caso particolare di funzione di aggregazione (COUNT) usata senza GROUP BY...
SELECT COUNT(*)
FROM film
WHERE rating = 'PG-13';
-- 5. Elencare il numero di film usciti (release_year) in ciascun anno, ma solo per gli anni in cui sono usciti almeno 10 film.
-- N.B. - Filtro sulle singole righe: WHERE (prima dell'elaborazione del GROUP BY)
-- N.B. - Filtro sui gruppi di righe: HAVING (dopo l'elaborazione del GROUP BY)
SELECT COUNT(*) AS numero,
    release_year
FROM film
GROUP BY release_year
HAVING numero >= 10;
-- 6. Produrre un elenco dei DVD (inventory_id, film.title, replacement_cost, payment) per il cui noleggio è stata pagata una somma maggiore del replacement_cost.
-- Interpretazione "semplice": un unico noleggio con pagamento con importo > replacement_cost
-- N.B. - No GROUP BY e condizione in WHERE!
SELECT inventory_id,
    f.title,
    replacement_cost,
    amount
FROM film f
    JOIN inventory i USING (film_id)
    JOIN rental r USING (inventory_id)
    JOIN payment p USING (rental_id)
WHERE amount > replacement_cost;
-- Interpretazione "complessa": tutti i noleggi con pagamento complessivo con importo > replacement_cost
-- N.B. - GROUP BY e condizione in HAVING!
SELECT inventory_id,
    f.title,
    replacement_cost,
    SUM(amount) AS payment
FROM film f
    JOIN inventory i USING (film_id)
    JOIN rental r USING (inventory_id)
    JOIN payment p USING (rental_id)
GROUP BY inventory_id
HAVING payment > replacement_cost;
-- 7. Elenco dei noleggi (film.title, rental_date, return_date) effettuati dal cliente 'SUSAN WILSON'.
SELECT title,
    rental_date,
    return_date
FROM rental r
    JOIN inventory i USING (inventory_id)
    JOIN film f USING (film_id)
    JOIN customer c USING (customer_id)
WHERE CONCAT(c.first_name, ' ', c.last_name) = 'SUSAN WILSON';
-- 8. Elenco dei DVD (inventory_id, n_clienti) noleggiati da almeno 5 clienti diversi.
SELECT i.inventory_id,
    COUNT(DISTINCT customer_id) AS n_clienti
FROM inventory i
    JOIN rental r ON (i.inventory_id = r.inventory_id)
GROUP BY i.inventory_id
HAVING n_clienti >= 5;
-- 9. Elenco degli (sic!!!) film (title) in cui hanno recitato almeno cinque attori.
SELECT title -- , COUNT(*) AS n_attori
FROM film f
    JOIN film_actor fa ON (f.film_id = fa.film_id)
GROUP BY f.film_id
HAVING COUNT(*) >= 5 -- n_attori >= 5
;
-- 10. Elenco dei DVD (inventory_id) per i quali risultano noleggi contemporanei (cioè per i quali risultano almeno due noleggi temporalmente sovrapposti).
-- piuttosto complicata ... ma non impossibile
-- 1. coppie di noleggi (diversi) dello stesso DVD:
-- r1.inventory_id = r2.inventory_id AND r1.rental_id != r2.rental_id :  STESSO DVD MA RENTAL DIVERSI!!!
-- 2. sovrapposizione intervalli temporali:
-- DATI GLI INTERVALLI [I1, F1], [I2, F2] ESSI SONO DISGIUNTI SE : F1 < I2 OR I1 > F2
-- E QUINDI SONO SOVRAPPOSTI SE : NOT( F1 < I2 OR I1 > F2 ) ovvero F1 >= I2 AND I1 <= F2
-- QUI GLI INTERVALLI SONO [rental_date, return_date] MA C'E' IL PROBLEMA DEI VALORI NULL PER return_date!!!
SELECT r1.inventory_id AS DVD
FROM rental r1,
    rental r2
WHERE r1.inventory_id = r2.inventory_id -- same DVD
    AND r1.rental_id != r2.rental_id -- different rentals
    AND r1.return_date >= r2.rental_date
    AND (
        (r1.rental_date <= r2.return_date)
        OR (r2.return_date IS NULL)
    ) -- Overlapping!!!
;
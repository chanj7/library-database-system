-- Users who borrowed both book and laptop which are overdue and have not been returned
USE mm_cpsc502101team04;
SELECT b.user_ID,
       b.ISBN,
       b.book_due_date,
       l.laptop_ID,
       l.laptop_due_date
FROM BOOKS_CHECK_OUT AS b
INNER JOIN LAPTOPS_CHECKED_OUT AS l ON b.user_ID = l.user_ID
WHERE book_due_date < book_check_in_date
  AND laptop_due_date < laptop_check_in_date
ORDER BY b.user_ID;

-- Books where the due day is in less than 1 week but have not been returned 
USE mm_cpsc502101team04;
SELECT c.user_ID,
       CONCAT(u.first_name, ' ', u.last_name) AS user_name,
       b.book_title,
       c.book_due_date
FROM BOOKS_CHECK_OUT AS c
JOIN USERS AS u ON u.user_ID = c.user_ID
JOIN BOOKS AS b ON c.ISBN = b.ISBN
WHERE book_check_in_date IS NULL
  AND book_due_date < '2021-11-18'
  AND book_due_date > '2021-11-11'
ORDER BY c.user_ID;

-- popularity of laptop model being used by Students
USE mm_cpsc502101team04;
SELECT l.laptop_model,
       COUNT(*) laptop_count_by_student
FROM LAPTOPS_CHECKED_OUT AS c
JOIN LAPTOPS AS l ON c.laptop_id = l.laptop_id
JOIN USERS AS u ON u.user_ID = c.user_ID
WHERE u.user_type = 'Student'
GROUP BY l.laptop_model
ORDER BY laptop_count_by_student DESC;

-- popularity of book subject in both students and faculties 
USE mm_cpsc502101team04;
SELECT b.book_subject,
       COUNT(*) bookCount,
       u.user_type
FROM BOOKS_CHECK_OUT AS c
JOIN BOOKS AS b ON b.ISBN = c.ISBN
JOIN USERS AS u ON u.user_ID = c.user_ID
GROUP BY b.book_subject,
         u.user_type
ORDER BY bookCount DESC
LIMIT 10;

-- Average book renting per person in both Students and Faculties
USE mm_cpsc502101team04;
SELECT C.user_type,
       C.count AS num_of_people,
       B.count AS book_count,
       B.count/C.count AS average_book_rent_by_person
FROM
  ( SELECT u.user_type,
           COUNT(*) COUNT
   FROM USERS AS u
   GROUP BY u.user_type) AS C
JOIN
  ( SELECT u.user_type,
           COUNT(*) COUNT
   FROM BOOKS_CHECK_OUT AS c
   JOIN BOOKS AS b ON b.ISBN = c.ISBN
   JOIN USERS AS u ON u.user_ID = c.user_ID
   GROUP BY u.user_type) AS B ON C.user_type = B.user_type;

-- All users with holds
USE mm_cpsc502101team04;
SELECT 
    HOLDS.user_ID,
    USERS.first_name,
    USERS.last_name,
    USERS.user_type AS 'Student/ Faculty',
    HOLDS.ISBN,
    HOLDS.hold_date_ready
FROM
    HOLDS
        INNER JOIN
    USERS ON HOLDS.user_ID = USERS.user_ID
ORDER BY hold_date_ready , last_name
LIMIT 10;

-- All books in French
USE mm_cpsc502101team04;
SELECT 
    ISBN,
    book_title,
    book_year,
    Language
FROM
    BOOKS
WHERE
    Language = 'French'
ORDER BY book_year;

-- Books checked out by a given user that have not yet been returned
USE mm_cpsc502101team04;
SELECT u.user_id, u.first_name, u.last_name, b.book_title, c.book_check_out_date, 
	c.book_check_in_date
FROM USERS u INNER JOIN BOOKS_CHECK_OUT c
ON u.user_id = c.user_id
INNER JOIN BOOKS b
ON c.isbn = b.isbn
WHERE c.book_check_in_date IS NULL
ORDER BY u.user_id;


-- All fiction books with only one copy available
USE mm_cpsc502101team04;
SELECT book_title, book_subject, isbn, num_copies
FROM BOOKS
WHERE num_copies = 1 AND book_subject = 'Fiction'
ORDER BY book_title;

-- All student users with fines due
USE mm_cpsc502101team04;
SELECT u.user_id, u.user_type, u.user_email, f.fine_amount
FROM USERS u INNER JOIN OVERDUE_FINES f
ON u.user_id = f.user_id
WHERE f.fine_amount > 0.00 AND u.user_type = 'Student'
ORDER BY u.user_id;

-- All holds that were ready for pick up before the current day and 
-- have not yet been checked out
USE mm_cpsc502101team04;
SELECT U.user_id, concat(U.first_name, ' ', U.last_name) as user_name, H.ISBN, 
	book_title, hold_date_ready
FROM HOLDS as H JOIN BOOKS_CHECK_OUT as BCO USING (ISBN)
	JOIN USERS as U ON U.user_id = H.user_id
    JOIN BOOKS as B ON B.ISBN = H.ISBN
WHERE NOT EXISTS 
	(SELECT ISBN, user_id
	FROM BOOKS_CHECK_OUT
    	WHERE H.user_id = BCO.user_id)
AND (NOW() > hold_date_ready)
ORDER BY U.user_id;

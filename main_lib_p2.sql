select * from books
select * from branch
select * from empolyees
select * from issued_status
select * from members
select * from return_status

--project tasks
--Task 1.
--Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books (isbn, book_title , category , rental_price , status , author , publisher)
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2:
--Update an Existing Member's Address
update members set 
member_address = '125 Oak St'
where member_id ='c103';

--Task 3:
--Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete  from issued_status
where issued_id = 'IS121';

--Task 4:
--Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where  issued_emp_id = 'E101';

--Task 5:
-- List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id, count(*) as total_issued
from issued_status
group by issued_emp_id
having count(issued_emp_id)>1
order by total_issued asc;


-- CTAS (Create Table As Select)
--Task 6:
-- Create Summary Tables: 
--Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
create table book_issued_counts
as
select b.isbn,b.book_title,count(ist.issued_id) as issued_count
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by b.isbn ,b.book_title;

select * from book_issued_counts 


-- Data Analysis & Findings
--The following SQL queries were used to address specific questions:

--Task 7.
-- Retrieve All Books in a Specific Category:
select * from books 
where category = 'Fantasy';

--Task 8: 
--Find Total Rental Income by Category:
select category,sum(rental_price)as total_income
from books
group by category;

   (OR)

select b.category,sum(b.rental_price)as total_income
from books as b
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by b.category;

--task 9
--List Members Who Registered in the Last 180 Days:

select * from members
where reg_date >=current_date - INTERVAL '180 days';

insert into members(member_id, member_name, member_address, reg_date) 
VALUES
('C120', 'jhon snow', '742 winterfell', '2024-05-7'), 
('C121', 'Alice son', '123 Main vall', '2024-06-1');
delete from members where member_id='C121'

--task 10
--List Employees with Their Branch Manager's Name and their branch details:

select  e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
	brh.*,
	e2.emp_name as manager
	from branch as brh
join
empolyees as e1
on e1.branch_id = brh.branch_id
join 
empolyees as e2
on e2.emp_id = brh.manager_id;

--Task 11.
-- Create a Table of Books with Rental Price Above a Certain Threshold 7$:

create table expensive_books as 
select * from books
where rental_price >7.00;
select * from expensive_books

--Task 12:
-- Retrieve the List of Books Not Yet Returned
select * from return_status

select * from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is  null;

--Advanced SQL Operations
--Task 13: Identify Members with Overdue Books

--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.


    select 
	ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
	rs.return_date,
	CURRENT_DATE - ist.issued_date as over_dues_days
	 from issued_status as ist
	 join members as m 
	 on
	 issued_member_id = member_id
	 join books as b
	 on 
	 b.isbn = ist.issued_book_isbn
	 left join
	 return_status as rs
	 on 
	 rs.issued_id = ist.issued_id
	 where rs.return_date is null
	 and (current_date - ist.issued_date)>30
	 order by ist.issued_member_id

--Task 14:
--Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

select * from books 
where isbn = '978-0-141-44171-6' 

update books 
set status  = 'no'
where isbn = '978-0-141-44171-6';
 select * from books

select * from return_status 
where issued_id = 'IS108'

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    ('RS123','IS134' ,CURRENT_DATE,'Good');
	
update books 
set status  = 'yes'
where isbn = '978-0-141-44171-6';

--store procedures

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$

/*
-- Testing FUNCTION add_return_records

--issued_id = IS135
--ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';
\*/*
-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

/*
Task 15: 
Branch Performance Report
Create a query that generates a performance report 
for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals.
*/*

	 select * from books
select * from branch
select * from empolyees
select * from issued_status
select * from members
select * from return_status

create table branch_reports
as
select
b.branch_id,
b.manager_id,
count(ist.issued_id)as no_of_books_issued,
count(rs.return_id)as no_of_books_return,
sum(bk.rental_price)as total_revenue
from issued_status as ist

join return_status as rs
on 
rs.issued_id = ist.issued_id
join books as bk
on
bk.isbn = ist.issued_book_isbn
join empolyees as ep
on
ep.emp_id = ist.issued_emp_id
join branch as b
on
b.branch_id = ep.branch_id
group by 1,2;

select * from branch_reports

/*Task 16: 
CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table
active_members containing members who have issued at
least one book in the last 2 months.
*/
create table active_members
as
select * from members
where member_id in (
select distinct issued_member_id 
from issued_status
where issued_date >= current_date -interval '2 months'
)

select * from active_members

or

--join method
select m.member_id,
m.member_name,
m.member_address,
m.reg_date
from members as m
join issued_status as ist
on 
m.member_id = ist.issued_member_id
where issued_date >=current_date -interval '2 months'
group by member_id


/*
Task 17:
--Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/*

select
ep.emp_name,
b.*,
count(ist.issued_id) as no_of_issued_books
from empolyees as ep
join issued_status as ist
on 
ep.emp_id = ist.issued_emp_id
join branch as b
on
b.branch_id = ep.branch_id
group by 1,2;

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display
the member name, book title, and the number of times they've issued damaged books.
*/




select * from books
select * from branch
select * from empolyees
select * from issued_status
select * from members
select * from return_status


select 
m.member_name,
bk.book_title ,
count(ist.issued_id)as damaged_books
from issued_status as ist
join members as m
on 
ist.issued_member_id = m.member_id
join return_status as rs
on 
ist.issued_id = rs.issued_id
join books as bk
on 
ist.issued_book_isbn = bk.isbn
where rs.book_quality = 'Damaged'
group by 1,2
having count(ist.issued_id)<2
ORDER BY
    damaged_books DESC,
    m.member_name,
    bk.book_title;

/*Task 19:
Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available,
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the
procedure should return an error message indicating that the book is currently not available.
*/

	
select * from books
select * from branch
select * from empolyees
select * from issued_status
select * from members
select * from return_status



CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

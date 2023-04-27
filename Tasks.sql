1а
with recursive tree(id, last_name, first_name, manager_id) as 
(select id,last_name, first_name, manager_id from bd6_employees 
where id=1
union all
select e.id, e.last_name, e.first_name, e.manager_id from tree 
join bd6_employees e on e.manager_id=tree.id)
select * from tree;
1б
create or replace procedure b() as $$
declare
 e_attrs record;
begin 
for e_attrs in (with recursive tree(id, last_name, first_name, 
manager_id) as 
(select id,last_name, first_name, manager_id from bd6_employees 
where id=1
union all
select e.id, e.last_name, e.first_name, e.manager_id from tree 
join bd6_employees e on e.manager_id=tree.id)
select * from tree)
loop
 raise info '% % %', 
e_attrs.id,e_attrs.last_name,e_attrs.first_name;
end loop;
end;
$$ 
language plpgsql;
call b();
2
CREATE OR REPLACE PROCEDURE change_salary() AS $$
DECLARE attrs bd6_employees%ROWTYPE;
difference numeric(8, 2) :=0;
counter integer :=0;
current_salary numeric(8, 2) := 0;
last_salary_plus_diff numeric (8, 2) :=0;
curs CURSOR FOR SELECT* FROM bd6_employees ORDER BY salary_in_euro;
BEGIN
 OPEN curs;
 LOOP
 FETCH curs INTO attrs;
 IF NOT FOUND THEN
 EXIT; 
 END IF;
 current_salary = attrs.salary_in_euro;
 last_salary_plus_diff = current_salary+difference;
 UPDATE bd6_employees SET salary_in_euro = last_salary_plus_diff -
mod(last_salary_plus_diff, 100)
 WHERE id=attrs.id;
 attrs.salary_in_euro = last_salary_plus_diffmod(last_salary_plus_diff, 100);
 difference = mod(last_salary_plus_diff, 100);
 RAISE INFO '% % %', attrs.last_name, attrs.first_name, 
attrs.salary_in_euro;
 END LOOP;
 CLOSE curs;
END 
$$ LANGUAGE plpgsql;
call change_salary();
3
create or replace procedure e_delete() as $$
declare
 e_attrs record;
begin 
for e_attrs in (select * from bd6_employees order by salary_in_euro 
DESC limit 10)
loop
 update bd6_employees set 
salary_in_euro=salary_in_euro+(select min(salary_in_euro) from 
bd6_employees) where id=e_attrs.id;
update bd6_employees set manager_id= NULL where 
manager_id=(select id from bd6_employees order by salary_in_euro limit 1 
);
delete from bd6_employees where id=(select id from 
bd6_employees order by salary_in_euro limit 1);
end loop;
end
$$ language plpgsql;
call e_delete();
select * from bd6_employees;
4
DROP TABLE IF EXISTS spiral;
create table spiral(f1 integer, f2 integer, f3 integer,f4 integer,f5 
integer);
create or replace procedure ad() as $$
declare
 i integer;
begin 
for i in 0..999
loop
 insert into spiral 
values(i*5+1,i*5+3,i*5+5,i*5+7,i*5+9),(i*5+2,i*5+4,i*5+6,i*5+8,i*5+10);
end loop;
end
$$ language plpgsql;
call ad();
select * from spiral;
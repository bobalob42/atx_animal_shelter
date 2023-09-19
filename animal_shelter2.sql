-- use row_number with partition by Animal ID to create unique id's to join both tables
-- use datediff to find difference in arrival and exit for all instances

select
	concat(abc.Animal_ID, "-", occur) as uniID_i
from (
	select
		i.Animal_ID,
		row_number() over (partition by i.Animal_ID) as occur
	from austin_animal_center_intakes i
	order by Animal_ID) abc;
    
select 
	concat(xyz.`Animal ID`, "-", occur) as uniID_o
from (
	select
		o.`Animal ID`,
        row_number() over (partition by o.`Animal ID`) as occur
	from austin_animal_center_outcomes o
    order by `Animal ID`) xyz;

-- this works but the values would need to be copy and pasted in Sheets to match the new ID's to the appropriate rows.

insert into austin_animal_center_intakes (new_ID)
select
	concat(abc.Animal_ID, "-", occur)
from (
	select
		i.Animal_ID,
        `DateTime`,
		row_number() over (partition by i.Animal_ID) as occur
	from austin_animal_center_intakes i
	order by 1, 2) abc;
    
select *
from austin_animal_center_intakes;

-- repeat with outcome table, new column, new id
alter table austin_animal_center_outcomes
ADD new_ID2 text;

-- add id's
insert into austin_animal_center_outcomes (new_ID2)
select
	concat(abc.`Animal ID`, "-", occur)
from (
	select
		o.`Animal ID`,
        `DateTime`,
		row_number() over (partition by o.`Animal ID`) as occur
	from austin_animal_center_outcomes o
	order by 1,2) abc;
    
-- view updated table with id's
select *
from austin_animal_center_outcomes;

-- the update clause will be more appropriate to keep this in sql
update austin_animal_center_intakes
set new_ID = (
	select
	concat(abc.Animal_ID, "-", occur) as uniID_i
		from (
			select
			i.Animal_ID,
			row_number() over (partition by i.Animal_ID) as occur
		from austin_animal_center_intakes i
		order by Animal_ID) abc
	)
where new_ID is null;

-- update test

with cte as (
		select
			i.Animal_ID,
			`DateTime`,
			row_number() over (partition by i.Animal_ID) as occur
		from austin_animal_center_intakes i
		order by 1, 2
)

update austin_animal_center_intakes
set new_ID = concat(Animal_ID, "-", occur)
where Animal_ID = cte.Animal_ID;

select
	i.Animal_ID,
	`DateTime`,
	row_number() over (partition by i.Animal_ID) as occur
from austin_animal_center_intakes i
order by 1, 2;		

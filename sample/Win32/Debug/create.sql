create table if not exists contacts (
	id integer primary key,
	first_name text not null,
	second_name text not null,
	birth_date text,
	photo blob
);

insert or ignore into contacts (id, first_name, second_name, birth_date) values (1, 'Marek', 'Pichór', '1991-03-24');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (2, 'Ryszard', 'Nowak', '1981-11-27');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (3, 'Jan', 'Kowalski', '1984-06-13');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (4, 'Andrzej', 'Wiœniewski', '1998-04-02');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (5, 'Piotr', 'Wójcik', '2015-07-11');
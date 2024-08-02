create table if not exists contacts (
	id integer primary key,
	first_name varchar(100) not null,
	second_name varchar(100) not null,
	birth_date varchar(100),
	photo blob
);

insert or ignore into contacts (id, first_name, second_name, birth_date) values (1, 'Jakub', 'Grzegorczyk', '1961-03-24');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (2, 'Ryszard', 'Nowak', '1987-11-27');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (3, 'Jan', 'Kowalski', '1993-06-13');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (4, 'Aleksandra', 'Wiœniewska', '1988-04-02');
insert or ignore into contacts (id, first_name, second_name, birth_date) values (5, 'Monika', 'Wójcik', '2017-07-11');
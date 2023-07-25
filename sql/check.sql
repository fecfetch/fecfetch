
CREATE TABLE developers(
	id SERIAL,-- OTO SIRALI VERİ GİRER 1,2,3 ŞEKLİNDE
	name VARCHAR(50) NOT NULL, --ISIM KISMI BOŞ KALAMAZ
	email VARCHAR(50) UNIQUE,
	salary REAL,
	prog_lang VARCHAR(20)
);

SELECT * FROM developers;

INSERT INTO developers(name, email, salary, prog_lang) VALUES(
	'Saffet Bey',
	'email@email.com',
	3000,
	'Python'
	
);
INSERT INTO developers(name, email, salary, prog_lang) VALUES(
	'dadas Bey',
	'das@emadasil.com',--'email@email.com' YAZAMAZDIK, ÇÜNKÜ UNİQUE YAPTIK AMMA AYNI VERMEYE ÇALIŞIYORUZ
	4231,
	'java'
	
);
CREATE TABLE doctors(
	id SERIAL,-- OTO SIRALI VERİ GİRER 1,2,3 ŞEKLİNDE
	name VARCHAR(50) NOT NULL, --ISIM KISMI BOŞ KALAMAZ
	email VARCHAR(50) UNIQUE,
	salary REAL,
	prog_lang VARCHAR(20)
);

SELECT * FROM doctors;

INSERT INTO doctors(name, email, salary) VALUES(
	'dadas Bey',
	'jdf@g.com',
	4231	
);
INSERT INTO doctors(name, email) VALUES(
	'',
	'jd23f@g.com'	
);

CREATE TABLE students1(
	id INT PRIMARY KEY,
	name VARCHAR(50),
	grade REAL,
	reg_date DATE
);

CREATE TABLE students2(
	id INT,
	name VARCHAR(50),
	grade REAL,
	reg_date DATE,
	CONSTRAINT std_pk PRIMARY KEY(id)
);
SELECT * FROM students2;

CREATE TABLE address2(
	addr_id INT,
	street VARCHAR(50),
	number REAL,
	student_id INT,--Foreign key yapcaz
	CONSTRAINT add_pk PRIMARY KEY(addr_id),
	CONSTRAINT add_fk FOREIGN KEY(student_id) REFERENCES students2(id)
);
SELECT * FROM address2;


CREATE TABLE personnel(
	id INT,
	name VARCHAR(50) NOT NULL CHECK(name <> ''), --isim boş olmasın kısıtı (CHECK) , <> not equals demek
	salary REAL CHECK(salary>=5000),--maaş 5000den az olmasın kısıtı
	age INT CHECK(age>0)
	);
	
INSERT INTO personnel VALUES(
	1,
	'Ali',
	10000,	
	25
);
SELECT * FROM personnel;



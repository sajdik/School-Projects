-- TABLES DESTRUCTOR

DROP TABLE administration CASCADE CONSTRAINTS;
DROP TABLE uses CASCADE CONSTRAINTS;
DROP TABLE appropriate CASCADE CONSTRAINTS;
DROP TABLE cure CASCADE CONSTRAINTS;
DROP TABLE animal CASCADE CONSTRAINTS;
DROP TABLE sister CASCADE CONSTRAINTS;
DROP TABLE doctor CASCADE CONSTRAINTS;
DROP TABLE drug CASCADE CONSTRAINTS;
DROP TABLE owner CASCADE CONSTRAINTS;
DROP TABLE species CASCADE CONSTRAINTS;
DROP TABLE employee CASCADE CONSTRAINTS;

-- SEQUENCE DETRUCTOR

DROP SEQUENCE owner_seq;

-- MATERIALIZED VIEW DESTRUCTOR

DROP MATERIALIZED VIEW owned_pets;

-- SEQUENCE CREATOR

CREATE SEQUENCE owner_seq START WITH 1;

-- TABLES CREATOR

CREATE TABLE employee(
    employee_id VARCHAR2(5), -- id
    title VARCHAR2(10),
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    -- adress
    street VARCHAR2(50) NOT NULL,
    city VARCHAR2(50) NOT NULL,
    -- bill
    bank_account VARCHAR2(20) NOT NULL UNIQUE,
    hour_rate FLOAT(10) NOT NULL,
    -- proj4
    personal_num VARCHAR2(11) NOT NULL
);

CREATE TABLE species(
    species_id VARCHAR2(5 CHAR), -- id
    species_name VARCHAR2(50 CHAR) NOT NULL
);

CREATE TABLE owner(
    owner_id VARCHAR2(5 CHAR), -- id
    first_name VARCHAR2(50 CHAR) NOT NULL,
    last_name VARCHAR2(50 CHAR) NOT NULL,
    -- adress
    city VARCHAR2(50 CHAR) NOT NULL,
    street VARCHAR2(50 CHAR) NOT NULL
);

CREATE TABLE drug(
    drug_id VARCHAR2(5 CHAR), -- id
    drug_name VARCHAR2(50 CHAR) NOT NULL,
    drug_type VARCHAR2(50 CHAR) NOT NULL,
    active_substance VARCHAR2(50 CHAR) NOT NULL,
    contraindication VARCHAR2(50 CHAR) NOT NULL
);

CREATE TABLE doctor(
    doctor_id VARCHAR2(5 CHAR) -- id
);

CREATE TABLE sister(
    sister_id VARCHAR2(5 CHAR) -- id
);

CREATE TABLE animal(
    animal_id VARCHAR2(5 CHAR), -- id
    animal_name VARCHAR2(50 CHAR) NOT NULL,
    birth_date DATE,
    last_visit DATE,
    -- foreign keys
    species_id VARCHAR2(5 CHAR),
    owner_id VARCHAR2(5 CHAR)
);

CREATE TABLE cure(
    cure_id VARCHAR2(5 CHAR), -- id
    diagnosis VARCHAR2(50 CHAR) NOT NULL,
    time_stamp TIMESTAMP(6) NOT NULL,
    status VARCHAR2(100) NOT NULL,
    price float(63) NOT NULL,
    -- foreign keys
    animal_id VARCHAR2(5 CHAR),
    doctor_id VARCHAR2(5 CHAR)
);

CREATE TABLE appropriate(
    recommended_dose VARCHAR2(50 CHAR) NOT NULL,
    -- foreign keys
    species_id VARCHAR2(5 CHAR),
    drug_id VARCHAR2(5 CHAR)
);

CREATE TABLE uses(
    dose VARCHAR2(50 CHAR) NOT NULL,
    -- foreign keys
    cure_id VARCHAR2(5 CHAR),
    drug_id VARCHAR2(5 CHAR)
);

CREATE TABLE administration(
    administration_id VARCHAR2(5 CHAR), -- id
    administration_date DATE NOT NULL,
    -- foreign keys
    employee_id VARCHAR2(5 CHAR),
    cure_id VARCHAR2(5 CHAR),
    drug_id VARCHAR2(5 CHAR)
);

-- PRIMARY KEYS

ALTER TABLE employee ADD CONSTRAINT PK_employee PRIMARY KEY (employee_id);
ALTER TABLE species ADD CONSTRAINT PK_species PRIMARY KEY (species_id);
ALTER TABLE owner ADD CONSTRAINT PK_owner PRIMARY KEY (owner_id);
ALTER TABLE drug ADD CONSTRAINT PK_drug PRIMARY KEY (drug_id);
ALTER TABLE doctor ADD CONSTRAINT PK_doctor PRIMARY KEY (doctor_id);
ALTER TABLE sister ADD CONSTRAINT PK_sister PRIMARY KEY (sister_id);
ALTER TABLE animal ADD CONSTRAINT PK_animal PRIMARY KEY (animal_id);
ALTER TABLE cure ADD CONSTRAINT PK_cure PRIMARY KEY (cure_id);
ALTER TABLE administration ADD CONSTRAINT PK_administration PRIMARY KEY (administration_id);

-- FOREIGN KEYS

ALTER TABLE doctor ADD CONSTRAINT FK_doctor FOREIGN KEY (doctor_id) REFERENCES employee;
ALTER TABLE sister ADD CONSTRAINT FK_sister FOREIGN KEY (sister_id) REFERENCES employee;
ALTER TABLE animal ADD CONSTRAINT FK_species_ani FOREIGN KEY (species_id) REFERENCES species;
ALTER TABLE animal ADD CONSTRAINT FK_owner_ani FOREIGN KEY (owner_id) REFERENCES owner;
ALTER TABLE cure ADD CONSTRAINT FK_animal_cure FOREIGN KEY (animal_id) REFERENCES animal;
ALTER TABLE cure ADD CONSTRAINT FK_doctor_cure FOREIGN KEY (doctor_id) REFERENCES doctor;
ALTER TABLE appropriate ADD CONSTRAINT FK_species_app FOREIGN KEY (species_id) REFERENCES species;
ALTER TABLE appropriate ADD CONSTRAINT FK_drug_app FOREIGN KEY (drug_id) REFERENCES drug;
ALTER TABLE uses ADD CONSTRAINT FK_cure_use FOREIGN KEY (cure_id) REFERENCES cure;
ALTER TABLE uses ADD CONSTRAINT FK_drug_use FOREIGN KEY (drug_id) REFERENCES drug;
ALTER TABLE administration ADD CONSTRAINT FK_employee_adm FOREIGN KEY (employee_id) REFERENCES employee;
ALTER TABLE administration ADD CONSTRAINT FK_cure_adm FOREIGN KEY (cure_id) REFERENCES cure;
ALTER TABLE administration ADD CONSTRAINT FK_drug_adm FOREIGN KEY (drug_id) REFERENCES drug;

-- CHECKS

ALTER TABLE employee ADD CONSTRAINT CHECK_hour_rate CHECK (hour_rate >= 0);
ALTER TABLE cure ADD CONSTRAINT CHECK_price CHECK (price >= 0);

-- TRIGGERS

CREATE OR REPLACE TRIGGER owner_id_inc
    BEFORE INSERT ON owner 
    FOR EACH ROW
BEGIN
    SELECT owner_seq.NEXTVAL
    INTO :NEW.owner_id
    FROM dual;
END;
/

CREATE OR REPLACE TRIGGER personal_num
    BEFORE INSERT OR UPDATE OF personal_num ON employee
    FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.personal_num, '^[0-9]{6}\/[0-9]{4}$') THEN
        RAISE VALUE_ERROR;
    END IF;
    
    IF ((NOT (CAST(SUBSTR(:NEW.personal_num, 3, 2) AS INT) BETWEEN 1 AND 12)) OR ((MOD(CAST(SUBSTR(:NEW.personal_num, 1, 2) AS INT), 4) = 0) AND (SUBSTR(:NEW.personal_num, 3, 2) IN ('02')) AND NOT (CAST(SUBSTR(:NEW.personal_num, 5, 2) AS INT) BETWEEN 1 AND 29)) OR ((SUBSTR(:NEW.personal_num, 3, 2) IN ('02')) AND NOT (CAST(SUBSTR(:NEW.personal_num, 5, 2) AS INT) BETWEEN 1 AND 28)) OR ((SUBSTR(:NEW.personal_num, 3, 2) IN ('01', '03', '05', '07', '08', '10', '12')) AND NOT (CAST(SUBSTR(:NEW.personal_num, 5, 2) AS INT) BETWEEN 1 AND 31)) OR ((SUBSTR(:NEW.personal_num, 3, 2) IN ('04', '06', '09', '11')) AND NOT (CAST(SUBSTR(:NEW.personal_num, 5, 2) AS INT) BETWEEN 1 AND 30)))
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'Wrong personal number!');
    END IF;
END;
/

-- Procedures --

-- Print name of spice, number of cured animals of that spice percentage it represent out of all cured animals
-- Argument speciesID - id of species
CREATE OR REPLACE PROCEDURE speciesCount(speciesID IN VARCHAR2)
AS
    CURSOR c_species IS SELECT species_id FROM species NATURAL JOIN animal;
    id c_species%ROWTYPE;
    allCount NUMBER;
    animalCount NUMBER;
    name species.species_name%TYPE;
    percentage NUMBER;
BEGIN
    animalCount := 0;
    allCount := 0;
    SELECT species_name INTO name FROM species WHERE species_id=speciesID;
    open c_species;
    LOOP
        FETCH c_species INTO id;
        EXIT WHEN c_species%NOTFOUND;
        IF (id.species_id = speciesID) THEN
          animalCount := animalCount + 1;
        END IF;
        allCount := allCount + 1;
    END LOOP;
    percentage := ((animalCount*100)/allCount);
    dbms_output.put_line('Animals of species "' || name || '" was cured ' || animalCount || ' times and represents ' || percentage || '% of all cured animals.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Species with id:' || speciesID || ' does not exists');
        WHEN ZERO_DIVIDE THEN
            dbms_output.put_line('No animals in database');
        WHEN OTHERS THEN
            raise_application_error(-20001, 'ERROR: speciesCount procedure failed');
END;
/

-- Print title name, number of employees with this title and average hour_rate with this title for each title
CREATE OR REPLACE PROCEDURE titles
AS
    CURSOR c_titles IS SELECT DISTINCT title FROM employee;
    c_title c_titles%ROWTYPE;
    employeeCount NUMBER;
    avgRate NUMBER;
BEGIN
    OPEN c_titles;
    LOOP
        FETCH c_titles INTO c_title;
        EXIT WHEN c_titles%NOTFOUND;
        SELECT AVG(e.hour_rate) INTO avgRate FROM employee e WHERE e.title=c_title.title;
        SELECT COUNT(e.employee_id) INTO employeeCount FROM employee e WHERE e.title=c_title.title;
        IF (employeeCount = 1) THEN
            dbms_output.put_line(employeeCount || ' employee has ' || c_title.title || ' title with hour rate: ' || avgRate);
        ELSE
            dbms_output.put_line(employeeCount || ' employees have ' || c_title.title || ' title with average hour rate: ' || avgRate);
        END IF;
    END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('No employees');
        WHEN OTHERS THEN
            raise_application_error(-20002, 'ERROR: titleRate procedure failed');
END;
/

-- MATERIALIZED VIEW

DROP MATERIALIZED VIEW owned_pets;

CREATE MATERIALIZED VIEW owned_pets
    BUILD IMMEDIATE
    REFRESH ON COMMIT
AS
    SELECT o.last_name AS NAME, a.animal_name
    FROM owner o, animal a WHERE o.owner_id = a.owner_id;


-- INSERT

INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (1,'Ms','Dee','Kruschev','21561 Namekagon Way','Madan','409-63348016/962',836.826, '730921/6682');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (2,'Rev','Gale','Pogson','43139 Hintze Point','Vilnyansk','830-14296389/889',541.331, '480806/7930');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (3,'Dr','Desi','Orts','603 Hagan Street','Qiongshan','734-53242328/949',575.303, '510126/8935');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (4,'Dr','Dulsea','Pawle','229 Northwestern Way','Sucun','934-12916024/184',664.492, '750603/7477');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (5,'Honorable','Flo','Iannuzzelli','3 Moose Avenue','Bi�r al ?ufayy','994-89273569/002',499.030 , '450421/3010');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (6,'Ms','Jessi','Nials','2 Lerdahl Circle','Dzhalka','577-90260191/753',740.745, '491008/8378');
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (7, 'Rev', 'Omar' ,'Antczak', '4648 Tomscot Court', 'Lingqian', '881-43487011/587', 213.110, '740813/6278');

INSERT INTO species (species_id, species_name)
VALUES(1,'Eagle goldhead');
INSERT INTO species (species_id, species_name)
VALUES(2,'Woodcock american');
INSERT INTO species (species_id, species_name)
VALUES(3,'Grey mouse lemur');
INSERT INTO species (species_id, species_name)
VALUES(4,'African wild dog');
INSERT INTO species (species_id, species_name)
VALUES(5,'Gorila dog');

INSERT INTO owner (first_name, last_name, city, street)
VALUES ('Keelia','Randell','Orivesi','73 Straubel Pass');
INSERT INTO owner (first_name, last_name, city, street)
VALUES ('Nata','Fraser','Cicheng','02 Lerdahl Place');
INSERT INTO owner (first_name, last_name, city, street)
VALUES ('Dorree','Crudginton','Orivesi','23 Porter Road');

INSERT INTO drug (drug_id, drug_name, drug_type, active_substance, contraindication)
VALUES (1,'paralen','IPLP','ADHD','Old');
INSERT INTO drug (drug_id, drug_name, drug_type, active_substance, contraindication)
VALUES (2,'ALAVIS CELADRIN 500 MG','DI','CELADRIN','Young');
INSERT INTO drug (drug_id, drug_name, drug_type, active_substance, contraindication)
VALUES (3,'AURUM 1','KP','AURUM','CELADRIN');
INSERT INTO drug (drug_id, drug_name, drug_type, active_substance, contraindication)
VALUES (4,'BO YEA SACC','KP','SACC','ADHD');
INSERT INTO drug (drug_id, drug_name, drug_type, active_substance, contraindication)
VALUES (5,'CAPRAVERUM CAT KITTENS - LACTATING CATS','DI','CAPRAVERUM','Non lactating cats');

INSERT INTO doctor (doctor_id) VALUES (3);
INSERT INTO doctor (doctor_id) VALUES (4);
INSERT INTO doctor (doctor_id) VALUES (5);

INSERT INTO sister (sister_id) VALUES (1);
INSERT INTO sister (sister_id) VALUES (2);
INSERT INTO sister (sister_id) VALUES (6);
INSERT INTO sister (sister_id) VALUES (7);

INSERT INTO animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (1,'Pepa', TO_DATE('06.07.2015','DD/MM/YYYY'),TO_DATE('10.03.2019','DD/MM/YYYY'),2,1);
INSERT INTO animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (2,'Patrik',TO_DATE('17.05.2018','DD/MM/YYYY'),TO_DATE('26.03.2019','DD/MM/YYYY'),4,1);
INSERT INTO animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (3,'Arin',TO_DATE('06.07.2016','DD/MM/YYYY'),TO_DATE('29.01.2018','DD/MM/YYYY'),3,2);
INSERT INTO animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (4,'Bisc',TO_DATE('19.10.2018','DD/MM/YYYY'),TO_DATE('03.11.2017','DD/MM/YYYY'),1,3);
INSERT INTO animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (5,'Pappi',TO_DATE('23.08.2010','DD/MM/YYYY'),TO_DATE('31.12.2017','DD/MM/YYYY'),2,3);

INSERT INTO cure (cure_id, diagnosis, time_stamp, status, price, animal_id, doctor_id)
VALUES (1,'Broken neck',TO_TIMESTAMP('6:21:45','hh24:mi:ss'),'Healed',5000.00,1,3);
INSERT INTO cure (cure_id, diagnosis, time_stamp, status, price, animal_id, doctor_id)
VALUES (2,'Burned',TO_TIMESTAMP('20:58:39','hh24:mi:ss'),'Next week check up',750.00,2,4);
INSERT INTO cure (cure_id, diagnosis, time_stamp, status, price, animal_id, doctor_id)
VALUES (3,'Lice',TO_TIMESTAMP('3:10:32','hh24:mi:ss'),'Healed',300,4,3);
INSERT INTO cure (cure_id, diagnosis, time_stamp, status, price, animal_id, doctor_id)
VALUES (4,'Broken tooth',TO_TIMESTAMP('4:41:24','hh24:mi:ss'),'Tooth removed',500,5,5);
INSERT INTO cure (cure_id, diagnosis, time_stamp, status, price, animal_id, doctor_id)
VALUES (5,'Fork in eye',TO_TIMESTAMP('11:08:40','hh24:mi:ss'),'Observation',10000.00,3,5);

INSERT INTO appropriate (recommended_dose, species_id, drug_id)
VALUES ('2 per day',1,1);
INSERT INTO appropriate (recommended_dose, species_id, drug_id)
VALUES ('1 per 4 hours',2,3);
INSERT INTO appropriate (recommended_dose, species_id, drug_id)
VALUES ('8 per day',3,2);
INSERT INTO appropriate (recommended_dose, species_id, drug_id)
VALUES ('once a day',4,5);
INSERT INTO appropriate (recommended_dose, species_id, drug_id)
VALUES ('once a week',5,4);

INSERT INTO uses (dose, cure_id, drug_id)
VALUES ('5ml injections every day',1,2);
INSERT INTO uses (dose, cure_id, drug_id)
VALUES ('1 tablet per day',2,4);
INSERT INTO uses (dose, cure_id, drug_id)
VALUES ('8ml per day',4,3);
INSERT INTO uses (dose, cure_id, drug_id)
VALUES ('3 tablets every 8 hours',3,5);
INSERT INTO uses (dose, cure_id, drug_id)
VALUES ('20ml injection per week',5,1);

INSERT INTO administration (administration_id, administration_date, employee_id, cure_id, drug_id)
VALUES (1,TO_DATE('15.02.2018','DD/MM/YYYY'),1,2,1);
INSERT INTO administration (administration_id, administration_date, employee_id, cure_id, drug_id)
VALUES (2,TO_DATE('24.08.2018','DD/MM/YYYY'),6,1,2);
INSERT INTO administration (administration_id, administration_date, employee_id, cure_id, drug_id)
VALUES (3,TO_DATE('18.11.2017','DD/MM/YYYY'),7,3,3);
INSERT INTO administration (administration_id, administration_date, employee_id, cure_id, drug_id)
VALUES (4,TO_DATE('11.08.2017','DD/MM/YYYY'),3,4,4);
INSERT INTO administration (administration_id, administration_date, employee_id, cure_id, drug_id)
VALUES (5,TO_DATE('01.10.2017','DD/MM/YYYY'),5,5,5);


-- SELECTS --

-- 2x select using 2 tables
-- Select name, birth_date and last visit of all animals owned by Keelia Randell
SELECT a.animal_name, a.birth_date, a.last_visit
FROM owner o, animal a
WHERE o.owner_id = a.owner_id and o.first_name = 'Keelia' and o.last_name = 'Randell';
-- Select prices of all animal Pepa cures
SELECT c.price
FROM cure c, animal a
WHERE c.animal_id = a.animal_id AND a.animal_name = 'Pepa';

-- select using 3 tables
-- Select prices of all cures on animals owned by Keelia Randell
SELECT c.price
FROM cure c, animal a, owner o
WHERE c.animal_id = a.animal_id AND a.owner_id= o.owner_id AND o.first_name = 'Keelia' AND o.last_name = 'Randell';

-- 2x select with group by and aggregation function
-- select highest hour rate of employee titles
SELECT e.title, max(e.hour_rate)
FROM employee e
GROUP BY e.title;
-- select cities and count of owners living in them
SELECT o.city, count(o.city)
FROM owner o
GROUP BY o.city;

-- Select with EXISTS
-- select first and last names of employees that never administrated a drug
SELECT e.first_name, e.last_name
FROM employee e
WHERE NOT exists(
  SELECT a.employee_id
  FROM administration a
    WHERE e.employee_id = a.employee_id
);

-- Select with predicate IN
-- Select first and last name of owners of animals with last visit in year 2017
SELECT o.first_name, o.last_name
FROM owner o
WHERE o.owner_id
IN(
    SELECT a.owner_id
    FROM animal a
    WHERE a.last_visit BETWEEN TO_DATE('01.01.2017','DD/MM/YYYY') AND TO_DATE('31.12.2017','DD/MM/YYYY')
  );

-- ACCESS RIGHTS TABLES

GRANT ALL ON employee TO xhampl10;
GRANT ALL ON species TO xhampl10;
GRANT ALL ON owner TO xhampl10;
GRANT ALL ON drug TO xhampl10;
GRANT ALL ON doctor TO xhampl10;
GRANT ALL ON sister TO xhampl10;
GRANT ALL ON animal TO xhampl10;
GRANT ALL ON cure TO xhampl10;
GRANT ALL ON appropriate TO xhampl10;
GRANT ALL ON uses TO xhampl10;
GRANT ALL ON administration TO xhampl10;

-- ACCESS RIGHTS PROCEDURES

GRANT EXECUTE ON speciesCount TO xhampl10;
GRANT EXECUTE ON titles TO xhampl10;


-- ACCESS MATERIALIZED VIEW
GRANT ALL ON owned_pets TO xhampl10;


-- SHOWCASE --

-- PROCEDURES

BEGIN
    titles;
END;

BEGIN
    speciesCount(2);
    speciesCount(5);
    speciesCount(10);
END;


-- TRIGGERS

SELECT * FROM owner;
INSERT INTO owner (first_name, last_name, city, street)
VALUES ('TEST','TEST','TEST','TEST');
SELECT * FROM owner;
-- letter
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (8,'TT','TEST','TEST','TEST','TEST','303-33333333/333',333.333, '73a921/6682');
-- wrong type
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (8,'TT','TEST','TEST','TEST','TEST','303-33333333/333',333.333, '733921-6682');
-- wrong month
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (8,'TT','TEST','TEST','TEST','TEST','303-33333333/333',333.333, '731321/6682');
-- leap year
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (8,'TT','TEST','TEST','TEST','TEST','303-33333333/333',333.333, '970229/6682');

INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (8,'TT','TEST','TEST','TEST','TEST','303-33333333/333',333.333, '960229/6682');
-- wrong day
INSERT INTO employee (employee_id, title, first_name, last_name, street, city, bank_account, hour_rate, personal_num)
VALUES (9,'TT','TEST','TEST','TEST','TEST','303-30303333/333',333.333, '960299/6682');

-- MATERIALIZED VIEW

SELECT * FROM owned_pets;
INSERT INTO XSAJDI01.animal (animal_id, animal_name, birth_date, last_visit, species_id, owner_id)
VALUES (6, 'Maga', TO_DATE('29.04.2015', 'DD/MM/YYYY'), TO_DATE('05.05.2017', 'DD/MM/YYYY'), 4, 3);
COMMIT;
SELECT * FROM owned_pets;
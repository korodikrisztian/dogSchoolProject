CREATE DATABASE dog_school;
USE dog_school;

/*---------------------------------TABLES-------------------------------------------*/

CREATE TABLE dog_owners (
    owner_id INT AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    e_mail VARCHAR(100),
    money_paid INT NOT NULL, 
    PRIMARY KEY (owner_id)
);


CREATE TABLE dog_trainers (
    trainer_id INT AUTO_INCREMENT,
    trainer_name VARCHAR(100) NOT NULL,
    trainer_gender VARCHAR(15) NOT NULL,
    trainer_age INT NOT NULL,
    trainer_phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (trainer_id)
);


CREATE TABLE dogs (
    dog_id INT AUTO_INCREMENT,
    owner_id INT,
    trainer_id INT,
    dog_name VARCHAR(100) NOT NULL,
    dog_breed VARCHAR(100) NOT NULL,
    dog_age INT NOT NULL,
    PRIMARY KEY (dog_id),
    FOREIGN KEY (owner_id) REFERENCES dog_owners(owner_id),
    FOREIGN KEY (trainer_id) REFERENCES dog_trainers(trainer_id)
);

/*---------------------------------INSERTING-------------------------------------------*/

INSERT INTO dog_trainers (trainer_name, trainer_gender, trainer_age, trainer_phone_number)
VALUES
	('Jhony', 'man', 31, '3621894261'),
	('Mariann', 'woman', 40, '3649517343'),
	('Esteban', 'man', 26, '3678461789');


INSERT INTO dog_owners (first_name, middle_name, last_name, phone_number, e_mail, money_paid) 
VALUES
('Barbara', NULL, 'Miserables', '3687491456', 'miserablesbabe@hotmail.hu', 400),
('Robert', NULL, 'Smith', '364654891', NULL, 800),
('Matilde', 'Miranda', 'Simarin', '365123612', 'miranda12@outlook.com', 100),
('Tenessie', NULL, 'Gordon', '366123135', NULL, 700),
('Jessica', 'Saint', 'McCharty', '365611232', NULL, 0);


INSERT INTO dogs (dog_name, dog_breed, dog_age, owner_id, trainer_id) 
VALUES
	('Ringo', 'Tabby', 4, 1, 1),
	('Cindy', 'Maine Coon', 10, 1, 1),
	('Dumbledore', 'Maine Coon', 11, 2, 1),
	('Egg', 'Persian', 4, 4, 2),
	('Misty', 'Tabby', 13, 5,  2),
	('George Michael', 'Ragdoll', 9, 2, 2),
	('Jackson', 'Sphynx', 7, 3, 3),
	('Mistery', 'Persian', 3, 2, 1),
	('Prapi', 'Maine', 1, 5, 1),
    ('Roberta', 'Tabby', 8, 4, 1);
    
/*---------------------------------QUERIES-------------------------------------------*/

DESC dogs;
DESC dog_owners;
DESC dog_trainers;

SELECT * FROM dogs;
SELECT * FROM dog_owners;
SELECT * FROM dog_trainers;
/*-------------------------*/
-- This query calculates the average age of all dogs in the 'dogs' table.
SELECT 
    AVG(dogs.dog_age)
FROM 
    dogs;

-- This query retrieves the first name, last name, and phone number of dog owners who have paid nothing.
SELECT 
    first_name, 
    last_name, 
    phone_number 
FROM 
    dog_owners
WHERE money_paid = 0;

-- This query counts the number of dogs for each breed and groups them by breed.
SELECT 
    dog_breed, 
    COUNT(dog_id) AS breed_count
FROM 
    dogs
GROUP BY dog_breed;

-- This query retrieves the names of owners, their dogs, and the trainer's name for dogs trained by trainer 1.
SELECT 
    dogo.first_name AS Owner, 
    d.dog_name AS Dog, 
    tr.trainer_name AS Trainername
FROM 
    dogs AS d
INNER JOIN dog_trainers AS tr
    ON tr.trainer_id = d.trainer_id
    INNER JOIN dog_owners AS dogo
    ON dogo.owner_id = d.owner_id
WHERE tr.trainer_id = 1;

-- This query calculates the total number of dogs each trainer has trained.
SELECT 
    dt.trainer_name, 
    COUNT(d.dog_id) AS all_dogs
FROM 
    dog_trainers AS dt
INNER JOIN dogs AS d
    ON dt.trainer_id = d.trainer_id
GROUP BY dt.trainer_name;

-- This query calculates the trainer with the least number of dogs trained.
SELECT 
    dt.trainer_name, 
    COUNT(d.dog_id) AS all_dogs
FROM 
    dog_trainers AS dt
INNER JOIN dogs AS d
    ON dt.trainer_id = d.trainer_id
GROUP BY dt.trainer_name
ORDER BY all_dogs ASC
LIMIT 1;

-- This query retrieves all dogs that are older than the average age of all dogs.
SELECT 
    d.dog_id, 
    d.dog_name, 
    d.dog_age
FROM 
    dogs AS d
WHERE d.dog_age > (SELECT AVG(dog_age) FROM dogs);

-- This query retrieves the youngest dog and its trainer.
WITH youngest AS (
    SELECT 
        d.dog_name, 
        d.dog_age, 
        d.trainer_id
    FROM 
        dogs AS d
    WHERE d.dog_age = (SELECT MIN(dog_age) FROM dogs)
)
SELECT 
    yd.dog_name, 
    yd.dog_age AS youngest, 
    dt.trainer_name
FROM 
    youngest AS yd
INNER JOIN dog_trainers AS dt
    ON dt.trainer_id = yd.trainer_id;

-- This query retrieves the owner details of those who have more than one dog.
WITH OwnersWithMultipleDogs AS (
    SELECT 
        owner_id, 
        COUNT(dog_id) AS dog_count
    FROM dogs
    GROUP BY owner_id
    HAVING dog_count > 1
)
SELECT 
    do.first_name, 
    do.last_name, 
    do.phone_number, 
    ow.dog_count
FROM OwnersWithMultipleDogs AS ow
INNER JOIN dog_owners AS do 
    ON do.owner_id = ow.owner_id;

-- This query calculates the average age of dogs for each trainer.
WITH TrainerAvgAge AS (
    SELECT 
        trainer_id, 
        AVG(dog_age) AS avg_age
    FROM dogs
    GROUP BY trainer_id
)
SELECT 
    dt.trainer_name, 
    taa.avg_age
FROM TrainerAvgAge AS taa
INNER JOIN dog_trainers AS dt 
    ON dt.trainer_id = taa.trainer_id;

-- This query retrieves both the youngest and oldest dog, including their trainer's name.
WITH YoungestDog AS (
    SELECT 
        d.dog_name, 
        d.dog_age, 
        dt.trainer_name
    FROM dogs AS d
    INNER JOIN dog_trainers AS dt
        ON dt.trainer_id = d.trainer_id
    WHERE d.dog_age = (SELECT MIN(dog_age) FROM dogs)
), OldestDog AS (
    SELECT 
        d.dog_name, 
        d.dog_age, 
        dt.trainer_name
    FROM dogs AS d
    INNER JOIN dog_trainers AS dt
        ON dt.trainer_id = d.trainer_id
    WHERE d.dog_age = (SELECT MAX(dog_age) FROM dogs)
)
SELECT 
    'Youngest' AS DogType, 
    yd.dog_name, 
    yd.dog_age, 
    yd.trainer_name
FROM 
    YoungestDog AS yd
UNION
SELECT 
    'Oldest' AS DogType, 
    od.dog_name, 
    od.dog_age, 
    od.trainer_name
FROM 
    OldestDog AS od;

-- This query categorizes dogs into 'Young', 'Adult', or 'Senior' based on their age.
SELECT 
    dog_name,
    dog_breed,
    dog_age,
    CASE 
        WHEN dog_age < 3 THEN 'Young'
        WHEN dog_age BETWEEN 3 AND 7 THEN 'Adult'
        WHEN dog_age > 7 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_category
FROM
    dogs;
    CREATE DATABASE dog_school;
USE dog_school;

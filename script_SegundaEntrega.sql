use students;


--           ----              --------------------CREACION DE VIEWS---------------------------------               --		
-- Vista con toda la informacion de las tablas --
CREATE VIEW student_full_profile AS
SELECT 
    s.student_id,
    s.age,
    g.gender_name,
    f.field_name,
    u.university_ranking,
    u.university_gpa,
    e.sat_score,
    e.high_school_gpa,
    a.internships_completed,
    a.projects_completed,
    a.certifications,
    c.job_offers,
    c.starting_salary,
    c.career_satisfaction,
    c.current_job_level
FROM student s
LEFT JOIN gender g ON s.gender_id = g.gender_id
LEFT JOIN field_of_study f ON s.field_id = f.field_id
LEFT JOIN university_information u ON s.university_id = u.university_id
LEFT JOIN education_background e ON s.education_id = e.education_id
LEFT JOIN academic_experience a ON s.experience_id = a.experience_id
LEFT JOIN career_outcome c ON s.outcome_id = c.outcome_id;

-- Vista de estadisticas de salarios por universidad--
CREATE VIEW university_salary_stats AS
SELECT 
    u.university_id,
    u.university_ranking,
    u.university_gpa,
    AVG(c.starting_salary) AS avg_starting_salary
FROM university_information u
JOIN student s ON u.university_id = s.university_id
JOIN career_outcome c ON s.outcome_id = c.outcome_id
GROUP BY u.university_id, u.university_ranking, u.university_gpa;

-- Vista con promedio de exito en finalizacion de carrera y satisfaccion
CREATE VIEW field_career_success AS
SELECT 
    f.field_name,
    COUNT(s.student_id) AS total_students,
    AVG(c.career_satisfaction) AS avg_career_satisfaction,
    AVG(c.years_to_promotion) AS avg_years_to_promotion
FROM field_of_study f
JOIN student s ON f.field_id = s.field_id
JOIN career_outcome c ON s.outcome_id = c.outcome_id
GROUP BY f.field_name;

-- ----------vista salary y satisfaction --------------------------
CREATE VIEW satisfaction_salary AS
SELECT 
    f.field_name,
    AVG(c.career_satisfaction) AS avg_satisfaction,
    AVG(c.starting_salary) AS avg_starting_salary
FROM student s
JOIN field_of_study f ON s.field_id = f.field_id
JOIN career_outcome c ON s.outcome_id = c.outcome_id
GROUP BY f.field_name;

-- llamado view con filtro----
SELECT * FROM satisfaction_salary ORDER BY avg_satisfaction DESC;


-- --------------------------------FUNCIONES----------------------------------------------------------------------------

-- funcion comparativa de satisfaccion segun carrera---------------------------------
DELIMITER //
CREATE FUNCTION career_satisfaction(fieldId INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE avgSatisfaction DECIMAL(4,2);

    SELECT AVG(c.career_satisfaction)
    INTO avgSatisfaction
    FROM student s
    JOIN career_outcome c ON s.outcome_id = c.outcome_id
    WHERE s.field_id = fieldId;

    RETURN avgSatisfaction;
END ;//
DELIMITER ;
-- ----- Llamado a funcion avg de satisfaccion
SELECT 
    f.field_name,
    career_satisfaction(f.field_id) AS avg_satisfaction
FROM field_of_study f
ORDER BY avg_satisfaction DESC;


-- --------------funcion avg time to promote-------------------------------


DELIMITER //

CREATE FUNCTION avg_to_promote(fieldId INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE avgYears DECIMAL(4,2);

    SELECT AVG(c.years_to_promotion)
    INTO avgYears
    FROM student s
    JOIN career_outcome c ON s.outcome_id = c.outcome_id
    WHERE s.field_id = fieldId;

    RETURN avgYears;
END;
//

DELIMITER ;
-- llamado funcion avg time to promote--
SELECT 
    f.field_name,
    avg_to_promote(f.field_id) AS avg_years_to_promotion
FROM field_of_study f
ORDER BY avg_years_to_promotion desc;

--   funcion salary by age -----

 
 DELIMITER //

CREATE FUNCTION salary_by_age(minAge INT, maxAge INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avgSalary DECIMAL(10,2);

    SELECT AVG(c.starting_salary)
    INTO avgSalary
    FROM student s
    JOIN career_outcome c ON s.outcome_id = c.outcome_id
    WHERE s.age BETWEEN minAge AND maxAge;

    RETURN avgSalary;
END;
//

DELIMITER ;

--  ejemplos de llamados para realizar comparativas---

SELECT salary_by_age(19, 22) AS ages_gap;
SELECT salary_by_age(23, 25) AS ages_25_30;
SELECT salary_by_age(25, 30) AS ages_19_25;

-- -----------------------------------------STORED PROCEDURES --------------------------------------------------------

-- avg salarial y satisfaccion segun carrera de estudio --
DELIMITER $$

CREATE PROCEDURE Get_Field_Statistics(IN fieldName VARCHAR(100))
BEGIN
    IF fieldName IS NULL OR fieldName = '' THEN
        SELECT 
            f.field_name AS Field,
            COUNT(s.student_id) AS Total_Students,
            AVG(c.starting_salary) AS Avg_Starting_Salary,
            AVG(c.career_satisfaction) AS Avg_Career_Satisfaction
        FROM 
            student s
        JOIN field_of_study f ON s.field_id = f.field_id
        JOIN career_outcome c ON s.outcome_id = c.outcome_id
        GROUP BY 
            f.field_name
		ORDER BY
             AVG(c.career_satisfaction) DESC;
    ELSE
        SELECT 
            f.field_name AS Field,
            COUNT(s.student_id) AS Total_Students,
            AVG(c.starting_salary) AS Avg_Starting_Salary,
            AVG(c.career_satisfaction) AS Avg_Career_Satisfaction
        FROM 
            student s
        JOIN field_of_study f ON s.field_id = f.field_id
        JOIN career_outcome c ON s.outcome_id = c.outcome_id
        WHERE 
            f.field_name = fieldName
        GROUP BY 
            f.field_name;
    END IF;
END $$

DELIMITER ;

--   llamados: uno por carrera especifica y otro para todas las carreras --
CALL Get_Field_Statistics('Arts');

CALL Get_Field_Statistics(NULL);

--  SP compara la satisfaccion y el balance vida-trabajo ------------------

DELIMITER //

CREATE PROCEDURE sp_life_career_balance()
BEGIN
    SELECT 
        f.field_name AS Career,
        COUNT(s.student_id) AS Total_Students,
        AVG(c.career_satisfaction) AS Avg_Satisfaction,
        AVG(c.work_life_balance) AS Avg_Work_Life_Balance
    FROM 
        student s
    JOIN 
        career_outcome c ON s.outcome_id = c.outcome_id
    JOIN 
        field_of_study f ON s.field_id = f.field_id
    GROUP BY 
        f.field_name
    ORDER BY 
        Avg_Satisfaction DESC;
END //

DELIMITER ;

--  llamada del procedure con parametros--------------

 CALL sp_life_career_balance();
 
 -- --------------------------------------------------triggers-------------------------------------------------------------------
 -- tabla para registro del trigger ( student_log)
 
 CREATE TABLE student_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(20)
);
--  ---trigger para registro con timestamp---------
DELIMITER //

CREATE TRIGGER after_student_insert
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_log (student_id, action_type)
    VALUES (NEW.student_id, 'INSERT');
END //

DELIMITER ;

-- ejemplo de ingreso para realizar consulta posterior----
INSERT INTO student (
    student_id, Age, gender_id, field_id,
    university_id, experience_id, outcome_id, skills_id, education_id
)
VALUES (
    'S05007', 23, 1, 3,
    2, 1, 2, 1, 3
);

-- trigger para guardar updates---

-- tabla para guardar los logs del trigger(update_log) --
CREATE TABLE update_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(20),
    changed_fields TEXT,
    old_values TEXT,
    new_values TEXT
);
-- trigger de log update--


DELIMITER //

CREATE TRIGGER after_student_update
AFTER UPDATE ON student
FOR EACH ROW
BEGIN
    DECLARE changes TEXT DEFAULT '';
    DECLARE old_vals TEXT DEFAULT '';
    DECLARE new_vals TEXT DEFAULT '';

    IF OLD.Age <> NEW.Age THEN
        SET changes = CONCAT(changes, 'Age, ');
        SET old_vals = CONCAT(old_vals, 'Age: ', OLD.Age, '; ');
        SET new_vals = CONCAT(new_vals, 'Age: ', NEW.Age, '; ');
    END IF;

    IF OLD.university_id <> NEW.university_id THEN
        SET changes = CONCAT(changes, 'University, ');
        SET old_vals = CONCAT(old_vals, 'University: ', OLD.university_id, '; ');
        SET new_vals = CONCAT(new_vals, 'University: ', NEW.university_id, '; ');
    END IF;

    IF OLD.experience_id <> NEW.experience_id THEN
        SET changes = CONCAT(changes, 'Experience, ');
        SET old_vals = CONCAT(old_vals, 'Experience: ', OLD.experience_id, '; ');
        SET new_vals = CONCAT(new_vals, 'Experience: ', NEW.experience_id, '; ');
    END IF;

    IF OLD.skills_id <> NEW.skills_id THEN
        SET changes = CONCAT(changes, 'Skills, ');
        SET old_vals = CONCAT(old_vals, 'Skills: ', OLD.skills_id, '; ');
        SET new_vals = CONCAT(new_vals, 'Skills: ', NEW.skills_id, '; ');
    END IF;

    IF OLD.education_id <> NEW.education_id THEN
        SET changes = CONCAT(changes, 'Education, ');
        SET old_vals = CONCAT(old_vals, 'Education: ', OLD.education_id, '; ');
        SET new_vals = CONCAT(new_vals, 'Education: ', NEW.education_id, '; ');
    END IF;

    IF changes <> '' THEN
        SET changes = LEFT(changes, LENGTH(changes) - 2);  
        INSERT INTO update_log (student_id, action_type, changed_fields, old_values, new_values)
        VALUES (NEW.student_id, 'UPDATE', changes, old_vals, new_vals);
    END IF;
END //

DELIMITER ;











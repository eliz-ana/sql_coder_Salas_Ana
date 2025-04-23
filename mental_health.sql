CREATE schema mental_health;
use mental_health;

CREATE TABLE mental_health_data (
    Age INT,
    Gender VARCHAR(10),
    Education_Level VARCHAR(50),
    Employment_Status VARCHAR(50),
    Sleep_Hours DECIMAL(3,1),
    Physical_Activity_Hrs DECIMAL(3,1),
    Social_Support_Score TINYINT,
    Anxiety_Score TINYINT,
    Depression_Score TINYINT,
    Stress_Level TINYINT,
    Family_History_Mental_Illness BOOLEAN,
    Chronic_Illnesses BOOLEAN,
    Medication_Use VARCHAR(20),
    Therapy BOOLEAN,
    Meditation BOOLEAN,
    Substance_Use VARCHAR(20),
    Financial_Stress TINYINT,
    Work_Stress TINYINT,
    Self_Esteem_Score TINYINT,
    Life_Satisfaction_Score TINYINT,
    Loneliness_Score TINYINT
);


CREATE TABLE personas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    education_level VARCHAR(50),
    employment_status VARCHAR(50)
);

INSERT INTO personas (age, gender, education_level, employment_status)
SELECT DISTINCT
    Age,
    Gender,
    Education_Level,
    Employment_Status
FROM mental_health.mental_health_data;


CREATE TABLE salud_mental (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT,
    anxiety_score INT,
    depression_score INT,
    stress_level INT,
    self_esteem_score INT,
    life_satisfaction_score INT,
    loneliness_score INT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);

INSERT INTO salud_mental (
    persona_id, anxiety_score, depression_score, stress_level,
    self_esteem_score, life_satisfaction_score, loneliness_score
)
SELECT
    p.id,
    m.Anxiety_Score,
    m.Depression_Score,
    m.Stress_Level,
    m.Self_Esteem_Score,
    m.Life_Satisfaction_Score,
    m.Loneliness_Score
FROM mental_health.mental_health_data m
JOIN personas p ON
    m.Age = p.age AND
    m.Gender = p.gender AND
    m.Education_Level = p.education_level AND
    m.Employment_Status = p.employment_status;
    
    CREATE TABLE salud_fisica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT,
    sleep_hours DECIMAL(3,1),
    physical_activity_hrs DECIMAL(3,1),
    chronic_illnesses INT,
    medication_use VARCHAR(20),
    therapy INT,
    meditation INT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);

INSERT INTO salud_fisica (
    persona_id, sleep_hours, physical_activity_hrs,
    chronic_illnesses, medication_use, therapy, meditation
)
SELECT
    p.id,
    m.Sleep_Hours,
    m.Physical_Activity_Hrs,
    m.Chronic_Illnesses,
    m.Medication_Use,
    m.Therapy,
    m.Meditation
FROM mental_health.mental_health_data m
JOIN personas p ON
    m.Age = p.age AND
    m.Gender = p.gender AND
    m.Education_Level = p.education_level AND
    m.Employment_Status = p.employment_status;



CREATE TABLE estilo_vida (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT,
    substance_use VARCHAR(20),
    financial_stress INT,
    work_stress INT,
    social_support_score INT,
    family_history_mental_illness INT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);




INSERT INTO estilo_vida (
    persona_id, substance_use, financial_stress, work_stress,
    social_support_score, family_history_mental_illness
)
SELECT
    p.id,
    m.Substance_Use,
    m.Financial_Stress,
    m.Work_Stress,
    m.Social_Support_Score,
    m.Family_History_Mental_Illness
FROM mental_health.mental_health_data m
JOIN personas p ON
    m.Age = p.age AND
    m.Gender = p.gender AND
    m.Education_Level = p.education_level AND
    m.Employment_Status = p.employment_status;
    
    CREATE TABLE factores_estres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT,
    financial_stress TINYINT,
    work_stress TINYINT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);

ALTER TABLE factores_estres DROP FOREIGN KEY factores_estres_ibfk_1;

SELECT CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'factores_estres' AND REFERENCED_TABLE_NAME = 'personas';


INSERT INTO factores_estres ( financial_stress, work_stress)
SELECT financial_stress, work_stress
FROM mental_health.mental_health_data;

INSERT INTO factores_estres (persona_id)
select persona_id from estilo_vida;


DROP TABLE factores_estres;
DROP TABLE estilo_vida;


-- agregando las foreing keys---------------------

ALTER TABLE salud_fisica
ADD CONSTRAINT fk_salud_fisica_persona
FOREIGN KEY (persona_id) REFERENCES personas(id);

ALTER TABLE estilo_vida
ADD CONSTRAINT fk_estilo_vida_persona
FOREIGN KEY (persona_id) REFERENCES personas(id);

ALTER TABLE salud_mental
ADD CONSTRAINT fk_salud_mental_persona
FOREIGN KEY (persona_id) REFERENCES personas(id);
-- modificacion de tablas ------
SELECT CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'estilo_vida' AND REFERENCED_TABLE_NAME = 'personas';

ALTER TABLE estilo_vida DROP FOREIGN KEY fk_estilo_vida_persona;

ALTER TABLE estilo_vida
DROP COLUMN financial_stress,
DROP COLUMN work_stress;


CREATE TABLE estilo_vida (
    id INT AUTO_INCREMENT PRIMARY KEY,
    persona_id INT,
    substance_use VARCHAR(20),
    financial_stress INT,
    work_stress INT,
    social_support_score INT,
    family_history_mental_illness INT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);
INSERT INTO estilo_vida (
    persona_id, substance_use, financial_stress, work_stress,
    social_support_score, family_history_mental_illness
)
SELECT
    p.id,
    m.Substance_Use,
    m.Financial_Stress,
    m.Work_Stress,
    m.Social_Support_Score,
    m.Family_History_Mental_Illness
FROM mental_health.mental_health_data m
JOIN personas p ON
    m.Age = p.age AND
    m.Gender = p.gender AND
    m.Education_Level = p.education_level AND
    m.Employment_Status = p.employment_status;

ALTER TABLE estilo_vida
ADD CONSTRAINT fk_estilo_vida_persona
FOREIGN KEY (persona_id) REFERENCES personas(id);

use mental_health;

CREATE TABLE factores_estres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    persona_id INT NOT NULL,
    tipo_estres VARCHAR(50) NOT NULL,
    nivel_estres TINYINT,
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);


-- insertar valores--
INSERT INTO factores_estres (persona_id, tipo_estres, nivel_estres)
SELECT persona_id, 'financial', financial_stress
FROM estilo_vida
WHERE financial_stress IS NOT NULL;

-- Insertar factor: estrés laboral
INSERT INTO factores_estres (persona_id, tipo_estres, nivel_estres)
SELECT persona_id, 'work', work_stress
FROM estilo_vida
WHERE work_stress IS NOT NULL;

INSERT INTO factores_estres (persona_id, tipo_estres, nivel_estres)
SELECT persona_id, 'general', stress_level
FROM salud_mental
WHERE stress_level IS NOT NULL;


ALTER TABLE estilo_vida
DROP COLUMN financial_stress,
DROP COLUMN work_stress;


ALTER TABLE salud_mental
DROP COLUMN stress_level;
-- borro la tabla original ---
drop TABLE mental_health_data;


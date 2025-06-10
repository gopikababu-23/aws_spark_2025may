START TRANSACTION;

INSERT INTO Students (StudentID, FirstName, LastName, DepartmentID, GPA)
VALUES (101, 'John', 'Doe', 1, 3.0), (102, 'Jane', 'Smith', 2, 3.2);

UPDATE Students SET GPA = 3.5 WHERE DepartmentID = 1;

IF ROW_COUNT() >= 3 THEN
    COMMIT;
ELSE
    ROLLBACK;
END IF;

DELIMITER //

CREATE TRIGGER AfterEnrollmentInsert
AFTER INSERT ON Enrollments
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (Action, Details)
    VALUES ('INSERT', CONCAT('Student ', NEW.StudentID, ' enrolled in Course ', NEW.CourseID));
END //

DELIMITER ;

CREATE VIEW DepartmentalGPAView AS
SELECT d.DepartmentName, AVG(s.GPA) AS AvgGPA
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

DELIMITER //

CREATE PROCEDURE AddStudent(IN studentID INT, IN firstName VARCHAR(50), IN lastName VARCHAR(50), IN deptID INT, IN gpa DECIMAL(3,2))
BEGIN
    START TRANSACTION;

    IF gpa > 4.0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid GPA';
    ELSE
        INSERT INTO Students (StudentID, FirstName, LastName, DepartmentID, GPA)
        VALUES (studentID, firstName, lastName, deptID, gpa);
        COMMIT;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CreateDepartmentView(IN deptID INT)
BEGIN
    SET @viewQuery = CONCAT('CREATE OR REPLACE VIEW Department_', deptID, ' AS SELECT * FROM Students WHERE DepartmentID = ', deptID);
    PREPARE stmt FROM @viewQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;
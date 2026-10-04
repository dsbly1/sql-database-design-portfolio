/* =============================================================================
   PLS School Database - 02: sample data
   Author : Damon Bly
   Origin : CISS 202 Case Study (Oct 2025). The Chen family, instructor
            Bruce Lee, and the Kung Fu / Chinese Classic Music classes come
            from the original case study exercises; the rest is sample data
            added to make the reports meaningful.

   Explicit IDs (IDENTITY_INSERT) keep foreign keys readable in this script.
   ============================================================================= */

USE PLS;
GO

SET NOCOUNT ON;

/* ---------- Families ---------- */
SET IDENTITY_INSERT People.Families ON;
INSERT INTO People.Families (FamilyId, FamilyName, HomePhone, Email, HomeAddress, City, [State], ZipCode)
VALUES
    (1, N'Chen',   N'2021112233', N'chen1234@gmail.com',   N'101 Chinaberry St', N'Edison',      N'NJ', N'08817'),
    (2, N'Garcia', N'7325550142', N'garcia.fam@gmail.com', N'48 Oak Ave',        N'New Brunswick', N'NJ', N'08901'),
    (3, N'Kim',    N'9175550187', N'kimhome@yahoo.com',    N'2200 Broadway',     N'New York',    N'NY', N'10024'),
    (4, N'Okafor', N'2035550119', N'okafor.g@gmail.com',   N'15 Elm St',         N'Stamford',    N'CT', N'06901'),
    (5, N'Zhang',  N'7325550166', N'zhangwei@outlook.com', N'9 Lotus Ct',        N'Edison',      N'NJ', N'08820'),
    (6, N'Miller', N'9085550133', N'rmiller@gmail.com',    N'310 Park Pl',       N'Princeton',   N'NJ', N'08540');
SET IDENTITY_INSERT People.Families OFF;

/* ---------- Persons (supertype) ---------- */
SET IDENTITY_INSERT People.Persons ON;
INSERT INTO People.Persons (PersonId, FirstName, LastName, Email, Phone)
VALUES
    -- guardians and students
    ( 1, N'Li',      N'Chen',   N'li1234@gmail.com',      N'2021212134'),
    ( 2, N'Alice',   N'Chen',   NULL,                     NULL),
    ( 3, N'Tom',     N'Chen',   NULL,                     NULL),
    ( 4, N'Maria',   N'Garcia', N'maria.garcia@gmail.com', N'7325550143'),
    ( 5, N'Sofia',   N'Garcia', NULL,                     NULL),
    ( 6, N'Mateo',   N'Garcia', NULL,                     NULL),
    ( 7, N'David',   N'Kim',    N'dkim@yahoo.com',        N'9175550188'),
    ( 8, N'Ethan',   N'Kim',    NULL,                     NULL),
    ( 9, N'Grace',   N'Okafor', N'okafor.g@gmail.com',    N'2035550120'),
    (10, N'Amara',   N'Okafor', NULL,                     NULL),
    (11, N'Wei',     N'Zhang',  N'zhangwei@outlook.com',  N'7325550167'),
    (12, N'Lily',    N'Zhang',  NULL,                     NULL),
    (13, N'Jason',   N'Zhang',  NULL,                     NULL),
    (14, N'Robert',  N'Miller', N'rmiller@gmail.com',     N'9085550133'),   -- adult student
    -- instructors
    (15, N'Bruce',   N'Lee',    N'brucelee123@gmail.com', N'2021231234'),
    (16, N'Mei',     N'Wang',   N'mwang@pls.org',         N'7325550170'),
    (17, N'Hui',     N'Lin',    N'hlin@pls.org',          N'7325550171'),
    (18, N'Daniel',  N'Park',   N'dpark@pls.org',         N'7325550172'),
    -- volunteers
    (19, N'Anna',    N'Lee',    N'annalee@gmail.com',     N'2021231235'),
    (20, N'James',   N'Brooks', N'jbrooks@gmail.com',     N'7325550180'),
    (21, N'Priya',   N'Shah',   N'pshah@gmail.com',       N'7325550181');
SET IDENTITY_INSERT People.Persons OFF;

/* ---------- Subtypes ---------- */
SET IDENTITY_INSERT People.Guardians ON;
INSERT INTO People.Guardians (GuardianId, PersonId, FamilyId, Relationship)
VALUES (1, 1, 1, N'Mother'),
       (2, 4, 2, N'Mother'),
       (3, 7, 3, N'Father'),
       (4, 9, 4, N'Mother'),
       (5, 11, 5, N'Father');
SET IDENTITY_INSERT People.Guardians OFF;

SET IDENTITY_INSERT People.Students ON;
INSERT INTO People.Students (StudentId, PersonId, FamilyId, BirthDate, Gender, EthnicBackground)
VALUES (1,  2, 1, '20101010', N'Female', N'Chinese'),
       (2,  3, 1, '20120922', N'Male',   N'Chinese'),
       (3,  5, 2, '20140315', N'Female', N'Hispanic'),
       (4,  6, 2, '20170602', N'Male',   N'Hispanic'),
       (5,  8, 3, '20131120', N'Male',   N'Korean'),
       (6, 10, 4, '20160108', N'Female', N'Nigerian'),
       (7, 12, 5, '20110530', N'Female', N'Chinese'),
       (8, 13, 5, '20190814', N'Male',   N'Chinese'),
       (9, 14, 6, '19850412', N'Male',   N'White');
SET IDENTITY_INSERT People.Students OFF;

SET IDENTITY_INSERT People.Instructors ON;
INSERT INTO People.Instructors (InstructorId, PersonId, Specialization, HireDate)
VALUES (1, 15, N'Martial Arts & Music', '20170104'),
       (2, 16, N'Chinese Language',     '20160815'),
       (3, 17, N'Calligraphy & Painting', '20190110'),
       (4, 18, N'Math & College Prep',  '20210601');
SET IDENTITY_INSERT People.Instructors OFF;

SET IDENTITY_INSERT People.Volunteers ON;
INSERT INTO People.Volunteers (VolunteerId, PersonId, [Role], StartDate)
VALUES (1, 19, N'Classroom Assistant', '20220901'),
       (2, 20, N'Event Helper',        '20230115'),
       (3, 21, N'Club Assistant',      '20240901');
SET IDENTITY_INSERT People.Volunteers OFF;

/* ---------- Curriculum and classes ---------- */
SET IDENTITY_INSERT Academics.CourseCatalog ON;
INSERT INTO Academics.CourseCatalog (CourseId, CourseName, CourseType, [Description])
VALUES (1, N'Kung Fu Step 1',          N'Sports',         N'Introductory martial arts forms and conditioning'),
       (2, N'Chinese Classic Music 1', N'Arts & Culture', N'Traditional instruments and folk songs'),
       (3, N'Mandarin Level 1',        N'Language',       N'Pinyin, tones, and everyday vocabulary for beginners'),
       (4, N'Mandarin Level 2',        N'Language',       N'Reading and conversation for continuing students'),
       (5, N'Chinese Calligraphy',     N'Arts & Culture', N'Brush technique and classic scripts'),
       (6, N'SAT Math Prep',           N'College Prep',   N'Problem solving and test strategy'),
       (7, N'Mandarin for Adults',     N'Language',       N'Conversational Mandarin for adult learners');
SET IDENTITY_INSERT Academics.CourseCatalog OFF;

SET IDENTITY_INSERT Academics.Classes ON;
INSERT INTO Academics.Classes
    (ClassId, CourseId, InstructorId, Term, MeetDay, StartTime, EndTime, StartDate, EndDate, MaxCapacity, TuitionFee)
VALUES
    (1, 1, 1, N'Fall 2025',   N'Saturday',  '17:00', '17:30', '20250906', '20251213', 10, 180.00),
    (2, 2, 1, N'Fall 2025',   N'Sunday',    '17:30', '18:00', '20250907', '20251214', 15, 150.00),
    (3, 3, 2, N'Fall 2025',   N'Saturday',  '10:00', '11:30', '20250906', '20251213', 12, 240.00),
    (4, 4, 2, N'Fall 2025',   N'Sunday',    '10:00', '11:30', '20250907', '20251214', 12, 240.00),
    (5, 5, 3, N'Fall 2025',   N'Saturday',  '13:00', '14:30', '20250906', '20251213',  4, 200.00),
    (6, 6, 4, N'Fall 2025',   N'Wednesday', '17:00', '19:00', '20250910', '20251210', 15, 320.00),
    (7, 7, 2, N'Fall 2025',   N'Tuesday',   '17:30', '19:00', '20250909', '20251209', 10, 260.00),
    (8, 3, 2, N'Spring 2026', N'Saturday',  '10:00', '11:30', '20260110', '20260425', 12, 240.00);
SET IDENTITY_INSERT Academics.Classes OFF;

/* ---------- Enrollments ----------
   Grades for Chinese Classic Music 1 (Alice A, Tom C) come from the
   original case study. Calligraphy (class 5) is intentionally full (4 of 4)
   to demonstrate the capacity check in usp_EnrollStudent. */
INSERT INTO Academics.Enrollments (StudentId, ClassId, EnrollDate, Grade)
VALUES
    (1, 1, '20250820', N'B'), (1, 2, '20250820', N'A'), (1, 4, '20250820', N'A'), (1, 5, '20250825', N'B'),
    (2, 2, '20250820', N'C'), (2, 3, '20250820', N'B'),
    (3, 3, '20250822', N'A'), (3, 5, '20250822', N'A'),
    (4, 1, '20250822', N'A'), (4, 3, '20250822', N'B'),
    (5, 1, '20250827', N'B'), (5, 4, '20250827', N'C'), (5, 6, '20250827', N'A'),
    (6, 1, '20250829', N'A'), (6, 3, '20250829', N'A'), (6, 5, '20250829', N'B'),
    (7, 4, '20250830', N'B'), (7, 5, '20250830', N'A'), (7, 6, '20250830', N'B'),
    (8, 3, '20250901', N'C'),
    (9, 7, '20250902', N'B'),
    (2, 8, '20251215', NULL), (4, 8, '20251215', NULL), (8, 8, '20251218', NULL);

/* ---------- Clubs ---------- */
SET IDENTITY_INSERT Activities.Clubs ON;
INSERT INTO Activities.Clubs (ClubId, ClubName, [Description], AdvisorId)
VALUES (1, N'Lion Dance Club',      N'Performs at the Lunar New Year festival', 1),
       (2, N'Chess & Go Club',      N'Weekly strategy games and tournaments',   4),
       (3, N'Chinese Painting Club', N'Ink-wash painting workshops',            3),
       (4, N'Debate Club',          N'Bilingual debate practice (forming)',     NULL);
SET IDENTITY_INSERT Activities.Clubs OFF;

INSERT INTO Activities.ClubMemberships (StudentId, ClubId, JoinDate)
VALUES (1, 3, '20250915'),
       (2, 1, '20250915'),
       (3, 1, '20250920'),
       (5, 1, '20250920'), (5, 2, '20250920'),
       (6, 3, '20251004'),
       (7, 2, '20251004'),
       (8, 1, '20251011');

INSERT INTO Activities.VolunteerAssignments (VolunteerId, ClassId, ClubId, AssignedDate)
VALUES (1, 1,    NULL, '20250906'),   -- Anna Lee assists Kung Fu Step 1
       (2, NULL, 1,    '20250915'),   -- James Brooks helps the Lion Dance Club
       (3, 3,    NULL, '20250906'),   -- Priya Shah assists Mandarin Level 1
       (3, NULL, 3,    '20250915');   -- and the Chinese Painting Club

/* ---------- Donors and donations ---------- */
SET IDENTITY_INSERT Fundraising.Donors ON;
INSERT INTO Fundraising.Donors (DonorId, DonorName, DonorType, Email, Phone)
VALUES (1, N'Chen Family',                 N'Individual',  N'chen1234@gmail.com',   N'2021112233'),
       (2, N'Golden Dragon Restaurant',    N'Business',    N'info@goldendragon.com', N'7325550190'),
       (3, N'Edison Community Foundation', N'Institution', N'grants@ecf.org',        N'7325550191'),
       (4, N'Jennifer Wu',                 N'Individual',  N'jwu@gmail.com',         NULL),
       (5, N'Pacific Trade Bank',          N'Business',    N'giving@ptbank.com',     N'2125550192');
SET IDENTITY_INSERT Fundraising.Donors OFF;

INSERT INTO Fundraising.Donations (DonorId, Amount, DonationDate, Purpose)
VALUES (1,  250.00, '20250915', N'Scholarship Fund'),
       (2, 1000.00, '20251001', N'Lunar New Year Festival'),
       (3, 5000.00, '20251120', N'Facility Improvements'),
       (4,  150.00, '20251205', N'General Fund'),
       (2,  750.00, '20260125', N'Lunar New Year Festival'),
       (5, 2500.00, '20260210', N'Scholarship Fund'),
       (1,  300.00, '20260301', N'Scholarship Fund'),
       (3, 4000.00, '20260415', N'Facility Improvements'),
       (4,  200.00, '20260510', N'General Fund');
GO

PRINT 'PLS sample data loaded.';

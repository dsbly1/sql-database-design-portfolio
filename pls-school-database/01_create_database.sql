/* =============================================================================
   PLS School Database - 01: create database, schemas, and tables
   Author : Damon Bly
   Origin : CISS 202 Introduction to Databases, Case Study (Oct 2025),
            extended for this portfolio

   PLS is a non-profit Chinese language and culture school. This script turns
   the case study's logical ERD into a physical SQL Server schema. Business
   rules from the case study are enforced with constraints wherever possible
   (see the "Rule:" comments).

   Run order: 01_create_database -> 02_seed_data -> 03_views_and_procedures
              -> 04_reporting_queries
   Safe to re-run: it drops and rebuilds the database.
   ============================================================================= */

USE master;
GO

IF DB_ID(N'PLS') IS NOT NULL
BEGIN
    ALTER DATABASE PLS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PLS;
END;
GO

CREATE DATABASE PLS;
GO

USE PLS;
GO

/* Schemas group tables by business area. */
CREATE SCHEMA People      AUTHORIZATION dbo;   -- everyone the school works with
GO
CREATE SCHEMA Academics   AUTHORIZATION dbo;   -- curriculum, classes, enrollment
GO
CREATE SCHEMA Activities  AUTHORIZATION dbo;   -- clubs and volunteer work
GO
CREATE SCHEMA Fundraising AUTHORIZATION dbo;   -- donors and donations
GO

/* =============================================================================
   PEOPLE
   Person is a supertype: shared attributes (name, email, phone) are stored
   once, and each role (student, guardian, instructor, volunteer) is a subtype
   table linked 1:1 through a UNIQUE foreign key to Persons.
   ============================================================================= */

CREATE TABLE People.Families
(
    FamilyId     INT           NOT NULL IDENTITY,
    FamilyName   NVARCHAR(40)  NOT NULL,
    HomePhone    NVARCHAR(15)  NOT NULL,
    Email        NVARCHAR(50)  NOT NULL,
    HomeAddress  NVARCHAR(60)  NULL,
    City         NVARCHAR(30)  NULL,
    [State]      NCHAR(2)      NULL,
    ZipCode      NVARCHAR(10)  NULL,
    CONSTRAINT PK_Families PRIMARY KEY (FamilyId)
);

CREATE TABLE People.Persons
(
    PersonId   INT           NOT NULL IDENTITY,
    FirstName  NVARCHAR(30)  NOT NULL,
    LastName   NVARCHAR(30)  NOT NULL,
    Email      NVARCHAR(50)  NULL,
    Phone      NVARCHAR(15)  NULL,
    CONSTRAINT PK_Persons PRIMARY KEY (PersonId)
);

CREATE TABLE People.Students
(
    StudentId         INT           NOT NULL IDENTITY,
    PersonId          INT           NOT NULL,
    FamilyId          INT           NOT NULL,
    BirthDate         DATE          NOT NULL,
    Gender            NVARCHAR(10)  NULL,
    EthnicBackground  NVARCHAR(30)  NULL,   -- Rule: open to all ethnic backgrounds
    CONSTRAINT PK_Students PRIMARY KEY (StudentId),
    CONSTRAINT UQ_Students_Person UNIQUE (PersonId),          -- one student row per person
    CONSTRAINT FK_Students_Persons  FOREIGN KEY (PersonId) REFERENCES People.Persons (PersonId),
    CONSTRAINT FK_Students_Families FOREIGN KEY (FamilyId) REFERENCES People.Families (FamilyId),
    CONSTRAINT CHK_Students_BirthDate CHECK (BirthDate <= CAST(SYSDATETIME() AS DATE))
);

CREATE TABLE People.Guardians
(
    GuardianId    INT           NOT NULL IDENTITY,
    PersonId      INT           NOT NULL,
    FamilyId      INT           NOT NULL,
    Relationship  NVARCHAR(20)  NOT NULL,   -- Mother, Father, Grandparent, ...
    CONSTRAINT PK_Guardians PRIMARY KEY (GuardianId),
    CONSTRAINT UQ_Guardians_Person UNIQUE (PersonId),
    CONSTRAINT FK_Guardians_Persons  FOREIGN KEY (PersonId) REFERENCES People.Persons (PersonId),
    CONSTRAINT FK_Guardians_Families FOREIGN KEY (FamilyId) REFERENCES People.Families (FamilyId)
);

CREATE TABLE People.Instructors
(
    InstructorId    INT           NOT NULL IDENTITY,
    PersonId        INT           NOT NULL,
    Specialization  NVARCHAR(40)  NOT NULL,
    HireDate        DATE          NOT NULL,
    CONSTRAINT PK_Instructors PRIMARY KEY (InstructorId),
    CONSTRAINT UQ_Instructors_Person UNIQUE (PersonId),
    CONSTRAINT FK_Instructors_Persons FOREIGN KEY (PersonId) REFERENCES People.Persons (PersonId)
);

CREATE TABLE People.Volunteers
(
    VolunteerId  INT           NOT NULL IDENTITY,
    PersonId     INT           NOT NULL,
    [Role]       NVARCHAR(40)  NOT NULL,   -- Rule: activities are supported by volunteers
    StartDate    DATE          NOT NULL,
    CONSTRAINT PK_Volunteers PRIMARY KEY (VolunteerId),
    CONSTRAINT UQ_Volunteers_Person UNIQUE (PersonId),
    CONSTRAINT FK_Volunteers_Persons FOREIGN KEY (PersonId) REFERENCES People.Persons (PersonId)
);

/* =============================================================================
   ACADEMICS
   CourseCatalog = what the school teaches; Classes = a scheduled offering of
   a course in a term; Enrollments resolves the many-to-many relationship
   between Students and Classes.
   ============================================================================= */

CREATE TABLE Academics.CourseCatalog
(
    CourseId     INT            NOT NULL IDENTITY,
    CourseName   NVARCHAR(50)   NOT NULL,
    CourseType   NVARCHAR(20)   NOT NULL,
    [Description] NVARCHAR(200) NULL,
    CONSTRAINT PK_CourseCatalog PRIMARY KEY (CourseId),
    CONSTRAINT UQ_CourseCatalog_Name UNIQUE (CourseName),
    -- Rule: language classes plus arts/culture, sports, math, college prep, and specialty training
    CONSTRAINT CHK_CourseCatalog_Type CHECK
        (CourseType IN (N'Language', N'Arts & Culture', N'Sports', N'Math', N'College Prep', N'Specialty'))
);

CREATE TABLE Academics.Classes
(
    ClassId       INT           NOT NULL IDENTITY,
    CourseId      INT           NOT NULL,
    InstructorId  INT           NULL,          -- NULL while a class is unassigned
    Term          NVARCHAR(20)  NOT NULL,      -- e.g. 'Fall 2025'
    MeetDay       NVARCHAR(10)  NOT NULL,
    StartTime     TIME(0)       NOT NULL,
    EndTime       TIME(0)       NOT NULL,
    StartDate     DATE          NOT NULL,
    EndDate       DATE          NOT NULL,
    MaxCapacity   INT           NOT NULL,
    TuitionFee    MONEY         NOT NULL CONSTRAINT DF_Classes_TuitionFee DEFAULT (0),
    CONSTRAINT PK_Classes PRIMARY KEY (ClassId),
    CONSTRAINT FK_Classes_CourseCatalog FOREIGN KEY (CourseId)     REFERENCES Academics.CourseCatalog (CourseId),
    CONSTRAINT FK_Classes_Instructors   FOREIGN KEY (InstructorId) REFERENCES People.Instructors (InstructorId),
    CONSTRAINT CHK_Classes_Dates    CHECK (StartDate < EndDate),
    CONSTRAINT CHK_Classes_Times    CHECK (StartTime < EndTime),
    CONSTRAINT CHK_Classes_Capacity CHECK (MaxCapacity > 0),
    CONSTRAINT CHK_Classes_Tuition  CHECK (TuitionFee >= 0),
    CONSTRAINT CHK_Classes_MeetDay  CHECK
        (MeetDay IN (N'Monday', N'Tuesday', N'Wednesday', N'Thursday', N'Friday', N'Saturday', N'Sunday')),
    -- Rule: open 10:00am-7:00pm on weekends, and 5:00pm-7:00pm on weekday evenings
    CONSTRAINT CHK_Classes_OpenHours CHECK
        (StartTime >= '10:00' AND EndTime <= '19:00'
         AND (MeetDay IN (N'Saturday', N'Sunday') OR StartTime >= '17:00'))
);

CREATE TABLE Academics.Enrollments
(
    EnrollmentId  INT       NOT NULL IDENTITY,
    StudentId     INT       NOT NULL,
    ClassId       INT       NOT NULL,
    EnrollDate    DATE      NOT NULL CONSTRAINT DF_Enrollments_EnrollDate DEFAULT (CAST(SYSDATETIME() AS DATE)),
    Grade         NCHAR(1)  NULL,              -- NULL until the class is graded
    CONSTRAINT PK_Enrollments PRIMARY KEY (EnrollmentId),
    CONSTRAINT UQ_Enrollments_StudentClass UNIQUE (StudentId, ClassId),   -- no double enrollment
    CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentId) REFERENCES People.Students (StudentId),
    CONSTRAINT FK_Enrollments_Classes  FOREIGN KEY (ClassId)   REFERENCES Academics.Classes (ClassId),
    CONSTRAINT CHK_Enrollments_Grade CHECK (Grade IN (N'A', N'B', N'C', N'D', N'F'))
);

/* =============================================================================
   ACTIVITIES
   ClubMemberships resolves the many-to-many relationship between Students
   and Clubs. VolunteerAssignments records where each volunteer helps: a
   class or a club, never both in one row.
   ============================================================================= */

CREATE TABLE Activities.Clubs
(
    ClubId        INT            NOT NULL IDENTITY,
    ClubName      NVARCHAR(40)   NOT NULL,
    [Description] NVARCHAR(200)  NULL,
    AdvisorId     INT            NULL,         -- an instructor, optional
    CONSTRAINT PK_Clubs PRIMARY KEY (ClubId),
    CONSTRAINT UQ_Clubs_Name UNIQUE (ClubName),
    CONSTRAINT FK_Clubs_Instructors FOREIGN KEY (AdvisorId) REFERENCES People.Instructors (InstructorId)
);

CREATE TABLE Activities.ClubMemberships
(
    StudentId  INT   NOT NULL,
    ClubId     INT   NOT NULL,
    JoinDate   DATE  NOT NULL CONSTRAINT DF_ClubMemberships_JoinDate DEFAULT (CAST(SYSDATETIME() AS DATE)),
    CONSTRAINT PK_ClubMemberships PRIMARY KEY (StudentId, ClubId),       -- composite key
    CONSTRAINT FK_ClubMemberships_Students FOREIGN KEY (StudentId) REFERENCES People.Students (StudentId),
    CONSTRAINT FK_ClubMemberships_Clubs    FOREIGN KEY (ClubId)    REFERENCES Activities.Clubs (ClubId)
);

CREATE TABLE Activities.VolunteerAssignments
(
    AssignmentId  INT   NOT NULL IDENTITY,
    VolunteerId   INT   NOT NULL,
    ClassId       INT   NULL,
    ClubId        INT   NULL,
    AssignedDate  DATE  NOT NULL,
    CONSTRAINT PK_VolunteerAssignments PRIMARY KEY (AssignmentId),
    CONSTRAINT FK_VolunteerAssignments_Volunteers FOREIGN KEY (VolunteerId) REFERENCES People.Volunteers (VolunteerId),
    CONSTRAINT FK_VolunteerAssignments_Classes    FOREIGN KEY (ClassId)     REFERENCES Academics.Classes (ClassId),
    CONSTRAINT FK_VolunteerAssignments_Clubs      FOREIGN KEY (ClubId)      REFERENCES Activities.Clubs (ClubId),
    -- exactly one of ClassId / ClubId is filled in
    CONSTRAINT CHK_VolunteerAssignments_Target CHECK
        ((ClassId IS NOT NULL AND ClubId IS NULL) OR (ClassId IS NULL AND ClubId IS NOT NULL))
);

/* =============================================================================
   FUNDRAISING
   Rule: funded by tuition and by donations from individuals, private
   businesses, and institutions. Donor details live in Donors (not repeated on
   every donation), which keeps Donations in third normal form.
   ============================================================================= */

CREATE TABLE Fundraising.Donors
(
    DonorId    INT           NOT NULL IDENTITY,
    DonorName  NVARCHAR(60)  NOT NULL,
    DonorType  NVARCHAR(12)  NOT NULL,
    Email      NVARCHAR(50)  NULL,
    Phone      NVARCHAR(15)  NULL,
    CONSTRAINT PK_Donors PRIMARY KEY (DonorId),
    CONSTRAINT CHK_Donors_Type CHECK (DonorType IN (N'Individual', N'Business', N'Institution'))
);

CREATE TABLE Fundraising.Donations
(
    DonationId    INT           NOT NULL IDENTITY,
    DonorId       INT           NOT NULL,
    Amount        MONEY         NOT NULL,
    DonationDate  DATE          NOT NULL,
    Purpose       NVARCHAR(50)  NULL,
    CONSTRAINT PK_Donations PRIMARY KEY (DonationId),
    CONSTRAINT FK_Donations_Donors FOREIGN KEY (DonorId) REFERENCES Fundraising.Donors (DonorId),
    CONSTRAINT CHK_Donations_Amount CHECK (Amount > 0)
);
GO

/* =============================================================================
   INDEXES on foreign keys that reports join or filter on most often.
   (Primary keys and UNIQUE constraints are indexed automatically.)
   ============================================================================= */

CREATE INDEX IX_Students_FamilyId     ON People.Students (FamilyId);
CREATE INDEX IX_Guardians_FamilyId    ON People.Guardians (FamilyId);
CREATE INDEX IX_Classes_CourseId      ON Academics.Classes (CourseId);
CREATE INDEX IX_Classes_InstructorId  ON Academics.Classes (InstructorId);
CREATE INDEX IX_Enrollments_ClassId   ON Academics.Enrollments (ClassId);
CREATE INDEX IX_ClubMemberships_Club  ON Activities.ClubMemberships (ClubId);
CREATE INDEX IX_Donations_DonorId     ON Fundraising.Donations (DonorId);
GO

PRINT 'PLS database and tables created.';

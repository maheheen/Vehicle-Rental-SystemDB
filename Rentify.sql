USE master;
DROP DATABASE VehicleRentalSystem;
CREATE DATABASE VehicleRentalSystem;

SELECT * FROM Customer;
SELECT * FROM Vehicle;
SELECT * FROM VehicleType;
SELECT * FROM FuelType;
SELECT * FROM UserRole;
SELECT * FROM VehicleType;
SELECT * FROM UserLogin;
SELECT * FROM Rental;
TRUNCATE TABLE UserLogin;



USE VehicleRentalSystem

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20),
    HomeAddress VARCHAR(255),
    DrivingLicenseNumber VARCHAR(30) UNIQUE,
    NationalIDNumber VARCHAR(30) UNIQUE,
    LoginID INT UNIQUE,
    FOREIGN KEY (LoginID) REFERENCES UserLogin(LoginID)
);

CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY IDENTITY(1,1),
    Brand VARCHAR(50),
    Model VARCHAR(50),
    MakeYear INT,
    RegNumber VARCHAR(30),
    SeatingCapacity INT,
    TransmissionType VARCHAR(20),
    TypeID INT,
	FuelTypeID INT,
	RATE INT,
	FOREIGN KEY (FuelTypeID) REFERENCES FuelType(FuelTypeID),
    FOREIGN KEY (TypeID) REFERENCES VehicleType(TypeID)
);
GO

CREATE TABLE Rental (
    RentalID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    VehicleID INT,
    RentalStartDate DATE,
    RentalEndDate DATE,
    TotalCost DECIMAL(10, 2),
    PickupLocation VARCHAR(100),
    DropoffLocation VARCHAR(100),

    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);


CREATE TABLE FuelType(

FuelTypeID INT PRIMARY KEY IDENTITY (1,1),
FuelName VARCHAR (100),
FuelRate INT

);

CREATE TABLE VehicleAvailability (
    VehicleID INT PRIMARY KEY IDENTITY(1,1),
    Brand VARCHAR(50),
    Model VARCHAR(50),
    IsAvailable BIT
);


CREATE TABLE VehicleType (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName VARCHAR(50) NOT NULL
    
);

CREATE TABLE UserLogin (
    LoginID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RoleID INT NOT NULL,
	FOREIGN KEY (RoleID) REFERENCES UserRole(RoleID)
);

INSERT INTO UserLogin
VALUES
--superadmin password = "superadmin"
('sa', '186cf774c97b60a1c106ef718d10970a6a06e06bef89553d9ae65d938a886eae', 3);

CREATE TABLE Availability (
    AvailabilityID INT PRIMARY KEY IDENTITY(1,1),
    VehicleID INT,
    Status VARCHAR(30), -- e.g., 'Available', 'Booked', 'Maintenance'
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

CREATE TABLE UserRole (     --identify if its customer, admin or superadmin
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(20) UNIQUE NOT NULL
);


INSERT INTO Vehicle (Brand, Model, MakeYear, RegNumber, SeatingCapacity, TransmissionType, TypeID, FuelTypeID, Rate)
VALUES
('Toyota', 'Corolla', 2020, 'ABC-1234', 5, 'Automatic', 1, 1, 5000),
('Honda', 'Civic', 2019, 'XYZ-5678', 5, 'Manual', 1, 1, 4800),
('Suzuki', 'WagonR', 2021, 'LMN-9012', 5, 'Automatic', 2, 1, 3000),
('Kia', 'Sportage', 2022, 'KIA-3456', 5, 'Automatic', 3, 2, 8000),
('Hyundai', 'Tucson', 2023, 'HYU-7890', 5, 'Automatic', 3, 2, 8200),
('Nissan', 'Dayz', 2018, 'NIS-1122', 4, 'Automatic', 2, 1, 2500),
('Toyota', 'Hiace', 2021, 'HI-3344', 15, 'Manual', 4, 2, 10000),
('Honda', 'BR-V', 2020, 'BRV-5566', 7, 'Automatic', 3, 1, 6500),
('Suzuki', 'Alto', 2022, 'ALT-7788', 4, 'Manual', 2, 1, 2700),
('Toyota', 'Fortuner', 2023, 'FOR-9900', 7, 'Automatic', 3, 2, 12000),
('Daihatsu', 'Mira', 2019, 'MIR-1235', 4, 'Automatic', 2, 1, 2800),
('Honda', 'City', 2018, 'CTY-4567', 5, 'Manual', 1, 1, 4500),
('Hyundai', 'Elantra', 2022, 'ELA-8901', 5, 'Automatic', 1, 2, 7000),
('Kia', 'Picanto', 2021, 'PIC-2345', 4, 'Automatic', 2, 1, 3200),
('Toyota', 'Land Cruiser', 2023, 'LCR-6789', 7, 'Automatic', 3, 2, 15000);



INSERT INTO FuelType (FuelName, FuelRate)
VALUES
('Petrol', 280),
('Diesel', 260),
('Hybrid', 300),
('Electric', 200);


INSERT INTO VehicleType (TypeName)
VALUES 
('Sedan'),
('Hatchback'),
('SUV'),
('Van'),
('Pickup Truck');


INSERT INTO UserRole( RoleName )

VALUES('Customer'),
('Admin'),
('SuperAdmin');

GO

CREATE PROCEDURE FilterVehicles
    @Brand VARCHAR(50) = NULL,
    @Model VARCHAR(50) = NULL,
    @MakeYear INT = NULL,
    @SeatingCapacity INT = NULL,
    @TransmissionType VARCHAR(20) = NULL,
    @TypeID INT = NULL,
    @FuelTypeID INT = NULL,
    @MinRate INT = NULL,
    @MaxRate INT = NULL
AS
BEGIN
    SELECT *
    FROM Vehicle
    WHERE (@Brand IS NULL OR Brand = @Brand)
      AND (@Model IS NULL OR Model = @Model)
      AND (@MakeYear IS NULL OR MakeYear = @MakeYear)
      AND (@SeatingCapacity IS NULL OR SeatingCapacity = @SeatingCapacity)
      AND (@TransmissionType IS NULL OR TransmissionType = @TransmissionType)
      AND (@TypeID IS NULL OR TypeID = @TypeID)
      AND (@FuelTypeID IS NULL OR FuelTypeID = @FuelTypeID)
      AND (@MinRate IS NULL OR RATE >= @MinRate)
      AND (@MaxRate IS NULL OR RATE <= @MaxRate);
END;


EXEC FilterVehicles
    @Brand = 'Toyota',
    @TransmissionType = 'Automatic',
    @MaxRate = 5000;


	EXEC FilterVehicles 
    @Brand = 'Toyota',
    @TransmissionType = 'Automatic';

	EXEC FilterVehicles 
    @SeatingCapacity = 5;

	GO


	CREATE PROCEDURE AuthenticateUser
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ul.LoginID,
        ul.PasswordHash,
        ul.RoleID,
        c.CustomerID
    FROM UserLogin ul
    LEFT JOIN Customer c ON ul.LoginID = c.LoginID
    WHERE ul.Username = @Username;
END;

GO

CREATE PROCEDURE RegisterCustomers
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @PhoneNumber VARCHAR(20),
    @HomeAddress VARCHAR(255),
    @DrivingLicenseNumber VARCHAR(30),
    @NationalIDNumber VARCHAR(30),
    @RoleID INT = 1 -- assuming 1 = Customer
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO UserLogin (Username, PasswordHash, RoleID)
    VALUES (@Username, @PasswordHash, @RoleID);

    DECLARE @LoginID INT = SCOPE_IDENTITY();

    INSERT INTO Customer (
        FirstName, LastName, Email, PhoneNumber, HomeAddress,
        DrivingLicenseNumber, NationalIDNumber, LoginID
    )
    VALUES (
        @FirstName, @LastName, @Email, @PhoneNumber, @HomeAddress,
        @DrivingLicenseNumber, @NationalIDNumber, @LoginID
    );
END;

CREATE PROCEDURE GetAdminUsers
AS
BEGIN
    SELECT LoginID, Username, RoleID
    FROM UserLogin
    WHERE RoleID IN (2, 3);
END;

CREATE PROCEDURE AddAdmin
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @RoleID INT
AS
BEGIN
    INSERT INTO UserLogin (Username, PasswordHash, RoleID)
    VALUES (@Username, @PasswordHash, @RoleID);
END;
CREATE PROCEDURE UpdateAdmins
    @LoginID INT,
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @RoleID INT,
    @CurrentUserRoleID INT
AS
BEGIN
    IF @CurrentUserRoleID != 3
    BEGIN
        RAISERROR('Only SuperAdmins can update admins.', 16, 1);
        RETURN;
    END

    UPDATE UserLogin
    SET Username = @Username,
        PasswordHash = @PasswordHash,
        RoleID = @RoleID
    WHERE LoginID = @LoginID;
END;


CREATE PROCEDURE RemoveAdmin
    @LoginID INT,
    @CurrentUserRoleID INT
AS
BEGIN
    IF @CurrentUserRoleID != 3
    BEGIN
        RAISERROR('Only SuperAdmins can remove admins.', 16, 1);
        RETURN;
    END

    DELETE FROM UserLogin
    WHERE LoginID = @LoginID;
END;


ALTER PROCEDURE RegisterCustomers
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @PhoneNumber VARCHAR(20),
    @HomeAddress VARCHAR(255),
    @DrivingLicenseNumber VARCHAR(30),
    @NationalIDNumber VARCHAR(30),
    @CNICImagePath VARCHAR(255),
    @RoleID INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO UserLogin (Username, PasswordHash, RoleID)
    VALUES (@Username, @PasswordHash, @RoleID);

    DECLARE @LoginID INT = SCOPE_IDENTITY();

    INSERT INTO Customer (
        FirstName, LastName, Email, PhoneNumber, HomeAddress,
        DrivingLicenseNumber, NationalIDNumber, CNICImagePath, LoginID
    )
    VALUES (
        @FirstName, @LastName, @Email, @PhoneNumber, @HomeAddress,
        @DrivingLicenseNumber, @NationalIDNumber, @CNICImagePath, @LoginID
    );
END;


--EXEC sp_rename 'Role', 'UserRole';
--SELECT * FROM Customer
--SELECT * FROM Vehicle
--ALTER TABLE Customer
--DROP COLUMN  PasswordHash;
--DROP TABLE UserLogin;
--DROP TABLE UserRole;
--ALTER TABLE Customer
--DROP CONSTRAINT UQ__Customer__1788CCAD8DE71641;
--ALTER TABLE Customer
--DROP COLUMN UserID;
--DROP TABLE Customer
--EXEC sp_rename 'Customer.UserName', 'LoginID' , 'COLUMN'
--EXEC sp_rename 'LoginID' , 'UserLogin';







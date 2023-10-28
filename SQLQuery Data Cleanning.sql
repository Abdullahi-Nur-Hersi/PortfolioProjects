-- looking the snapshot of our data
SELECT
	*
FROM
	dbo.NashvilleHousing;


-- extracting the date column
-- convert saledate column from datetime data type into date

SELECT
	saledate,
	CAST(saledate AS Date) AS saledate
FROM	
	dbo.NashvilleHousing

-- or you can use CONVERT Function to cast the data type

SELECT
	saledate,
	CONVERT(Date, SaleDate) AS saledate
FROM	
	dbo.NashvilleHousing

-- Update the correct datatype in the database

UPDATE NashvilleHousing
SET SaleDate = CAST(saledate AS Date)

-- make sure if successfuly updated
SELECT
	saledate, 
	SaleDate
	dbo.NashvilleHousing


UPDATE NashvilleHousing
SET NewSaledate = CAST(saledate AS Date);

-- the update seems not function because UPDATE function does not Change the data type so SaleDate stays as datetime
-- to change the data type we use this function

-- ALTER TABLE NashvilleHousing 
-- ALTER COLUMN SaleDate DATE

-- let's create a new salesdate

ALTER TABLE NashvilleHousing
ADD salesdate Date

-- let's use UPDATE Function to add in the new column

UPDATE NashvilleHousing
SET salesdate = CONVERT(Date, saledate)

-- let's check if the update is seccessful

SELECT
	saledate,
	salesdate
FROM
	dbo.NashvilleHousing

-- let's check the propert address

SELECT
COUNT(*) AS Numaddress, 
	PropertyAddress
FROM
	dbo.NashvilleHousing
GROUP BY
	PropertyAddress
ORDER BY Numaddress DESC

-- in the obove query we can see 29 NULL values in the PropertyAddress
-- let's check data with the NULL PropertyAddress Values

SELECT
	*
FROM
	dbo.NashvilleHousing
WHERE 
	PropertyAddress IS NULL

-- as we can see most of NULL Values 20 are associated with the SingleFamily in the LandUse column
SELECT
	COUNT(*)
FROM
	dbo.NashvilleHousing
WHERE 
	PropertyAddress IS NULL
AND LandUse = 'SINGLE FAMILY'

-- let's if the PropertyAddresses have ParcellID if the PropertyAddress is Missing Let's populate the PropetyAddress with the same ParcellId if exists
-- first we will join the table by it self.
-- Select data from two instances of the 'NashvilleHousing' table, aliasing them as 'a' and 'b' for brevity.
-- This query aims to populate missing 'PropertyAddress' values in 'a' with values from 'b' when 'PropertyAddress' in 'a' is NULL.

SELECT
    a.ParcelID, 
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) -- This function checks if a.PropertyAddress is NULL and populates it with the values in b.PropertyAddress if it's not NULL.
-- Join the 'NashvilleHousing' table with itself using aliases 'a' and 'b'.
-- It matches records based on the same 'ParcelID' but excludes records with the same 'UniqueID'.
FROM
    dbo.NashvilleHousing a
JOIN
    dbo.NashvilleHousing b
ON
    a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]  -- This condition ensures that records with duplicate UniqueID values are not joined.

WHERE 
    a.PropertyAddress IS NULL  -- Filter the result set to include records where 'a.PropertyAddress' is NULL.
							   -- This is where we want to populate missing 'PropertyAddress' values.


-- as we now know the values to fillup in the missing values as we created new column with that values
-- lets UPDATE our table  with the new corrected values

UPDATE a -- in this case we use only the alias not the the table name
SET	
	a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	dbo.NashvilleHousing a
JOIN 
	dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE 
	a.PropertyAddress IS NULL

-- if we re-run the earlier query we can see the is no null values anymore

SELECT
    a.ParcelID, 
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) -- This function checks if a.PropertyAddress is NULL and populates it with the values in b.PropertyAddress if it's not NULL.
-- Join the 'NashvilleHousing' table with itself using aliases 'a' and 'b'.
-- It matches records based on the same 'ParcelID' but excludes records with the same 'UniqueID'.
FROM
    dbo.NashvilleHousing a
JOIN
    dbo.NashvilleHousing b
ON
    a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]  -- This condition ensures that records with duplicate UniqueID values are not joined.

WHERE 
    a.PropertyAddress IS NULL  -- Filter the result set to include records where 'a.PropertyAddress' is NULL.

-- we can all so check by using the normal and simplified query

SELECT
	*
FROM
	dbo.NashvilleHousing
WHERE
	PropertyAddress IS NULL

-- if you see the PropertyAddress column it contains the address and the city name
-- we want to split the address and city name by its delimiter 


SELECT
	PropertyAddress
FROM
	dbo.NashvilleHousing

-- we will use what is called SUBSTRING and character index
-- SUBSTRING is a function that extracts a substring from a given string.
--CHARINDEX counts the number of characters in the cell or its used to specify the position 
-- CHARINDEX(',', PropertyAddress) - 1 determines the length of the substring. 
-- It calculates the position of the first comma (,) in the 'PropertyAddress' and subtracts 1 to get the length of the substring.
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, -- Retreiving the address (all text before comma)
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City -- retreiving the city name (all text after comma)
FROM
	dbo.NashvilleHousing

-- let's create two new columns and add the new splited address and city values

-- Add a new column named 'Address' of type NVARCHAR(225) to the 'NashvilleHousing' table.
ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(225)

-- Populate the 'Address' column with a substring from the 'PropertyAddress' column.
-- It extracts the part of the address before the first comma.
UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- Add a new column named 'City' of type NVARCHAR(255) to the 'NashvilleHousing' table.
ALTER TABLE NashvilleHousing
ADD City NVARCHAR(255)

-- Populate the 'City' column with a substring from the 'PropertyAddress' column.
-- It extracts the part of the address after the first comma.
UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- let's check the new added columns

SELECT
	Address,
	City
FROM
	dbo.NashvilleHousing


-- now let's check OwnerAddress\
-- as you see we have the Address, the City and the State in one column

SELECT
	OwnerAddress
FROM
	dbo.NashvilleHousing

-- Now we want to split the OwnerAddress into 3 different columns
-- we don't want to use SUBSTRING fucntion agian as we want to simplify our task
-- we will use PARSENAME
-- parsename function is usefull only with Periods not commas, so we should replace the comma with Period
-- we will use REPLACE Function inside PARSENAME function.
-- PARSENAME function Starts spliting form the back to the first
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	dbo.NashvilleHousing

-- let's create columns for these splitted values and add the values in it.
-- Step 1: Add a new column named 'Ownersaddress' of type NVARCHAR(255) to the 'NashvilleHousing' table.
ALTER TABLE NashvilleHousing
ADD Ownersaddress NVARCHAR(255)

-- Step 2: Populate the 'Ownersaddress' column by splitting the 'OwnerAddress' column using the PARSENAME function.
-- The third part of the split, corresponding to the address, is extracted and assigned to 'Ownersaddress.'
-- Commas in 'OwnerAddress' are replaced with periods before parsing.
UPDATE NashvilleHousing
SET Ownersaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Step 3: Add a new column named 'Ownerscity' of type NVARCHAR(255) to the 'NashvilleHousing' table.
ALTER TABLE NashvilleHousing
ADD Ownerscity NVARCHAR(255)

-- Step 4: Populate the 'Ownerscity' column by splitting the 'OwnerAddress' column using the PARSENAME function.
-- The second part of the split, corresponding to the city, is extracted and assigned to 'Ownerscity.'
-- Commas in 'OwnerAddress' are replaced with periods before parsing.
UPDATE NashvilleHousing
SET Ownerscity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Step 5: Add a new column named 'Ownersstate' of type NVARCHAR(255) to the 'NashvilleHousing' table.
ALTER TABLE NashvilleHousing
ADD Ownersstate NVARCHAR(255)

-- Step 6: Populate the 'Ownersstate' column by splitting the 'OwnerAddress' column using the PARSENAME function.
-- The first part of the split, corresponding to the state, is extracted and assigned to 'Ownersstate.'
-- Commas in 'OwnerAddress' are replaced with periods before parsing.
UPDATE NashvilleHousing
SET Ownersstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- lets check if the columns and values added in our table

SELECT
	OwnerAddress, -- this is the original column and the rest are the splited columns
	Ownersaddress,
	Ownerscity,
	Ownersstate
FROM
	dbo.NashvilleHousing
-- now let's check SoldAsVacant Column

SELECT
	DISTINCT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
-- lets count each value

SELECT
	SoldAsVacant,
	COUNT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 2

-- our next step will be to convert SoldAsVacant values of (Y and N) to (Yes and No)
-- We will use CASE WHEN Funcitons

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM
	dbo.NashvilleHousing

-- let's Update our table by incoporating the new corrected values

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-- lets double check if the values inserted

SELECT
	SoldAsVacant,
	COUNT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant

-- Now we will remove duplicates
-- we are going Partition our data 
-- and then we will use CTE to simplify our task
-- and lastly we will delete the duplicate entries
-- we will write CTE function to find where there are duplicate values
-- we gonna partition it things we are expencting to be unique

WITH RowNum AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					Salesdate,
					LegalReference
	ORDER BY	    UniqueID) AS row_num
FROM
	dbo.NashvilleHousing
--ORDER BY
--	ParcelID
)
SELECT
	*
FROM
	RowNum
WHERE 
	row_num > 1
ORDER BY 
	PropertyAddress

-- as we find all of the duplicate values now we will delete the duplicates using DELETE function

WITH RowNum AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					Salesdate,
					LegalReference
	ORDER BY	    UniqueID) AS row_num
FROM
	dbo.NashvilleHousing
--ORDER BY
--	ParcelID
)
DELETE
FROM
	RowNum
WHERE 
	row_num > 1
--ORDER BY 
--	PropertyAddress

-- we run the above function to check if there is duplicates we find all duplicate values have been deleted.
------------------------------------------------------------------------------------------------------------------

-- now we will delete un wanted columns.

SELECT
	*
FROM
	dbo.NashvilleHousing

-- let's delete OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-- lets drop also SaleDate Column as we create other corrected Saledate column

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
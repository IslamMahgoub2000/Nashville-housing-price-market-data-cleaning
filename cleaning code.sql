/* DATA CLEANING SQL QUERIES of the Nashville Housing Dataset*/
-- This is a Case study focus on data cleaning using SQL
-- The dataset is available on https://www.kaggle.com/tmthyjames/nashville-housing-data

SELECT *
FROM dbo.housing

------------------------------------------------------
--Standardize Date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM dbo.housing

UPDATE dbo.housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;
UPDATE dbo.housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------
-- Populate Property address data
SELECT *
FROM dbo.housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID  -- Same ParcelID = Same address


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM dbo.housing A
JOIN dbo.housing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE  dbo.housing A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM dbo.housing
JOIN dbo.housing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------
-- Breaking out Address into induvidual columns (Address, City)

SELECT PropertyAddress -- The delimiter is a comma
FROM dbo.housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.housing

ALTER TABLE dbo.housing -- Address
ADD PropertySplitAdress NVARCHAR(255);
UPDATE dbo.housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE dbo.housing -- City
ADD PropertySplitCity NVARCHAR(255);
UPDATE dbo.housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM dbo.housing

------------------------------------------------------
-- Breaking Owner Address -- This time with PARSENAME
SELECT OwnerAddress
FROM dbo.housing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM dbo.housing


ALTER TABLE nashvillehousing -- Address
ADD OwnerSplitAdress NVARCHAR(255);
UPDATE dbo.housing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE nashvillehousing -- City
ADD OwnerSplitCity NVARCHAR(255);
UPDATE dbo.housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE dbo.housing -- State
ADD OwnerSplitState NVARCHAR(255);
UPDATE dbo.housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM dbo.housing



------------------------------------------------------
-- Changing Y an N to Yes and No in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM dbo.housing

UPDATE dbo.housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

------------------------------------------------------
-- Removing duplicates

WITH RowNumCTE AS ( --temp table
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID )
					row_num					
FROM dbo.housing
--ORDER BY ParcelID 
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1


------------------------------------------------------
--Removing unused columns 
SELECT *
FROM dbo.housing

ALTER TABLE portfolio_project.dbo.nashvillehousing
DROP COLUMN OwnerAddress,
			PropertyAddress

ALTER TABLE portfolio_project.dbo.nashvillehousing
DROP COLUMN SaleDate
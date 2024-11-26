-- cleaning data in SQL Queries
SELECT * 
FROM PortfolioProjects.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjects.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Select saleDateConverted
From PortfolioProjects.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT  PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing
--WHERE PropertyAddress is null

SELECT  PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]; 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null; 



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null; 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelID;

SELECT 
SUBSTRING(PropertyAddress, 1,  CHARINDEX (',' ,PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,  CHARINDEX (',' ,PropertyAddress)+1, LEN (PropertyAddress)) as Address
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitAddress NvarChar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX (',' ,PropertyAddress)-1) 

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitCity NvarChar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX (',' ,PropertyAddress)+1, LEN (PropertyAddress))


SELECT
PARSENAME (REPLACE (OwnerAddress, ',','.'),3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME (REPLACE (OwnerAddress,',', '.'),1)
FROM PortfolioProjects.dbo.NashvilleHousing;

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress NvarChar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitCity NvarChar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET  OwnerSplitCity= PARSENAME (REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitState NvarChar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET  OwnerSplitState = PARSENAME (REPLACE (OwnerAddress,',', '.'),1)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold and vacant " field

select Distinct(SoldAsVacant), COUNT (SoldAsVacant)
FROM PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant 
Order by 2;


Select SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant 

END 
FROM PortfolioProjects.dbo.NashvilleHousing;

update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant =CASE
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant 

END 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- remove duplicates

select * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID
			   ) row_num
FROM PortfolioProjects.dbo.NashvilleHousing
order by ParcelID

WITH RowNumCTE AS (

select * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID
			   ) row_num
FROM PortfolioProjects.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate



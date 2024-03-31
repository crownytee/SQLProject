--DATA CLEANING USING SQL

SELECT *
FROM NashvilleHousing

--Data Format Standadization

Select SaleDate,CONVERT(Date, SaleDate) 
From NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Property Address Data Population

Select*
From NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID

--Join the table to itself where ParcelID is Same but the UniqueID is different

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Check if a.propertyAddress isnull, if yes then Populate the Value of b.property address in it.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Update the Table to Remove the Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Break out Address into Individual Columns(Address, City, State) using SUBSTRINGS

SELECT PropertyAddress
FROM NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select*
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

-- Seperate OwnwerAddress Column into seperate columns using another method: PARSENAME

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
From NashvilleHousing

-- Arrange columns into Forwards, Parsename count backwards.

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitSate Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitSate = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From NashvilleHousing

--Change Y and N to YES and NO in *Sold as Vacant* field

Select Distinct(SoldAsVacant)
From NashvilleHousing

--Count the Distinct values in *Sold as Vacant* field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

-- Update *Sold as vacant* Field in NashVillHousing
UPDATE NashvilleHousing
SET SoldAsVacant = Case
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

-- Confirm Update in *SoldAsVacant* field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

-- REMOVE DUPLICATES DATA USING CTEs
-- View all the Duplicates Data

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				    )row_num

From NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num > 1
Order by PropertyAddress

-- DELETE DUPLICATES 

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				    )row_num

From NashvilleHousing
)
DELETE
From RowNumCTE
WHERE row_num > 1

-- Confirm If Duplicates Still Exist

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				    )row_num

From NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num > 1
Order by PropertyAddress

-- DELETE UNUSED COLUMNS

Select*
From NashVilleHousing

Alter TABLE NashVilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE NashVilleHousing
Drop COLUMN SaleDate
















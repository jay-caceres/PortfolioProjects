
-- Standardize Date Format
SELECT saleDate, CONVERT(Date,saleDate)
FROM [NashvilleHousing ]


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE [NashvilleHousing ]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------
--Populate Property Address Data
--same parcelID with same property address

SELECT *
FROM [NashvilleHousing ]
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

--checks for null values with self join
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [NashvilleHousing ] a
JOIN [NashvilleHousing ] b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--updates values in table
UPDATE a
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [NashvilleHousing ] a
JOIN [NashvilleHousing ] b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--breaking out address into individual columns
SELECT PropertyAddress
FROM [NashvilleHousing ]
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

FROM [NashvilleHousing ]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



--Owner Address
SELECT OwnerAddress
FROM [NashvilleHousing ]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [NashvilleHousing ]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change "sold as vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM [NashvilleHousing ]

UPDATE [NashvilleHousing ]
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END


--remove duplicates
WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
    PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
    ORDER BY UniqueID) row_num
    
FROM [NashvilleHousing ]
)
--ACTUALLY DELETING 
--SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- delete unused column
SELECT * 
FROM [NashvilleHousing ]

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

SELECT CONVERT(SaleDate,DATE)
FROM housing.nashville_housing;

SELECT *
from nashville_housing;
DESC nashville_housing;
SELECT CONVERT(SaleDate,CHAR)
FROM nashville_housing;
UPDATE nashville_housing
SET SaleDate=CONVERT(SaleDate,CHAR);
DESC nashville_housing;

-- changing data type of acolumn
ALTER TABLE nashville_housing
MODIFY COLUMN SaleDate DATE;

-- populate property adress data 
SELECT *
FROM nashville_housing
-- WHERE PropertyAddress="0";
ORDER BY ParcelID;


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,coalesce(b.PropertyAddress,a.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
ON a.ParcelID=b.ParcelID
AND a.uniqueID <> b.UniqueID
WHERE a.PropertyAddress="0";

UPDATE nashville_housing a
JOIN nashville_housing b
ON a.ParcelID = b.ParcelID
AND a.uniqueID <> b.uniqueID
SET a.PropertyAddress = COALESCE(NULLIF(a.PropertyAddress, '0'), b.PropertyAddress)
WHERE a.PropertyAddress = '0';

-- BREAKING out Address into individual columns (Address ,city,state)
SELECT PropertyAddress
FROM nashville_housing;

SELECT 
substring(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) AS address,
substring(PropertyAddress,LOCATE(',',PropertyAddress)+1) AS city  ,length(PropertyAddress) AS length
FROM nashville_housing;

-- adding new column called propertysplit adress as varchar
ALTER TABLE nashville_housing
ADD propertysplitaddress VARCHAR(255);

-- giving data
UPDATE nashville_housing
SET propertysplitaddress =substring(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

-- adding another column name propertysplitcity
ALTER TABLE nashville_housing
ADD propertysplitcity VARCHAR(255);

-- giving data
UPDATE nashville_housing
SET propertysplitcity=substring(PropertyAddress,LOCATE(',',PropertyAddress)+1);

SELECT *
FROM nashville_housing;


-- Owner address
SELECT OwnerAddress
FROM nashville_housing;

-- using substring_index
SELECT 
substring_index(OwnerAddress,',',-3),
substring_index(OwnerAddress,',',-2),
substring_index(OwnerAddress,',',-1)
FROM nashville_housing;

-- adding it to the table
ALTER TABLE nashville_housing
ADD Owneraddress_split VARCHAR(255);

UPDATE nashville_housing
SET Owneraddress_split =substring_index(OwnerAddress,',',-3);

-- adding ownercitysplit
ALTER TABLE nashville_housing
ADD Ownercity_split VARCHAR(255);

UPDATE nashville_housing
SET Ownercity_split =substring_index(OwnerAddress,',',-2);

-- adding ownerstate
ALTER TABLE nashville_housing
ADD Ownerstate_split VARCHAR(255);

UPDATE nashville_housing
SET Ownerstate_split =substring_index(OwnerAddress,',',-1);



-- change Y and N to yes and no in "sold as vacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashville_housing	
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldASVacant,
 CASE WHEN SoldAsVacant="Y" THEN "Yes"
 WHEN SoldAsVacant="N" THEN "No"
 ELSE SoldAsVacant
 END
 FROM nashville_housing;
 
 -- updating table
 UPDATE nashville_housing
 SET SoldAsVacant=CASE WHEN SoldAsVacant="Y" THEN "Yes"
 WHEN SoldAsVacant="N" THEN "No"
 ELSE SoldAsVacant
 END;
 
 
 -- remove duplicates
 
 -- this query gives duplicate values
DELETE n1 FROM nashville_housing n1
JOIN (
    SELECT UniqueID 
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
                   ORDER BY UniqueID
               ) AS row_num
        FROM nashville_housing
    ) AS subquery
    WHERE row_num > 1
) AS duplicates
ON n1.UniqueID = duplicates.UniqueID;


-- delete unused column 
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;


ALTER TABLE nashville_housing
DROP COLUMN SaleDate; 


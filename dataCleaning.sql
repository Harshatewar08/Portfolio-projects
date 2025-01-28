select * 
FROM "dataCleaning".nashville_housing

---------------------------------------------------------------------------

-- Populate Property Address data 

select *
FROM "dataCleaning".nashville_housing
--where propertyaddress is null
Order by parcelid

select a.parcelId, a.Propertyaddress,b.parcelId, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress)
FROM "dataCleaning".nashville_housing a
JOIN "dataCleaning".nashville_housing b 
	ON a.parcelId = b.parcelId 
	AND a."UniqueId" is distinct from b."UniqueId"
where a.propertyaddress is null


UPDATE "dataCleaning".nashville_housing
SET Propertyaddress =  coalesce(a.propertyaddress, b.propertyaddress)
FROM "dataCleaning".nashville_housing a
JOIN "dataCleaning".nashville_housing b 
	ON a.parcelId = b.parcelId 
	AND a."UniqueId" is distinct from b."UniqueId"
where a.propertyaddress is null

----------------------------------------------------------------------------------------------------------------------
-- Breaking out  property address into individual columns (address, city )

select propertyaddress
FROM "dataCleaning".nashville_housing
--where propertyaddress is null
--Order by parcelid

SELECT 
SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) as address,
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress) ) as city
FROM "dataCleaning".nashville_housing;


ALTER TABLE "dataCleaning".nashville_housing
ADD propertySplitaddress varchar(200)

Update "dataCleaning".nashville_housing
set propertySplitaddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)

ALTER TABLE "dataCleaning".nashville_housing
ADD propertySplitcity varchar(200)

update "dataCleaning".nashville_housing
set propertySplitCity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1, LENGTH(propertyaddress) )

-- Breaking out  owner address into individual columns (address, city,state )

select owneraddress ,
split_part(owneraddress,',', 1) as address,
split_part(owneraddress,',', 2) as city,
split_part(owneraddress,',', 3) as state
FROM "dataCleaning".nashville_housing



ALTER TABLE "dataCleaning".nashville_housing
ADD OwnerSplitaddress varchar(200)

Update "dataCleaning".nashville_housing
set OwnerSplitaddress = split_part(owneraddress,',', 1)


ALTER TABLE "dataCleaning".nashville_housing
ADD OwnerSplitcity varchar(200)

Update "dataCleaning".nashville_housing
set OwnerSplitcity = split_part(owneraddress,',', 2)



ALTER TABLE "dataCleaning".nashville_housing
ADD OwnerSplitState varchar(200)

Update "dataCleaning".nashville_housing
set OwnerSplitState = split_part(owneraddress,',', 3)





SELECT  * 
FROM "dataCleaning".nashville_housing
WHERE owneraddress is not null


-- Changing Y and N into yes and no in "soldasvacant" column

SELECT distinct(soldasvacant), count(soldasvacant)
FROM "dataCleaning".nashville_housing
GROUP BY 1
ORder by 2;




SELECT soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
		when  soldasvacant = 'N' then 'No'
		ELSE soldasvacant END
FROM "dataCleaning".nashville_housing


UPDATE "dataCleaning".nashville_housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
		when  soldasvacant = 'N' then 'No'
		ELSE soldasvacant END

----------------------------------------------------------------
--Removing duplicates

--Identifying duplicates
WITH RowNumCTE AS(
select *,
ROW_NUMBER() over (
partition by parcelID,
				propertyaddress,
				saleprice,
				saleDate,
				legalreference
				order by 
					nashville_housing."UniqueId"
) as row_num
FROM "dataCleaning".nashville_housing
Order by parcelId
)
SELECT * 
FROM RowNumCTE
where row_num >1
ORDER BY parcelId

-- DELETING Duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY parcelID,
                            propertyaddress,
                            saleprice,
                            saleDate,
                            legalreference
               ORDER BY nashville_housing."UniqueId"
           ) AS row_num
    FROM "dataCleaning".nashville_housing
)
DELETE FROM "dataCleaning".nashville_housing
USING RowNumCTE
WHERE "dataCleaning".nashville_housing."UniqueId" = RowNumCTE."UniqueId"
  AND RowNumCTE.row_num > 1;

----------------------------------------------------------------------------------------------

-- Delete unused Columns


select * 
FROM "dataCleaning".nashville_housing


ALTER TABLE "dataCleaning".nashville_housing
DROP COLUMN owneraddress

ALTER TABLE "dataCleaning".nashville_housing
DROP COLUMN TaxDistrict

ALTER TABLE "dataCleaning".nashville_housing
DROP COLUMN propertyaddress

ALTER TABLE "dataCleaning".nashville_housing
DROP COLUMN saledate
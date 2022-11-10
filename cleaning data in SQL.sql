/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portprjt].[dbo].[Nashville]
  use portprjt
  select*
  from portprjt.dbo.Nashville

  --to standardize sale date format
  select SaleDateConverted, CONVERT(date, SaleDate)
  from portprjt.dbo.Nashville
 
  update Nashville
  set SaleDate = CONVERT(Date, SaleDate)

--to show the updated date format, we say:
Alter Table Nashville
add SaleDateConverted date;
update Nashville
set SaleDateConverted = CONVERT(Date, SaleDate)



--POPULATE THE PROPERTY ADDRESS
select *
  from portprjt.dbo.Nashville
  --where PropertyAddress is null
  order by ParcelID

  --from the code above, we see that some rows have the same parcelid and the same property address and that could have been the reason why some property address appear as null
  --we need to populate the property address that appear as null but duplicate parcelid
  --to write this code, we need to do a self-join


  select a.PropertyAddress,a.ParcelID, b.PropertyAddress, b.ParcelID
  from portprjt.dbo.Nashville a
  join portprjt.dbo.Nashville b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  where a.PropertyAddress is null

  --after runnimg the code, you'll find out that a.propertyaddress has missing values whereas b.property address does not, and there is a new column containing the PropertyAdddress we which to use to populate a.property address
  --to populate the property address, we say:
  select a.PropertyAddress,a.ParcelID, b.PropertyAddress, b.ParcelID, isnull (a.PropertyAddress, b.PropertyAddress)
  from portprjt.dbo.Nashville a
  join portprjt.dbo.Nashville b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  where a.PropertyAddress is null

  --to populate the a.propertyAddress with the newly formed column
  update a
  set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
  from portprjt.dbo.Nashville a
  join portprjt.dbo.Nashville b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
  where a.PropertyAddress is null


  --BREAKING OUT ADDRESS INTO DIFFERENT COLUMNS (ADDRESS, CITY, STATE)
  select PropertyAddress
  from portprjt.dbo.Nashville
  --where PropertyAddress is null
  --order by ParcelID

  --Using substring
  select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
  --CHARINDEX(',', PropertyAddress)
   from portprjt.dbo.Nashville
  --the code above runs fine, but Address comes with comma   
  --to correct this, we rewrite code
   select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
  --CHARINDEX(',', PropertyAddress)
   from portprjt.dbo.Nashville

   select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
  --CHARINDEX(',', PropertyAddress)
   from portprjt.dbo.Nashville
   --to add the new variables to the table ie Nashville
   
 
   Alter Table Nashville
add PropertySplitAddress Nvarchar(255);
update Nashville
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table Nashville
add PropertySplitCity Nvarchar(255);
update Nashville
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

--Using Parsename to separate OwnerAddress
select OwnerAddress
from portprjt.dbo.Nashville

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from portprjt.dbo.Nashville

use portprjt
--Use databaseName came in handy because for some unknown reason the query couldn't access the table
Alter Table Nashville
add OwnerSplitAddress Nvarchar(255);
update Nashville
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table Nashville
add OwnerSplitCity Nvarchar(255);
update Nashville
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

use portprjt
Alter Table Nashville
add OwnerSplitState Nvarchar(255);
Update Nashville
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select *
from portprjt.dbo.Nashville

--CHANGE Y and N to YES and NO IN SOLDASVACANT FIELD
select distinct(SoldAsVacant), count(SoldAsVacant)
from portprjt.dbo.Nashville
group by SoldAsVacant
order by 2 asc
--using Case Statement
select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from portprjt.dbo.Nashville

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end


--REMOVING DUPLICATES
--the code below helps to find the rows in the data that are duplicates
with ROWNUMCTE as(
select*,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
						) row_num

from portprjt.dbo.Nashville
--order by ParcelID
)
--to find duplicate rows
select *
from ROWNUMCTE
where row_num > 1
order by PropertyAddress

with ROWNUMCTE as(
select*,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
						) row_num

from portprjt.dbo.Nashville
--order by ParcelID
)
--to delete the duplicate rows
delete
from ROWNUMCTE
where row_num > 1
--order by PropertyAddress


--DELETING UNUSED COLUMNS ie PropertyAddress, OwnerAddress, TaxDistrict
 select*
  from portprjt.dbo.Nashville

  Alter Table portprjt.dbo.Nashville
  drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

  select*
  from portprjt.dbo.Nashville

   Alter Table portprjt.dbo.Nashville
  drop column SaleDate

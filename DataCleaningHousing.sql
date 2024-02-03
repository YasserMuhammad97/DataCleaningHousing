/*

Cleaning Data in SQL Queries

*/


  select * from PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

   select convert(Date,SaleDate ) as salesdate
   from PortfolioProject..NashvilleHousing

   alter table PortfolioProject..NashvilleHousing
   add SaleDateConverted Date;
   
   update PortfolioProject..NashvilleHousing
   set SaleDateConverted =  convert(Date,SaleDate );


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
  select   a.ParcelID , a.PropertyAddress,b.ParcelID ,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update  a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

  
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- property address
	select PropertyAddress , SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
	,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress)) as address2
	from PortfolioProject..NashvilleHousing

	alter table PortfolioProject..NashvilleHousing
   add PropertySplitAddress nvarchar(255);
   
   update PortfolioProject..NashvilleHousing
   set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1);

   alter table PortfolioProject..NashvilleHousing
   add PropertySplitCity nvarchar(255);
   
   update PortfolioProject..NashvilleHousing
   set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress));

	-- owner address

   select OwnerAddress
   from PortfolioProject..NashvilleHousing

	select OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3)  
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2) , PARSENAME(REPLACE(OwnerAddress,',','.'),1)  
	from PortfolioProject..NashvilleHousing
	where OwnerAddress is not null;

	
	alter table PortfolioProject..NashvilleHousing
   add OwnerSplitAddress nvarchar(255)
   ,OwnerSplitcity nvarchar(255) , OwnerSplitState nvarchar(255);
   
   update PortfolioProject..NashvilleHousing
   set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)
   , OwnerSplitcity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)
   ,OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1);

 

 
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select SoldAsVacant , count(SoldAsVacant)
from PortfolioProject..NashvilleHousing 
group by SoldAsVacant

select SoldAsVacant, CASE
 when SoldAsVacant = 'N' Then 'No'
 when SoldAsVacant = 'Y' then 'Yes'
 else SoldAsVacant
 end as NewSoldAsVacant
from PortfolioProject..NashvilleHousing 

update PortfolioProject..NashvilleHousing
set SoldAsVacant = CASE
 when SoldAsVacant = 'N' Then 'No'
 when SoldAsVacant = 'Y' then 'Yes'
 else SoldAsVacant
 end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
 
 with RoWNumCTE as (
 select *,ROW_NUMBER() over (	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
				 ORDER BY UniqueID) row_num 
 from PortfolioProject..NashvilleHousing 
 )
 delete from RoWNumCTE
 where row_num > 1


 ---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



 Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
-- cleaning data in SQL 

Select * 
From [PortfolioProject].[dbo].[NasvhvilleHousing]

--Change/Standardize sales date 

Select SaleDateCoverted, CONVERT (date,SaleDate)
From PortfolioProject.dbo.NasvhvilleHousing


Update PortfolioProject].[dbo].[NasvhvilleHousing]
SET SaleDate = CONVERT(date,SaleDate)


Alter table PortfolioProject.dbo.NasvhvilleHousing
Add SaleDateCoverted  Date;

Update PortfolioProject.dbo.NasvhvilleHousing
SET SaleDateCoverted = CONVERT(date,SaleDate)


Select * from PortfolioProject.dbo.NasvhvilleHousing


--populate property Address Data 

Select *
From PortfolioProject.dbo.NasvhvilleHousing
--Where PropertyAddress is null
Order by ParcelID 

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NasvhvilleHousing a 
Join PortfolioProject.dbo.NasvhvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null 


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NasvhvilleHousing a 
Join PortfolioProject.dbo.NasvhvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null 

--Breaking out address into individual Columns (address, City, state) 


Select SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress)) as Address 
from PortfolioProject.dbo.NasvhvilleHousing


Alter table PortfolioProject.dbo.NasvhvilleHousing
Add PropertySplitAddress  nvarchar (255);

Update PortfolioProject.dbo.NasvhvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1)

Alter table PortfolioProject.dbo.NasvhvilleHousing
Add PropertySplitCity  nvarchar (255);

Update PortfolioProject.dbo.NasvhvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, Len(PropertyAddress))


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NasvhvilleHousing


Alter table PortfolioProject.dbo.NasvhvilleHousing
Add OwnerSplitAddress  nvarchar (255);

Update PortfolioProject.dbo.NasvhvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


Alter table PortfolioProject.dbo.NasvhvilleHousing
Add OwnerSplitCity  nvarchar (255);

Update PortfolioProject.dbo.NasvhvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


Alter table PortfolioProject.dbo.NasvhvilleHousing
Add OwnerSplitState  nvarchar (255);

Update PortfolioProject.dbo.NasvhvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


Select * From PortfolioProject.dbo.NasvhvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NasvhvilleHousing
Group by (SoldAsVacant)

Select SoldAsVacant
,Case 
When SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
Else SoldAsVacant
End
From PortfolioProject.dbo.NasvhvilleHousing


update PortfolioProject.dbo.NasvhvilleHousing
Set SoldAsVacant = Case 
When SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
Else SoldAsVacant
End



-------------------------------------------------------------------------------------------------------


--Remove Duplicates 

--* not a standard practice to delete data from database 

WITH RowNumCTE AS (
Select *, 
row_number () over(
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID ) row_num 


From PortfolioProject.dbo.NasvhvilleHousing
--order by ParcelID
)

--Delete
Select * 
from RowNumCTE
where row_num > 1 
--order by PropertyAddress

-------------------------------------------------------------------------------------------------------
--Delete Unused Columns 
--Best practice is to not do this with your raw data and this is typically done when creating a view 


Select * 
From PortfolioProject.dbo.NasvhvilleHousing

Alter Table  PortfolioProject.dbo.NasvhvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table  PortfolioProject.dbo.NasvhvilleHousing
Drop Column SaleDate


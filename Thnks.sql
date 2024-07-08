
-- add new date column
alter table dbo.Thnks
add new_date_sent date

--set the new column as date column
update dbo.Thnks
set new_date_sent  =cast(date_sent as date)

--drop the unwanted date columns
alter table dbo.Thnks
drop column date_sent

--rename to 'Date_sent'
EXEC sp_rename 'dbo.Thnks.new_date_sent', 'Date_sent', 'COLUMN'

--Add columns to the tabel
alter table dbo.Thnks
add  Sumcost decimal(18, 2) ,
Countitemsent int,
percentage_item_opened decimal(18, 2) ,
percentage_item_redeemed decimal(18, 2),
percentage_replied decimal(18, 2)


--Create a temporary table "TempResults" 
select *,
sum(total_cost) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) as "Sum_cost",
count(*) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) as "Count_itemsent",
cast(sum(case when opened = 1 then 1 else 0 end) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) as decimal)/
count(*) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) * 100 as "%item_opened",
cast(sum(case when redeemed = 1 then 1 else 0 end) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) as decimal)/
count(*) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) * 100 as "%item_redeemed",
cast(sum(case when reply_back = 1 then 1 else 0 end) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) as decimal)/
count(*) over (partition by user_id,team_id,ThnksItem_Sent order by user_id) * 100 as "%replied"
INTO #TempResults
from Thnks

--Update table to match the columns and input value
UPDATE T
SET T.Sumcost = TR.Sum_cost,
    T.Countitemsent = TR.Count_itemsent,
    T.percentage_item_opened = TR."%item_opened",
    T.percentage_item_redeemed =TR."%item_redeemed",
    T.percentage_replied = TR."%replied"
FROM Thnks T
JOIN #TempResults TR ON T.user_id = TR.user_id AND T.team_id = TR.team_id AND T.ThnksItem_Sent = TR.ThnksItem_Sent;

--Rename the final columns
EXEC sp_rename 'dbo.Thnks.Sumcost', 'Sum_cost', 'COLUMN';
EXEC sp_rename 'dbo.Thnks.Countitemsent', 'Count_item', 'COLUMN';
EXEC sp_rename 'dbo.Thnks.percentage_item_opened', 'Percentage_opened', 'COLUMN';
EXEC sp_rename 'dbo.Thnks.percentage_item_redeemed', 'Percentage_redeemed', 'COLUMN';
EXEC sp_rename 'dbo.Thnks.percentage_replied', 'Percentage_replied', 'COLUMN';

select * from Thnks

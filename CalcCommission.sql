/* get Sales for a specific office for the current month */
Alter PROCEDURE dbo.calcCommission @salesmonth date

AS

DECLARE 
@AgentSalesAmt money, @OfficeTarget money, @AgentId int, @Rate numeric(10,5), @multiplier numeric(10,2),@OfficeName varchar(50)

/* popualate total sales per office */
SELECT agent.agentid, booking.OFFICENAME, sum(revenue) as AgentSalesAmt, rate,1000000.00 as officetarget ,1000000.00 as commission
INTO #AgentSalesTemp
from Agent
join booking on booking.AGENTID= agent.AGENTID
Where BOOKINGDATE between FORMAT(@salesmonth, 'yyyy-MM-01') and eomonth(@salesmonth)
group by agent.agentid, booking.officename,rate

-- Uncommentbelow to View temp table
--select * from #AgentSalesTemp

select @OfficeName= office.officename
from office
where salesdate =  FORMAT(@salesmonth, 'yyyy-MM-01');

update #AgentSalesTemp
set OfficeTarget = 
(select officetarget from office where OFFICENAME =

(
CASE

	when @OfficeName = 'Australia'
	then 'Australia'

	when @OfficeName = 'South Africa'
	then 'South Africa'

	when @OfficeName = 'Canada'
	then 'Canada'

	when @OfficeName = 'UK & Ireland'
	then 'UK & Ireland'

	when @OfficeName = 'France'
	then 'France'

	when @OfficeName = 'Germany'
	then 'Germany'
end

)	and salesdate =  FORMAT(@salesmonth, 'yyyy-MM-01'))
	

PRINT @OFFICENAME

--set officetarget = 
--(select officetarget from office where OFFICENAME = @officename
--and salesdate =  FORMAT(@salesmonth, 'yyyy-MM-01'))

-- Flow of control to determaine whether agents get a higher commission based on meeting or exceeding the office target.
IF (SELECT sum(AgentSalesAmt)/max(officeTarget)  from #AgentSalesTemp) < 1.00
SET @multiplier =1.00

IF (SELECT sum(AgentSalesAmt)/max(officeTarget) from #AgentSalesTemp) between 1.00 and 1.10
SET @multiplier =1.20
ELSE 
SET @multiplier = 1.40

/*update temp table*/
UPDATE #AgentSalesTemp
SET commission = RATE*@multiplier*AgentSalesAmt

/*view temp table */
select * from #AgentSalesTemp

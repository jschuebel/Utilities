declare @dtm as date, @dtmSunday as date
declare @dofw int, @daystilSun int
--select @dtm=cast('11/1/' + cast(Year(GetDate()) as varchar) as date)
select @dtm=cast('11/1/2010' as date)
SELECT @dofw=DATEPART(weekday, @dtm)
SELECT @dofw dayofweek
select @daystilSun=ABS(1-@dofw)
select @daystilSun daystilSun

select @dtmSunday=dateadd(d,@daystilSun,@dtm)


select @dtmSunday


--1st Sun of Nov
--1=Sun-7=Sat.
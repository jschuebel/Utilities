 CREATE FUNCTION [dbo].[GetEasterDate](
  @wYear AS int
)
RETURNS datetime
AS
BEGIN
	declare @g int, @c int, @h int, @i int, @j int, @p int
	declare @wDay int, @wMonth int
	declare @est date

--	declare @wYear int
--	set @wYear=2013

	set @g= @wYear % 19
	set @c= @wYear / 100
	set @h= (@c - (@c/4) - ((8*@c+13) / 25) + (19 * @g) + 15) % 30
	set @i= @h - (@h/28) * (1-(@h/28) * (29/@h+1) * ((21-@g)/11))
	set @j= (@wYear + (@wYear/4) + @i + 2 - @c + (@c/4)) % 7
	set @p= @i - @j + 28
	set @wDay = @p
	set @wMonth = 4
	if (@p > 31)
	set @wDay = @p - 31
	else
	set @wMonth = 3
	set @est = cast((cast(@wMonth as varchar) + '/' + cast(@wDay as varchar) + '/' + cast(@wYear as varchar)) as date)
	--select @g mod, @c yearv, @h hv, @i iv, @j jv, @p pv, @est easter
  RETURN @est
END



select [dbo].GetEasterDate(2010)
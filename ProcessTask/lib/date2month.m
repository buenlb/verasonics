function days = date2month(year,mo,day)
moDays = [31,28,31,30,31,30,31,31,30,31,30,31];

days = year*12+mo-1+day/moDays(mo);
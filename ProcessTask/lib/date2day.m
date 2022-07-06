function days = date2day(year,mo,day)
moDays = [31,28,31,30,31,30,31,31,30,31,30,31];

days = year*365+sum(moDays(1:(mo-1)))+day;
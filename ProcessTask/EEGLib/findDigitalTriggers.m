function idx = findDigitalTriggers(d)

idx = find(diff(d)>0);
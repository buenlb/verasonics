function idx = myBinner(sessions,param,bins)

bins = [-inf,bins(2:end-1),inf];

if length(sessions)~=length(param)
    error('Sessions and param must be the same length!')
end

idx = discretize(param,bins);
function pv=rndttest(x,y,varargin)
% RNDTTEST Perform a Randomisation test to assess difference in means.
% Permutation or randomisation tests are a useful alternative to more
% standard parametric tests for analysing experimental data. They have the
% advantage of making no distributional assumptions (such as Normality)
% about the data, while remaining as powerful as more standard tests. 
% The t-test assumes that the two groups arose by drawing samples from two
% Normally distributed populations, and that we are investigating whether
% these populations differ in their mean. 
% The randomisation test, on the other hand, assumes that some initial set
% of individuals were randomly allocated to two treatment groups.
% The number of permutations to be examined soon grows prohibitively large,
% so, this function uses two approaches: an Exact Method when the possible
% permutations are less than 20.000 and a Monte Carlo Naive Method when the
% permutations are more than 20.000.
% 
% Syntax: pvalue=rndttest(x,y,delta,alpha)
% 
% Inputs: 
%           X and Y (mandatory) - data vectors. 
%           DELTA and ALPHA (optional)- If Monte Carlo method is used it is 
%           necessary to evaluate how many times the process must be 
%           reiterated to ensure that p-value is within DELTA units of the 
%           true one with (1-ALPHA)*100% confidence. 
%           (Default DELTA=ALPHA=0.01).
% 
% Output:    p-value
% 
% Example: 
%           X=[10 11 12]; Y=[17 18 19];
% 
%           Calling on Matlab the function: rndttest(X,Y)
% 
%           Answer is:
% 
% RANDOMISATION TEST
% --------------------------------------------------------------------------------
% Exact Method
% --------------------------------------------------------------------------------
% 20 randomisations evaluated
% Probability (p-value) that the observed difference is accidental: 0.1000
% --------------------------------------------------------------------------------
% 
% This p-value is the best one that can be quoted for these data. It is
% based only on the assumption that individuals are allocated at random
% to groups. It does not assume anything about Normality of
% distributions, which may or may not be true. Even when such
% assumptions are true, the randomisation test is as powerful as a t-test.
% (If you are curious, a t-test of the experimental data in our example gives p=0.00102)
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2008) Rndttest: An alternative to Student t-test assessing difference in means.  
% http://www.mathworks.com/matlabcentral/fileexchange/20928


%Input error handling
p = inputParser;
addRequired(p,'x',@(x) validateattributes(x,{'numeric'},{'row','real','finite','nonnan','nonempty'}));
addRequired(p,'y',@(x) validateattributes(x,{'numeric'},{'row','real','finite','nonnan','nonempty'}));
addOptional(p,'delta',0.01, @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','nonnan','>',0,'<',1}));
addOptional(p,'alpha',0.01, @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','nonnan','>',0,'<',1}));
parse(p,x,y,varargin{:});
alpha=p.Results.alpha; delta=p.Results.delta;
clear p

%set constant values
Nx=length(x); Ny=length(y); T=Nx+Ny; m=min(Nx,Ny); z=[x y];
obsdiff=abs(mean(x)-mean(y)); %observed difference between means

Pms=round(exp(gammaln(T+1)-gammaln(m+1)-gammaln(T-m+1))); %Number of permutations

if Pms<20000 %If the number of permutation is not too high, use the exact method
    flag=0;
    Table=combnk(1:T,m); %all possible allocations
    Xm=mean(z(Table),2); %mean of the first group
    if Nx==Ny %If you have two balanced groups...
        %...to find the elements of the second group, simply flip Table
        Ym=mean(z(flipud(Table)),2); 
    else %If you have two unbalanced groups...
        %There is not a simple function to choose from the whole dataset 
        %the elements that are not in the first group. You would implement
        %a FOR...END cycle like this:
        %   w=1:1:T; Ym=zeros(Pms);
        %   for I=1:Pms
        %       Ym(I)=mean(z(setdiff(w,Table(I,:))));
        %   end
        %In alternative, you can use a simple, arithmetic trick...
        %Replicate the vector of the whole dataset and add the elements of 
        %the first group with changed sign...
        Z=[repmat(z,Pms,1) -z(Table)];
        %..then compute the sum for each row: in this case the element of
        %the first group will be erased and you'll have only the sum of the
        %elements of the second group. To obtain the mean, simply divide
        %for the correct number: max(Nx,Ny) or T-m.
        Ym=sum(Z,2)./max(Nx,Ny);
    end
    d=abs(Xm-Ym); %Compute the magnitude of the difference of the means
else %If the number of permutation is too high, use a MonteCarlo Naive method
    flag=1;
    %Pms=simulation size to ensure that p-value is within delta units of the
    %true one with (1-alpha)*100% confidence. Psycometrika 1979; Vol.44:75-83.
    Pms=round(((-realsqrt(2)*erfcinv(2-alpha))/(2*delta))^2);
    d=zeros(1,Pms); %vector preallocation
    for I=1:Pms
        %shuffle the dataset array using the Fisher-Yates shuffle algorithm
        %Sattolo's version. This is faster than Matlab RANDPERM: to be
        %clearer: Fisher-Yates is O(n) while Randperm is O(nlog(n))
        for J=T:-1:2
            k=ceil((J-1).*rand);
            tmp=z(k);
            z(k)=z(J);
            z(J)=tmp;
        end
        d(I)=abs(mean(z(1:Nx))-mean(z(Nx+1:end)));
    end
end
%Of the Pms differences in means, how many are greater than, or equal 
%in magnitude to, the one obtained in the experiment? 
K=length(d(d>=obsdiff));
%Therefore, the probability of finding a difference as large as that
%obtained, in the absence of an effect, is:
p=K/Pms;

%display results
tr=repmat('-',1,80); %spacer
disp('RANDOMISATION TEST')
disp(tr)
if flag
    disp('Monte Carlo Naive Method')
else
    disp('Exact Method')
end
disp(tr)
fprintf('%d randomisations evaluated\n',Pms)
if p>0.0001
    fprintf('Probability (p-value) that the observed difference is accidental: %0.4f\n',p)
else
    fprintf('Probability (p-value) that the observed difference is accidental: %0.4e\n',p)
end
if flag
    fprintf('p-value is within %0.4f units of the true one with %0.4f%% confidence\n',delta,(1-alpha)*100)
end
disp(tr)

if nargout
    pv=p;
end
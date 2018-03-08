%loads and names
load('size.mat');
sizeIndustry= Size;
clear Size;
load('booktomarket.mat');
load( 'monthlyReturns.mat' );
monthlyReturns = monthlyReturns1(1:size(monthlyReturns1,1)-1 ,:);
clear monthlyReturns1;

%set criterion
numWinners=round(0.1*size(monthlyReturns,2));
numLosers=round(0.1*size(monthlyReturns,2));
%Equally Weighted Portfolio
weight = 1/ numWinners;

%Estimation of Momentum
compoundedReturns=ones( size(monthlyReturns,1 ), size(monthlyReturns,2)) ;
monthlyReturns( isnan(monthlyReturns)==1 ) =0;
monthlyReturns( monthlyReturns==-99.99 ) =0;
monthlyReturns=monthlyReturns/100;

%Estimation of Compounded returns
%I treated null values as 0
%in the sense that these assets, for this month, will neither be
%winners nor losers
%our data include returns no prices, so we use comounding
prices = zeros(size(monthlyReturns,1) , size(monthlyReturns,2));
for i=1:size(monthlyReturns,2 )
    prices(1,i) = 1;
    for j=2:size(monthlyReturns,1 )
        if j==2
            prices(j-1,i)
        end
        compoundedReturns(j,i)=(1+monthlyReturns(j,i) )*compoundedReturns(j,i) ; 
        %prices(j,i) = monthlyReturns(j,i) * ( prices(j-1,i) +1); 
    end
end

%Estimation of Pt-1 / Pt-12
momentumMatrix=zeros(size(monthlyReturns,1 )-12 , size(monthlyReturns,2 ));

for numAsset = 1:size(monthlyReturns,2 )
  
    for i = 13: size(monthlyReturns,1 )
        momentumMatrix(i-12,numAsset) =  compoundedReturns(i-1,numAsset)/ compoundedReturns(i-12,numAsset);
        
    end
end

%Correcting matrix so as to remove later the nan elements
momentumMatrix( momentumMatrix ==1 ) = -100;

%Sort of Momentum Matrix
[sortedMatrixofReturns,indexMatrix] = sort( momentumMatrix,2);
numAssets = size(momentumMatrix,2);

PorReturn= zeros(1, size(momentumMatrix,1 )-1 );
for time =2: size(momentumMatrix,1)
        tempPorReturn=0;
        i=1;
         temp=1;
        while temp<=numLosers
                if( momentumMatrix( time-1,i ) ~=-100 )
                    tempPorReturn = tempPorReturn - weight*monthlyReturns(time,indexMatrix(time-1,i));
                    temp = temp+1;
                end
                i=i+1;
        end
        
        temp=1;
        i= numAssets;
        while temp<=numWinners
        
            tempPorReturn = tempPorReturn + weight*monthlyReturns(time,indexMatrix(time-1,i));
            temp=temp+1;
        
            i=i-1;
        end
        PorReturn(time-1)= tempPorReturn;
end

load('STR.mat');
startDate = datenum('31-07-1926');
endDate = datenum('31-01-2018');
xData = linspace(startDate,endDate,1099);
xData = xData(14:1098);
figure(1)
correctTime =2: size(momentumMatrix,1);
plot( (xData),cumprod(PorReturn+1)-1 ,'r');  
hold on
plot ( (xData),cumprod(STR+1) -1 ,'b' ) ;
datetick;
legend('Momentum','STR')
axis tight

momentum=PorReturn;
save('momentumMatrix.mat' , 'momentum');

xlswrite('momentum.xlsx',cumprod(PorReturn+1)-1 );
xlswrite( 'STR.xlsx',(cumprod(STR+1) -1) );




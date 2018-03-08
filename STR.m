load('size.mat');
sizeIndustry= Size;
clear Size;

load('booktomarket.mat');

%load('DATAFinanceExercise2.mat');
%monthlyReturns = AverageValueWeightedReturnsMonthly;
%clear AverageValueWeightedReturnsMonthly;

load( 'monthlyReturns.mat' );
monthlyReturns = monthlyReturns1(1:size(monthlyReturns1,1)-1 ,:);
monthlyReturns( monthlyReturns == -99.99 )= NaN;
clear monthlyReturns1;


numWinners=round(0.1*size(monthlyReturns,2));
numLosers=round(0.1*size(monthlyReturns,2));
%Equally Weighted Portfolio
weight = 1/ numWinners;

%Estimation of STReversal
[sortedMatrixofReturns,indexMatrix] = sort( monthlyReturns,2);
numAssets = size(monthlyReturns,2);


PorReturn= zeros(1, size(monthlyReturns,1 )-1 );
for time =2: size(monthlyReturns,1)
  
      tempNan = isnan(sortedMatrixofReturns(time-1,:)); 

        tempPorReturn=0;
        i=1;
         temp=1;
        while temp<=numLosers
            if isnan( monthlyReturns(time,indexMatrix(time-1,i)) )==0
                tempPorReturn = tempPorReturn  + weight* monthlyReturns(time,indexMatrix(time-1,i));
                temp = temp+1;
            end
               i=i+1;
        end
        
        temp=1;
        i= numAssets - (sum(tempNan,2));
        while temp<=numWinners
        if isnan(monthlyReturns(time,indexMatrix(time-1,i))) ==0
            tempPorReturn = tempPorReturn-weight* monthlyReturns(time,indexMatrix(time-1,i));
            temp=temp+1;
        end
            i=i-1;
        end
        PorReturn(time-1)= tempPorReturn;
end

PorReturnFinal=PorReturn/100;

figure(1)
correctTime =2: size(monthlyReturns,1);
plot( log(correctTime),cumprod(PorReturnFinal +1)-1 );  
datetick
axis tight

STR = PorReturnFinal(1, 13:1097);
save('STR.mat' , 'STR');

xlswrite( 'STR.xlsx',(cumprod(STR+1) -1) );
function [fulldate,I]=add_date(date)

% Usage
%		 [fulldate,I]=add_date(date)
%
% Add missing dates in the input date-vector.
% Format of the date is [YEAR MONTH DAY], dates must
% be ordered in descending order.
%
% Optional output I is the indexes of original dates
% within the full date-vector.
%

V =[31 29 31 30 31 30 31 31 30 31 30 31]; %Leap year's days
NV=[31 28 31 30 31 30 31 31 30 31 30 31]; %Regular year's days

%wbh=waitbar(0,'Please wait...');
%set(wbh,'Name','ADD_DATE (c) 2000');
L=size(date,1);

I=[1:L];
i=1;
e=2;
while i<size(date,1)
   
   d=ymdhms2d([date(i,:) 0 0 0],[date(i+1,:) 0 0 0]);
   if d>0 error(['Date must be ordered descendingly: case ' num2str(date(i,:))]); end
   if d==0 
      %disp(['Double date deleted: ' num2str(date(i,:))]);
      date=[date(1:i,:);date(i+2:size(date,1),:)];
   end
      
   d=-d-1;
   date1=date(i,:);
   newdate=[];
   for j=1:d
      if date1(3)~=1 
      % Not the 1-st day of the month
         newdate(j,:)=[date1([1 2]) date1(3)-1];
      else
      % 1-st day of the month
      	if date1(2)==1 
      	% January,1
            newdate(j,:)=[date1(1)-1,12,31];
         else
            if ((mod(date1(1),4)==0 & mod(date1(1),100)~=0) | mod(date1(1),1000)==0) % Leap year
               newdate(j,:)=[date1(1),date1(2)-1,V(date1(2)-1)];
            else
               newdate(j,:)=[date1(1),date1(2)-1,NV(date1(2)-1)];
            end
         end
      end
      date1=newdate(j,:);
   end
   date=[date(1:i,:);newdate;date(i+1:size(date,1),:)];
   
   i=i+1+d;
   
   I(e:length(I))=I(e:length(I))+d;
   e=e+1;
   
   %if(mod(e,ceil(L/100))==0)
   %   waitbar(e/L);
   %end
   
end
fulldate=date;

%close(wbh);
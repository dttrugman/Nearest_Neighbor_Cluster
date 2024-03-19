function [newind,I]=makeindex(ind,isadd)

% Adds the following to the input index:
% 1) missing dates (if isadd=1),
% 2) day of week, 
% 3) time in days from Jan 1,1900, and 
% 4) time in years (1year=365.25 days)
%
% Usage
%     [newind,I]=makeind(ind,isadd)
%
% Input:
%     ind is the index in columnwise format 
%            [Year Month Day F1 F2 ... Fk]
% Outputs:
%     newind is the index in columnwise format
%     [1             2            3    4     5   6           7    8   ...            ]
%     [Time_in_Years Time_in_Days Year Month Day Day_of_Week F1   F2  ... Fk  Seq.num]
%
%     I is the indexes of original index within the new one: ind==newind(I,:)
%

lag1=ymdhms2d([1900 01 01 00 00 00],[ind(1,[1 2 3]) 00 00 00]);
lag2=ymdhms2d([1900 01 01 00 00 00],[ind(size(ind,1),[1 2 3]) 00 00 00]);
lag=min(lag1,lag2);

if exist('isadd')~=1
   isadd=0;
end

if isadd
	if lag1<lag2
	% Input dates are in ascending order
		[newind,I]=add_date(ind(length(ind):-1:1,[1 2 3]));
		I=I(length(I):-1:1);
	else
	% Input dates are in descending order
		[newind,I]=add_date(ind(:,[1 2 3]));
    end
   
   newind=newind(length(newind):-1:1,:); % Make in ascending order
   I=size(newind,1)-I+1;
   
	Time_in_Days=[1:size(newind,1)]'+lag;
else
   if lag1>lag2
   % If input dates are in descending order
      newind=ind(length(ind):-1:1,1:3);
      I=[1:size(ind,1)];
      I=size(ind,1)-I+1;
   else
      newind=ind(:,1:3);
      I=[1:size(ind,1)];
   end
   Time_in_Days=zeros(size(newind,1),1);
end

Day_of_Week=zeros(size(newind,1),1);
% Calculate time in days
Time_in_Days(1,1)=ymdhms2d([1900 01 01 00 00 00],[newind(1,:) 00 00 00]);
Day_of_Week(1,1)=mod(1+mod(Time_in_Days(1,1),7),7);
wbh=waitbar(0,'Please wait...');
for i=2:length(newind)
   Delta=ymdhms2d([newind(i-1,:) 00 00 00],[newind(i,:) 00 00 00]);
   Time_in_Days(i,1)=Time_in_Days(i-1)+Delta;
   Day_of_Week(i,1)=mod(Day_of_Week(i-1)+mod(Delta,7),7);
   if mod(i,10)==0
       waitbar(i/length(newind));
   end
end
close(wbh);

Time_in_Years=1900+Time_in_Days/365.25;  % time in years

newind=[Time_in_Years,Time_in_Days,newind,Day_of_Week];
newind(I,[7:7+size(ind,2)-4])=ind(:,[4:size(ind,2)]);
newind(:,size(newind,2)+1)=[1:size(newind,1)]';

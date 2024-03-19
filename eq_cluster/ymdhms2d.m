function d=ymdhms2d(DATE1,DATE2)

% Usage
%     d=ymdhms2d(DATE1,DATE2)
%
% Calculate interoccurrence time
% (in days) between dates in the form
% [Year Month Day Hour Min Sec]
%

if size(DATE1,2)~=6 | size(DATE2,2)~=6
   error('Dates must be of the form: [Year Month Day Hour Min Sec]');
end

VD =[31 29 31 30 31 30 31 31 30 31 30 31];
NVD=[31 28 31 30 31 30 31 31 30 31 30 31];

if(size(DATE1,1)*size(DATE2,1)>200)
   iswbh=1;
	wbh=waitbar(0,'Please wait...');
	set(wbh,'Name','YMDHMS2D (c) 2000');
   LL=floor(size(DATE1,1)*size(DATE2,1)/100);
else
   iswbh=0;
end


for i=1:size(DATE1,1)
   for j=1:size(DATE2,1)
      
      date1=DATE1(i,:);
      date2=DATE2(j,:);
      c=1; % sign of the difference
      
      B=date1>date2;
      E=date1==date2;
      if    B(1) | ...
            (E(1)&B(2)) | ...
            (E(1)&E(2)&B(3)) | ...
            (E(1)&E(2)&E(3)&B(4)) | ...
            (E(1)&E(2)&E(3)&E(4)&B(5)) | ...
            (E(1)&E(2)&E(3)&E(4)&E(5)&B(6))
         tmp=date1;
         date1=date2;
         date2=tmp;
         c=-1;
      end
      
      Y1=date1(1);
      M1=date1(2);
      D1=date1(3);
      H1=date1(4);
      Min1=date1(5);
      S1=date1(6);
      
      Y2=date2(1);
      M2=date2(2);
      D2=date2(3);
      H2=date2(4);
      Min2=date2(5);
      S2=date2(6);
      
      FullY=[Y1+1:Y2-1];
      V=find( (mod(FullY,4)==0 & mod(FullY,100)~=0) | mod(FullY,1000)==0 );
      DeltaY=length(V)*366+(length(FullY)-length(V))*365;
      
      if (mod(Y1,4)==0 & mod(Y1,100)~=0)|mod(Y1,1000)==0
         DeltaM1=sum(VD(1:M1-1));
         L1=366;
      else
         DeltaM1=sum(NVD(1:M1-1));
         L1=365;
      end
      if (mod(Y2,4)==0 & mod(Y2,100)~=0)|mod(Y2,1000)==0
         DeltaM2=sum(VD(1:M2-1));
         L2=366;
      else
         DeltaM2=sum(NVD(1:M2-1));
         L2=365;
      end
      
      Delta1=DeltaM1+sum([D1-1 H1 Min1 S1].*[1 1/24 1/24/60 1/24/60/60]);
      Delta2=DeltaM2+sum([D2-1 H2 Min2 S2].*[1 1/24 1/24/60 1/24/60/60]);
      
      if E(1)
         Delta=Delta2-Delta1;
      else
         Delta=L1-Delta1+Delta2;
      end
      
      d(i,j)=c*(DeltaY+Delta);
      
      if iswbh
      if(mod(i*j,LL)==0)
         waitbar(i*j/LL/100);
      end
      end
      
   end
end

if iswbh
	close(wbh);
end
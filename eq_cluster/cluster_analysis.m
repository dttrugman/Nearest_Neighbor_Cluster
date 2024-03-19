% Seismic cluster analysis
% (called by eq_cluster.m)

% (modified after clust_analys_2D.m)
%------------------------------------------------------
% Version: March 11, 2011
%------------------------------------------------------

% Threshold between cluster and homogeneous parts
% according to a 2-component Gaussian mixture model
I=find(~isnan(log10(TN.*RN)) & TN>0 & RN>0);
[c,mu1,mu2,sigma1,sigma2,A,A2,p1,p2] = ...
    normalmix_1D(log10(TN(I).*RN(I)),-6,-3,1,1);

P1 = P'; % parent-pointer structure

% Mainshock condition
K = find(log10(TN)+log10(RN)> c);
P1(K) = 0;

clust=[];
Ifor=[];
Iaft=[];
Imain=[];
Pfin=[];

main_mag = 0;
K=find(P1==0); % first events in clusters

wbh=waitbar(0,'Please wait...');
set(wbh,'Name','EQ cluster analysis');
for i=1:length(K)
    [I0,delta] = descend_all(P1,K(i)); % descendants (aftershocks, direct+indirect) of the current EQ
    I = I0;
    
    % Cluster analysis
    [mmax,imax] = max(mag(I));
    IM = I(imax); % mainshock index
    IF = I(find(time(I)<=time(IM))); % foreshock + mainshock index 
    IA = I(find(time(I)>=time(IM))); % aftershock + mainshock index 
    IF0 = I(find(time(I)<time(IM))); % foreshock index
    IA0 = I(find(time(I)>time(IM))); % aftershock index
    
    clust.L(i) = length(I); % number of earthquakes in the cluster
    clust.LA(i) = length(IA0); % number of aftershocks
    clust.LF(i) = length(IF0); % number of foreshocks
    
    clust.m(i) =  mmax; % maximal (mainshock) magnitude
    
    if ~isempty(IA0)
        % maximal aftershock magnitude
        clust.mA(i) = max(mag(IA0)); 
        % average distance to mainshock
        clust.distA(i) = mean(latlonkm([Lon(IM) Lat(IM) 0],[Lon(IA0) Lat(IA0) zeros(size(Lat(IA0)))]));
    else
        clust.mA(i)=NaN;
        clust.distA(i)=NaN;
    end
        
    if ~isempty(IF0)
        % maximal foreshock magnitude
        clust.mF(i) = max(mag(IF0)); 
        % average distance to mainshock
        clust.distF(i) = mean(latlonkm([Lon(IM) Lat(IM) 0],[Lon(IF0) Lat(IF0) zeros(size(Lat(IF0)))]));
    else
        clust.mF(i)=NaN;
        clust.distF(i)=NaN;
    end
    
    clust.dur(i) = range(time(I)); % total duration
    clust.durF(i) = range(time(IF)); % foreshock duration
    clust.durA(i) = range(time(IA)); % aftershock duration
    
    clust.durFa(i) = mean(time(IM)-time(IF)); % ave. foreshock duration
    clust.durAa(i) = mean(time(IA)-time(IM)); % ave. aftershock duration
    
    clust.E(i) = sum(10.^((mag(I)+6)*1.5)); % total moment, Nm
    clust.EM(i) = sum(10.^((mmax+6)*1.5)); % mainshock moment, Nm
    clust.EF(i) = sum(10.^((mag(IF0)+6)*1.5)); % foreshock moment, Nm
    clust.EA(i) = sum(10.^((mag(IA0)+6)*1.5)); % aftshock moment, Nm
    
    Ifor(end+[1:length(IF0)]) = IF0;
    Iaft(end+[1:length(IA0)]) = IA0;
    Imain(end+1)=IM;
    
    Pfin(IF0,1)=IM;
    Pfin(IA0,1)=IM;
    Pfin(IM,1)=IM;
        
    if mod(i,10)==0
        waitbar(i/length(K));
    end
    
end
close(wbh);
if isempty(clust)
    clust.L=NaN;
    clust.m=NaN;
    clust.dur=NaN;
    clust.durF=NaN;
    clust.durA=NaN;
    clust.E=NaN;
    clust.EM=NaN;
    clust.EF=NaN;
    clust.EA=NaN;
end

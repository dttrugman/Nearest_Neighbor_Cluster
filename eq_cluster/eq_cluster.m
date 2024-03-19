%==========================================================
%              Earthquake cluster detection
%==========================================================
%
% Usage: Edit parameters in section "PARAMETERS" and run
%        >> eq_cluster
%
% Input: A columnwise earthquake catalog in text format that 
% has the following info: [year month day min sec lat lon mag] 
% (in any order, other columns may be present as well); all
% additional information (like column titles) should be commented
% using the "%" signs
%
% Parameters (variables set up in section PARAMETERS):
%       df    is the fractal dimension of epicenters (0 < df <= 2)
%       b     is the GR slope
%       p     is the weight parameter for defining TN, RN (0< p < 1)
%       mmin  is the lower magnitude cutoff
%
%       fdir  is the catalog directory
%       fname is the name of the file with catalog (no extension!)
%       fext  is the catalog file extension
%       (also specify catalog columns with relevant EQ info)
%
% Outputs (variables in Matlab workspace):
%       cat  is the input catalog
%
%       time is the catalog time in years
%       Lon  is the event longitudes
%       Lat  is the event latitudes
%       mag  is the event magnitudes
%
%       P    is the Baiesi-Paczuski tree (as a parent-pointer vector)
%       n    is the Baiesi-Pacziski distance
%       D    is the spatial distance to parent [km]
%       T    is the time to parent [years]
%       M    is the parent magnitude
%       TN   is the normalized time to parent
%       RN   is the normalized distance to parent
%
%       Pfin  is the cluster index vector
%       Imain is the vector of mainshock indices
%       Iaft  is the vector of aftershock indices
%       Ifor  is the vector of foreshock indices
%
%       clust is a Matlab structure with cluster statistics;
%             it has the following fields:
%       .L    is the total number of events in the cluster
%       .LA   is the number of aftershock
%       .LF   is the number of foreshocks
%       .m    is the mainshock magnitude
%       .mA   is the maximal aftershock magnitude
%       .mF   is the maximal foreshock magnitude
%       .distA is the average distnace between mainshock and aftershocks  
%       .distF is the average distnace between mainshock and forershocks
%       .dur  is the duration of the cluster
%       .durA is the aftershock duration
%       .durF is the foreshock duration
%       .durAa is the average time between mainshock and aftershocks
%       .durFa is the average time between mainshock and forershocks
%       .E   is the total seismic moment of the cluster
%       .EM  is the seismic moment of the mainshock
%       .EA  is the total seismic moment of aftershocks
%       .EF  is the total seismic moment of foreshocks
%
% References: 
% Zaliapin et al., PRL 101, 018501 (2008)  doi:10.1103/PhysRevLett.101.018501
% Zaliapin and Ben-Zion, JGR, 118(6), 2847-2864 (2013) doi:10.1002/jgrb.50179
% 
% =========================================================
% Version: March 29, 2021
% =========================================================
% Questions/comments: Ilya Zaliapin 
% E-mail: zal@unr.edu
% Web: https://zaliapin.github.io/
% =========================================================


% =========================================================
% Programms called 
% (must be in the working directory OR on the Matlab path)
%----------------------------------------------------------
%    add_date.m
%    bp.m
%    descend_all.m
%    latlonkm.m
%    makeindex.m
%    normalmix_1D.m
%    ymdhms2d.m
%    
%    gauss.m (plots only, can be supressed)
%    xymap.m (plots only, can be supressed)
%    setfig.m (plots only, can be supressed)
% =========================================================

%================   PARAMETERS  ===========================
% (Edit values in this secion before running the program)
%==========================================================

% Catalog directory, file name, extension
fdir = '/...'; 
fname = 'NSL_catalog_col';
fext = '.txt';

% Lower magnitude cutoff
mmin = 0.0; 

% Algorithm parameters 
% (for type = 1 must match those from "par.clust") 
df=1.6; % fractal dimension of epicenters
b=1.0; % GR slope

% Weight parameter to define TN and RN
% (p = 0.5 by default)
p = 0.5; 

%=================== ONLY for type = 0 =============================
% If type = 0, edit the section below
% (skip this section if type = 1, the values won't be used)
%===================================================================

% Catalog format
yeari   = 1;  % year column index
monthi  = 2;  % month column index
dayi    = 3;  % day column index
houri   = 4;  % hour column index
mini    = 5;  % minute column index
seci    = 6;  % second column index
magi    = 10;  % magnitude column index
loni    = 8;  % longitude column index
lati    = 7;  % latitude column index
depi    = 9; % depth column index

%============= END of PARAMETERs ==========================

% Load the catalog
eval(['load ' fdir fname fext]);
eval(['cat=' fname ';']);

% Magnitude cutoff
I=find(cat(:,magi)>=mmin);
cat=cat(I,:);

year = cat(:,yeari);
month = cat(:,monthi);
day = cat(:,dayi);
hour = cat(:,houri);
minute = cat(:,mini);
sec = cat(:,seci);

for i=1:length(year)
  time(i,1) = year(i) + date2doy(datenum(year(i),month(i),day(i),hour(i),minute(i),sec(i)))/365.25;
end

[time,Itime]=sort(time);
cat=cat(Itime,:);

year = cat(:,yeari);
month = cat(:,monthi);
day = cat(:,dayi);
hour = cat(:,houri);
minute = cat(:,mini);
sec = cat(:,seci);

mag = cat(:,magi); % magnitude
Lon = cat(:,loni); % longitude
Lat = cat(:,lati); % latitude
depth = cat(:,depi); % depth

% Compute Baiesi-Paczuski tree
[P,n,D,T,M]=bp(time,mag,Lon,Lat,[],b,df);


TN = T.*10.^(-p*b*M); % Normalized time
RN = D.^df.*10.^(-(1-p)*b*M); % Normalized distance

% Cluster analysis (results are in structure clust)
if 1
    cluster_analysis

    mark=zeros(size(mag));
    mark(Imain)=2;
    mark(Iaft)=1;
    mark(Ifor)=-1;
end

if 1
    % Output catalog (uses results of cluster_analysis.m)
    Iout = [yeari monthi dayi houri mini seci lati loni magi];
    out = [[1:length(cat)]' cat(:,Iout) mark P Pfin];
    fid=fopen('cat_out.txt','wt');
    %fprintf(fid,'%5i %3i %3i %3i %3i %6.2f %6.2f %6.2f %6.2f %9.3f %9.3f
    %%5d %9.3f %9.3f %6.2f %2d %7d %7d\n',out');
    fprintf(fid,'%9i %5i %3i %3i %3i %3i %9.3f %9.3f %9.3f %9.3f %2d %7d %7d\n',out');
    fclose(fid)
end

if 1
% plot 2-D histogram
%--------------------------------------------------------------------
    figure
    w = gauss(30,30,15,15);   % gaussian kernel
    w=w/sum(sum(w));        % normalize
    [K,Ta,Xa] = xymap(log10(TN),log10(RN),[],'s',200,200,[-8 0],[-5 3]);
    h = pcolor(10.^Ta,10.^Xa,conv2(K',w,'same'));
    set(gca,'xscale','log','yscale','log')
    set(h,'edgecolor','none')
    colorbar
    set(gca,'FontSize',12)
    xlabel('Rescaled time, T ','FontSize',14)
    ylabel('Rescaled distance, R ','FontSize',14)
    colormap(jet)
    setfig
    
    figure 
    I=find(~isnan(log10(TN.*RN)) & TN>0 & RN>0);
    [~,mu1,mu2,sigma1,sigma2,A,A2,p1,p2] = ...
        normalmix_1D(log10(TN(I).*RN(I)),-6,-3,1,1);
    histogram(log10(TN(I).*RN(I)),100,'Normalization','pdf');
    [h,g]=histcounts(log10(TN(I).*RN(I)),100);
    
    hold on
    plot(g,A*normpdf(g,mu1,sigma1),g,A2*normpdf(g,mu2,sigma2));
    colormap(jet)
    setfig
    xlabel('Nearest-neighbor proximity, \eta')
    ylabel('Density')
end
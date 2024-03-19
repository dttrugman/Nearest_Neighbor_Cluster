function [P,n,D,T,M]=bp(time,mag,Lon,Lat,depth,b,df,lag,iswaitbar)

% Baiesi-Paczuski metric [PHYSICAL REVIEW E 69, 066106 (2004)]
%
% Inputs:
%       time is the ocurrence time of events in years
%       mag  is the event magnitude
%       (Lon,Lat,depth) are event coordinates
%       b    is the GR slope
%       df   is the fractal dimension of epicenters
% Outputs (all are the same size as the EQ catalog):
%      P is the resulting tree (parent-pointer format)
%      n is the nearest-neighbor BP-distance
%      D is the nearest-neighbor spatial distance
%      T is the nearest-neighbor temporal distance
%      M is the magniude of the parent event

% Parameters
%========================================
%dm=0.1;  % magnitude step in the catalog
%C=10^-9; % normalization constant
tmin=0; % seconds
dmin=0; % meters
%========================================

if exist('iswaitbar')~=1
    iswaitbar = 1;
end

[tmp,imin]=min(time);
P(imin,1)=0; % first element is the root
n(imin,1)=Inf;
T(imin,1)=NaN;
D(imin,1)=NaN;
M(imin,1)=NaN;

time=time*365.25*24*60*60;
if exist('lag')~=1
    lag=Inf;
else
    lag=lag*365.25*24*60*60;
end

% check if time is sorted
%dt=diff(time);
%if ~isempty(find(dt<0))
%    warning('time is not sorted, the program may work incorrectly')
%end

if iswaitbar
    wbh=waitbar(0,'Please wait...');
    set(wbh,'Name','Baiesi-Paczuski metric, 2004')
end
for i=1:length(time)
    I=find(time<time(i) & time>=time(i)-lag);
    %I = [1:i-1]'; % previous events
    if ~isempty(I)
        %d=degdist([Lat(i) Lon(i) 0],[Lat(I) Lon(I) zeros(size(I))]);
        %d=latlonkm([Lat(i) Lon(i) depth(i)],[Lat(I) Lon(I) depth(I)]);
        d=latlonkm([Lat(i) Lon(i)],[Lat(I) Lon(I)]);
        d=d*1000;
        d=max(d,dmin);
        t=max(time(i)-time(I),tmin);
        nc=t.*d.^df.*10.^(-b*mag(I));
        %nc=t.*exp((10^-6)*t).*d'.^df.*exp((10^-4)*d'.^df);
        %nc=t.^2+(d'.^(2*df));
        [n(i,1),imin]=min(nc);
        P(i,1)=I(imin);
        D(i,1)=d(imin);
        T(i,1)=t(imin);
        M(i,1)=mag(I(imin));
    else
        n(i,1)=Inf;
        P(i,1)=0;
        D(i,1)=0;
        T(i,1)=0;
        M(i,1)=0;
    end
    if iswaitbar
        if mod(i,10)==0
            waitbar(i/length(time));
        end
    end
end

T = T/365.25/24/60/60;
D = D/1000;
if iswaitbar
    close(wbh);
end

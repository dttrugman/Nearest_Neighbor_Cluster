function [M,xa,ya,xn,yn]=xymap(x,y,v,type,Nx,Ny,XLim,YLim)

% 2D histogram for a marked point process v(x,y)
%
% Usage
%     [M,xa,ya,xn,yn]=xymap(x,y,v) - use distinct values of x and y
%     [M,xa,ya,xn,yn]=xymap(x,y,[]) - assumes that v=ones(size(x));
%     [M,xa,ya,xn,yn]=xymap(x,y,v,type,Nx,Ny) - divide the values into Nx (Ny) groups
%     [M,xa,ya,xn,yn]=xymap(x,y,v,type,Nx,Ny,XLim,YLim) - use the values from the specified range
% type is either "m" (mean) or "s" (sum)

if isempty(v)
    v=ones(size(x));
end

if nargin==2
   xn=sort(distinct(x));
   yn=sort(distinct(y));
   
   xa=xn;
   ya=yn;
   
   for i=1:length(xn)
	for j=1:length(yn)
   	I=find(x==xn(i) & y==yn(j));
   	M(i,j)=length(I);
	end
	end
else
   
	if exist('YLim')~=1
  	   minY=min(y);
  	   maxY=max(y);
	else
   	minY=min(YLim);
   	maxY=max(YLim);
	end
	if exist('XLim')~=1
   	minX=min(x);
   	maxX=max(x);
	else
   	minX=min(XLim);
   	maxX=max(XLim);
	end
   
   I=find(x>=minX & x<=maxX & y>=minY & y<=maxY);
   x=x(I);
   y=y(I);
   v=v(I);
   
   stepx=(maxX-minX)/Nx;
   stepy=(maxY-minY)/Ny;
   xn=ceil((x-minX)./stepx);		% categoryzing x
	I=find(xn==0);						%
	xn(I)=1;								%
	yn=ceil((y-minY)./stepy);  	% categoryzing y
	I=find(yn==0);						%
   yn(I)=1;								%
   
   xa=[minX:stepx:maxX-stepx];
   ya=[minY:stepy:maxY-stepy];
   
	for i=1:Nx
	for j=1:Ny
   	I=find(xn==i & yn==j);
    %ave=100;
    %I = find(abs(xn-i)<=ave & abs(yn-j)<=ave);
    %Dx = abs(i-xn(I));
    %Dy = abs(j-yn(I));
    %W = 1./(Dx.^2+Dy.^2+1);
   	if type=='s'
        M(i,j)=nansum(v(I));
    elseif type=='m'
        M(i,j)=nanmean(v(I));
    else
        error('type must be either ''s'' or ''m''');
    end
	end
    end 
end
%I = isnan(M);
%M(I)=0;


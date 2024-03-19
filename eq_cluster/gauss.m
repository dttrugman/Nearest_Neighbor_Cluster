function gauss = gauss(N,M,sigma1,sigma2,X0,Y0,alpha);

% Usage
%      gauss = gauss(N,M,sigma1,sigma2,X0,Y0,alpha);
%
% Generates the matrix with 2D Gaussian hat.
%
% Inputs
%      N,M    are sizes of output matrix;
%      sigma1 is the deviation along X;
%      sigma2 is the deviation along Y;
%      X0,Y0  are the coordinates of the center of the hat
%                    (optional; center of output matrix by default);
%      alpha  is the angle of rotation of the hat from axis X
%                                       (optional; 0 by default).
%
% Output
%      gauss  is the matrix of size NxM with gaussian hat.
%

if nargin < 5
	X0 = round(N/2);
	Y0 = round(M/2);
end;

if nargin < 7
	alpha = 0;
end;
	

[x,y] = meshgrid(1:N,1:M);
R = [cos(alpha),sin(alpha);-sin(alpha),cos(alpha)];
B = R'*diag([1/sigma1,1/sigma2])*R;

gauss  = exp(-.5*((x-X0).^2*B(1,1) + ...
                2*(x-X0).*(y-Y0)*B(1,2) + ...
                  (y-Y0).^2*B(2,2)));

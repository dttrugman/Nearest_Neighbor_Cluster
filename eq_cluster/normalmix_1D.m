function [c,mu1,mu2,sigma1,sigma2,A,A2,p1,p2]=normalmix_1D(x,mu1i,mu2i,sigma1i,sigma2i)

% Estimates parameters of a 2-component 1-D Gaussian mixture model
% (uses the EM algorithm)
%
% Usage
%     [c,mu1,mu2,sigma1,sigma2]=normalmix_1D(x,mu1i,mu2i,sigma1i,sigma2i)
% Inputs:
%     x is the data sample to be analysed
%     mu#i,sigma#i are the initial parameters of components
% Outputs:
%     c is the maximum likelihood boundary between the hats
%     mu#,sigma# are the estimated paraeters of components
%

Ai=.5;
A2i=.5;
epsilon=1;
p1a=zeros(length(x),1);
p2a=zeros(length(x),1);
p1=zeros(length(x),1);
p2=zeros(length(x),1);
epsilon0=0.001;

while epsilon>epsilon0
   
    p1a=Ai*(1/(sqrt(2*pi*sigma1i^2))*exp(-(((x-mu1i)/sigma1i).^2)/2));
    p2a=A2i*(1/(sqrt(2*pi*sigma2i^2))*exp(-(((x-mu2i)/sigma2i).^2)/2));

    p1=p1a./(p1a+p2a);
    p2=p2a./(p1a+p2a);

    A = sum(p1)/length(x);
    A2 = sum(p2)/length(x);
    
    mu1 = sum(p1.*x)/sum(p1);
    mu2 = sum(p2.*x)/sum(p2);

    sigma1=sqrt(sum(p1.*(x-mu1).^2)/sum(p1));
    sigma2=sqrt(sum(p2.*(x-mu2).^2)/sum(p2));

epsilon1=abs(Ai-A);
epsilon2=abs(mu1i-mu1);
epsilon3=abs(mu2i-mu2);
epsilon4=abs(sigma1i-sigma1);
epsilon5=abs(sigma2i-sigma2);
epsilon=max([epsilon1,epsilon2,epsilon3,epsilon4,epsilon5]);

Ai=A;
A2i=A2;
mu1i=mu1;
mu2i=mu2;
sigma1i=sigma1;
sigma2i=sigma2;

end

aa=(-(2*(sigma1^2)))+(2*(sigma2^2));
bb=(((mu2*2))*((sigma1^2)*2))+(-(mu1*2)*((sigma2^2)*2));
cc=((-(mu2^2))*((sigma1^2)*2))+((mu1^2)*((sigma2^2)*2))-((log(sigma2/sigma1))*((sigma1^2)*2)*((sigma2^2)*2));
c1=(-bb+sqrt((bb^2)-(4*aa*cc)))/(2*aa);
c2=(-bb-sqrt((bb^2)-(4*aa*cc)))/(2*aa);

if mu1<c1 && c1<mu2
    c=c1;
else
    c=c2;
end

end
function [InsigmaDS InsigmaAS InsigmaSF]=ParamSet()

X=rand(3,1);
rDS_AS=0.6; %Correlation between delay spread and angle spread
rSF_DS=-0.5; %Correlation between shadow fading and delay spread
rSF_AS=-0.5; %Correlation between shadow fading and  angle spread
eDS=0.288; %Logarithmic standard deviation of delay spread
eAS=0.13; %Logarithmic standard deviation of angle spread 
mDS=-6.8; %Logarithmic mean of delay spread
mAS=0.69; %Logarithmic mean of angle spread
rSF=0.5; %Correlated shadow fading

%Setting Delay spread and angle spread as stated in 3GPP paper
A=[1 rDS_AS rSF_DS;rDS_AS 1 rSF_AS; rSF_AS rSF_AS 1];
B=[0 0 0; 0 0 0; 0 0 rSF];
C=(A-B)^(1/2);
W=rand(3,1);
D=C*W+[0 0 0; 0 0 0; 0 0 sqrt(rSF)]*X;
a=D(1,1);
b=D(2,1);
InsigmaDS=10^(eDS*a+mDS);
InsigmaAS=10^(eAS*b+mAS);
%/

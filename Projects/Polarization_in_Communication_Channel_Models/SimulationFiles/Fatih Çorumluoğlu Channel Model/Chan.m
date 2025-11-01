function [Hsut AoDm AoAm Fm]=Chan(Pn,M,t,T1,S,U,AoDn,AoAn,thetav,v,kappa,dBS,dMS,BSAS,MSAS)

Fm=2*pi*rand(1,M);%Randon phase for each of the M subpaths 1x20 Matrix
AoDm=AoDn+BSAS*randn(1,M);%Angles of departure for each of the M subpaths
AoAm=AoAn+MSAS*randn(1,M);%Angles of arrival for each of the M subpaths

%3 sector antenna setup
for m=0:M-1
    Ang=AoDm(m+1);
    if Ang>180
        Ang=360-Ang; %makes sure the angle is smaller than 180
    elseif Ang<-180
        Ang=360+Ang;%and bigger than -180
    end
    Am=20;%Antenna maximum attenuation in dB
    Ang3db=70;%3 dB beamwidth in degrees
    A=-min(12*((Ang/Ang3db)^2),Am); %Taken from 3GPP paper
    G=10^(0.1*A); %The gain equation described in 3GPP paper 
    Gh(m+1)=G;
    m=m+1;
end
%/3 sector antenna set

%Channel model setup
for i=1:T1
    for s=1:S
        for u=1:U
            sumh=0;
            for m=1:M 
                %SCM Channel model
                h(m)=sqrt((Pn)/M)*sqrt(Gh(m))*exp(j*kappa*dBS(s)*sind(AoDm(m)))*exp(j*(kappa*dMS(u)*sind(AoAm(m))+Fm(m)))*exp(j*kappa*v*cosd(AoAm(m)-thetav)*t(i));                
                %/SCM Channel model
                sumh=sumh+h(m);                              
            end    
            Hsu(s,u)=sumh;
        end
    end
    Hsut{i,1}=Hsu;%Impulse response matrix for every instant t
end
%/Channel model setup
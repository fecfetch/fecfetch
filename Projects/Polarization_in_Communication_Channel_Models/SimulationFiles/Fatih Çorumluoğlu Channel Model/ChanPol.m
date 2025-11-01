function [HsutPol AoDmPol AoAmPol FmPol]=ChanPol(Pn,M,t,T1,S,U,AoDn,AoAn,thetav,v,kappa,dBS,dMS,BSAS,MSAS,aBS,bMS,rn)

FmPol=(2*pi)*rand(4,M);%random phase for each of the M subpaths
AoDmPol=AoDn+BSAS*randn(1,M);%Angles of Departure for each of the M subpaths
AoAmPol=AoAn+MSAS*randn(1,M);%Angles of Arrival for each of the M subpaths

%Channel model setup
%Setting up polarization for the BS array
S=2*S;
A1=ones(1,S)*aBS; %BS array multiplied with BS antenna tilt (in this case 0 degrees)
B1=zeros(1,length(A1)); %Make an array of 0s with the length of S  
Cr1=B1; 
DBS1=B1;
DBS2=B1; %Empty array to store the newly generated cross polarized antenna positions 
for i=1:(length(A1)/2)
    B1(2*i-1)=A1(i); %This part does not effect B1 for this case but it would have made sense if the BS antenna tilt was not 0
    Cr1(2*i)=90-A1(i); %Generate cross-Polarized array 
    DBS1(2*i-1)=dBS(i);
    DBS2(2*i)=dBS(i); %Puts the cross Polarized antenna pairs at the same location (together with the column 19) 
end
A1=B1+Cr1; %Re-build the full array of angles for BS
dBS=DBS1+DBS2; %Re-build the distances array of BS
%/Polarization for the BS array set

%/Setting up polarization for the MS array
U=2*U;
A2=ones(1,U)*bMS;
B2=zeros(1,length(A2));
Cr2=B2;
DMS1=B2;
DMS2=B2;
for i=1:(length(A2)/2)
    B2(2*i-1)=A2(i);
    Cr2(2*i)=90-A2(i);
    DMS1(2*i-1)=dMS(i);
    DMS2(2*i)=dMS(i);
end
A2=B2+Cr2; %Re-build the full array of angles of MS
dMS=DMS1+DMS2; %Re-build the distances array of MS
%/Polarization for the MS array set
    
for i=1:T1
    for s=1:S
        for u=1:U
            sumh=0;
            for m=1:M
                %Dual-Polarized SCM channel model
                h(m)=sqrt((Pn)/M)*([cosd(A1(s)) sind(A1(s))*cosd(AoDmPol(m))]*[exp(j*FmPol(1,m)) sqrt(rn)*exp(j*FmPol(2,m));sqrt(rn)*exp(j*FmPol(3,m)) exp(j*FmPol(4,m))]*[cosd(A2(u));sind(A2(u))*cosd(AoAmPol(m))])*exp(j*kappa*dBS(s)*sind(AoDmPol(m)))*exp(j*(kappa*dMS(u)*sind(AoAmPol(m))))*exp(j*kappa*v*cosd(AoAmPol(m)-thetav)*t(i));
                %/Dual-Polarized SCM channel model 
                sumh=sumh+h(m);
            end    
            Hsu(s,u)=sumh;
        end
    end
    HsutPol{i,1}=Hsu;
end

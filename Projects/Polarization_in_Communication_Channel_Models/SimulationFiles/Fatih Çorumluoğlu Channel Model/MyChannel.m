
%Constants

S=6; %Number of BS antennas
U=4; %Number of MS antennas
N=6; %Number of clusters (paths)
M=20; %Number of subclusters (subpaths)
aBS=0; %BS antenna tilt w.r.t. z axis
bMS=0; %MS antenna tilt w.r.t. z axis
c=3*(10^8);%propagation velocity in m/sec
FC=2; %carrier frequency in GHz
f=2*(10^9);%carrier frequency in Hz
lamda=c/f;%wavelength of the carrier in meters
kappa=(2*pi)/lamda;%wavenumber of the carrier 
DBS=[6,6,6,6,6]; %Distance between antennas of BS array in wavelengths
DMS=[0.4,0.6,0.4];%distance between antennas of MS array in wavelengths
BSAS=2; %Base Station Angle Spread
MSAS=35; %Mobile Station Angle Spread
dBS1=DBS*lamda;%Distance between antennas of BS array in meters
dMS1=DMS*lamda;%Distance between the antennas of MS array in meters
rAS=1.2; %AoD/Angle Spread ratio
rDS=1.4; %Delays/Delay spread ratio
V=60; %MS velocity (km/h)
v=(10/36)*V; %Magnitude of the velocity of mobile station in m/sec 
R=1700; %Radius 

T=0.1;
T1=100;
t=[1:1:T1]*0.001; %time matrix
[InSigmaDS InSigmaAS ]=ParamSet();
DS=InSigmaDS; %Delay spread 
AS=InSigmaAS; %Angle spread
SNR=15; %Signal to noise ratio

rn=0.0316; %Linear XPD value for the NLoS components (for Polarized)

d=round(R*rand(1));%Distance between the BS and MS in meters

OmegaBS=0;%BS antenna broadside angle
OmegaMS=round(360*rand(1));% MS antenna broadside angle
thetaBS=round(360*rand(1));%Angle between the BS antenna broadside and the LOS connection
thetav=round(360*rand(1));%Angle between the direction of the MS and the LOS connection
thetaMS=round(abs(OmegaBS-OmegaMS+thetaBS+180));%Angle between the MS antenna broadside and the LOS connection

%/Constants set
dBS(1)=0;
%Bs antenna distance setup
for k=1:length(dBS1) %iterates from k to length(dBS1)=5 , dBS1 is equal to DBS*lamda(distance between BS antenna elements in meters) 
    tot=dBS1(k);
    dBS(k+1)=dBS(k)+tot; %puts the antennas to their positions relative to the referance antenna (dBS(1)). DBS provides the distance between adjacent antennas and dBS stores the relative positions of each antenna. ex: [0 6 12 18 ....] 
end
%/

%Ms antenna distance setup
dMS(1)=0;
for k=1:length(dMS1)
    tot=dMS1(k);
    dMS(k+1)=dMS(k)+tot; %same as the BS setup.
end
%/

t=[1:1:100]*0.001; %time matrix

%Environment Setup

hBS=32; %Base station height
hMS=1.5; %Mobile station height
Cc=0;
PLdB=(44.9-6.55*log10(hBS))*log10(d/1000)+45.5+(35.46-1.1*hMS)*log10(1000*FC)-13.82*log10(hBS)+0.7*hMS+ Cc; %Suburban macrocell environment (taken from 3gpp paper)

%Power Delay Profile
zn=rand(1,N);
for k=1:N
    tn(k)=-rDS*DS*log(zn(k)); %random delays (taken from 3gpp paper)
end
tn=sort(tn); %sorting greatest to smallest
tn=tn-tn(1);
s=10^(0.1*3);
xn=s*randn(1,N);
for k=1:N
    P(k)=exp((((1-rDS)*tn(k))/(rDS*DS)))*10^(-xn(k)/10); %Power computation (taken from 3gpp paper)
end
sumP=sum(P);
Pn=P/sumP; %Power for each cluster N
%/Power Delay Profile

A=rAS*AS*randn(1,N); %Random initial values for generating the angle of departures for each cluster
x=abs(A); %make an array of the absolute values of the elements of A


for k=1:N-1

    l=k; %to store the initial value of k
    for j=k+1:N
        if x(j)<x(l) %evaluates if absolute values of any of the next elements in the array A is smaller than the the absolute value of the element in the current index  
            l=j; %..if so, l will become the index of that element. If l changes (this if statement gets initiated) then this if statement will continue looking for any other even smaller numbers to the right of this element.  
        end 
    end 
    if l~=k %checks if the above 'if' function has been initiated (if the value of k changed)
        oldAl=A(l); %stores the real value of the element which has the smallest absolute value (aquired from above if statement)
        oldxl=x(l); %does the same as above for the element in the absolute valued array
        A(l)=A(k); %put the kth element into the place of the lth element (smallest element)
        x(l)=x(k); %same as above for the element in the absolute valued array
        A(k)=oldAl; %put the smallest valued element in the kth index of the array A
        x(k)=oldxl; %%same as above for the element in the absolute valued array 
    end % The smallest absolute valued element is changed with the element in the kth index so the values will get sorted from smaller to greater as k goes from 1 to N and the remaining smallest (absolute valued) number gets swapped with the number in the kth index
end %The function sorts the absolute values of the elements in the array A from smallest to greatest.
AoAn=thetaMS*ones(1,N)+104.12*(1-exp(-0.2175*abs(10*log10(Pn))))*randn(1); %Angles of arrival for each cluster
AoDn=thetaBS*ones(1,N)+A;  %Angles of departure for each cluster
%/Environment set

%Fast Fading Channel Setup

for n=1:N
    
    [Hsut AoDm AoAm Fm]=Chan(Pn(n),M,t,T1,S,U,AoDn(n),AoAn(n),thetav,v,kappa,dBS,dMS,BSAS,MSAS); %Channel for non-Polarized antenna design
    Hn{n,1}=Hsut; %impulse response matrix for every cluster
    
    AoAnm{n,1}=AoAm; %Angle of arrival for every subcluster
    AoDnm{n,1}=AoDm; %Angle of departure for every subcluster
    
    [HsutPol AoDmPol AoAmPol FmPol]=ChanPol(Pn(n),M,t,T1,S,U,AoDn(n),AoAn(n),thetav,v,kappa,dBS,dMS,BSAS,MSAS,aBS,bMS,rn); %Channel for Polarized antenna design
    HnPol{n,1}=HsutPol; %impulse response matrix for every cluster (Polarized)
    
    AoAnmPol{n,1}=AoAmPol; %Angle of arrival for every subcluster (Polarized)
    AoDnmPol{n,1}=AoDmPol; %Angle of departure for every subcluster (Polarized)
    
    %n=n+1;
end

% /Channel Set

C=Capacity(N,SNR,Hn,T1,S,U); %Calculate capacity
CPol=Capacity(N,SNR,HnPol,T1,2*S,2*U); %Calculate capacity (Polarized)


for k=1:length(t)
    cap(k)=C(k,1); %channel capacity for every time instant
    capPol(k)=CPol(k,1); %channel capacity for every time instant (Polarized)
    
    res(k)=Hn{1,1}{k,1}(1,1); %impulse response matrix for every time instant 
    resPol(k)=HnPol{1,1}{k,1}(1,1); %impulse response matrix for every time instant (Polarized)
end

%Plot setup
data{1}=t;
data{2}=real(10*log10(res));
data{3}=tn;
data{4}=Pn;
data{5}=T1;
data{6}=real(xcorr(res,'coeff'));
data{7}=thetav;
data{8}=AoAn;
data{9}=AoDn;
data{10}=R;
data{11}=N;
data{12}=d;
data{14}=thetaBS;
data{15}=OmegaBS;
data{16}=cap;
data{17}=v*FC*(0.001);
data{18}=real(10*log10(resPol));
data{19}=real(xcorr(resPol,'coeff'));
data{20}=capPol;
%/Plot params set 
plots(data); %Plotting function

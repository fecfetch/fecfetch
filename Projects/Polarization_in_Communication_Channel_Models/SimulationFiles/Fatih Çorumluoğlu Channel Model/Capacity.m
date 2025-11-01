function [cap]=Capacity(N,SNR,Hn,t,S,U)
r=10^(SNR/10);

for k=1:N
Hsut=Hn{k};
for i=1:t    
    A=Hsut{i,1};
    cap(k,i)=log2(det(eye(U)+(r/S)*A'*A)); %Capacity equation for each time interval
end
end
cap=sum(cap);
cap=cap';
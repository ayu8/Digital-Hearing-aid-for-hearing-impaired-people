clc
clear
close all

disp('input sound')

load handel.mat

fs=Fs;

y = y(:, 1);

sound(y);
pause(10);

figure,plot(y);
title('input');
xlabel('samples');
ylabel('amplitude');

y = awgn(y,40);
noi = y;
figure,plot(y);

xlabel('samples');
ylabel('amplitude');
title('awgn');
disp('playing added noise...');
sound(y);
pause(10)

%'Fp,Fst,Ap,Ast' (passband frequency, stopband frequency, passband ripple, stopband attenuation)

hlpf = fdesign.lowpass('Fp,Fst,Ap,Ast',3.0e3,3.5e3,0.5,50,fs);
% Designing the filter
D = design(hlpf);
freqz(D);%plot frquency response of the filter
x = filter(D,y);

disp('playing denoised sound');
figure,plot(x);
title('denoise');
sound(x,fs);

xlabel('samples');
ylabel('amplitude');
pause(10)

% freq shaper using band pass

T = 1/fs;
len = length(x);
p = log2(len);
p = ceil(p); %rounds each element of p to the nearest integer greater than or equal to that element. 
N = 2^p;
%'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2' (Stopband frequency1, Passband freq1, Passband freq2, stopband freq2, stopband attenuation1, passband ripple, stopband attenuation2))
f1 = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',2000,3000,4000,5000,60,2,60,2*fs);

% Designing the filter
hd = design(f1,'equiripple');
y = filter(hd,x);
freqz(hd);
y = y*100;

disp('playing frequency shaped...');
sound(y,fs);
pause(10);

% amplitude shaper
 
disp('amplitude shaper')
out1=fft(y);
phse=angle(out1);
mag=abs(out1)/N;
[magsig,~]=size(mag);
threshold=1000;
out=zeros(magsig,1);
 
for i=1:magsig/2
 
   if(mag(i)>threshold)
       mag(i)=threshold;mag(magsig-i)=threshold;
 
   end
 
   out(i)=mag(i)*exp(j*phse(i));
   out(magsig-i)=out(i);
 
end
 
outfinal=real(ifft(out))*10000;
disp('playing amplitude shaped...');
sound(outfinal,fs);
pause(10);
 
load handel.mat
figure;
subplot(2,1,1);
spectrogram(noi);
title('Spectrogram of Original Signal');
 
subplot(2,1,2);
spectrogram(outfinal);
title('Spectrogram of Adjusted Signal');
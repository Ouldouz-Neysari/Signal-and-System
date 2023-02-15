tstart = -1;
tend = 1;
fs = 50;
ts = 1/fs;

t = tstart:ts:tend-ts;
N = length(t);
x1 = dirac(t) > 0;

figure();

plot(t,x1);

figure();
subplot(2,1,1)
freq1 = 0:fs/N:(N-1)*fs/N; 
 x1f = fft(x1);
 first_eq = abs(x1f)/max(abs(x1f));
 plot(freq1,first_eq)

subplot(2,1,2)
freq2 = -fs/2:fs/N:fs/2-fs/N;
x2f = fftshift(fft(x1));
second_eq = abs(x2f)/max(abs(x2f));
plot(freq2,second_eq)
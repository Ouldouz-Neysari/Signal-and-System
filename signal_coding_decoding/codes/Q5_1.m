tstart = -19;
tend = 19;
fs = 50;
ts = 1/fs;

t = tstart:ts:tend-ts;
N = length(t);
x5  = 0;
for k = -9:9
    x5 = x5 + rectpuls(t-2*k);
end
figure();

plot(t,x5);

figure();
subplot(2,1,1)
freq1 = 0:fs/N:(N-1)*fs/N; 
 x1f = fft(x5);
 first_eq = abs(x1f)/max(abs(x1f));
 plot(freq1,first_eq)

subplot(2,1,2)
freq2 = -fs/2:fs/N:fs/2-fs/N;
x2f = fftshift(fft(x5));
second_eq = abs(x2f)/max(abs(x2f));
plot(freq2,second_eq)
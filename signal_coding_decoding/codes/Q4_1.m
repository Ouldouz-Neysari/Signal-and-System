tstart = 0;
tend = 1;
fs = 100;
ts = 1/fs;

t = tstart:ts:tend-ts;
N = length(t);
x1 = cos(2*pi*15*t + pi/4);

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

figure();
subplot(2,1,1)
tol = 1e-6;
x2f(abs(x2f) < tol) = 0;
theta = angle(x2f);
plot(freq2,theta/pi)
xlabel 'Frequency (Hz)'
ylabel 'Phase / \pi'
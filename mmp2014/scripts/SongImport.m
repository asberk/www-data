%% This is a basic introductory file to certain aspects of Fourier analysis.
%  Note that many details remain to be filled in and that this should not
%  be considered a "complete" guide. 

% Define a time vector t
t = linspace(0, 1, 101);
% and a signal f = f(t)
f = sin(2*pi*t);

plot(t, f, 'b-');
% define the odd extension
fo = [f f];

tlong = linspace(0, 100, 10100);
flong = sin(2*pi*tlong);

fhat = fft(fo);
fhatlong = fft(flong);

%% Load a song into MATLAB
[wavFile fs] = wavread('songs/elysium_the-young-false-man_live.wav');

wavL = wavFile(:, 1);
wavR = wavFile(:, 2);

t = (0:size(wavL,1)-1)/fs;

plot(t, wavL);

wavhatL = fft(wavL);

semilogx(1./t, abs(wavhatL));

chi_t = (t> 10 & t< 16);

wavClip = wavL(chi_t);
tClip = t(chi_t);
plot(tClip, wavClip);

wavCliphat = fft(wavClip);
semilogx(1./tClip, abs(wavCliphat));


chi_t2 = (t>10 & t<10.01);
wavClip2 = wavL(chi_t2);
tClip2 = t(chi_t2);
plot(tClip2, wavClip2);

semilogx(1./tClip2, abs(fft(wavClip2)));


%% FFT introduction file

%% Clean previous session
clear all; % remove all variables in cache
close all; % close all figure windows
clc; % clear command window

%% Set up time domain
% half-length of sample
L = 1024;
% Sampling frequency
Fs = 2*L;
% time vector
t = linspace(0, 1, 2*L+1);
t = t(1:end-1);
%% Make Dirac Comb
% density parameter (try varying this)
n = 32;
% scaling function for nonzero coefficients
H = exp(-linspace(-2, 2, L/n).^2);
% scaled "Dirac Comb"
dc = zeros(1, 2*L);
dc(n-1:n:end) = [H H];
% Fourier coefficients of Dirac Comb
Mdc = length(dc); % for zero padding
Ndc = pow2(nextpow2(Mdc)); % for zero padding
Fdc = fft(dc,Ndc); % take Fourier transform
fdc = (0:Ndc-1)*(Fs/Ndc); % frequency components

%% Make noisy signal
x = sin(2*pi*400*(t-2)) + ...
    .5*sin(2*pi*100*t) + ...
    1.7*sin(2*pi*20*t) + ...
    2*randn(size(t));
Mx = length(x); % for zero padding
Nx = pow2(nextpow2(Mx)); % for zero padding
Fx = fft(x, Nx); % take Fourier transform
fx = (0:Nx-1)*(Fs/Nx); % frequency components

%% Plots
% Dirac Comb
subplot(2, 1, 1); % first plot in window
plot(t, dc); % plot Dirac Comb as a function of time
title('Dirac comb, $t\in [0,1]$ s', ... 
    'Interpreter', 'latex', 'FontSize', 16); % title of plot
xlabel('time $t$ (s)', 'Interpreter', 'latex'); % x axis label
ylabel('Amplitude', 'Interpreter', 'latex'); % y axis label
subplot(2,1,2); % second plot in window
plot(fdc(1:end/2), abs(Fdc(1:end/2))); % plot PSD as function of frequency
title('$\mathcal{F}$(Dirac Comb), $f \in [0, 2048]$ Hz', ...
    'Interpreter', 'latex', 'FontSize', 16); % title of plot
xlabel('Frequency $f$ (Hz)', 'Interpreter', 'latex'); % x axis label
ylabel('Amplitude', 'Interpreter', 'latex'); % y axis label

figure; % new window

% sine waves
subplot(2, 1, 1); % first plot in window
plot(t, x); % plot noisy signal as function of time
title('noisy sines, $t\in [0,1]$ s', ...
    'Interpreter', 'latex', 'FontSize', 16); % title of plot
xlabel('time $t$ (s)', 'Interpreter', 'latex'); % x axis label
ylabel('Amplitude', 'Interpreter', 'latex'); % y axis label
subplot(2,1,2); % second plot in window 
plot(fx(1:end/2), abs(Fx(1:end/2))); % plot PSD as function of frequency 
title('$\mathcal{F}(x), f \in [0, 2048]$ Hz', ... 
    'Interpreter', 'latex', 'FontSize', 16); % title of plot
xlabel('Frequency $f$ (Hz)', 'Interpreter', 'latex'); % x axis label
ylabel('Amplitude', 'Interpreter', 'latex'); % y axis label 

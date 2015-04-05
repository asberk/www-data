%% Basic Integral transform approximations
clear all; close all; clc;
t = linspace(0, 6, 6001); % seconds
x = [sin(2*pi*2*t(t<3))+sin(2*pi*13*t(t<3)),...
    sin(2*pi*5*(t(t>=3)-3))];
x2 = x + (t>=1.5 & t < 4.5).*sin(2*pi*10*t);

[tau f] = meshgrid([0:.1:5]+.5, 0:15);
Gx = zeros(size(tau));
Gx2 = zeros(size(tau));

for j = 1:size(tau, 1)
    for k = 1:size(tau, 2)
        Gx(j,k) = gabor(t,x,tau(j,k), f(j,k), .7);
        Gx2(j,k) = gabor(t,x2,tau(j,k), f(j,k), .7);
    end
end

subplot(2, 1, 1); plot(t,x);
title('$\sin\,\,(4\pi t)+\sin\,\,(26*\pi t), t<3$ and $\sin\,\,(10\pi t), t\geq 3$', ...
    'Interpreter', 'latex', 'FontSize', 16);
xlabel('time $t$ (s)', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex');
subplot(2, 1, 2); imagesc(tau(1, :), f(:, 1), abs(Gx));
title('Gabor transform, $G_x(\tau,f)$, $\tau \in [1/2, 11/2], f\in[0,15]$~~~~~~~', ...
    'Interpreter', 'latex', 'FontSize', 16);
xlabel('time shift $\tau$ (s)', 'Interpreter', 'latex');
ylabel('Frequency $f$ (Hz)', 'Interpreter', 'latex');

figure;

subplot(2, 1, 1); plot(t,x2);
H= title('Compound sinusoids', 'Interpreter', 'latex', 'FontSize', 16);
xlabel('time $t$ (s)', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex');
subplot(2, 1, 2); imagesc(tau(1, :), f(:, 1), abs(Gx2));
title('Gabor transform, $G_{x_2}(\tau,f)$, $\tau \in [1/2, 11/2], f\in[0,15]$~~~~~~~', ...
    'Interpreter', 'latex', 'FontSize', 16, 'HorizontalAlignment', 'Center');
xlabel('time shift $\tau$ (s)', 'Interpreter', 'latex');
ylabel('Frequency $f$ (Hz)', 'Interpreter', 'latex');

%% This script gives an example of Fourier series computations and summations
% This script file computes the Fourier coefficients for certain continuous
% functions over finite intervals and plots the results in a fun way!

% Suppose our function was f(x) = x on the interval [0, pi]. We can think
% about the *odd extension* of f to the interval [-pi, pi] by defining 
% f2(x) = f(x) for x in [0, pi] and f2(x) = -f(-x) for x in [-pi, 0). 
%
% Quickly note that ?sin^2(nx)dx = pi for every integer n, where the bounds
% of integration are [-pi, pi]. 
% We define the kth Fourier coefficient of f, fhat_k, by 
% fhat_k = pi^(-1/2)?f(x)sin(kx)dx where the bounds of integration are
% [-pi, pi]. 
%
% ?f(x)sin(kx)dx = ?xsin(kx)dx = -(x/k)cos(kx)|_(-pi)^pi + k^(-1)?cos(kx)dx

fancy = 0;

if fancy
    %% The quick way of generating the example
    % clear everything
    clear all; close all; clc;
    
    % define domain and function
    t = linspace(-3*pi, 3*pi, 6001);
    x = mod((t-pi)./pi, 2)-1;
    
    % define vector of wavenumbers (the frequencies are given by omega = 2?n)
    n = (1:100).';
    % exercise: compute the Fourier coefficients for each n to determine that:
    xhat_n = 2.*(-1).^(n+1)./(n.*pi); % Fourier coefficients
    basis = sin(bsxfun(@times, n, t)); % basis vectors (unnormalized)
    FourierTerms = bsxfun(@times, xhat_n, basis); % multiply each Fourier coefficient to its corresponding basis vector
    S_n = cumsum(FourierTerms); % compute cumulative sum to give partial sums for each value in n
    
    for j = 1:max(n)
        plot(t, x, t, S_n(j, :)); % plot each partial sum against the actual function
        pause;                    % What do you notice??
    end
end

if (1-fancy)
    %% The more explicit way of doing the same thing.
    clear all; close all; clc;
    % define our domain and function.
    t = linspace(-3*pi, 3*pi, 6001);
    x = mod((t-pi)./pi, 2)-1;
    
    N = 100; % highest degree of approximation
    xhat_n = zeros(N, 1); % 'empty' vector for Fourier coefficients
    basis = zeros(N, 6001); % matrix for basis vectors
    FourierTerms = zeros(N, 6001); % empty matrix for terms of Fourier series at each point in t
    for n = 1:N % loop over frequencies
        % compute norm of basis vectors (notice that all are equal to ? ---
        % why is this so?)
        basisVectorNorm = integral(@(y) sin(n.*y).*sin(n.*y), -pi, pi, 'AbsTol', 1e-10)
        % compute n-th Fourier coefficient using the integral function
        xhat_n(n) = integral(@(y) y.*sin(n.*y)/basisVectorNorm, -pi, pi, 'AbsTol', 1e-10);        
        % compute n-th (normalized) basis vector
        basis(n, :) = sin(n*t)./basisVectorNorm;
        % compute n-th Fourier term
        FourierTerms(n,:) = xhat_n(n)*basis(n,:);
        % compute n-th Fourier partial sum
        S_n(n,:) = sum(FourierTerms);
        % plot n-th partial sum against our function x
        plot(t, x, t, S_n(n,:));
        pause; % wait for user to press Enter
    end
end

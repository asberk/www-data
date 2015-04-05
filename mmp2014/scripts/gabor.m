%% Gabor transform
% t = time variable
% x = x(t), a signal as a function of time t
% f = frequency
% tau = mean of gaussian mask
function y = gabor(t, x, tau, f, alpha)
intgnd = exp(-pi.*alpha.*(tau - t).^2-f.*t.*2.*pi*1i).*x;
N = length(x);
if (mod(N-1,3) == 0)
    % Simpson's 3/8 Rule
    h = mean(diff(t(1:min(N,1000))));
    w = zeros(size(x)) + 3;
    w([1 end]) = 1;
    w(1+3*(1:((N-4)/3))) = 2;
    y = 3*h/8*w*intgnd.'; 
    % The 3 in the expression above comes from the fact that the 
    % subintervals (a,b) are further subdivided into three subintervals 
    % each, so that 3*h = b-a, and each (a,b) is represented by four data 
    % points. 
elseif (mod(N-1, 2) == 0)
    % Simpson's Rule
    h = mean(diff(t(1:min(N,1000))));
    w = zeros(size(x)) + 2;
    w(2:2:end) = 4;
    w([1 end]) = 1;
    y = 2*h/6*w*intgnd.';
else 
    display('fix something...');
    y = [];
end
end
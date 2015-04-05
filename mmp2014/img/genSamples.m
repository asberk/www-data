%% Generates good sample images for use with FFT2
a = -5; b = 5; N = 1024;
x = linspace(-5, 5, 1024);
y = x;
[X Y] = meshgrid(x,y);

tol = (b-a)/N;
R = 3;

% Change this numnber to change which case Matlab evaluates!
egNumber = 5; % Pick any n for 0 ? n ? 5

switch egNumber % evaluate example number equal to egNumber
    case 0
        Z0 = zeros(size(X));
        Z0(X.^2 + Y.^2 < R) = 1; % 1-Ball
        FZ0 = fft2(Z0);
        FZ0n = fftshift(FZ0./max(abs(FZ0(:))));
        imagesc(x, y, log(1 + abs(FZ0n))); colormap gray;
    case 1
        Z1 = zeros(size(X));
        Z1((X.^2 + Y.^2 > R*(1-tol)) & (X.^2 + Y.^2 < R*(1+tol))) = 1; % 1-sphere
        FZ1 = fft2(Z1);
        FZ1n = fftshift(FZ1./max(abs(FZ1(:))));
        imagesc(x, y, log(1 + abs(FZ1n))); colormap gray;
    case {2, 3}
        Z2 = zeros(size(X));
        Z2((-5:5)+512,:) = 100; % thick line in real space
        FZ2 = fft2(Z2);
        FZ2n = fftshift(FZ2./max(abs(FZ2(:))));
        if egNumber == 3
            v = FZ2(:, 513);
            FZ3 = FZ2;
            FZ3(:, (-50:50)+512) = repmat(v, 1, 101); % thick line in Fourier space
            Z3 = ifft2(FZ3);
            imagesc(x, y, abs(Z3)); colormap gray;
        else
            imagesc(x, y, log(1+abs(FZ2n))); colormap gray;
        end
    case 4
        R2 = 2;
        Z4 = zeros(size(X));
        Z4(X < R2 & X > -R2 & Y < R2 & Y > -R2) = 1; % box
        FZ4 = fft(Z4);
        FZ4n = fftshift(FZ4./max(abs(FZ4(:))));
        imagesc(x, y, log(1 + abs(FZ4n))); colormap gray;
    case 5
        fur = imread('fur.jpg');
        fur1 = fur(:, :, 1);
        Fur = fft2(fur1);
        Furn = log(1+ abs(fftshift(Fur)));
        imagesc(Furn);
end
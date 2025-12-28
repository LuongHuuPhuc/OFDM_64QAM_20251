% Vai tro
% - OFDM thu: 
%   + Bo CP 
%   + FFT 
%   + Tinh dap ung kenh H(k)s
function [rxGrid, Hk] = ofdm_demodulate(rxTime, h, Nfft, Ncp, Nused)

    symLen = Nfft + Ncp;
    Nsym = length(rxTime) / symLen;

    rxMat = reshape(rxTime, symLen, Nsym);

    % Bỏ CP
    rxNoCP = rxMat(Ncp+1:end,:);

    % FFT
    Y = fft(rxNoCP, Nfft, 1);

    % Đáp ứng kênh H(k) (giống nhau cho mọi symbol do quasi-static)
    Hk_full = fft([h; zeros(Nfft-length(h),1)], Nfft);
    Hk = repmat(Hk_full(1:Nused), 1, Nsym);

    rxGrid = Y(1:Nused,:);
end

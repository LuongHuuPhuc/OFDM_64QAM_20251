% Vai tro
%   - Thực hiện OFDM thu 
%       + Bỏ Cycle Prefix  
%       + FFT 
%       + Tinh dap ung kenh H(k)
% Input: 
%   - rxTime: Chuỗi tín hiệu sau kênh + Nhiễu trong miền thời gian
%   - h: Đáp ưng xung kênh miền thời gian dùng để tính H(k)
%   - Nfft, Ncp, Nused: Giống bên phát, đảm bảo đồng bộ phát-thu
% Output: 
%   - rxGrid: Ma trận tín hiệu thu miền tần số kích thước (Nused x Nsym) 
%   - Hk: Đáp ứng kênh theo từng Subcarrier kích thước (Nused x Nsym)
%         Do kênh quasi-static -> Giống nhau cho mọi symbol
function [rxGrid, Hk] = ofdm_demodulate(rxTime, h, Nfft, Ncp, Nused)
    symLen = Nfft + Ncp;
    Nsym = length(rxTime) / symLen;
    rxMat = reshape(rxTime, symLen, Nsym);

    % Bỏ CP
    rxNoCP = rxMat(Ncp+1:end,:);

    % FFT
    Y = fft(rxNoCP, Nfft, 1) / sqrt(Nfft); % Normalize FFT (doi xung IFFT * sqrt(Nfft))

    % Đáp ứng kênh H(k) (giống nhau cho mọi symbol do quasi-static)
    Hk_full = fft([h(:); zeros(Nfft-length(h),1)], Nfft);
    half = Nused / 2;

    % Lay dung cac bin tuong ung voi anh xa ben phat
    Hk_used = [Hk_full(2:half+1); Hk_full(Nfft-half+1:Nfft)];
    Hk = repmat(Hk_used, 1, Nsym);
    rxGrid = [Y(2:half+1,:); Y(Nfft-half+1:Nfft,:)];
end

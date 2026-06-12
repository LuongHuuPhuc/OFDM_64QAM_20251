% Vai tro
%   - Thực hiện cân bằng LMMSE miền tần số trên từng Carrier 
%   - Nằm ngay sau khi thu OFDM và FFT xong
%   - Ước lượng symbol phát X(k)
%
% Phai thuc hien can bang sau khi thu OFDM va FFT xong vi can khoi phuc lai
% tin hieu goc bi meo mo do kenh truyen (bu tru suy hao bien do va pha do
% hien tuong fading cua kenh Rayleigh) 
% -> Do thi chom sao bi meo. 
% -> Dong thoi giam loai bo nhieu va han che khuech dai nhieu (nhu ZF) -> BER/SER tot hon
%
% Input: 
%   - Y: tín hiệu thu miền tần số Y(k) = H(k)*X(k) + W(k)
%       với H(k) là kênh Rayleigh, W(k) là nhiễu Gauss
%   - H: Đáp ứng kênh theo subcarrier (đã biết chính xác perfect CSI)
%   - N0: Phương sai nhiễu miền tần số (tỷ số giữa phương sai tạp âm và
%   phương sai tín hiệu)
% Output: 
%   - xHat: Ước lượng Symbol sau cân bằng

function xHat = lmmse_equalize(Y, H, N0)
    % LMMSE từng subcarrier
    % conj(H): dung de bu pha kenh H (triet pha de bo lech pha)
    % abs(H).^2: Cong suat kenh
    % +N0: De mau so khong tien ve 0 khi kenh rat yeu -> Khong khuech dai
    % qua muc cong suat nhieu
    xHat = (conj(H) ./ (abs(H).^2 + N0)) .* Y;
end

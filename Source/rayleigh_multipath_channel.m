% Vai trò:
%   - Mô phỏng kênh truyền Rayleigh đa đường (quasi-static)
%   - Áp dụng tích chập tuyến tính lên toàn bộ chuỗi OFDM
%   - Lọc trên tín hiệu chuỗi (stream) đúng với truyền thực tế
% Input: 
%   - txTime: Chuỗi tín hiệu OFDM miền thời gian (đã bao gồm CP)
%   - Lch: Số tap/số bậc của kênh truyền Rayleigh (số đường truyền đa đường)
% Output: 
%   - rxTime: Chuỗi tín hiệu sau kênh, chưa có nhiễu, đã bị suy hao + trễ pha do kênh
%   - h: Vector đáp ứng xung kênh Rayleigh (Lch x 1), dùng để tính: H(k)=FFT{h}

function [rxTime, h] = rayleigh_multipath_channel(txTime, Lch)
    % Sinh tap Rayleigh (chuẩn hoá năng lượng kênh)
    h = (randn(Lch, 1) + 1i*randn(Lch, 1)) / sqrt(2 * Lch);

    % Lọc toàn bộ chuỗi thời gian (tích chập tuyến tính)
    rx_full = filter(h, 1, txTime);

    % Cắt lại đúng độ dài như txTime (bỏ phần đuôi dư do kênh)
    rxTime = rx_full(1:length(txTime));
end

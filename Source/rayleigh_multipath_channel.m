% Vai trò:
% - Mô phỏng kênh Rayleigh đa đường (quasi-static)
% - Lọc trên tín hiệu chuỗi (stream) đúng với truyền thực tế
function [rxTime, h] = rayleigh_multipath_channel(txTime, Lch)
    % Sinh tap Rayleigh (chuẩn hoá năng lượng kênh)
    h = (randn(Lch,1) + 1i*randn(Lch,1)) / sqrt(2*Lch);

    % Lọc toàn bộ chuỗi thời gian (tích chập tuyến tính)
    rx_full = filter(h, 1, txTime);

    % Cắt lại đúng độ dài như txTime (bỏ phần đuôi dư do kênh)
    rxTime = rx_full(1:length(txTime));
end

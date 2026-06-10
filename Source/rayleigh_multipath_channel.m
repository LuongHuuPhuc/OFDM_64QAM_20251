% Vai trò:
%   - Mô phỏng kênh truyền Rayleigh đa đường (quasi-static) nhiễu thành thị
%   - Khác với kênh truyền Gauss, nhiễu chỉ cộng ngẫu nhiên, kênh truyên
%   Rayleigh vừa có nhiễu, vừa có hiện tượng pha đinh (tín hiệu lên xuống
%   thất thường) do hiện tượng đa đường (phản xạ, nhiễu xạ, ISI).
%   - Áp dụng bộ lọc FIR (tích chập tuyến tính) lên toàn bộ chuỗi OFDM
%   - Lọc trên tín hiệu chuỗi (stream) đúng với truyền thực tế
% Input: 
%   - txTime: Chuỗi tín hiệu OFDM miền thời gian (đã bao gồm CP) gửi đi
%   - Lch: Số tap/số bậc của kênh truyền Rayleigh (số đường truyền đa đường)
% Output: 
%   - rxTime: Chuỗi tín hiệu sau kênh, chưa có nhiễu, đã bị suy hao + trễ pha do kênh
%   - h: Vector đáp ứng xung kênh Rayleigh (Lch x 1), dùng để tính: H(k)=FFT{h}

function [rxTime, h] = rayleigh_multipath_channel(txTime, Lch)
    % Sinh dap ung xung cua kenh voi so tap Lch Rayleigh
    % -> Bieu dien kenh Gauss dang so phuc (randn(Lch, 1) + 1i*randn(Lch, 1)
    % khi do, bien do cua kenh truyen (do lon cua so phuc) se tuan theo phan bo Rayleigh
    % -> Chia sqrt(2 * Lch) de chuan hoa de tong nang luong kenh xap xi 1
    h = (randn(Lch, 1) + 1i*randn(Lch, 1)) / sqrt(2 * Lch);

    % Lọc toàn bộ chuỗi thời gian (tích chập tuyến tính) - chính là bộ lọc FIR
    % Tin hieu phat di nhan voi nhiều hệ số Rayleigh và trễ nhiều mẫu khác
    % nhau, tạo ra ISI và fading 
    rx_full = filter(h, 1, txTime);

    % Cắt lại đúng độ dài như txTime (bỏ phần đuôi dư do kênh)
    rxTime = rx_full(1:length(txTime));
end

% Vai tro
%   - Thực hiện cân bằng LMMSE miền tần số trên từng Carrier 
%   - Ước lượng symbol phát X(k)
% Input: 
%   - Y: tín hiệu thu miền tần số Y(k)=H(k)X(k)+W(k)
%   - H: Đáp ứng kênh theo subcarrier (đã biết chính xác perfect CSI)
%   - N0: Phương sai nhiễu miền tần số
% Output: 
%   - xHat: Ước lượng Symbol sau cân bằng

function xHat = lmmse_equalize(Y, H, N0)
    % LMMSE từng subcarrier
    xHat = (conj(H) ./ (abs(H).^2 + N0)) .* Y;
end

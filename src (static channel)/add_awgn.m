% Vai tro
%   - Mo phong nhieu trang (tuan theo phan bo Gauss phuc) 
% Input
%   - x: Chuỗi tín hiệu (thường là sau kênh), miền thời gian 
%   - N0: Phương sai nhiễu

function [y] = add_awgn(x, N0)
    % N0: Cong suat nhieu tren moi mau phuc
    noise = sqrt(N0 / 2) * (randn(size(x)) + 1i * randn(size(x)));
    y = x + noise;
end
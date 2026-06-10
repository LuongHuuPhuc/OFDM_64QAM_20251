% Vai tro
%   - Mo phong nhieu trang/nhieu Gauss (tuan theo phan bo Gauss phuc) 
%   - Day co the hieu la kenh truyen Gauss, lam cho tin hieu bi nhieu theo
%   kieu cong ngau nhien (theo phan bo chuan), bien do tin hieu thu duoc
%   khong thay doi theo thoi gian
%   - Dung de mo hinh hoa kenh truyen thuc te, co tieng on, anh huong moi truong...
% Input
%   - x: Chuỗi tín hiệu (thường là sau kênh) trong miền thời gian 
%   - N0: Phương sai nhiễu

function [y] = add_awgn(x, N0)
    % N0: Cong suat nhieu tren moi mau phuc
    noise = sqrt(N0 / 2) * (randn(size(x)) + 1i * randn(size(x)));
    y = x + noise;
end
% Vai tro:
%   - Chuyen tin hieu tu mien tan so sang mien thoi gian
%   - IFFT (Inverse Fast Fourier Transform) 
%   - Them Cyclic Prefix (Tien to tuan hoan)
% Y nghia: 
%   - Day chinh la OFDM phat
% Input: 
%   - txGrid: Ma tran phuc (Nused x Nsym), du lieu mien tan so, 
%             moi phan tu la 1 symbol QAM
%   - Nfft: So diem (sample) cho phép biến đổi fft, xac dinh so subcarrier OFDM
%           xac dinh do phan giai tan so va thoi gian tinh toan
%   - Ncp: Do dai Cyclic Prefix, dam bao N_cp >= L_ch - 1
%   - Nused: So Subcarrier thuc su mang du lieu
% Output: 
%   - txTime: Chuoi tin hieu OFDM mien thoi gian san sang dua qua kenh truyen

function txTime = ofdm_modulate(txGrid, Nfft, Ncp, Nused)

    % txGrid: dữ liệu miền tần số [subcarrier x symbol]
    Nsym = size(txGrid, 2);

    % Ánh xạ dữ liệu vào FFT bin
    X = zeros(Nfft, Nsym);
    X(1:Nused,:) = txGrid;

    % IFFT
    x = ifft(X, Nfft, 1);

    % Thêm Cyclic Prefix
    x_cp = [x(end-Ncp+1:end,:); x];

    % Chuyển sang chuỗi thời gian
    txTime = x_cp(:).';
end

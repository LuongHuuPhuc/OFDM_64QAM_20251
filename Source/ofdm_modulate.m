% Vai tro:
% - Chuyen tin hieu tu mien tan so sang mien thoi gian
% - IFFT + them Cyclic Prefix
% Y nghia: 
% - Day chinh la OFDM phat
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

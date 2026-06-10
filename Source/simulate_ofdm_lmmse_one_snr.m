% Vai tro: 
%   - Mo phong toan bo he thong cho 1 gia tri SNR duy nhat
%   - La "xuong song" cua he thong mo phong
% Y nghia: 
%   Tach ra rieng de:
%   - De lap Monte Carlo va lay trung binh phan phoi cua ket qua
%   - De thay Equalizer (ZF ↔ LMMSE ↔ MMSE)
% Input: 
%   - SNRdB (scalar): Ti so tin hieu tren nhieu (dB) de xac dinh cong suat
%   nhieu AWGN 
%   - cfg (struct cau hinh): Chua toan bo tham so he thong OFDM 
% Output: 
%   - ber: Ti le loi bit (BER = So bit sai / Tong so bit) [0,1]
%   - ser: Ti le loi ky ty (SER = So symbol sai / Tong so symbol) [0,1]

function [ber, ser] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg)
    % Moi symbol mang k bit (64-QAM) (k = 6)
    % Tuc la cu 6bit se tao 1 symbol phuc s = I + jQ
    k = log2(cfg.M);

    %% ===== SINH BIT NGẪU NHIÊN =====
    % 1 OFDM co 128 subcarrier -> 128 x 6 = 768 bits
    % 1 frame co 200 OFDM -> 200 x 128 x 6 = 153600 bits
    nBits = cfg.Nused * cfg.Nsym * k;
    txBits = randi([0 1], nBits, 1);

    %% ===== ĐIỀU CHẾ 64-QAM =====
    % UnitAveragePower = true -> Chuan hoa cong suat trung binh cua symbol = 1
    txSym = qammod(txBits, cfg.M, 'InputType','bit','UnitAveragePower',true);
    txGrid = reshape(txSym, cfg.Nused, cfg.Nsym);

    %% ===== OFDM PHÁT =====
    txTime = ofdm_tx(txGrid, cfg.Nfft, cfg.Ncp, cfg.Nused);

    %% ===== CHO QUA KÊNH RAYLEIGH ĐA ĐƯỜNG (QUASI-STATIC, STREAM) =====
    % rxTime_noNoise la tin hieu sau kenh Rayleigh, chua co nhieu
    [rxTime_noNoise, h] = rayleigh_multipath_channel(txTime, cfg.Lch);

    %% ===== TÍNH NHIỄU AWGN THEO CÔNG SUẤT THỰC TẾ MIỀN THỜI GIAN =====
    % Sau khi cho qua kenh truyen Rayleigh thi moi chi mo phong suy hao
    % bien do, lech pha, da duong nhung thuc te con co nhieu tu moi truong
    % nen can them nhieu AGWN -> y = hx + n (h la kenh Rayleigh, n la nhieu Gauss)

    SNR_linear = 10^(SNRdB/10); % Chuyen SNR sang dB tuyen tinh
    sigPow_time = mean(abs(rxTime_noNoise).^2);  % Cong suat tin hieu thuc te trong mien thoi gian
    noise_var_time = sigPow_time / SNR_linear;   % phương sai nhiễu AGWN (do manh-yeu cua nhieu) trong mien thoi gian

    % Phai chu dong tao White Noise (tuan theo phan bo Gauss)
    rxTime = add_awgn(rxTime_noNoise, noise_var_time);

    %% ===== OFDM THU =====
    % (tính Hk từ h)
    [rxGrid, Hk] = ofdm_rx(rxTime, h, cfg.Nfft, cfg.Ncp, cfg.Nused);

    %% ===== PHUONG SAI NHIEU MIEN TAN SO =====
    % Sau normalize FFT/IFFT doi xung, phuong sai nhieu tan so = phuong sai thoi gian 
    noise_var_freq = noise_var_time;

    %% ===== CÂN BẰNG LMMSE =====
    % LMMSE được dùng ngay sau thu tín hiệu và FFT xong, trước khi giải điều chế 
    switch cfg.eqType
        case "LMMSE"
            xHat = lmmse_equalize(rxGrid, Hk, noise_var_freq);
        case "ZF"
            xHat = rxGrid ./ Hk;
        case "NONE"
            % Gia thiet may thu khong co bo can bang kenh, nen dua truc
            % tiep tin hieu thu duoc sau FFT vao bo giai dieu che
            xHat = rxGrid;   % không cân bằng
    end

    %% ===== GIẢI ĐIỀU CHẾ =====
    rxBits = qamdemod(xHat(:), cfg.M, 'OutputType','bit','UnitAveragePower',true);
    rxSym = qamdemod(xHat(:), cfg.M, 'OutputType', 'integer', 'UnitAveragePower', true);
    txSym_int = qamdemod(txSym, cfg.M, 'OutputType','integer','UnitAveragePower',true);

    % Tinh BER
    ber = mean(rxBits ~= txBits);

    % Tinh SER (So sanh truc tiep symbol thu voi symbol phat)
    ser = mean(rxSym ~= txSym_int);
end

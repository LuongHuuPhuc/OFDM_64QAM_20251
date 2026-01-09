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

    k = log2(cfg.M);

    %% ===== SINH BIT =====
    nBits = cfg.Nused * cfg.Nsym * k;
    txBits = randi([0 1], nBits, 1);

    %% ===== ĐIỀU CHẾ 64-QAM =====
    txSym = qammod(txBits, cfg.M, 'InputType','bit','UnitAveragePower',true);
    txGrid = reshape(txSym, cfg.Nused, cfg.Nsym);

    %% ===== OFDM PHÁT =====
    txTime = ofdm_modulate(txGrid, cfg.Nfft, cfg.Ncp, cfg.Nused);

    %% ===== KÊNH RAYLEIGH ĐA ĐƯỜNG (QUASI-STATIC, STREAM) =====
    [rxTime_noNoise, h] = rayleigh_multipath_channel(txTime, cfg.Lch);

    %% ===== TÍNH NHIỄU AWGN THEO CÔNG SUẤT THỰC TẾ MIỀN THỜI GIAN =====
    SNR_linear = 10^(SNRdB/10);
    sigPow_time = mean(abs(rxTime_noNoise).^2);           % công suất tín hiệu time
    noise_var_time = sigPow_time / SNR_linear;            % phương sai nhiễu time

    rxTime = add_awgn(rxTime_noNoise, noise_var_time);

    %% ===== OFDM THU =====
    % (tính Hk từ h)
    [rxGrid, Hk] = ofdm_demodulate(rxTime, h, cfg.Nfft, cfg.Ncp, cfg.Nused);

    %% ===== N0 DÙNG CHO LMMSE Ở MIỀN TẦN SỐ =====
    noise_var_freq = noise_var_time * cfg.Nfft;

    %% ===== CÂN BẰNG LMMSE =====
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

    ber = mean(rxBits ~= txBits);

    rxSym_hat = qammod(rxBits, cfg.M, 'InputType','bit','UnitAveragePower',true);
    ser = mean(rxSym_hat ~= txSym);
end

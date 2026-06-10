% Vai tro:
% - La entry point cua chuong trinh
% - Quet SNR tu thap den cao 
% - Chay Monte Carlo giam SAI SO THONG KE de uoc luong BER/SER
% - Ve do thi BER/SER 

function main_ofdm_lmmse_64qam_plot()
    clc; close all;

    %% ================= CAU HINH MO PHONG =================
    cfg.Nfft = 256;      % Số điểm FFT (số subcarrier) (Kích thước lưới tần số)
    cfg.Ncp = 64;        % Độ dài Cyclic Prefix (Gan vao truoc OFDM symbol de triet tieu nhieu)
    cfg.Nsym = 200;      % Số OFDM symbol gui di trong 1 frame (tuong duong 1 lan lap)
    cfg.M = 64;          % Bậc điều chế 64-QAM
    cfg.Lch = 8;         % Số tap của kênh Rayleigh đa đường 
    cfg.SNRdB_vec = 0:2:30;    % Vector các giá trị SNR khảo sát (Dải nhiễu)
    cfg.Nframe = 100;          % Số lan chay Monte Carlo de tim xac suat loi (tuong duong so frame)
    cfg.Nused = 128;       % Số sóng mang con chứa dữ liệu (Nused = Nfft/2 là để chừa cho Guard Band)
    cfg.eqType = "LMMSE";  % "LMMSE" | "ZF" | "NONE"

    % 1 OFDM symbol (Nsym) co 128 subcarrier, moi subcarrier mang 1 symbol 64-QAM 
    % -> 1 OFDM symbol = 128 QAM symbols
    % 1 frame co 200 OFDM symbol, moi OFDM chua 128 subcarrier
    % -> 25600 subcarrier/frame, moi subcarrier xuat hien 200 lan -> 25600 QAM symbols

    % ===== LUU KET QUA =====
    ber_lmmse = zeros(size(cfg.SNRdB_vec));
    ser_lmmse = zeros(size(cfg.SNRdB_vec));
    ber_none = zeros(size(cfg.SNRdB_vec));
    ser_none = zeros(size(cfg.SNRdB_vec));
    
    %% ================= VONG LAP THEO TUNG SNR =================

    % ----------------Dùng LMMSE ---------------
    cfg.eqType = "LMMSE";  % "LMMSE" | "ZF" | "NONE"

    for i = 1:length(cfg.SNRdB_vec)
        SNRdB = cfg.SNRdB_vec(i);
        ber_sum = 0;
        ser_sum = 0;

        % Chay Monte Carlo (lap di lap lai) de uoc luong xac suat BER/SER
        for k = 1:cfg.Nframe
            [ber1, ser1] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg);
            ber_sum = ber_sum + ber1;
            ser_sum = ser_sum + ser1;
        end

        % Chia lai cho so frame de tinh theo Monte Carlo
        ber_lmmse(i) = ber_sum / cfg.Nframe;
        ser_lmmse(i) = ser_sum / cfg.Nframe;
    end

     % ---------------- KHONG DUNG LMMSE CÂN BẰNG ---------------
    cfg.eqType = "NONE";  % "LMMSE" | "ZF" | "NONE"

    for i = 1:length(cfg.SNRdB_vec)
        SNRdB = cfg.SNRdB_vec(i);
        ber_sum = 0;
        ser_sum = 0;
    
        % Chay Monte Carlo (lap di lap lai) de uoc luong xac suat BER/SER
        for k = 1:cfg.Nframe
            [ber1, ser1] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg);
            ber_sum = ber_sum + ber1;
            ser_sum = ser_sum + ser1;
        end

        % Chia lai cho so frame de tinh theo Monte Carlo
        ber_none(i) = ber_sum / cfg.Nframe;
        ser_none(i) = ser_sum / cfg.Nframe;
    end

    %% ----------------- VE BIEU DO SO SANH LMMSE & NONE ----------------
    figure(Name="BER & SER comparison");
    grid on;

    % BER 
    semilogy(cfg.SNRdB_vec, ber_none, 'o--', 'LineWidth', 1.8); hold on;
    semilogy(cfg.SNRdB_vec, ber_lmmse, 'o-',  'LineWidth', 1.8);
    
    % SER
    semilogy(cfg.SNRdB_vec, ser_none, 's--',  'LineWidth', 1.8);
    semilogy(cfg.SNRdB_vec, ser_lmmse, 's-',  'LineWidth', 1.8);
    grid on;

    ylim([1e-3 1]);
    xlabel('SNR (dB)');
    ylabel('Error Rate (BER/SER)');
    title('So sánh BER & SER: Không cân bằng vs LMMSE (OFDM 64-QAM)');
    legend('BER - No Equalizer', ...
           'BER - LMMSE', ...
           'SER - No Equalizer', ...
           'SER - LMMSE', ...
           'Location','southwest');
end                                             

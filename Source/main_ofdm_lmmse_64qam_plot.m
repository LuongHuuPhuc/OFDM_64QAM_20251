% Vai tro:
% - La entry point cua chuong trinh
% - Quet SNR tu thap den cao 
% - Chay Monte Carlo de giam sai so thong ke 
% - Ve do thi BER/SER 

function main_ofdm_lmmse_64qam_plot()
    clc; close all;

    %% ================= CẤU HÌNH MÔ PHỎNG =================
    cfg.Nfft      = 256;      % Số điểm FFT (số subcarrier) (Dvi: mau)
    cfg.Ncp       = 64;       % Độ dài Cyclic Prefix (Dvi: mau)
    cfg.Nsym      = 200;      % Số symbol OFDM trong 1 frame
    cfg.M         = 64;       % Bậc điều chế 64-QAM
    cfg.Lch       = 8;        % Số tap của kênh Rayleigh đa đường 
    cfg.SNRdB_vec = 0:2:30;   % Vector các giá trị SNR khảo sát (Dải nhiễu)
    cfg.Nframe    = 20;       % Số frame (lần lặp) Monte Carlo
    cfg.Nused     = cfg.Nfft; % Số subcarrier mang dữ liệu
    cfg.eqType    = "LMMSE";  % "LMMSE" | "ZF" | "NONE"

    % ===== LUU KET QUA =====
    ber_lmmse = zeros(size(cfg.SNRdB_vec));
    ser_lmmse = zeros(size(cfg.SNRdB_vec));
    ber_none = zeros(size(cfg.SNRdB_vec));
    ser_none = zeros(size(cfg.SNRdB_vec));
    
    %% ===== TEST NHANH =====
    cfg.eqType = "LMMSE";
    [ber_test, ser_test] = simulate_ofdm_lmmse_one_snr(30, cfg);
    fprintf("BER (LMMSE, 30dB): %.3e\n", ber_test);
    fprintf("SER (LMMSE, 30dB): %.3e\n", ser_test);
           
    %% ================= VÒNG LẶP THEO SNR =================

    % ----------------Dùng LMMSE ---------------
    cfg.eqType = "LMMSE";  % "LMMSE" | "ZF" | "NONE"

    for i = 1:length(cfg.SNRdB_vec)
        SNRdB = cfg.SNRdB_vec(i);
        ber_sum = 0;
        ser_sum = 0;

        for k = 1:cfg.Nframe
            [ber1, ser1] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg);
            ber_sum = ber_sum + ber1;
            ser_sum = ser_sum + ser1;
        end

        ber_lmmse(i) = ber_sum / cfg.Nframe;
        ser_lmmse(i) = ser_sum / cfg.Nframe;
    end

     % ----------------KHONG DUNG LMMSE CÂN BẰNG ---------------
    cfg.eqType = "NONE";  % "LMMSE" | "ZF" | "NONE"

    for i = 1:length(cfg.SNRdB_vec)
        SNRdB = cfg.SNRdB_vec(i);
        ber_sum = 0;
        ser_sum = 0;
    
        for k = 1:cfg.Nframe
            [ber1, ser1] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg);
            ber_sum = ber_sum + ber1;
            ser_sum = ser_sum + ser1;
        end
    
        ber_none(i) = ber_sum / cfg.Nframe;
        ser_none(i) = ser_sum / cfg.Nframe;
    end

    %% ================= VẼ BIỂU ĐỒ =================

    %% ----------------- FIGURE 1: LMMSE (BER & SER) ----------------
    figure(Name="LMMSE Only");
    grid on;

    semilogy(cfg.SNRdB_vec, ber_lmmse, 'o-', 'LineWidth', 1.8);
    hold on; 
    semilogy(cfg.SNRdB_vec, ser_lmmse, 's-', 'LineWidth', 1.8);
    
    ylim([1e-3 1]);
    xlabel('SNR (dB)');
    ylabel('Tỉ lệ lỗi');
    title('OFDM + Rayleigh + AWGN + LMMSE (64-QAM)');
    legend('BER','SER', 'Location','southwest');

    %% ----------------- FIGURE 2: SO SANH LMMSE & NONE (BER & SER) ----------------
    figure(Name="BER & SER comparison");
    grid on;

    % BER 
    semilogy(cfg.SNRdB_vec, ber_none, 'o--', 'LineWidth', 1.8);
    hold on;
    semilogy(cfg.SNRdB_vec, ber_lmmse, 'o-',  'LineWidth', 1.8);
    hold on;
    
    % SER
    semilogy(cfg.SNRdB_vec, ser_none, 's--',  'LineWidth', 1.8);
    hold on;
    semilogy(cfg.SNRdB_vec, ser_lmmse, 's-',  'LineWidth', 1.8);

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

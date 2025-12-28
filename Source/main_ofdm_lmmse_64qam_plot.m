% Vai tro:
% - La entry point cua chuong trinh
% - Quet SNR tu thap den cao 
% - Chay Monte Carlo de giam sai so thong ke 
% - Ve do thi BER/SER 
function main_ofdm_lmmse_64qam_plot()
    clc; close all;

    % ================= CẤU HÌNH MÔ PHỎNG =================
    cfg.Nfft      = 256;      % Số điểm FFT (số subcarrier)
    cfg.Ncp       = 64;       % Độ dài Cyclic Prefix
    cfg.Nsym      = 200;      % Số symbol OFDM
    cfg.M         = 64;       % Điều chế 64-QAM
    cfg.Lch       = 8;        % Số tap của kênh Rayleigh
    cfg.SNRdB_vec = 0:2:30;   % Dải SNR khảo sát
    cfg.Nframe    = 20;       % Số frame Monte Carlo
    cfg.Nused     = cfg.Nfft;% Số subcarrier sử dụng

    ber = zeros(size(cfg.SNRdB_vec));
    ser = zeros(size(cfg.SNRdB_vec));
    
    [ber_test, ser_test] = simulate_ofdm_lmmse_one_snr(30, cfg);
    fprintf("BER: %d\n", ber_test);
    fprintf("SER: %d\n", ser_test);
           
    % ================= VÒNG LẶP THEO SNR =================
    for i = 1:length(cfg.SNRdB_vec)
        SNRdB = cfg.SNRdB_vec(i);
        ber_sum = 0;
        ser_sum = 0;

        for k = 1:cfg.Nframe
            [ber1, ser1] = simulate_ofdm_lmmse_one_snr(SNRdB, cfg);
            ber_sum = ber_sum + ber1;
            ser_sum = ser_sum + ser1;
        end

        ber(i) = ber_sum / cfg.Nframe;
        ser(i) = ser_sum / cfg.Nframe;
    end

    % ================= VẼ BIỂU ĐỒ =================
    figure(Name="Simualtion");
    semilogy(cfg.SNRdB_vec, ber, 'o-', 'LineWidth', 1.8);
    hold on;
    semilogy(cfg.SNRdB_vec, ser, 's-', 'LineWidth', 1.8);
    grid on;
    xlabel('SNR (dB)');
    ylabel('Tỉ lệ lỗi');
    title('OFDM + Rayleigh + AWGN + LMMSE (64-QAM)');
    legend('BER','SER');
end

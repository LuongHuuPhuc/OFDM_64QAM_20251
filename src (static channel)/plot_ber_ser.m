% Vai tro:
%   - Ve do thi BER vs SNR va SER vs SNR tren hai figure rieng biet
%   - Ham do thi doc lap, co the goi lai tu bat ky script mo phong nao
% Input:
%   - SNRdB_vec : Vector cac gia tri SNR (dB), vi du 0:2:30
%   - BER       : Mang ket qua BER tuong ung voi SNRdB_vec
%   - SER       : Mang ket qua SER tuong ung voi SNRdB_vec
% Output:
%   - Khong co output; ham chi ve do thi

function plot_ber_ser(SNRdB_vec, BER, SER)

    %% ===== FIGURE 1: BER vs SNR =====
    figure('Name', 'BER vs SNR - OFDM 64-QAM LMMSE');

    semilogy(SNRdB_vec, BER, 'o-', ...
             'LineWidth', 1.8, ...
             'MarkerSize', 6, ...
             'Color', [0.00 0.45 0.74]);   % xanh duong

    grid on;
    xlabel('SNR (dB)', 'FontSize', 12);
    ylabel('BER', 'FontSize', 12);
    title('BER vs SNR — OFDM 64-QAM, Rayleigh + AWGN + LMMSE', ...
          'FontSize', 13);
    legend('BER (LMMSE)', 'Location', 'southwest');
    ylim([1e-4 1]);
    xlim([SNRdB_vec(1) SNRdB_vec(end)]);
    set(gca, 'FontSize', 11);

    %% ===== FIGURE 2: SER vs SNR =====
    figure('Name', 'SER vs SNR - OFDM 64-QAM LMMSE');

    semilogy(SNRdB_vec, SER, 's-', ...
             'LineWidth', 1.8, ...
             'MarkerSize', 6, ...
             'Color', [0.85 0.33 0.10]);   % cam do

    grid on;
    xlabel('SNR (dB)', 'FontSize', 12);
    ylabel('SER', 'FontSize', 12);
    title('SER vs SNR — OFDM 64-QAM, Rayleigh + AWGN + LMMSE', ...
          'FontSize', 13);
    legend('SER (LMMSE)', 'Location', 'southwest');
    ylim([1e-4 1]);
    xlim([SNRdB_vec(1) SNRdB_vec(end)]);
    set(gca, 'FontSize', 11);

end

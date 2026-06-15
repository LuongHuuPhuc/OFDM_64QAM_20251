% Vai tro:
%   - Ve chom sao (constellation) 64-QAM truoc va sau can bang LMMSE
%   - Hien thi tren 1 figure voi 2 subplot (1x2) de so sanh truc quan
%   - Su dung plot() thay cho scatter() de dam bao tuong thich GNU Octave
% Input:
%   - Y     : Tin hieu mien tan so TRUOC can bang [Nused x Nsym] (phuc)
%             (txGrid bi lam can boi Rayleigh + nhieu AWGN)
%   - X_hat : Uoc luong symbol SAU can bang LMMSE [Nused x Nsym] (phuc)
%             (du kien hoi tu ve 64 cum diem ly tuong)
% Dieu kien goi: Nen truyen du lieu tai SNR = 20 dB
% Output:
%   - Khong co output; ham chi ve do thi

function plot_constellation(Y, X_hat)

    figure('Name', 'Constellation: Before vs After LMMSE EQ (SNR=20dB)');

    %% ===== SUBPLOT 1: TRUOC CAN BANG =====
    subplot(1, 2, 1);

    plot(real(Y(:)), imag(Y(:)), '.', ...
         'MarkerSize', 4, ...
         'Color', [0.20 0.55 0.85]);   % xanh nhat — the hien su lan xuat cua Rayleigh

    grid on;
    axis([-2 2 -2 2]);
    xlabel('In-phase (I)', 'FontSize', 11);
    ylabel('Quadrature (Q)', 'FontSize', 11);
    title('Before EQ (Y),  SNR = 20 dB', 'FontSize', 12);
    set(gca, 'FontSize', 10);

    %% ===== SUBPLOT 2: SAU CAN BANG LMMSE =====
    subplot(1, 2, 2);

    plot(real(X_hat(:)), imag(X_hat(:)), '.', ...
         'MarkerSize', 4, ...
         'Color', [0.85 0.33 0.10]);   % cam do — the hien su hoi tu ro rang

    grid on;
    axis([-2 2 -2 2]);
    xlabel('In-phase (I)', 'FontSize', 11);
    ylabel('Quadrature (Q)', 'FontSize', 11);
    title('After LMMSE (X\_hat)', 'FontSize', 12);
    set(gca, 'FontSize', 10);

    %% ===== TIEU DE CHUNG =====
    % Compatible voi ca MATLAB lan GNU Octave
    suptitle_text = 'Constellation Diagram — OFDM 64-QAM, Rayleigh Channel, SNR = 20 dB';
    % suptitle() co san trong MATLAB; trong Octave dung annotation thay the
    if exist('suptitle', 'file') || exist('suptitle', 'builtin')
        suptitle(suptitle_text);
    else
        % Fallback cho GNU Octave: dat tieu de tren cua so
        set(gcf, 'Name', suptitle_text);
    end

end

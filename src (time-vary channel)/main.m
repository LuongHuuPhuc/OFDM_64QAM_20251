% main.m
% Main Simulation Loop for OFDM System over Time-Varying Rayleigh Multipath Channel
% Features: Jakes' Model Fading, Comb-type Pilots, LS/LMMSE Channel Estimation,
%           ZF/LMMSE Equalization, Soft-Decision Max-Log Demapping.
% Compatible strictly with GNU Octave.

clc; clear; close all;

%% ================= SYSTEM PARAMETERS =================
N_fft   = 64;                   % FFT Size
N_used  = 52;                   % Used Subcarriers
N_cp    = 16;                   % Cyclic Prefix Length
N_sym   = 100;                  % Number of OFDM symbols per frame
N_frame = 20;                   % Number of Monte Carlo iterations (frames)
SNR_vec = 0:2:30;               % SNR range in dB
mod_schemes = [4, 16, 64];      % QPSK, 16-QAM, 64-QAM
mod_names = {'QPSK', '16-QAM', '64-QAM'};

% --- Pilot Configuration (Comb-type) ---
pilot_spacing = 4;              % Distance between pilots
pilot_idx = 1:pilot_spacing:N_used; 
data_idx = setdiff(1:N_used, pilot_idx);
N_pilots = length(pilot_idx);
N_data = length(data_idx);

% --- Channel Parameters (Time-Varying) ---
L_ch = 8;                       % Number of multipath taps
fd = 50;                        % Maximum Doppler shift (Hz) (Mobility)
Ts = 1/(N_fft * 15e3);          % Sampling time (assuming 15kHz subcarrier spacing)

%% ================= RESULT INITIALIZATION =================
num_snr = length(SNR_vec);
num_mod = length(mod_schemes);

% Arrays to store BER and SER
ber_zf    = zeros(num_mod, num_snr);
ser_zf    = zeros(num_mod, num_snr);
ber_lmmse = zeros(num_mod, num_snr);
ser_lmmse = zeros(num_mod, num_snr);

%% ================= MONTE CARLO SIMULATION LOOP =================
for m_idx = 1:num_mod
    M = mod_schemes(m_idx);
    k_bits = log2(M);
    
    fprintf('======================================================\n');
    fprintf('Starting Simulation for %s\n', mod_names{m_idx});
    fprintf('======================================================\n');
    
    for snr_idx = 1:num_snr
        SNR_dB = SNR_vec(snr_idx);
        SNR_linear = 10^(SNR_dB / 10);
        
        err_bits_zf = 0; err_bits_lmmse = 0;
        err_syms_zf = 0; err_syms_lmmse = 0;
        total_bits = 0; total_syms = 0;
        
        for frame = 1:N_frame
            %% 1. TRANSMITTER
            % 1.1 Data Generation
            num_data_bits = N_data * N_sym * k_bits;
            tx_bits = randi([0 1], num_data_bits, 1);
            
            % 1.2 Modulation
            tx_data_syms = qam_modulator(tx_bits, M);
            tx_data_syms = reshape(tx_data_syms, N_data, N_sym);
            
            % 1.3 Pilot Insertion (Comb-type)
            tx_pilots = exp(1j * 2 * pi * rand(N_pilots, N_sym)); % Random PSK pilots
            
            tx_grid = zeros(N_used, N_sym);
            tx_grid(data_idx, :) = tx_data_syms;
            tx_grid(pilot_idx, :) = tx_pilots;
            
            % 1.4 OFDM Modulation (IFFT + CP)
            tx_signal = ofdm_modulator(tx_grid, N_fft, N_cp);
            
            %% 2. CHANNEL (TIME-VARYING + AWGN)
            % 2.1 Jakes' Multipath Fading Model
            h_time = jakes_fading_channel(L_ch, fd, Ts, length(tx_signal));
            
            % 2.2 Convolution with Time-Varying Channel
            rx_faded = apply_time_varying_channel(tx_signal, h_time);
            
            % 2.3 Add AWGN
            rx_signal = add_awgn(rx_faded, SNR_dB);
            
            %% 3. RECEIVER
            % 3.1 OFDM Demodulation (Remove CP + FFT)
            rx_grid = ofdm_demodulator(rx_signal, N_fft, N_used, N_cp, N_sym);
            
            % Extract received pilots and data
            rx_pilots = rx_grid(pilot_idx, :);
            rx_data = rx_grid(data_idx, :);
            
            % 3.2 Channel Estimation (Comb-type)
            H_ls_pilots = ls_channel_estimation(rx_pilots, tx_pilots);
            H_lmmse_pilots = lmmse_channel_estimation(rx_pilots, tx_pilots, SNR_linear, h_time, pilot_idx, N_fft);
            
            % Interpolation to get channel across all data subcarriers
            H_ls_data = interpolate_channel(H_ls_pilots, pilot_idx, data_idx);
            H_lmmse_data = interpolate_channel(H_lmmse_pilots, pilot_idx, data_idx);
            
            % 3.3 Equalization
            rx_eq_zf = zf_equalizer(rx_data, H_ls_data);
            rx_eq_lmmse = lmmse_equalizer(rx_data, H_lmmse_data, SNR_linear);
            
            % 3.4 Soft-Decision Demapping (LLR via Max-Log Approximation)
            llr_zf = soft_demapper_maxlog(rx_eq_zf, H_ls_data, M, SNR_linear);
            llr_lmmse = soft_demapper_maxlog(rx_eq_lmmse, H_lmmse_data, M, SNR_linear);
            
            % 3.5 Bit Recovery (Thresholding LLRs)
            % For soft demapping, LLR < 0 implies bit 1, LLR >= 0 implies bit 0 
            % (depending on specific LLR definition, we will formalize this in the helper function)
            rx_bits_zf = double(llr_zf < 0); 
            rx_bits_lmmse = double(llr_lmmse < 0);
            
            % 3.6 Symbol Recovery for SER calculation
            rx_syms_zf = qam_modulator(rx_bits_zf, M);
            rx_syms_lmmse = qam_modulator(rx_bits_lmmse, M);
            
            %% 4. ERROR CALCULATION
            % Calculate Bit Errors
            err_bits_zf = err_bits_zf + sum(tx_bits ~= rx_bits_zf);
            err_bits_lmmse = err_bits_lmmse + sum(tx_bits ~= rx_bits_lmmse);
            
            % Calculate Symbol Errors
            tx_data_syms_flat = tx_data_syms(:);
            err_syms_zf = err_syms_zf + sum(tx_data_syms_flat ~= rx_syms_zf);
            err_syms_lmmse = err_syms_lmmse + sum(tx_data_syms_flat ~= rx_syms_lmmse);
            
            total_bits = total_bits + num_data_bits;
            total_syms = total_syms + (N_data * N_sym);
        end
        
        % Average BER and SER for current SNR
        ber_zf(m_idx, snr_idx) = err_bits_zf / total_bits;
        ser_zf(m_idx, snr_idx) = err_syms_zf / total_syms;
        ber_lmmse(m_idx, snr_idx) = err_bits_lmmse / total_bits;
        ser_lmmse(m_idx, snr_idx) = err_syms_lmmse / total_syms;
        
        fprintf('SNR = %2d dB | BER (ZF): %.4e | BER (LMMSE): %.4e\n', SNR_dB, ber_zf(m_idx, snr_idx), ber_lmmse(m_idx, snr_idx));
    end
end

%% ================= PLOTTING RESULTS =================
plot_ber_ser(SNR_vec, ber_zf, ber_lmmse, ser_zf, ser_lmmse, mod_names);

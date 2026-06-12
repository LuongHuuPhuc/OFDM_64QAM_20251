clc;
clear;
close all;

%% =========================
% THAM SO
%% =========================

N = 200;           % So symbol

sps = 100;         % Mau / symbol

Fs = 10000;        % Tan so lay mau

fc = 200;          % Song mang RF

SNR_dB = 8;        % Muc nhieu

%% =========================
% SINH DU LIEU BPSK
%% =========================

bits = randi([0 1],1,N);

symbols = 2*bits - 1;

%% =========================
% UPSAMPLING
%% =========================

tx_baseband = repelem(symbols,sps);

%% =========================
% PULSE SHAPING
%% =========================

pulse = ones(1,sps);

tx_baseband = conv(tx_baseband,pulse,'same');

tx_baseband = tx_baseband/max(abs(tx_baseband));

%% =========================
% SONG MANG RF
%% =========================

t = (0:length(tx_baseband)-1)/Fs;

carrier = cos(2*pi*fc*t);

%% =========================
% TIN HIEU PHAT
%% =========================

tx_rf = tx_baseband .* carrier;

%% =========================
% KENH RAYLEIGH
%% =========================

h_raw = (randn(size(tx_rf)) + 1j*randn(size(tx_rf)))/sqrt(2);

L = 1000;     % cang lon fading cang cham

h = filter(ones(1,L)/L,1,h_raw);

h = abs(h);

h = h/max(h);

%% =========================
% TRUYEN QUA KENH
%% =========================

rx_rf = h .* tx_rf;

%% =========================
% THEM AWGN
%% =========================

signal_power = mean(rx_rf.^2);

noise_power = signal_power/(10^(SNR_dB/10));

noise = sqrt(noise_power)*randn(size(rx_rf));

rx_rf = rx_rf + noise;

%% =========================
% CHI VE 1 DOAN NGAN
%% =========================

start_idx = 5000;

num_samples = 3000;

idx = start_idx:start_idx+num_samples-1;

%% =========================
% PLOT
%% =========================

figure('Color','w');

subplot(4,1,1)
plot(t(idx),tx_rf(idx),'LineWidth',1)
grid on
title('Tin hieu RF phat')
ylabel('Amplitude')

subplot(4,1,2)
plot(t(idx),rx_rf(idx),'LineWidth',1)
grid on
title('Tin hieu RF sau Rayleigh + AWGN')
ylabel('Amplitude')

subplot(4,1,3)
plot(t(idx),h(idx),'LineWidth',1.5)
grid on
title('Bien do kenh Rayleigh')
ylabel('|h(t)|')

subplot(4,1,4)
plot(t(idx),abs(rx_rf(idx)),'LineWidth',1)
grid on
title('Bao tin hieu thu')
xlabel('Time (s)')
ylabel('|r(t)|')
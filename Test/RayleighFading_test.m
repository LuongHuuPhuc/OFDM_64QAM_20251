clc;
clear;
close all;

%% Tham so 
N = 1000;                  % Số symbol
bits = randi([0 1],1,N);   % Bit ngẫu nhiên
Fs = 1000; % Tan so lay mau
fc = 500;  % Tan so song mang

% Dieu che BPSK
tx = 2*bits - 1; % Symbol: 0->-1, 1->+1

%% Tao kenh Rayleigh
h_raw = (randn(1,N) + 1j*randn(1,N))/sqrt(2); % Nhieu Gauss phuc

% Lam muot de mo phong fading thay doi cham 
L = 30; % Do dai cua so trung binh

h = filter(ones(1,L)/L,1,h_raw);

% Tín hiệu sau kênh
rx = h .* tx;

%% Noi suy Waveform (Upsampling) 
sps = 20;                       % Samples/Symbol
tx_wave = repelem(tx,sps);      % Mỗi symbol lặp lại 20 lần
rx_wave = repelem(rx,sps);      % Nội suy tín hiệu thu

%% Pulse shaping (DAC) - Baseband analog signal
% Lam mem bien do dang xung de giong tin hieu vat ly 
% Neu muon phat qua RF thi nhan them song mang 
b = ones(1,sps)/sps;            % Bộ lọc trung bình trượt
tx_wave = filter(b,1,tx_wave);  % Làm mượt tín hiệu phát
rx_wave = filter(b,1,rx_wave);  % Làm mượt tín hiệu thu

% Truc thoi gian 
t = 0:length(tx_wave)-1;        % Trục mẫu
time = t/Fs;                    % Truc thoi gian thuc

%% Song mang
carrier = cos(2*pi*fc*time);

% Tin hieu RF phat 
tx_rf = tx_wave .* carrier;

% Tin hieu RF thu 
rx_rf = real(rx_wave) .* carrier;

%% Vẽ so sánh

% Chi lay 1 doan ngan de quan sat
start_idx = 2000;     % Mau bat dau
num_samples = 400;    % So mau can hien thi

idx = start_idx : start_idx + num_samples - 1;

subplot(4,1,1)
plot(time(idx),tx_wave(idx),'LineWidth',1.2)
grid on
title('Baseband BPSK')
ylabel('Amplitude')

subplot(4,1,2)
plot(time(idx),tx_rf(idx),'LineWidth',1.2)
grid on
title('Tin hieu RF phat')
ylabel('Amplitude')

subplot(4,1,3)
plot(time(idx),rx_rf(idx),'LineWidth',1.2)
grid on
title('Tin hieu RF sau kenh Rayleigh')
ylabel('Amplitude')

subplot(4,1,4)
plot(abs(h),'LineWidth',1.5)
grid on
title('Bien do kenh Rayleigh |H(k)|')
xlabel('Symbol Index')
ylabel('|H(k)|')
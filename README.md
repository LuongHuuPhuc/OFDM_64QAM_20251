## Mô phỏng hệ thống OFDM sử dụng bộ lọc LMMSE trên kênh truyền Rayleigh nhiễu trắng, điều chế 64 QAM. Đánh giá chất lượng của BER/SER
Chuỗi xử lý tín hiệu: 

```java
Bit → QAM → OFDM (IFFT + CP)
    → Kênh Rayleigh đa đường
    → Nhiễu AWGN
    → FFT
    → LMMSE Equalizer
    → Giải điều chế QAM
    → Tính BER / SER
```

## Chức năng của từng file

|File| Chức năng|
|----|----------|
|`main_ofdm_lmmse_64qam_plotplot.m`|Chương trình chính: chạy mô phỏng theo SNR, vẽ BER/SER|
|`simulate_ofdm_lmmse_one_snr.m`|Mô phỏng toàn bộ hệ thống OFDM cho 1 giá trị SNR|
|`ofdm_modulate.m`| OFDM phát: ánh xạ subcarrier → IFFT → thêm CP|
|`rayleigh_multipath_channel.m` |Mô phỏng kênh Rayleigh đa đường trong miền thời gian|
|`add_awgn.m`| Thêm nhiễu trắng AWGN|
|`ofdm_demodulate.m`|OFDM thu: bỏ CP → FFT → lấy đáp ứng kênh|
|`lmmse_equalize.m`| Bộ cân bằng LMMSE miền tần số|

## Luồng dữ liệu tổng thể 

```powershell
Random Bits
   ↓
64-QAM Modulation
   ↓
OFDM Modulator (IFFT + CP)
   ↓
Rayleigh Multipath Channel
   ↓
AWGN
   ↓
Remove CP + FFT
   ↓
LMMSE Equalizer
   ↓
QAM Demodulation
   ↓
BER / SER

```

![Block Diagram](/Images/BlockDiagram.png)

## Kết quả mô phỏng 

![Sim Result](/Images/SimResult.png)

#### Note: Nhiễu trắng (AWGN - Additive White Gaussian Noise) 


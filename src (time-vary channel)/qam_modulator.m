function syms = qam_modulator(bits, M)
    % QAM_MODULATOR Custom, highly optimized Gray-coded QAM Modulator
    %   syms = qam_modulator(bits, M)
    %   Inputs:
    %     bits - Column vector of binary values (0 and 1)
    %     M    - Modulation order (4 for QPSK, 16 for 16-QAM, 64 for 64-QAM)
    %   Outputs:
    %     syms - Modulated complex symbols with unit average power (column vector)
    
    k_bits = log2(M);
    
    % Ensure bits is a column vector
    bits = bits(:);
    num_bits = length(bits);
    
    if mod(num_bits, k_bits) ~= 0
        error('Length of bits must be a multiple of log2(M).');
    end
    
    N_syms = num_bits / k_bits;
    
    % Reshape bits into blocks (each row represents bits for one symbol)
    bits_reshaped = reshape(bits, k_bits, N_syms).';
    
    if M == 4
        % QPSK (M=4)
        I_bits = bits_reshaped(:, 1);
        Q_bits = bits_reshaped(:, 2);
        
        % 0 -> +1, 1 -> -1
        I = 1 - 2 * I_bits;
        Q = 1 - 2 * Q_bits;
        
        syms = I + 1j * Q;
        
        % Normalize power (E_avg = 2)
        syms = syms / sqrt(2);
        
    elseif M == 16
        % 16-QAM (M=16)
        I_bits = bits_reshaped(:, 1:2);
        Q_bits = bits_reshaped(:, 3:4);
        
        % Gray-coded PAM mapping table for 16-QAM
        % Binary: 00(0)->-3, 01(1)->-1, 10(2)->3, 11(3)->1
        pam_map = [-3, -1, 3, 1]; 
        
        % Convert binary to decimal index (1-based)
        I_idx = I_bits(:, 1) * 2 + I_bits(:, 2) + 1;
        Q_idx = Q_bits(:, 1) * 2 + Q_bits(:, 2) + 1;
        
        % Map and ensure column vectors
        I = pam_map(I_idx); I = I(:);
        Q = pam_map(Q_idx); Q = Q(:);
        
        syms = I + 1j * Q;
        
        % Normalize power (E_avg = 10)
        syms = syms / sqrt(10);
        
    elseif M == 64
        % 64-QAM (M=64)
        I_bits = bits_reshaped(:, 1:3);
        Q_bits = bits_reshaped(:, 4:6);
        
        % Gray-coded PAM mapping table for 64-QAM
        % Binary to Index mapping:
        % 000(0)->-7, 001(1)->-5, 010(2)->-1, 011(3)->-3, 
        % 100(4)->+7, 101(5)->+5, 110(6)->+1, 111(7)->+3
        pam_map = [-7, -5, -1, -3, 7, 5, 1, 3];
        
        % Convert binary to decimal index (1-based)
        I_idx = I_bits(:, 1) * 4 + I_bits(:, 2) * 2 + I_bits(:, 3) + 1;
        Q_idx = Q_bits(:, 1) * 4 + Q_bits(:, 2) * 2 + Q_bits(:, 3) + 1;
        
        % Map and ensure column vectors
        I = pam_map(I_idx); I = I(:);
        Q = pam_map(Q_idx); Q = Q(:);
        
        syms = I + 1j * Q;
        
        % Normalize power (E_avg = 42)
        syms = syms / sqrt(42);
        
    else
        error('Unsupported modulation order M. Only 4, 16, and 64 are supported.');
    end
end

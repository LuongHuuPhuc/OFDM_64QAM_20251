function rxBits = custom_qamdemod(y, M)
    % CUSTOM_QAMDEMOD Lightweight QAM demodulator compatible with Octave
    % y: received complex symbols
    % M: modulation order (must be square, e.g., 16, 64, 256)
    
    k = log2(M);
    sqrtM = sqrt(M);
    
    % Unit average power normalization factor
    avg_power = 2 * (M - 1) / 3;
    scale_factor = sqrt(avg_power);
    
    % Undo power scaling
    sym = y(:) * scale_factor;
    
    % Extract I and Q parts
    pam_I = real(sym);
    pam_Q = -imag(sym); % Undo the inverted Q axis
    
    % Demodulate PAM (Hard Decision)
    % Limit to range
    pam_I = max(min(pam_I, sqrtM - 1), -(sqrtM - 1));
    pam_Q = max(min(pam_Q, sqrtM - 1), -(sqrtM - 1));
    
    % Map back to decimal index
    dec_I = round((pam_I + sqrtM - 1) / 2);
    dec_Q = round((pam_Q + sqrtM - 1) / 2);
    
    % Limit decimal values to [0, sqrtM-1] just in case
    dec_I = max(min(dec_I, sqrtM - 1), 0);
    dec_Q = max(min(dec_Q, sqrtM - 1), 0);
    
    % Decimal to Binary
    k_half = k / 2;
    bin_I = zeros(length(dec_I), k_half);
    bin_Q = zeros(length(dec_Q), k_half);
    
    for i = 1:k_half
        bin_I(:, k_half - i + 1) = mod(floor(dec_I ./ (2^(i-1))), 2);
        bin_Q(:, k_half - i + 1) = mod(floor(dec_Q ./ (2^(i-1))), 2);
    end
    
    % Binary to Gray
    bits_I = zeros(size(bin_I));
    bits_Q = zeros(size(bin_Q));
    
    bits_I(:, 1) = bin_I(:, 1);
    bits_Q(:, 1) = bin_Q(:, 1);
    
    for i = 2:k_half
        bits_I(:, i) = xor(bin_I(:, i-1), bin_I(:, i));
        bits_Q(:, i) = xor(bin_Q(:, i-1), bin_Q(:, i));
    end
    
    % Combine I and Q bits
    rxBits_matrix = [bits_I, bits_Q];
    
    % Reshape back to column vector
    rxBits = reshape(rxBits_matrix.', [], 1);
end

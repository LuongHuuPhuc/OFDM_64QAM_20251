function y = custom_qammod(x, M)
    % CUSTOM_QAMMOD Lightweight QAM modulator compatible with Octave
    % x: input bit vector (column)
    % M: modulation order (must be square, e.g., 16, 64, 256)
    
    k = log2(M);
    if mod(k, 2) ~= 0
        error('Only square QAM (M=16, 64, 256...) is supported.');
    end
    
    % Reshape x into rows of k bits
    x_matrix = reshape(x(:), k, []).';
    
    k_half = k / 2;
    bits_I = x_matrix(:, 1:k_half);
    bits_Q = x_matrix(:, k_half+1:end);
    
    % Convert Gray bits to Binary
    bin_I = zeros(size(bits_I));
    bin_Q = zeros(size(bits_Q));
    
    bin_I(:, 1) = bits_I(:, 1);
    bin_Q(:, 1) = bits_Q(:, 1);
    
    for i = 2:k_half
        bin_I(:, i) = xor(bin_I(:, i-1), bits_I(:, i));
        bin_Q(:, i) = xor(bin_Q(:, i-1), bits_Q(:, i));
    end
    
    % Convert Binary to Decimal
    weights = 2.^((k_half-1):-1:0).';
    dec_I = bin_I * weights;
    dec_Q = bin_Q * weights;
    
    % Map to PAM levels
    sqrtM = sqrt(M);
    pam_I = 2 * dec_I - (sqrtM - 1);
    % MATLAB's qammod usually has Q axis inverted for standard mapping
    pam_Q = -(2 * dec_Q - (sqrtM - 1)); 
    
    % Complex symbol
    sym = pam_I + 1i * pam_Q;
    
    % Unit average power normalization
    avg_power = 2 * (M - 1) / 3;
    y = sym / sqrt(avg_power);
    
    % Return column vector
    y = y(:);
end

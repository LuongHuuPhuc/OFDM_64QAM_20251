% Vai tro
% - Can bang LMMSE mien tan so 
function xHat = lmmse_equalize(Y, H, N0)
    % LMMSE từng subcarrier
    xHat = (conj(H) ./ (abs(H).^2 + N0)) .* Y;
end

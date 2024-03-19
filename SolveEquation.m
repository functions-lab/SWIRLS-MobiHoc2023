function [x] = SolveEquation(M, y)
    [sizeY, sizeX] = size(M);

    M_1 = [M y];
%     M_2 = mod(rref(M_1), 2);
    M_2 = M_1;
    i = 1;
    j = 1;
    jb = zeros(1,0);
    while i <= sizeY && j <= sizeX+1
        % Find value and index of largest element in the remainder of column j.
        [p, k] = max(abs(M_2(i:sizeY,j)));
        k = k+i-1;
        if p <= 1e-10
            % The column is negligible, zero it out.
            M_2(i:sizeY,j) = 0;
            j = j + 1;
        else
            % Remember column index
            jb = [jb j]; %#ok<AGROW>
            % Swap i-th and k-th rows.
            M_2([i k],j:end) = M_2([k i],j:end);
            % Divide the pivot row by the pivot element.
            M_2(i,j:end) = M_2(i,j:end)./M_2(i,j);
            % Subtract multiples of the pivot row from all the other rows.
            for k = [1:i-1 i+1:sizeY]
                M_2(k,j:end) = xor(M_2(k,j:end), M_2(k,j).*M_2(i,j:end));
            end
            i = i + 1;
            j = j + 1;
        end
    end

    M_3 = M_2;
    x = NaN(sizeX, 1);
    for rowIdx = sizeY: -1: 1
        for colIdx = sizeX: -1 : 1
            if M_3(rowIdx, colIdx) ~= 0
                if isnan(x(colIdx))
                    x(colIdx) = M_3(rowIdx, end);
                end
                M_3(rowIdx, end) = xor(M_3(rowIdx, end), x(colIdx));
            end
        end
    end
    x(isnan(x)) = 0;
    
    if sum(mod(y - M*x, 2)) > 0
        disp("Warning!");
    end
end
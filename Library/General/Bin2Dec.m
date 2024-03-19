function [dec] = Bin2Dec(bin)
    binLen = length(bin);
    dec = 0;
    for binIdx = 1: binLen
        if bin(binIdx) == 0
            dec = dec * 2;
        else
            dec = dec * 2 + 1;
        end
    end
end
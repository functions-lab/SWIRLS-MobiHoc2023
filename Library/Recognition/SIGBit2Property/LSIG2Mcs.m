function [mcs] = LSIG2Mcs(LSIGBit)
    mcsBit = LSIGBit(1: 3)';
    if all(mcsBit == [1 1 0])
        mcs = 0;
    elseif all(mcsBit == [1 1 1])
        mcs = 1;
    elseif all(mcsBit == [0 1 0])
        mcs = 2;
    elseif all(mcsBit == [0 1 1])
        mcs = 3;
    elseif all(mcsBit == [1 0 0])
        mcs = 4;
    elseif all(mcsBit == [1 0 1])
        mcs = 5;
    elseif all(mcsBit == [0 0 0])
        mcs = 6;
    elseif all(mcsBit == [0 0 1])
        mcs = 7;
    else
        disp("Warning: Modulation and Coding Scheme NOT Found!");
    end
end
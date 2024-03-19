function [time] = LSIG2Time(LSIGBit)
    timeBit = LSIGBit(6: 17);
    timeDec = Bin2Dec(flip(timeBit));
    time = (4*floor((timeDec+3)/3)+20) * 1e-6;
end
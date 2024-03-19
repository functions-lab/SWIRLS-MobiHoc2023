function [psdu] = LSIG2Psdu(LSIGBit)
    timeBit = LSIGBit(6: 17);
    psdu = Bin2Dec(flip(timeBit));
end
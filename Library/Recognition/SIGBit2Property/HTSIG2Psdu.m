function [psdu] = HTSIG2Psdu(HTSIGBit)
    timeBit = HTSIGBit(9: 24);
    psdu = Bin2Dec(flip(timeBit));
end
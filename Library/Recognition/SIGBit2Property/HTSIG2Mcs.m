function [mcs] = HTSIG2Mcs(HTSIGBit)
    mcsBit = HTSIGBit(1: 5);
    mcs =Bin2Dec(flip(mcsBit));
end
function [speed] = HTSIG2Speed(HTSIGBit)
    mcs = HTSIG2Mcs(HTSIGBit);
    ant = floor(mcs/8) + 1;
    [modu, code] = SplitMCS(mcs, "HT");
    speedAnt = ant;
    speedModu = log2(modu);
    speedCode = (code - 1) / code;
    speedMCS = speedAnt * speedModu * speedCode;

    bandBit = HTSIGBit(8);
    if bandBit == 0
        speedBand = 1;
    else
        speedBand = 2;
    end

    speed = 13 * speedMCS * speedBand;
end
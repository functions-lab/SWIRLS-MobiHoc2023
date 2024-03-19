function [band] = HTSIG2Band(HTSIGBit)
    bandBit = HTSIGBit(8);
    if bandBit == 0
        band = "CBW20";
    else
        band = "CBW40";
    end
end
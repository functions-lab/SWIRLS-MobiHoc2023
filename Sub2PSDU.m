function [psdu, mcs, modu, code, ant, band, bit] = Sub2PSDU(input, subList)
    mapMatAll = load("HTSIG_Mat.mat").mapMat;
    mapVecAll = load("HTSIG_Mat.mat").mapVec;
    
    bitList = 1: 22;
    sub = real(input) + imag(input);
    sub(sub==-1) = 0;
    mapMat = mapMatAll(subList, bitList);
    mapVec = mapVecAll(subList);
    
    bit = SolveEquation(mapMat, xor(mapVec, sub'));
    
    psduBit = bit(7: 22);
    psdu = Bin2Dec(flip(psduBit));
    mcsBit = bit(1: 5);
    mcs = Bin2Dec(flip(mcsBit));
    [modu, code] = SplitMCS(mcs, "HT");
    ant = floor(mcs/8) + 1;
    if bit(6)==0
        band = "CBW20";
    else
        band = "CBW40";
    end
end
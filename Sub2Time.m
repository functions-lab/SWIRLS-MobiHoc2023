function [time, bit] = Sub2Time(input, subList)
    mapMatAll = load("LSIG_Mat.mat").mapMat;
    mapVecAll = load("LSIG_Mat.mat").mapVec;

    bitList = 1: 12;
    sub = input;
    sub(sub==-1) = 0;
    mapMat = mapMatAll(subList, bitList);
    mapVec = mapVecAll(subList);

    bit = SolveEquation(mapMat, xor(mapVec, sub'));

    timeDec = Bin2Dec(flip(bit));
    time = (4*floor((timeDec+3)/3)+20) * 1e-6;
end
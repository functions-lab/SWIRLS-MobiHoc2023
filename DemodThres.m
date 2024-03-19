function [Y_test] = DemodThres(X_train, Y_train, X_test)
%     trainNum = size(X_train, 1);
    testNum = size(X_test, 1);
    Y_train_2 = unique(Y_train);

    Y_test = zeros(testNum, 1);
    for testIdx = 1: testNum
        [~, idx] = min(abs(X_test(testIdx)-Y_train_2));
        Y_test(testIdx) = Y_train_2(idx);
    end
end